import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'nav_loading.dart';

class LoadingNavObserver extends NavigatorObserver {
  // Threshold más alto para evitar flashes de loading en navegación rápida
  static const int _loadingThresholdMs = 400;
  Timer? _safetyEndTimer;

  void _cancelSafetyEnd() {
    _safetyEndTimer?.cancel();
    _safetyEndTimer = null;
  }

  void _endNextFrame() {
    _cancelSafetyEnd();
    // Cierre en el siguiente frame
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await SchedulerBinding.instance.endOfFrame;
      NavLoading.instance.end();
    });
    // Respaldo: forzar cierre tras 600ms por si el callback no corre a tiempo
    _safetyEndTimer = Timer(const Duration(milliseconds: 600), () {
      NavLoading.instance.end();
      _cancelSafetyEnd();
    });
  }

  /// No mostrar overlay cuando viene de login/registro.
  bool _isComingFromAuth(Route? previousRoute) {
    final name = previousRoute?.settings.name?.toString() ?? '';
    return name == '/login_screen' || name == '/register_screen';
  }

  /// No mostrar overlay cuando el destino es la pantalla principal (Coach/Player).
  bool _isGoingToMainApp(Route? newRoute) {
    final name = newRoute?.settings.name?.toString() ?? '';
    return name == '/coach_screen' || name == '/player_screen';
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final skipOverlay =
        _isComingFromAuth(previousRoute) || _isGoingToMainApp(route);
    if (!skipOverlay) {
      NavLoading.instance.begin(thresholdMs: _loadingThresholdMs);
    }
    _endNextFrame();
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final skipOverlay =
        _isComingFromAuth(oldRoute) || (newRoute != null && _isGoingToMainApp(newRoute));
    if (!skipOverlay) {
      NavLoading.instance.begin(thresholdMs: _loadingThresholdMs);
    }
    _endNextFrame();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // No mostrar loading en pop (navegación hacia atrás) - debe ser instantánea
    _endNextFrame();
    super.didPop(route, previousRoute);
  }
}
