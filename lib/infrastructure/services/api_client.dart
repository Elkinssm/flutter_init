import 'dart:async';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/config/errors/app_error_reporter.dart';
import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/config/security/tls_pinning.dart';
import 'package:coach_app/infrastructure/services/api_logger.dart';
import 'package:coach_app/infrastructure/services/session_service.dart';
import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/providers/session_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Cliente HTTP con baseUrl de [Environment], headers Accept/Content-Type,
/// interceptor que añade Bearer token desde sesión; en 401 intenta refresh token y reintenta la petición.
final apiClientProvider = Provider<Dio>((ref) {
  final session = ref.read(sessionServiceProvider);
  Completer<_RefreshResult>? refreshCompleter;
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  TlsPinning.applyToDio(dio);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await session.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        final opts = error.requestOptions;
        if (opts.path.contains('/refresh-token')) {
          await _clearAndGoLogin(ref, session);
          return handler.next(error);
        }

        final wasRetried = opts.extra['__retried_after_refresh'] == true;
        if (wasRetried) {
          await _clearAndGoLogin(ref, session);
          return handler.next(error);
        }

        final currentToken = await session.getToken();
        if (currentToken == null || currentToken.isEmpty) {
          await _clearAndGoLogin(ref, session);
          return handler.next(error);
        }

        try {
          if (refreshCompleter == null || refreshCompleter!.isCompleted) {
            refreshCompleter = Completer<_RefreshResult>();
            () async {
              try {
                final refreshDio = Dio(
                  BaseOptions(baseUrl: Environment.apiUrl),
                );
                TlsPinning.applyToDio(refreshDio);
                refreshDio.interceptors.add(
                  ApiLoggerInterceptor(enabled: Environment.enableHttpLogs),
                );
                final r = await refreshDio.post<Map<String, dynamic>>(
                  '/refresh-token',
                  options: Options(
                    headers: {
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $currentToken',
                    },
                  ),
                );
                final data = r.data;
                final newToken = _extractToken(data);
                final expiresAt = _extractExpiresAt(data);
                if (newToken != null && newToken.isNotEmpty) {
                  await session.updateToken(newToken, expiresAt: expiresAt);
                  refreshCompleter?.complete(
                    _RefreshResult(token: newToken, forceLogout: false),
                  );
                  return;
                }
                // Refresh respondió pero sin token utilizable.
                refreshCompleter?.complete(
                  const _RefreshResult(forceLogout: true),
                );
              } on DioException catch (e, st) {
                AppErrorReporter.report(
                  e,
                  st,
                  context: 'api_client.refresh_token',
                );
                final code = e.response?.statusCode ?? 0;
                refreshCompleter?.complete(
                  _RefreshResult(forceLogout: code == 401 || code == 403),
                );
              } catch (e, st) {
                AppErrorReporter.report(
                  e,
                  st,
                  context: 'api_client.refresh_token',
                );
                refreshCompleter?.complete(
                  const _RefreshResult(forceLogout: false),
                );
              }
            }();
          }

          final refreshResult = await refreshCompleter!.future;
          if ((refreshResult.token ?? '').isNotEmpty) {
            opts.headers['Authorization'] = 'Bearer ${refreshResult.token}';
            opts.extra['__retried_after_refresh'] = true;
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
          if (refreshResult.forceLogout) {
            await _clearAndGoLogin(ref, session);
          }
          return handler.next(error);
        } catch (e, st) {
          AppErrorReporter.report(
            e,
            st,
            context: 'api_client.refresh_retry_flow',
          );
          return handler.next(error);
        }
      },
    ),
  );
  dio.interceptors.add(
    ApiLoggerInterceptor(enabled: Environment.enableHttpLogs),
  );
  return dio;
});

Future<void> _clearAndGoLogin(Ref ref, SessionService session) async {
  await session.clearSession();
  clearUserRole();
  ref.read(currentUserRoleProvider.notifier).state = null;
  final ctx = rootNavKey.currentContext;
  if (ctx != null && ctx.mounted) {
    GoRouter.of(ctx).go('/login_screen');
  }
}

class _RefreshResult {
  const _RefreshResult({this.token, required this.forceLogout});

  final String? token;
  final bool forceLogout;
}

String? _extractToken(Map<String, dynamic>? map) {
  final data = map ?? const <String, dynamic>{};
  final direct =
      data['token']?.toString() ??
      data['access_token']?.toString() ??
      data['jwt']?.toString() ??
      data['jwt_token']?.toString();
  if ((direct ?? '').isNotEmpty) return direct;
  final nested = data['data'];
  if (nested is Map) {
    final m = Map<String, dynamic>.from(nested);
    final nestedToken =
        m['token']?.toString() ??
        m['access_token']?.toString() ??
        m['jwt']?.toString() ??
        m['jwt_token']?.toString();
    if ((nestedToken ?? '').isNotEmpty) return nestedToken;
  }
  return null;
}

String? _extractExpiresAt(Map<String, dynamic>? map) {
  final data = map ?? const <String, dynamic>{};
  final direct = data['expires_at']?.toString() ?? data['exp']?.toString();
  if ((direct ?? '').isNotEmpty) return direct;
  final nested = data['data'];
  if (nested is Map) {
    final m = Map<String, dynamic>.from(nested);
    final nestedExp = m['expires_at']?.toString() ?? m['exp']?.toString();
    if ((nestedExp ?? '').isNotEmpty) return nestedExp;
  }
  return null;
}
