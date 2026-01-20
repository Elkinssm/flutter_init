import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'nav_loading.dart';

class LoadingNavObserver extends NavigatorObserver {
  // Threshold más alto para evitar flashes de loading en navegación rápida
  static const int _loadingThresholdMs = 400;

  void _endNextFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await SchedulerBinding.instance.endOfFrame;
      NavLoading.instance.end();
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    // Solo mostrar loading para rutas que realmente lo necesitan
    NavLoading.instance.begin(thresholdMs: _loadingThresholdMs);
    _endNextFrame();
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    NavLoading.instance.begin(thresholdMs: _loadingThresholdMs);
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
