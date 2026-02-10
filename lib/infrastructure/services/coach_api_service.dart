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

  /// GET /api/coach/equipos/{equipo_id} — Detalle de equipo.
  Future<Map<String, dynamic>?> getEquipo(int equipoId) async =>
      _get('/coach/equipos/$equipoId');

  /// PUT /api/coach/equipos/{equipo_id}
  Future<Map<String, dynamic>> putEquipo(int equipoId, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/coach/equipos/$equipoId', data: body);
    return response.data ?? {};
  }

  /// GET /api/coach/equipos/{equipo_id}/alineacion
  Future<Map<String, dynamic>?> getAlineacion(int equipoId) async =>
      _get('/coach/equipos/$equipoId/alineacion');

  /// PUT /api/coach/equipos/{equipo_id}/alineacion — body: { "formacion": "4-4-2" }
  Future<Map<String, dynamic>> putAlineacion(int equipoId, String formacion) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/coach/equipos/$equipoId/alineacion',
      data: {'formacion': formacion},
    );
    return response.data ?? {};
  }

  /// GET /api/coach/jugadores/{id} — Detalle de un jugador.
  Future<Map<String, dynamic>?> getJugador(int jugadorId) async =>
      _get('/coach/jugadores/$jugadorId');

  /// POST /api/coach/jugadores — Crear jugador. Body según API (nombre_completo, equipo_id, dorsal, etc.).
  Future<Map<String, dynamic>> postJugador(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>('/coach/jugadores', data: body);
    return response.data ?? {};
  }

  /// POST /api/coach/categorias/{equipo_id}/jugadores
  /// Si el backend aún no soporta esta ruta, hace fallback a /coach/jugadores.
  Future<Map<String, dynamic>> postJugadorByCategoria(
    int equipoId,
    Map<String, dynamic> body,
  ) async {
    final scopedBody = Map<String, dynamic>.from(body)..remove('equipo_id');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/coach/categorias/$equipoId/jugadores',
        data: scopedBody,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      // Backend no implementado o método no permitido: usa endpoint actual documentado.
      if (code == 404 || code == 405) {
        final fallbackBody = Map<String, dynamic>.from(body)
          ..putIfAbsent('equipo_id', () => equipoId);
        return postJugador(fallbackBody);
      }
      rethrow;
    }
  }

  /// PUT /api/coach/jugadores/{id}
  Future<Map<String, dynamic>> putJugador(int jugadorId, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/coach/jugadores/$jugadorId', data: body);
    return response.data ?? {};
  }

  /// DELETE /api/coach/jugadores/{id}
  Future<void> deleteJugador(int jugadorId) async {
    await _dio.delete('/coach/jugadores/$jugadorId');
  }

  /// POST /api/coach/partidos — Programar partido.
  Future<Map<String, dynamic>> postPartido(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>('/coach/partidos', data: body);
    return response.data ?? {};
  }

  /// PUT /api/coach/partidos/{id} — Actualizar (reprogramar o resultado).
  Future<Map<String, dynamic>> putPartido(int partidoId, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/coach/partidos/$partidoId', data: body);
    return response.data ?? {};
  }

  /// DELETE /api/coach/partidos/{id}
  Future<void> deletePartido(int partidoId) async {
    await _dio.delete('/coach/partidos/$partidoId');
  }

  /// GET /api/coach/categorias/{equipo_id}/asistencia/resumen — ?año=2026
  Future<Map<String, dynamic>?> getAsistenciaResumen(int equipoId, {int? anio}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coach/categorias/$equipoId/asistencia/resumen',
        queryParameters: anio != null ? {'año': anio} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }
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

final coachPartidosByEquipoProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, equipoId) {
  return ref.read(coachApiServiceProvider).getPartidos(equipoId: equipoId);
});

final coachPosicionesProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(coachApiServiceProvider).getPosiciones();
});

final coachEquipoProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, equipoId) {
  return ref.read(coachApiServiceProvider).getEquipo(equipoId);
});

final coachAlineacionProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, equipoId) {
  return ref.read(coachApiServiceProvider).getAlineacion(equipoId);
});

final coachJugadorDetailProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, jugadorId) {
  return ref.read(coachApiServiceProvider).getJugador(jugadorId);
});

final coachAsistenciaResumenProvider = FutureProvider.family<Map<String, dynamic>?, ({int equipoId, int? anio})>((ref, params) {
  return ref.read(coachApiServiceProvider).getAsistenciaResumen(params.equipoId, anio: params.anio);
});
