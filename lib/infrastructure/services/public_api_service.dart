import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para endpoints públicos (sin auth): escuelas y posiciones para completar perfil.
class PublicApiService {
  PublicApiService(this._dio);

  final Dio _dio;

  /// GET /api/public/escuelas — Lista de escuelas (para selector completar perfil).
  Future<Map<String, dynamic>?> getEscuelas() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>('/public/escuelas');
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/public/posiciones — Lista de posiciones (para selector completar perfil).
  Future<Map<String, dynamic>?> getPosiciones() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>('/public/posiciones');
      return response.data;
    } on DioException {
      rethrow;
    }
  }
}

final publicApiServiceProvider = Provider<PublicApiService>((ref) {
  return PublicApiService(ref.read(apiClientProvider));
});

final publicEscuelasProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(publicApiServiceProvider).getEscuelas();
});

final publicPosicionesProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(publicApiServiceProvider).getPosiciones();
});
