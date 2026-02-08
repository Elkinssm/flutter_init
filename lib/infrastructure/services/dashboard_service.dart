import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para consumir dashboards de Jugador y Coach según el plan de consumo.
class DashboardService {
  DashboardService(this._dio);

  final Dio _dio;

  /// GET /api/jugador/dashboard — Resumen: jugador, equipo, escuela, asistencia, próximo encuentro.
  /// Solo cuando [Environment.useBackend] es true; si no, devuelve null para usar datos locales.
  Future<Map<String, dynamic>?> getJugadorDashboard() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jugador/dashboard',
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/coach/dashboard — Resumen: coach, total jugadores/equipos, asistencia por mes, próximos entrenamientos.
  /// Solo cuando [Environment.useBackend] es true; si no, devuelve null para usar datos locales.
  /// Timeout 15s para no bloquear la pantalla.
  Future<Map<String, dynamic>?> getCoachDashboard() async {
    if (!Environment.useBackend) return null;
    final response = await _dio.get<Map<String, dynamic>>('/coach/dashboard');
    return response.data;
  }
}

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.read(apiClientProvider));
});

/// Cache del dashboard del jugador. Invalida con ref.invalidate(jugadorDashboardProvider).
final jugadorDashboardProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(dashboardServiceProvider).getJugadorDashboard();
});

/// Cache del dashboard del coach. Invalida con ref.invalidate(coachDashboardProvider).
/// Pequeña demora antes de pedir para que la pantalla pinte primero y no se trabe al entrar.
final coachDashboardProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return ref.read(dashboardServiceProvider).getCoachDashboard();
});
