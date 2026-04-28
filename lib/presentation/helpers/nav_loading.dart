import 'dart:async';
import 'dart:math' as math;
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart';

class NavLoading {
  NavLoading._();
  static final NavLoading instance = NavLoading._();

  OverlayEntry? _entry;
  Timer? _delayTimer;
  Timer? _hideTimer;
  bool _requested = false;
  DateTime? _shownAt;
  int _minVisibleMs = 700;

  void begin({int thresholdMs = 150, int minVisibleMs = 700}) {
    _cancelDelay();
    _cancelHide();
    _requested = true;
    _minVisibleMs = minVisibleMs;
    if (thresholdMs <= 0) {
      _show();
      return;
    }
    _delayTimer = Timer(Duration(milliseconds: thresholdMs), _show);
  }

  void end() {
    _requested = false;
    _cancelDelay();
    final entry = _entry;
    if (entry == null) return;

    final shownAt = _shownAt;
    final elapsed =
        shownAt == null ? _minVisibleMs : DateTime.now().difference(shownAt).inMilliseconds;
    final remaining = _minVisibleMs - elapsed;
    if (remaining > 0) {
      _cancelHide();
      _hideTimer = Timer(Duration(milliseconds: remaining), _remove);
      return;
    }
    _remove();
  }

  void _show() {
    if (!_requested || _entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => const _SplashOverlay(),
    );
    rootNavKey.currentState?.overlay?.insert(_entry!);
    _shownAt = DateTime.now();
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
    _shownAt = null;
  }

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
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
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: const SizedBox.expand(
          child: AppLoadingContent(),
        ),
      ),
    );
  }
}

/// Componente de loading de la app. Reutilizable para splash y overlay global.
class AppLoadingContent extends StatefulWidget {
  const AppLoadingContent({super.key});

  @override
  State<AppLoadingContent> createState() => _AppLoadingContentState();
}

class _AppLoadingContentState extends State<AppLoadingContent>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      _motionController.repeat(period: const Duration(milliseconds: 1400));
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sidePad = wp(context, isPhone(context) ? 0.06 : 0.08);
    final logoW = isPhone(context) ? wp(context, 0.52) : wp(context, 0.38);
    final titleSize = ts(context, 34);
    final subtitleSize = ts(context, 19);

    return maxWidthCenter(
      context: context,
      max: 720,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        child: Column(
          children: [
            const Spacer(flex: 5),
            FadeTransition(
              opacity: _entranceController,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1).animate(
                  CurvedAnimation(
                    parent: _entranceController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Column(
                  children: [
                    _MovingPlayerLogo(
                      controller: _motionController,
                      width: logoW,
                    ),
                    SizedBox(height: hp(context, 0.055)),
                    Text(
                      'Preparando\ntu equipo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF0B1926),
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: hp(context, 0.025)),
                    Text(
                      'Organizando todo para que tengas\nla mejor experiencia.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}

class _MovingPlayerLogo extends StatelessWidget {
  const _MovingPlayerLogo({required this.controller, required this.width});

  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final phase = t * math.pi * 2;
        final stride = math.sin(phase);
        final stepLift = (1 - math.cos(phase * 2)) / 2;
        final sway = stride * 8.0;
        final lift = -5.0 * stepLift;
        final rotation = stride * 0.055;
        final squash = 1 - (0.018 * stepLift);
        final stretch = 1 + (0.014 * stepLift);
        final shadowWidth = width * (0.42 - (0.05 * stepLift));
        final shadowOpacity = 0.14 - (0.035 * stepLift);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(sway, lift),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scaleX: stretch,
                  scaleY: squash,
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: hp(context, 0.018)),
            Container(
              width: shadowWidth,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    const Color.fromRGBO(
                      217,
                      73,
                      41,
                      1,
                    ).withValues(alpha: shadowOpacity),
                    const Color.fromRGBO(217, 73, 41, 0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
