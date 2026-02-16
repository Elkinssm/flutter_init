import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/api_logger.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService({Dio? dio, String? host, String? scheme, int? port})
    : _dio = dio ?? _buildDio(),
      _host = host ?? Environment.backendHost,
      _scheme = scheme ?? Environment.backendScheme,
      _port = port ?? Environment.backendPort;

  final Dio _dio;
  final String _host;
  final String _scheme;
  final int _port;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    dio.interceptors.add(
      ApiLoggerInterceptor(enabled: Environment.enableHttpLogs),
    );
    return dio;
  }

  String get _baseUrl => '$_scheme://$_host:$_port/api';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Modo local: retornar datos mock sin conectar al backend
    if (!Environment.useBackend) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockLogin(email, password);
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw AuthException(
        _extractMessage(error) ??
            'No se pudo iniciar sesión. Verifica las credenciales o la conexión.',
      );
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? passwordConfirmation,
  }) async {
    // Modo local: retornar datos mock sin conectar al backend
    if (!Environment.useBackend) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockRegister(email, password);
    }

    final confirm = passwordConfirmation ?? password;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/register',
        data: {
          'email': email,
          'password': password,
          'password_confirmation': confirm,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw AuthException(
        _extractMessage(error) ??
            'No se pudo registrar. Verifica la conexión o intenta más tarde.',
      );
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  /// Cierra sesión en el backend. Solo tiene efecto si [Environment.useBackend] es true.
  Future<void> logout(String token) async {
    if (!Environment.useBackend || token.isEmpty) return;
    try {
      await _dio.post<void>(
        '$_baseUrl/logout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (_) {
      // Si falla (401, red, etc.) igual limpiamos sesión en el cliente
    }
  }

  /// Login rápido de prueba usando credenciales definidas en [Environment].
  Future<AuthResult> testLogin() {
    return login(
      email: Environment.testLoginEmail,
      password: Environment.testLoginPassword,
    );
  }

  /// Solicita envío de correo para recuperación de contraseña.
  Future<String> forgotPassword({required String email}) async {
    if (!Environment.useBackend) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'Si el email está registrado, recibirás un enlace para restablecer tu contraseña.';
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data?['message']?.toString() ??
          'Si el email está registrado, recibirás un enlace para restablecer tu contraseña.';
    } on DioException catch (error) {
      throw AuthException(
        _extractMessage(error) ??
            'No fue posible procesar la recuperación de contraseña.',
      );
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  /// Restablece contraseña usando token enviado por correo.
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!Environment.useBackend) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'Contraseña restablecida correctamente. Ya puedes iniciar sesión.';
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/reset-password',
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data?['message']?.toString() ??
          'Contraseña restablecida correctamente. Ya puedes iniciar sesión.';
    } on DioException catch (error) {
      throw AuthException(
        _extractMessage(error) ?? 'No fue posible restablecer la contraseña.',
      );
    } catch (error) {
      throw AuthException('Error inesperado: $error');
    }
  }

  // Datos mock para modo local - LOGIN
  AuthResult _mockLogin(String email, String password) {
    final lower = email.toLowerCase();
    // Usar solo la parte antes del @ para detectar rol y evitar falsos positivos con el dominio
    final localPart = lower.split('@').first;
    final isAdmin = localPart.contains('admin');
    final isCoach = localPart.contains('coach') || localPart.contains('entrenador');
    // Perfil incompleto para probar: usuario "incompleto@mail.com" o "perfil@mail.com"
    final profileComplete =
        lower != 'incompleto@mail.com' && lower != 'perfil@mail.com';

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
    final token =
        map['token']?.toString() ??
        map['access_token']?.toString() ??
        (map['data'] is Map ? (map['data'] as Map)['token']?.toString() : null);
    final expiresAtRaw = map['expires_at']?.toString();
    final userJson = (map['usuario'] as Map?)?.cast<String, dynamic>() ?? {};
    final user = AuthUser.fromJson(userJson);
    return AuthResult(
      message: map['message']?.toString() ?? 'Operación exitosa',
      token: token,
      expiresAt: expiresAtRaw,
      user: user,
    );
  }

  String? _extractMessage(DioException error) {
    final resp = error.response?.data;
    if (resp is Map && resp['message'] != null) {
      return resp['message'].toString();
    }
    if (resp is String && resp.isNotEmpty) {
      return resp;
    }
    return error.message;
  }
}

class AuthResult {
  AuthResult({
    required this.message,
    required this.user,
    this.token,
    this.expiresAt,
  });

  final String message;
  final String? token;

  /// ISO 8601 (ej. 2026-02-12T23:31:48+00:00). Para renovar token antes de que expire.
  final String? expiresAt;
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

  /// Rol normalizado para rutas: ADMIN/ENTRENADOR/COACH → coach, JUGADOR/PLAYER → player.
  String get normalizedRole {
    final r = rol.toUpperCase();
    if (r == 'ADMIN' || r == 'ENTRENADOR' || r == 'COACH') return 'coach';
    if (r == 'JUGADOR' || r == 'PLAYER') return 'player';
    return 'player';
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
