import 'dart:convert';

import 'package:coach_app/config/errors/app_error_reporter.dart';
import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves para [SharedPreferences].
const _kToken = 'auth_token';
const _kExpiresAt = 'auth_expires_at';
const _kUser = 'auth_user';

/// Persistencia de sesión (token, expires_at, usuario) para restaurar al abrir la app.
class SessionService {
  SessionService({
    SharedPreferences? prefs,
    FlutterSecureStorage? secureStorage,
  }) : _prefs = prefs,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage;
  String? _tokenCache;
  String? _expiresAtCache;
  String? _userJsonCache;
  bool _cacheLoaded = false;
  Future<void>? _loadCacheFuture;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _ensureCacheLoaded() async {
    if (_cacheLoaded) return;
    if (_loadCacheFuture != null) return _loadCacheFuture;

    _loadCacheFuture = () async {
      final prefs = await _storage;
      try {
        _tokenCache = await _secureStorage.read(key: _kToken);
        _expiresAtCache = await _secureStorage.read(key: _kExpiresAt);
      } on PlatformException catch (e, st) {
        // Si Android no puede descifrar un valor persistido de una instalación
        // anterior, limpiamos credenciales seguras y forzamos nuevo login.
        await _clearSecureStorageSafely();
        AppErrorReporter.report(
          e,
          st,
          context: 'session_service.ensure_cache_loaded.secure_storage',
        );
        _tokenCache = null;
        _expiresAtCache = null;
      }
      _userJsonCache = prefs.getString(_kUser);
      _cacheLoaded = true;
      _loadCacheFuture = null;
    }();

    return _loadCacheFuture;
  }

  /// Guarda token, expires_at y usuario tras login/register.
  Future<void> saveSession({
    required String token,
    required AuthUser user,
    String? expiresAt,
  }) async {
    final prefs = await _storage;
    await _writeSecureValue(_kToken, token);
    if (expiresAt != null) {
      await _writeSecureValue(_kExpiresAt, expiresAt);
    } else {
      await _deleteSecureValue(_kExpiresAt);
    }
    final userMap = {
      'id': user.id,
      'email': user.email,
      'rol': user.rol,
      'nombre': user.nombre,
      'apellido': user.apellido,
      'perfil_completo': user.profileComplete,
    };
    final userJson = jsonEncode(userMap);
    await prefs.setString(_kUser, userJson);

    _tokenCache = token;
    _expiresAtCache = expiresAt;
    _userJsonCache = userJson;
    _cacheLoaded = true;
  }

  /// Actualiza solo el token (y opcionalmente expires_at) tras refresh.
  Future<void> updateToken(String token, {String? expiresAt}) async {
    await _writeSecureValue(_kToken, token);
    if (expiresAt != null) {
      await _writeSecureValue(_kExpiresAt, expiresAt);
    } else {
      await _deleteSecureValue(_kExpiresAt);
    }
    _tokenCache = token;
    _expiresAtCache = expiresAt;
    _cacheLoaded = true;
  }

  /// Elimina sesión (logout).
  Future<void> clearSession() async {
    final prefs = await _storage;
    await _clearSecureStorageSafely();
    await prefs.remove(_kUser);
    _tokenCache = null;
    _expiresAtCache = null;
    _userJsonCache = null;
    _cacheLoaded = true;
  }

  /// Devuelve el token guardado o null.
  Future<String?> getToken() async {
    await _ensureCacheLoaded();
    return _tokenCache;
  }

  /// Devuelve expires_at (ISO 8601) o null.
  Future<String?> getExpiresAt() async {
    await _ensureCacheLoaded();
    return _expiresAtCache;
  }

  /// Devuelve el usuario guardado o null. Solo campos necesarios para UI/rol.
  Future<AuthUser?> getSavedUser() async {
    await _ensureCacheLoaded();
    final jsonStr = _userJsonCache;
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
    } catch (e, st) {
      AppErrorReporter.report(e, st, context: 'session_service.get_saved_user');
      return null;
    }
  }

  /// True si hay token guardado.
  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _writeSecureValue(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on PlatformException catch (e, st) {
      await _clearSecureStorageSafely();
      AppErrorReporter.report(
        e,
        st,
        context: 'session_service.write_secure_value.$key',
      );
      rethrow;
    }
  }

  Future<void> _deleteSecureValue(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException catch (e, st) {
      AppErrorReporter.report(
        e,
        st,
        context: 'session_service.delete_secure_value.$key',
      );
    }
  }

  Future<void> _clearSecureStorageSafely() async {
    try {
      await _secureStorage.delete(key: _kToken);
      await _secureStorage.delete(key: _kExpiresAt);
    } on PlatformException catch (e, st) {
      AppErrorReporter.report(
        e,
        st,
        context: 'session_service.clear_secure_storage',
      );
    }
  }
}
