import 'package:flutter/foundation.dart';

/// Punto único para reportar errores de la app.
///
/// En producción se puede conectar aquí Crashlytics/Sentry sin tocar el resto
/// del código.
class AppErrorReporter {
  const AppErrorReporter._();

  static void report(Object error, StackTrace stackTrace, {String? context}) {
    final prefix = context == null ? '[ERROR]' : '[ERROR][$context]';
    debugPrint('$prefix $error');
    debugPrint(stackTrace.toString());
  }
}
