/// Configuración global del entorno de la aplicación
///
/// INSTRUCCIONES DE USO:
/// =====================
///
/// 1. Para usar el BACKEND REAL:
///    - Cambia useBackend a true
///    - Configura backendHost según tu caso:
///      * '10.0.2.2' para emulador Android
///      * '192.168.x.x' para dispositivo físico (tu IP local)
///      * '127.0.0.1' para pruebas en la misma máquina
///
/// 2. Para usar MODO LOCAL (sin backend):
///    - Cambia useBackend a false
///    - La app usará datos mock y no intentará conectar al servidor
///
/// EJEMPLO:
///   static const bool useBackend = false; // Modo local
///   static const bool useBackend = true;  // Modo backend
class Environment {
  // ============================================
  // CONFIGURACIÓN: Cambia esto según necesites
  // ============================================

  /// Modo de operación:
  /// - true: Se conecta al backend real
  /// - false: Usa datos locales/mock (sin conexión al backend)
  static const bool useBackend = true; // Cambia a false para modo local

  /// Selector de backend cuando `useBackend = true`.
  /// - `BackendTarget.local`: emulador Android/local network
  /// - `BackendTarget.prod`: API productiva (Render)
  static const BackendTarget backendTarget = BackendTarget.prod;

  // Configuración local (emulador Android por defecto)
  static const String localBackendHost = '10.0.2.2';
  static const String localBackendScheme = 'http';
  static const int localBackendPort = 8000;

  // Configuración productiva
  static const String prodBackendHost = 'coachapp-uy5w.onrender.com';
  static const String prodBackendScheme = 'https';
  static const int prodBackendPort = 443;

  // API compatible con el resto del proyecto
  static String get backendHost =>
      backendTarget == BackendTarget.prod ? prodBackendHost : localBackendHost;
  static String get backendScheme =>
      backendTarget == BackendTarget.prod ? prodBackendScheme : localBackendScheme;
  static int get backendPort =>
      backendTarget == BackendTarget.prod ? prodBackendPort : localBackendPort;

  /// Logs HTTP en consola (request/response/error) para depurar consumo de API.
  /// Recomendado: true en desarrollo, false en producción.
  static const bool enableHttpLogs = true;

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

enum BackendTarget { local, prod }
