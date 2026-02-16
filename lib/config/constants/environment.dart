class Environment {
  static const bool isProd = false; // true=prod, false=local/mock

  // Si false: usa datos mock (sin llamadas API).
  static const bool useBackend = true;
  static const bool enableHttpLogs = !isProd;
  static const bool showForceReloadButton = !isProd;

  static const String localHost = '10.0.2.2';
  static const int localPort = 8000;

  static const String prodHost = 'coachapp-uy5w.onrender.com';
  static const int prodPort = 443;

  static String get backendScheme => isProd ? 'https' : 'http';
  static String get backendHost => isProd ? prodHost : localHost;
  static int get backendPort => isProd ? prodPort : localPort;

  static String get baseUrl => '$backendScheme://$backendHost:$backendPort';
  static String get apiUrl => '$baseUrl/api';

  // Login rápido en desarrollo.
  static const String testLoginEmail = 'coach@demo.com';
  static const String testLoginPassword = 'secret123';

  // Contacto soporte (drawer).
  static const String supportWhatsAppNumber = '573146170183';
  static const String supportWhatsAppMessage =
      'Hola, necesito ayuda con Training Once+';
}
