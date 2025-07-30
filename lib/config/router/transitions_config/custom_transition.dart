import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CustomTransition {
  static CustomTransitionPage fade(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
