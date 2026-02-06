import 'package:coach_app/config/constants/environment.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService({
    Dio? dio,
    String? host,
    String? scheme,
    int? port,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
        _host = host ?? Environment.backendHost,
        _scheme = scheme ?? Environment.backendScheme,
        _port = port ?? Environment.backendPort;

  final Dio _dio;
  final String _host;
  final String _scheme;
  final int _port;

  String get _baseUrl => '$_scheme://$_host:$_port/api';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Modo local: retornar datos mock sin conectar al backend
    if (!Environment.useBackend) {
      print('[AUTH SERVICE] Modo LOCAL - Usando datos mock');
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de red
      return _mockLogin(email, password);
    }

    // Modo backend: conectar al servidor real
    print('[AUTH SERVICE] Modo BACKEND - Conectando a $_baseUrl/login');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '',
          },
        ),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw AuthException(_extractMessage(error) ??
          'No se pudo iniciar sesión. Verifica las credenciales o la conexión.');
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
  }) async {
    // Modo local: retornar datos mock sin conectar al backend
    if (!Environment.useBackend) {
      print('[AUTH SERVICE] Modo LOCAL - Usando datos mock para registro');
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de red
      return _mockRegister(email, password);
    }

    // Modo backend: conectar al servidor real
    print('[AUTH SERVICE] Modo BACKEND - Conectando a $_baseUrl/register');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/register',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '',
          },
        ),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw AuthException(_extractMessage(error) ??
          'No se pudo registrar. Verifica la conexión o intenta más tarde.');
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  // Datos mock para modo local - LOGIN
  AuthResult _mockLogin(String email, String password) {
    final lower = email.toLowerCase();
    final isAdmin = lower.contains('admin') || lower.contains('demo');
    final isCoach = lower.contains('coach') || lower.contains('entrenador');
    // Perfil incompleto para probar: usuario "incompleto@mail.com" o "perfil@mail.com"
    final profileComplete = lower != 'incompleto@mail.com' && lower != 'perfil@mail.com';

    final rol = isAdmin ? 'ADMIN' : (isCoach ? 'COACH' : 'PLAYER');

    return AuthResult(
      message: 'Login correcto (MODO LOCAL)',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: AuthUser(
        id: 1,
        email: email,
        rol: rol,
        nombre: isAdmin ? 'Admin' : (isCoach ? 'Entrenador' : 'Jugador'),
        apellido: 'Demo',
        estado: 'ACTIVO',
        fechaRegistro: DateTime.now().toString(),
        ultimoLogin: DateTime.now().toString(),
        intentosFallidos: 0,
        profileComplete: profileComplete,
      ),
    );
  }

  // Datos mock para modo local - REGISTER
  AuthResult _mockRegister(String email, String password) {
    return AuthResult(
      message: 'Registro exitoso (MODO LOCAL)',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: AuthUser(
        id: 999,
        email: email,
        rol: 'PLAYER',
        nombre: 'Nuevo',
        apellido: 'Usuario',
        estado: 'ACTIVO',
        fechaRegistro: DateTime.now().toString(),
        ultimoLogin: DateTime.now().toString(),
        intentosFallidos: 0,
        profileComplete: true,
      ),
    );
  }

  AuthResult _parseAuthResponse(Map<String, dynamic>? data) {
    final map = data ?? {};
    final token = map['token']?.toString();
    final userJson = (map['usuario'] as Map?)?.cast<String, dynamic>() ?? {};
    final user = AuthUser.fromJson(userJson);
    return AuthResult(
      message: map['message']?.toString() ?? 'Operación exitosa',
      token: token,
      user: user,
    );
  }

  String? _extractMessage(DioException error) {
    final resp = error.response?.data;
    if (resp is Map && resp['message'] != null) return resp['message'].toString();
    if (resp is String && resp.isNotEmpty) return resp;
    return error.message;
  }
}

class AuthResult {
  AuthResult({
    required this.message,
    required this.user,
    this.token,
  });

  final String message;
  final String? token;
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
    this.profileComplete = true,
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
      profileComplete: json['perfil_completo'] as bool? ?? true,
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
  final bool profileComplete;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
