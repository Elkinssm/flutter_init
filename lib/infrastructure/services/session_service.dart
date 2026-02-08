import 'dart:convert';

import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves para [SharedPreferences].
const _kToken = 'auth_token';
const _kExpiresAt = 'auth_expires_at';
const _kUser = 'auth_user';

/// Persistencia de sesión (token, expires_at, usuario) para restaurar al abrir la app.
class SessionService {
  SessionService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda token, expires_at y usuario tras login/register.
  Future<void> saveSession({
    required String token,
    required AuthUser user,
    String? expiresAt,
  }) async {
    final prefs = await _storage;
    await prefs.setString(_kToken, token);
    if (expiresAt != null) {
      await prefs.setString(_kExpiresAt, expiresAt);
    } else {
      await prefs.remove(_kExpiresAt);
    }
    final userMap = {
      'id': user.id,
      'email': user.email,
      'rol': user.rol,
      'nombre': user.nombre,
      'apellido': user.apellido,
      'perfil_completo': user.profileComplete,
    };
    await prefs.setString(_kUser, jsonEncode(userMap));
  }

  /// Elimina sesión (logout).
  Future<void> clearSession() async {
    final prefs = await _storage;
    await prefs.remove(_kToken);
    await prefs.remove(_kExpiresAt);
    await prefs.remove(_kUser);
  }

  /// Devuelve el token guardado o null.
  Future<String?> getToken() async {
    final prefs = await _storage;
    return prefs.getString(_kToken);
  }

  /// Devuelve expires_at (ISO 8601) o null.
  Future<String?> getExpiresAt() async {
    final prefs = await _storage;
    return prefs.getString(_kExpiresAt);
  }

  /// Devuelve el usuario guardado o null. Solo campos necesarios para UI/rol.
  Future<AuthUser?> getSavedUser() async {
    final prefs = await _storage;
    final jsonStr = prefs.getString(_kUser);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AuthUser(
        id: map['id'] as int? ?? 0,
        email: map['email']?.toString() ?? '',
        rol: map['rol']?.toString() ?? '',
        nombre: map['nombre']?.toString() ?? '',
        apellido: map['apellido']?.toString() ?? '',
        estado: '',
        fechaRegistro: '',
        ultimoLogin: '',
        intentosFallidos: 0,
        profileComplete: map['perfil_completo'] as bool? ?? true,
      );
    } catch (_) {
      return null;
    }
  }

  /// True si hay token guardado.
  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
