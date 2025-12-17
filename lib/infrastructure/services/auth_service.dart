import 'dart:io';

import 'package:dio/dio.dart';

class AuthService {
  AuthService({
    Dio? dio,
    String? hostOverride,
    String scheme = 'http',
    int port = 8000,
  })  : host = hostOverride ?? _defaultHost,
        _scheme = scheme,
        _port = port,
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  final Dio _dio;
  final String host;
  final String _scheme;
  final int _port;

  static String get _defaultHost => '127.0.0.1';

  String get baseUrl => '$_scheme://$host:$_port/api';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '',
          },
        ),
      );

      final data = response.data ?? {};
      final token = data['token'] as String?;
      final userJson = (data['usuario'] as Map?)?.cast<String, dynamic>();
      if (token == null || userJson == null) {
        throw const AuthException('Respuesta del servidor incompleta.');
      }

      return AuthResult(
        message: data['message']?.toString() ?? 'Login correcto',
        token: token,
        user: AuthUser.fromJson(userJson),
      );
    } on DioException catch (error) {
      final resp = error.response?.data;
      String? message;
      if (resp is Map && resp['message'] != null) {
        message = resp['message'].toString();
      } else if (resp is String && resp.isNotEmpty) {
        message = resp;
      }
      throw AuthException(
        message ??
            error.message ??
            'Error al iniciar sesión. Verifica tus credenciales o la conexión.',
      );
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }
}

class AuthResult {
  AuthResult({
    required this.message,
    required this.token,
    required this.user,
  });

  final String message;
  final String token;
  final AuthUser user;
}

class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellido,
    required this.estado,
    required this.fechaRegistro,
    required this.ultimoLogin,
    required this.intentosFallidos,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int? ?? 0,
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      fechaRegistro: json['fecha_registro']?.toString() ?? '',
      ultimoLogin: json['ultimo_login']?.toString() ?? '',
      intentosFallidos: json['intentos_fallidos'] as int? ?? 0,
    );
  }

  final int id;
  final String email;
  final String rol;
  final String nombre;
  final String apellido;
  final String estado;
  final String fechaRegistro;
  final String ultimoLogin;
  final int intentosFallidos;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
