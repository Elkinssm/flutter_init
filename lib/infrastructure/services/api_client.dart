import 'dart:async';

import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/config/router/app_router.dart';
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
  Completer<String?>? refreshCompleter;
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
            refreshCompleter = Completer<String?>();
            () async {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: Environment.apiUrl));
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
                final newToken = data?['token']?.toString();
                final expiresAt = data?['expires_at']?.toString();
                if (newToken != null && newToken.isNotEmpty) {
                  await session.updateToken(newToken, expiresAt: expiresAt);
                  refreshCompleter?.complete(newToken);
                  return;
                }
                refreshCompleter?.complete(null);
              } catch (_) {
                refreshCompleter?.complete(null);
              }
            }();
          }

          final refreshedToken = await refreshCompleter!.future;
          if (refreshedToken != null && refreshedToken.isNotEmpty) {
            opts.headers['Authorization'] = 'Bearer $refreshedToken';
            opts.extra['__retried_after_refresh'] = true;
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
        } catch (_) {
          // refresh flow falló: cerrar sesión y redirigir
        }

        await _clearAndGoLogin(ref, session);
        return handler.next(error);
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
