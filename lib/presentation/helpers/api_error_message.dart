import 'package:dio/dio.dart';

String apiErrorMessage(
  Object? error, {
  String defaultMessage = 'Ocurrió un error inesperado. Intenta de nuevo.',
  String? forbiddenMessage,
}) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      final backendMessage = data['message'].toString().trim();
      if (backendMessage.isNotEmpty && code != 500) {
        return backendMessage;
      }
    }

    if (code == 401) {
      return 'Tu sesión expiró. Inicia sesión nuevamente.';
    }
    if (code == 403) {
      return forbiddenMessage ?? 'No tienes permisos para esta acción.';
    }
    if (code == 404) {
      return 'No se encontró la información solicitada.';
    }
    if (code != null && code >= 500) {
      return 'El servidor no está disponible en este momento.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'No se pudo conectar con el servidor. Intenta de nuevo.';
    }
  }

  return defaultMessage;
}
