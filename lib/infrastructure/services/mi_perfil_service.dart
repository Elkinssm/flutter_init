import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para perfil del usuario autenticado: ver, editar, cambiar contraseña, completar perfil.
class MiPerfilService {
  MiPerfilService(this._dio);

  final Dio _dio;

  /// GET /api/mi-perfil — Perfil completo (usuario + jugador o entrenador).
  Future<Map<String, dynamic>?> getMiPerfil() async {
    if (!Environment.useBackend) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>('/mi-perfil');
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// PUT /api/mi-perfil — Actualizar perfil (campos opcionales).
  Future<Map<String, dynamic>> putMiPerfil(Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/mi-perfil', data: body);
    return response.data ?? {};
  }

  /// PUT /api/mi-perfil/password — Cambiar contraseña.
  Future<Map<String, dynamic>> putMiPerfilPassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/mi-perfil/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response.data ?? {};
  }

  /// PUT /api/mi-perfil/completar — Completar perfil jugador (tras registro).
  /// Acepta JSON o multipart con foto. Body según API_REQUEST_RESPONSE.
  Future<Map<String, dynamic>> putMiPerfilCompletar(Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/mi-perfil/completar', data: body);
    return response.data ?? {};
  }

  /// PUT /api/mi-perfil/foto — Actualizar foto del usuario autenticado.
  Future<Map<String, dynamic>> putMiPerfilFoto(MultipartFile foto) async {
    final form = FormData.fromMap({'foto': foto});
    final response = await _dio.put<Map<String, dynamic>>(
      '/mi-perfil/foto',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data ?? {};
  }
}

final miPerfilServiceProvider = Provider<MiPerfilService>((ref) {
  return MiPerfilService(ref.read(apiClientProvider));
});

final miPerfilProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(miPerfilServiceProvider).getMiPerfil();
});
