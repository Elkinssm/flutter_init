import 'dart:async';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/widgets/texts/primary_title_text.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

class NavLoading {
  NavLoading._();
  static final NavLoading instance = NavLoading._();

  OverlayEntry? _entry;
  Timer? _delayTimer;
  bool _requested = false;

  void begin({int thresholdMs = 150}) {
    _cancelDelay();
    _requested = true;
    _delayTimer = Timer(Duration(milliseconds: thresholdMs), () {
      if (_requested && _entry == null) {
        _entry = OverlayEntry(
          builder: (_) => const _SplashOverlay(),
        );
        rootNavKey.currentState?.overlay?.insert(_entry!);
      }
    });
  }

  void end() {
    _requested = false;
    _cancelDelay();
    _entry?.remove();
    _entry = null;
  }

  void _cancelDelay() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }
}

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay();

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Center(
          child: Container(
            color: const Color.fromRGBO(255, 255, 255, 1),
            child: const AppLoadingContent(),
          ),
        ),
      ),
    );
  }
}

/// Componente de loading de la app (logo + barra + texto). Reutilizable en registro, etc.
class AppLoadingContent extends StatelessWidget {
  const AppLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final sidePad = wp(context, isPhone(context) ? 0.06 : 0.08);
    final spaceTop = hp(context, 0.04);
    final spaceMid = hp(context, 0.025);
    final spaceBottom = hp(context, 0.035);
    final logoW = isPhone(context) ? wp(context, 0.55) : wp(context, 0.40);
    final logoH = logoW * (280 / 280);
    final barHeight = isPhone(context) ? 16.0 : 20.0;
    final barRadius = isPhone(context) ? 8.0 : 10.0;
    final titleSize = ts(context, 28);

    return maxWidthCenter(
      context: context,
      max: 720,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: spaceTop),
            SizedBox(
              width: logoW,
              height: logoH,
              child: Image.asset(
                'assets/images/subtract.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: spaceMid),
            _CustomLinearProgressIndicator(
              progressValue: null,
              height: barHeight,
              radius: barRadius,
            ),
            SizedBox(height: spaceBottom),
            PrimaryTitleText(
              text: 'Cargando\ntu experiencia... ',
              spacingText: 1,
              size: titleSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomLinearProgressIndicator extends StatelessWidget {
  const _CustomLinearProgressIndicator({
    this.progressValue,
    required this.height,
    required this.radius,
  });

  final double? progressValue;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color.fromRGBO(11, 25, 38, 1)),
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: LinearProgressIndicator(
          value: progressValue,
          color: const Color.fromRGBO(11, 25, 38, 1),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
    );
  }
}
