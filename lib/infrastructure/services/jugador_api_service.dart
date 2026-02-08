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
      final path = anio != null ? '/jugador/resumen?año=$anio' : '/jugador/resumen';
      final response = await _dio.get<Map<String, dynamic>>(path);
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
