import 'package:dio/dio.dart';

/// Simple client to hit the health endpoint used for the test page.
class HealthService {
  HealthService({
    Dio? dio,
    String? hostOverride,
    String scheme = 'http',
    int port = 8000,
  }) : host = hostOverride ?? _defaultHost,
       _scheme = scheme,
       _port = port,
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

  static String get _defaultHost => '127.0.0.1';

  int get port => _port;
  String get endpoint => '$_scheme://$host:$_port/api/health';

  Future<HealthCheckResult> check() async {
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
