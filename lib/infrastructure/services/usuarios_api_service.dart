import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para endpoints /api/usuarios.
class UsuariosApiService {
  UsuariosApiService(this._dio);

  final Dio _dio;

  /// GET /api/usuarios
  Future<List<dynamic>> getUsuarios() async {
    final response = await _dio.get<List<dynamic>>('/usuarios');
    return response.data ?? <dynamic>[];
  }

  /// GET /api/usuarios/{id}
  Future<Map<String, dynamic>> getUsuario(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/usuarios/$id');
    return response.data ?? {};
  }

  /// POST /api/usuarios/jugadores (ADMIN/ENTRENADOR)
  Future<Map<String, dynamic>> postUsuarioJugador(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/usuarios/jugadores',
      data: body,
    );
    return response.data ?? {};
  }

  /// POST /api/usuarios/coach (solo ADMIN)
  Future<Map<String, dynamic>> postUsuarioCoach(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/usuarios/coach',
      data: body,
    );
    return response.data ?? {};
  }

  /// PUT /api/usuarios/{id}
  Future<Map<String, dynamic>> putUsuario(int id, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/usuarios/$id',
      data: body,
    );
    return response.data ?? {};
  }

  /// DELETE /api/usuarios/{id}
  Future<Map<String, dynamic>> deleteUsuario(int id) async {
    final response = await _dio.delete<Map<String, dynamic>>('/usuarios/$id');
    return response.data ?? {};
  }
}

final usuariosApiServiceProvider = Provider<UsuariosApiService>((ref) {
  return UsuariosApiService(ref.read(apiClientProvider));
});
