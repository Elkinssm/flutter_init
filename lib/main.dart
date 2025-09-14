import 'dart:async';
import 'dart:ui';

import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/config/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) debugPrint(details.stack.toString());
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught zone error: $error');
    debugPrint(stack.toString());
    return true;
  };
  runZonedGuarded(
    () => runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => const ProviderScope(child: MyApp()),
      ),
    ),
    (error, stack) {
      debugPrint('runZonedGuarded: $error');
      debugPrint(stack.toString());
    },
  );
}
// runApp(const ProviderScope(child: MyApp())),
// runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => const ProviderScope(child: MyApp()))),

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'coach_app',
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
