import 'dart:convert';
import 'dart:io';

import 'package:coach_app/config/constants/environment.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class TlsPinning {
  const TlsPinning._();

  static void applyToDio(Dio dio) {
    if (kIsWeb) return;
    if (!Environment.useBackend) return;
    if (!Environment.enableTlsPinning) return;

    final adapter = dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final client = HttpClient();
      // Nunca aceptar certificados inválidos.
      client.badCertificateCallback = (_, __, ___) => false;
      return client;
    };

    adapter.validateCertificate = (certificate, host, port) {
      if (certificate == null) return false;

      // Aplicar pinning solo al backend objetivo.
      if (host.toLowerCase() != Environment.backendHost.toLowerCase()) {
        return true;
      }

      final certSha256 =
          sha256.convert(utf8.encode(certificate.pem)).toString().toLowerCase();

      return Environment.tlsPinsSha256.contains(certSha256);
    };
  }
}
