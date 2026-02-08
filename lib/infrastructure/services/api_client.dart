import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/providers/session_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Cliente HTTP con baseUrl de [Environment], headers Accept/Content-Type,
/// interceptor que añade Bearer token desde sesión y en 401 limpia sesión y redirige a login.
final apiClientProvider = Provider<Dio>((ref) {
  final session = ref.read(sessionServiceProvider);
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
        if (error.response?.statusCode == 401) {
          await session.clearSession();
          clearUserRole();
          final ctx = rootNavKey.currentContext;
          if (ctx != null && ctx.mounted) {
            GoRouter.of(ctx).go('/login_screen');
          }
        }
        handler.next(error);
      },
    ),
  );
  return dio;
});
