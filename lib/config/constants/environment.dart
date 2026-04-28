class Environment {
  // Control explícito y simple por bandera.
  static const bool isProd = true; // true=prod, false=dev/local

  // Backend real (debe ser true en prod).
  static const bool useBackend = true;
  static const bool forceHttpLogs = bool.fromEnvironment(
    'FORCE_HTTP_LOGS',
    defaultValue: true,
  );
  static bool get enableHttpLogs => !isProd || forceHttpLogs;
  static bool get showForceReloadButton => !isProd;
  static bool get showDevQuickActions => !isProd;

  // Para APK interna puedes dejarlo en false; para cliente final/tienda en true.
  static const bool enforceTlsPinning = false;
  static bool get enableTlsPinning =>
      isProd && enforceTlsPinning && tlsPinsSha256.isNotEmpty;

  static const String localHost = '10.0.2.2';
  static const int localPort = 8000;

  static const String prodHost = 'coachapp-uy5w.onrender.com';
  static const int prodPort = 443;

  static String get backendScheme => isProd ? 'https' : 'http';
  static String get backendHost => isProd ? prodHost : localHost;
  static int get backendPort => isProd ? prodPort : localPort;

  static String get baseUrl => '$backendScheme://$backendHost:$backendPort';
  static String get apiUrl => '$baseUrl/api';

  // Lista de huellas SHA-256 de certificado, separadas por coma.
  // Se configura por --dart-define=TLS_PINS_SHA256=pin1,pin2
  static const String _tlsPinsSha256Csv = String.fromEnvironment(
    'TLS_PINS_SHA256',
    defaultValue: '',
  );
  static List<String> get tlsPinsSha256 => _tlsPinsSha256Csv
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  // Login rápido en desarrollo.
  static const String testLoginEmail = 'coach@demo.com';
  static const String testLoginPassword = 'secret123';

  // Contacto soporte (drawer).
  static const String supportWhatsAppNumber = '573146170183';
  static const String supportWhatsAppMessage =
      'Hola, necesito ayuda con Training Once+';

  static void validate() {
    if (isProd && !useBackend) {
      throw StateError(
        'Configuración inválida: en producción useBackend debe ser true',
      );
    }
    if (isProd && enforceTlsPinning && tlsPinsSha256.isEmpty) {
      throw StateError(
        'TLS pinning activado sin pines configurados. '
        'Define TLS_PINS_SHA256 en build de release.',
      );
    }
  }
}
