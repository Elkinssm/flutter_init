import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para endpoints Admin y Admin+Coach de tipo CRUD genérico.
class AdminSharedApiService {
  AdminSharedApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: body);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final response = await _dio.delete<Map<String, dynamic>>(path);
    return response.data ?? {};
  }

  // Admin: Escuelas
  Future<Map<String, dynamic>> getEscuelas({Map<String, dynamic>? query}) =>
      _get('/escuelas', query: query);
  Future<Map<String, dynamic>> getEscuela(int id) => _get('/escuelas/$id');
  Future<Map<String, dynamic>> postEscuela(Map<String, dynamic> body) =>
      _post('/escuelas', body);
  Future<Map<String, dynamic>> putEscuela(int id, Map<String, dynamic> body) =>
      _put('/escuelas/$id', body);
  Future<Map<String, dynamic>> deleteEscuela(int id) => _delete('/escuelas/$id');

  // Admin: Posiciones
  Future<Map<String, dynamic>> getPosicionesAdmin({Map<String, dynamic>? query}) =>
      _get('/posiciones', query: query);
  Future<Map<String, dynamic>> getPosicion(int id) => _get('/posiciones/$id');
  Future<Map<String, dynamic>> postPosicion(Map<String, dynamic> body) =>
      _post('/posiciones', body);
  Future<Map<String, dynamic>> putPosicion(int id, Map<String, dynamic> body) =>
      _put('/posiciones/$id', body);
  Future<Map<String, dynamic>> deletePosicion(int id) => _delete('/posiciones/$id');

  // Admin: Tipos de métrica
  Future<Map<String, dynamic>> getTiposMetrica({Map<String, dynamic>? query}) =>
      _get('/tipos-metrica', query: query);
  Future<Map<String, dynamic>> getTipoMetrica(int id) => _get('/tipos-metrica/$id');
  Future<Map<String, dynamic>> postTipoMetrica(Map<String, dynamic> body) =>
      _post('/tipos-metrica', body);
  Future<Map<String, dynamic>> putTipoMetrica(int id, Map<String, dynamic> body) =>
      _put('/tipos-metrica/$id', body);
  Future<Map<String, dynamic>> deleteTipoMetrica(int id) =>
      _delete('/tipos-metrica/$id');

  // Admin: Equipos
  Future<Map<String, dynamic>> getEquipos({Map<String, dynamic>? query}) =>
      _get('/equipos', query: query);
  Future<Map<String, dynamic>> getEquipoAdmin(int id) => _get('/equipos/$id');
  Future<Map<String, dynamic>> postEquipo(Map<String, dynamic> body) =>
      _post('/equipos', body);
  Future<Map<String, dynamic>> putEquipoAdmin(int id, Map<String, dynamic> body) =>
      _put('/equipos/$id', body);
  Future<Map<String, dynamic>> deleteEquipoAdmin(int id) => _delete('/equipos/$id');

  // Admin: Temporadas
  Future<Map<String, dynamic>> getTemporadas({Map<String, dynamic>? query}) =>
      _get('/temporadas', query: query);
  Future<Map<String, dynamic>> getTemporada(int id) => _get('/temporadas/$id');
  Future<Map<String, dynamic>> postTemporada(Map<String, dynamic> body) =>
      _post('/temporadas', body);
  Future<Map<String, dynamic>> putTemporada(int id, Map<String, dynamic> body) =>
      _put('/temporadas/$id', body);
  Future<Map<String, dynamic>> deleteTemporada(int id) => _delete('/temporadas/$id');

  // Admin+Coach: Entrenador-Equipo
  Future<Map<String, dynamic>> getEntrenadoresEquipos({Map<String, dynamic>? query}) =>
      _get('/entrenadores-equipos', query: query);
  Future<Map<String, dynamic>> getEntrenadorEquipo(int id) =>
      _get('/entrenadores-equipos/$id');
  Future<Map<String, dynamic>> postEntrenadorEquipo(Map<String, dynamic> body) =>
      _post('/entrenadores-equipos', body);
  Future<Map<String, dynamic>> putEntrenadorEquipo(int id, Map<String, dynamic> body) =>
      _put('/entrenadores-equipos/$id', body);
  Future<Map<String, dynamic>> deleteEntrenadorEquipo(int id) =>
      _delete('/entrenadores-equipos/$id');

  // Admin+Coach: Jugador-Equipo
  Future<Map<String, dynamic>> getJugadoresEquipos({Map<String, dynamic>? query}) =>
      _get('/jugadores-equipos', query: query);
  Future<Map<String, dynamic>> getJugadorEquipo(int id) =>
      _get('/jugadores-equipos/$id');
  Future<Map<String, dynamic>> postJugadorEquipo(Map<String, dynamic> body) =>
      _post('/jugadores-equipos', body);
  Future<Map<String, dynamic>> putJugadorEquipo(int id, Map<String, dynamic> body) =>
      _put('/jugadores-equipos/$id', body);
  Future<Map<String, dynamic>> deleteJugadorEquipo(int id) =>
      _delete('/jugadores-equipos/$id');

  // Admin+Coach: Entrenamientos
  Future<Map<String, dynamic>> getEntrenamientos({Map<String, dynamic>? query}) =>
      _get('/entrenamientos', query: query);
  Future<Map<String, dynamic>> getEntrenamiento(int id) => _get('/entrenamientos/$id');
  Future<Map<String, dynamic>> postEntrenamiento(Map<String, dynamic> body) =>
      _post('/entrenamientos', body);
  Future<Map<String, dynamic>> putEntrenamiento(int id, Map<String, dynamic> body) =>
      _put('/entrenamientos/$id', body);
  Future<Map<String, dynamic>> deleteEntrenamiento(int id) =>
      _delete('/entrenamientos/$id');

  // Admin+Coach: Asistencias de entrenamiento
  Future<Map<String, dynamic>> getAsistenciasEntrenamiento({
    Map<String, dynamic>? query,
  }) => _get('/asistencias-entrenamiento', query: query);
  Future<Map<String, dynamic>> getAsistenciaEntrenamiento(int id) =>
      _get('/asistencias-entrenamiento/$id');
  Future<Map<String, dynamic>> postAsistenciaEntrenamiento(
    Map<String, dynamic> body,
  ) => _post('/asistencias-entrenamiento', body);
  Future<Map<String, dynamic>> putAsistenciaEntrenamiento(
    int id,
    Map<String, dynamic> body,
  ) => _put('/asistencias-entrenamiento/$id', body);
  Future<Map<String, dynamic>> deleteAsistenciaEntrenamiento(int id) =>
      _delete('/asistencias-entrenamiento/$id');

  // Admin+Coach: Partidos (global /partidos)
  Future<Map<String, dynamic>> getPartidosShared({Map<String, dynamic>? query}) =>
      _get('/partidos', query: query);
  Future<Map<String, dynamic>> getPartidoShared(int id) => _get('/partidos/$id');
  Future<Map<String, dynamic>> postPartidoShared(Map<String, dynamic> body) =>
      _post('/partidos', body);
  Future<Map<String, dynamic>> putPartidoShared(int id, Map<String, dynamic> body) =>
      _put('/partidos/$id', body);
  Future<Map<String, dynamic>> deletePartidoShared(int id) => _delete('/partidos/$id');

  // Admin+Coach: Estadísticas de partido
  Future<Map<String, dynamic>> getEstadisticasPartido({Map<String, dynamic>? query}) =>
      _get('/estadisticas-partido', query: query);
  Future<Map<String, dynamic>> getEstadisticaPartido(int id) =>
      _get('/estadisticas-partido/$id');
  Future<Map<String, dynamic>> postEstadisticaPartido(Map<String, dynamic> body) =>
      _post('/estadisticas-partido', body);
  Future<Map<String, dynamic>> putEstadisticaPartido(
    int id,
    Map<String, dynamic> body,
  ) => _put('/estadisticas-partido/$id', body);
  Future<Map<String, dynamic>> deleteEstadisticaPartido(int id) =>
      _delete('/estadisticas-partido/$id');

  // Admin+Coach: Mediciones
  Future<Map<String, dynamic>> getMedicionesShared({Map<String, dynamic>? query}) =>
      _get('/mediciones', query: query);
  Future<Map<String, dynamic>> getMedicion(int id) => _get('/mediciones/$id');
  Future<Map<String, dynamic>> postMedicion(Map<String, dynamic> body) =>
      _post('/mediciones', body);
  Future<Map<String, dynamic>> putMedicion(int id, Map<String, dynamic> body) =>
      _put('/mediciones/$id', body);
  Future<Map<String, dynamic>> deleteMedicion(int id) => _delete('/mediciones/$id');

  // Admin+Coach: Logros
  Future<Map<String, dynamic>> getLogrosShared({Map<String, dynamic>? query}) =>
      _get('/logros', query: query);
  Future<Map<String, dynamic>> getLogro(int id) => _get('/logros/$id');
  Future<Map<String, dynamic>> postLogro(Map<String, dynamic> body) =>
      _post('/logros', body);
  Future<Map<String, dynamic>> putLogro(int id, Map<String, dynamic> body) =>
      _put('/logros/$id', body);
  Future<Map<String, dynamic>> deleteLogro(int id) => _delete('/logros/$id');
}

final adminSharedApiServiceProvider = Provider<AdminSharedApiService>((ref) {
  return AdminSharedApiService(ref.read(apiClientProvider));
});
