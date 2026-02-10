import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio API para pantallas del rol Jugador.
class JugadorApiService {
  JugadorApiService(this._dio);

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

  /// GET /api/jugador/categorias — Lista de equipos/categorías del jugador.
  Future<Map<String, dynamic>?> getCategorias() async => _get('/jugador/categorias');

  /// GET /api/jugador/categoria — Categoría actual + estadísticas + estudiantes.
  Future<Map<String, dynamic>?> getCategoriaActual() async => _get('/jugador/categoria');

  /// GET /api/jugador/categorias/{equipo_id} — Detalle de una categoría/equipo.
  Future<Map<String, dynamic>?> getCategoriaById(int equipoId) async =>
      _get('/jugador/categorias/$equipoId');

  /// GET /api/jugador/resumen — Opcional: ?año=2025
  Future<Map<String, dynamic>?> getResumen({int? anio}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/resumen',
        queryParameters: anio != null ? {'año': anio} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/jugador/estadisticas — Opcional: ?temporada_id=1
  Future<Map<String, dynamic>?> getEstadisticas({int? temporadaId}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/estadisticas',
        queryParameters: temporadaId != null ? {'temporada_id': temporadaId} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/jugador/mediciones — Opcional: ?tipo_metrica_id=1
  Future<Map<String, dynamic>?> getMediciones({int? tipoMetricaId}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/mediciones',
        queryParameters: tipoMetricaId != null ? {'tipo_metrica_id': tipoMetricaId} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/jugador/logros — Opcional: ?temporada_id=1
  Future<Map<String, dynamic>?> getLogros({int? temporadaId}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/logros',
        queryParameters: temporadaId != null ? {'temporada_id': temporadaId} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/jugador/partidos — Opcional: ?estado=proximos|pasados|todos
  Future<Map<String, dynamic>?> getPartidos({String? estado}) async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/partidos',
        queryParameters: estado != null ? {'estado': estado} : null,
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }
}

final jugadorApiServiceProvider = Provider<JugadorApiService>((ref) {
  return JugadorApiService(ref.read(apiClientProvider));
});

/// Lista de categorías del jugador. Devuelve null si !useBackend.
final jugadorCategoriasProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getCategorias();
});

/// Categoría actual del jugador.
final jugadorCategoriaActualProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getCategoriaActual();
});

/// Resumen (asistencia/estadísticas) del jugador. [anio] opcional.
final jugadorResumenProvider = FutureProvider.family<Map<String, dynamic>?, int?>((ref, anio) {
  return ref.read(jugadorApiServiceProvider).getResumen(anio: anio);
});

final jugadorEstadisticasProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getEstadisticas();
});

final jugadorMedicionesProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getMediciones();
});

final jugadorLogrosProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getLogros();
});

final jugadorPartidosProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(jugadorApiServiceProvider).getPartidos();
});
