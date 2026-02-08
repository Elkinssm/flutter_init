import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';

/// Cliente para probar GET /api/health. Usa [Environment] por defecto (misma URL que login/API).
class HealthService {
  HealthService({
    Dio? dio,
    String? hostOverride,
    String? schemeOverride,
    int? portOverride,
  }) : host = hostOverride ?? Environment.backendHost,
       _scheme = schemeOverride ?? Environment.backendScheme,
       _port = portOverride ?? Environment.backendPort,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 5),
             ),
           );

  final Dio _dio;
  final String host;
  final String _scheme;
  final int _port;

  int get port => _port;
  String get endpoint => '$_scheme://$host:$_port/api/health';

  Future<HealthCheckResult> check() async {
    if (!Environment.useBackend) {
      return HealthCheckResult(
        message: 'Modo local (backend desactivado)',
        raw: {
          'status': 'local',
          'message': 'useBackend = false. Activa el backend en Environment para probar conexión.',
        },
      );
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(endpoint);
      final data = response.data;
      final message = switch (data) {
        {'status': final status} => status.toString(),
        {'message': final msg} => msg.toString(),
        _ => 'Sin datos de estado',
      };

      return HealthCheckResult(message: message, raw: data);
    } on DioException catch (error) {
      final message = error.message ?? 'Error al consultar el healthcheck';
      throw HealthCheckException(message);
    } catch (error) {
      throw HealthCheckException('Error inesperado: $error');
    }
  }
}

class HealthCheckResult {
  HealthCheckResult({required this.message, this.raw});

  final String message;
  final Map<String, dynamic>? raw;
}

class HealthCheckException implements Exception {
  HealthCheckException(this.message);
  final String message;

  @override
  String toString() => message;
}
