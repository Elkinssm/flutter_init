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
  static const bool useBackend = false; // Cambia a false para modo local

  // Configuración del backend (solo se usa si useBackend = true)
  // Para Android emulador, usa '10.0.2.2'
  // Para dispositivo físico, usa tu IP local (ej: '192.168.20.24')
  // Para pruebas en la misma máquina, usa '127.0.0.1'
  static const String backendHost = '10.0.2.2'; // Cambia según tu caso
  static const String backendScheme = 'http';
  static const int backendPort = 8000;

  // URLs del backend
  static String get baseUrl => '$backendScheme://$backendHost:$backendPort';
  static String get apiUrl => '$baseUrl/api';

  // Helper para logs
  static String get mode => useBackend ? 'BACKEND' : 'LOCAL';
}
