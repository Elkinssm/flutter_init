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

  /// GET /api/public/equipos-disponibles — Equipos para completar perfil jugador.
  /// Soporta filtro opcional por escuela: `?escuela_id=<id>`.
  Future<Map<String, dynamic>?> getEquiposDisponibles({int? escuelaId}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/public/equipos-disponibles',
        queryParameters: {if (escuelaId != null) 'escuela_id': escuelaId},
      );
      return response.data;
    } on DioException {
      return null;
    }
  }

  /// Legacy fallback: GET /api/public/equipos.
  Future<Map<String, dynamic>?> getEquipos() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>('/public/equipos');
      return response.data;
    } on DioException {
      return null;
    }
  }

  /// GET /api/public/posiciones — Lista de posiciones (para selector completar perfil).
  Future<Map<String, dynamic>?> getPosiciones() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/public/posiciones',
      );
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

final publicEquiposProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(publicApiServiceProvider).getEquiposDisponibles();
});
