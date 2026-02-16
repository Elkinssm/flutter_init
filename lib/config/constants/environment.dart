/// Configuración global del entorno de la aplicación
///
/// INSTRUCCIONES DE USO:
/// =====================
///
/// Cambia solo [appProfile] para controlar modo local/prod y herramientas debug.
class Environment {
  // ============================================
  // CONFIGURACIÓN: Cambia esto según necesites
  // ============================================

  /// Perfil actual de la app:
  /// - demoLocal: sin backend, datos mock
  /// - devBackendLocal: backend local + herramientas debug
  /// - prodBackend: backend productivo (sin herramientas debug)
  static const AppProfile appProfile = AppProfile.devBackendLocal;

  // Configuración local (emulador Android por defecto)
  static const String localBackendHost = '10.0.2.2';
  static const String localBackendScheme = 'http';
  static const int localBackendPort = 8000;

  // Configuración productiva
  static const String prodBackendHost = 'coachapp-uy5w.onrender.com';
  static const String prodBackendScheme = 'https';
  static const int prodBackendPort = 443;

  /// Activa consumo de backend.
  static bool get useBackend => appProfile != AppProfile.demoLocal;

  /// Selector efectivo de backend.
  static BackendTarget get backendTarget {
    switch (appProfile) {
      case AppProfile.devBackendLocal:
        return BackendTarget.local;
      case AppProfile.prodBackend:
        return BackendTarget.prod;
      case AppProfile.demoLocal:
        return BackendTarget.local;
    }
  }

  // API compatible con el resto del proyecto
  static String get backendHost =>
      backendTarget == BackendTarget.prod ? prodBackendHost : localBackendHost;
  static String get backendScheme =>
      backendTarget == BackendTarget.prod
          ? prodBackendScheme
          : localBackendScheme;
  static int get backendPort =>
      backendTarget == BackendTarget.prod ? prodBackendPort : localBackendPort;

  /// Logs HTTP en consola (request/response/error) para depurar consumo de API.
  static bool get enableHttpLogs => appProfile == AppProfile.devBackendLocal;

  /// Switch manual (rápido) para mostrar el botón flotante de recarga forzada.
  /// Recomendado:
  /// - true: cuando pruebas local/mock
  /// - false: para pruebas de usuario final / producción
  static const bool forceReloadButtonEnabled = true;

  /// Visibilidad efectiva del botón de recarga.
  static bool get showForceReloadButton => forceReloadButtonEnabled;

  // URLs del backend
  static String get baseUrl => '$backendScheme://$backendHost:$backendPort';
  static String get apiUrl => '$baseUrl/api';

  // Helper para logs
  static String get mode => useBackend ? 'BACKEND' : 'LOCAL';

  /// Credenciales para el botón "Probar login rápido" (solo desarrollo).
  static const String testLoginEmail = 'coach@demo.com';
  static const String testLoginPassword = 'secret123';

  /// Contacto de soporte por WhatsApp (formato internacional sin + ni espacios).
  /// Ejemplo Colombia: 573001234567
  static const String supportWhatsAppNumber = '573146170183';
  static const String supportWhatsAppMessage =
      'Hola, necesito ayuda con Training Once+';

  // ========== CREDENCIALES PARA PROBAR EN LOCAL ==========
  //
  // LOGIN — El rol se detecta por la parte ANTES del @:
  //   - "admin" en el nombre → ADMIN (redirige a coach_screen)
  //   - "coach" o "entrenador" en el nombre → COACH (redirige a coach_screen)
  //   - Cualquier otro → PLAYER (redirige a player_screen)
  //
  // +----------+-------------------------+-------------+
  // | Rol      | Email                   | Contraseña  |
  // +----------+-------------------------+-------------+
  // | Admin    | admin@demo.com          | secret123   |
  // | Coach    | coach@demo.com          | secret123   |
  // | Jugador  | jugador1@demo.com       | secret123   |
  // | Jugador  | incompleto@mail.com     | secret123   | → perfil incompleto
  // | Jugador  | perfil@mail.com         | secret123   | → perfil incompleto
  // +----------+-------------------------+-------------+
  //
  // REGISTRO — Cualquier email válido funciona en modo local.
  // El registro crea sesión automáticamente y redirige a player_screen.
}

enum AppProfile { demoLocal, devBackendLocal, prodBackend }

enum BackendTarget { local, prod }
