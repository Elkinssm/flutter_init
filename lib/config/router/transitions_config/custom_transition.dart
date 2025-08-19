import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CustomTransition {
  static CustomTransitionPage slideLeft(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final offsetIn = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved);
        return SlideTransition(position: offsetIn, child: child);
      },
    );
  }
}
