import 'package:coach_app/presentation/providers/loading_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  static const String name = '/loading_screen';
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(loadingProvider.notifier).initializeApp(context);
      if (mounted) context.go('/welcome_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(loadingProvider);
    final effectiveProgress =
        (progress < _controller.value) ? _controller.value : progress;

    final sidePad = wp(context, isPhone(context) ? 0.06 : 0.08);
    final spaceTop = hp(context, 0.04);
    final spaceMid = hp(context, 0.025);
    final spaceBottom = hp(context, 0.035);
    final logoW = isPhone(context) ? wp(context, 0.55) : wp(context, 0.40);
    final logoH = logoW * (280 / 280);
    final barHeight = isPhone(context) ? 16.0 : 20.0;
    final barRadius = isPhone(context) ? 8.0 : 10.0;
    final titleSize = ts(context, 28);

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Center(
          child: Container(
            color: const Color.fromRGBO(255, 255, 255, 1),
            child: maxWidthCenter(
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
                      progressValue: effectiveProgress,
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CustomLinearProgressIndicator extends StatelessWidget {
  const _CustomLinearProgressIndicator({
    required this.progressValue,
    required this.height,
    required this.radius,
  });

  final double progressValue;
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
