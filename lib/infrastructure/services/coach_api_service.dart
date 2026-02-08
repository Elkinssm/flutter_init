import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio API para pantallas del rol Coach (y Admin donde aplique).
class CoachApiService {
  CoachApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>?> _get(String path) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/coach/categorias — Lista de categorías/equipos con total de miembros.
  Future<Map<String, dynamic>?> getCategorias() async => _get('/coach/categorias');

  /// GET /api/coach/categorias/{equipo_id}/jugadores
  Future<Map<String, dynamic>?> getJugadoresByEquipo(int equipoId) async =>
      _get('/coach/categorias/$equipoId/jugadores');

  /// GET /api/coach/categorias/{equipo_id}/asistencia?fecha=YYYY-MM-DD
  Future<Map<String, dynamic>?> getAsistencia(int equipoId, String fecha) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coach/categorias/$equipoId/asistencia',
        queryParameters: {'fecha': fecha},
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// POST /api/coach/categorias/{equipo_id}/asistencia
  Future<Map<String, dynamic>> postAsistencia(
    int equipoId, {
    required String fecha,
    required List<Map<String, dynamic>> asistencias,
    String? hora,
  }) async {
    final body = <String, dynamic>{
      'fecha': fecha,
      'asistencias': asistencias,
    };
    if (hora != null) body['hora'] = hora;
    final response = await _dio.post<Map<String, dynamic>>(
      '/coach/categorias/$equipoId/asistencia',
      data: body,
    );
    return response.data ?? {};
  }

  /// GET /api/coach/partidos — Opcional: ?equipo_id=1
  Future<Map<String, dynamic>?> getPartidos({int? equipoId}) async {
    if (!Environment.useBackend) return null;
    try {
      final path = equipoId != null
          ? '/coach/partidos?equipo_id=$equipoId'
          : '/coach/partidos';
      final response = await _dio.get<Map<String, dynamic>>(path);
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/coach/posiciones — Para formulario crear jugador.
  Future<Map<String, dynamic>?> getPosiciones() async => _get('/coach/posiciones');
}

final coachApiServiceProvider = Provider<CoachApiService>((ref) {
  return CoachApiService(ref.read(apiClientProvider));
});

final coachCategoriasProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(coachApiServiceProvider).getCategorias();
});

final coachJugadoresProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, equipoId) {
  return ref.read(coachApiServiceProvider).getJugadoresByEquipo(equipoId);
});

/// fecha en formato YYYY-MM-DD
final coachAsistenciaProvider =
    FutureProvider.family<Map<String, dynamic>?, ({int equipoId, String fecha})>(
  (ref, params) {
    return ref
        .read(coachApiServiceProvider)
        .getAsistencia(params.equipoId, params.fecha);
  },
);

final coachPartidosProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(coachApiServiceProvider).getPartidos();
});

final coachPosicionesProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(coachApiServiceProvider).getPosiciones();
});
