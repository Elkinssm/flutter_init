import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CustomTransition {
  /// Transición suave con slide + fade (recomendada)
  static CustomTransitionPage slideLeft(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curva suave para entrada
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Slide desde la derecha (movimiento visible)
        final offsetTween = Tween<Offset>(
          begin: const Offset(
            0.5,
            0,
          ), // 50% de desplazamiento - visible pero no exagerado
          end: Offset.zero,
        ).animate(curved);

        // Fade ligero para suavizar el inicio
        final fadeTween = Tween<double>(
          begin: 0.3, // Empieza un poco visible
          end: 1.0,
        ).animate(curved);

        return FadeTransition(
          opacity: fadeTween,
          child: SlideTransition(position: offsetTween, child: child),
        );
      },
    );
  }

  /// Transición rápida solo con fade (para navegación frecuente)
  static CustomTransitionPage fadeOnly(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  /// Sin transición (instantáneo)
  static CustomTransitionPage none(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
