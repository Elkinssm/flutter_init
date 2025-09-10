import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'nav_loading.dart';

class LoadingNavObserver extends NavigatorObserver {
  void _endNextFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await SchedulerBinding.instance.endOfFrame;
      NavLoading.instance.end();
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    NavLoading.instance.begin(thresholdMs: 150);
    _endNextFrame();
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    NavLoading.instance.begin(thresholdMs: 150);
    _endNextFrame();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    NavLoading.instance.begin(thresholdMs: 150);
    _endNextFrame();
    super.didPop(route, previousRoute);
  }
}
