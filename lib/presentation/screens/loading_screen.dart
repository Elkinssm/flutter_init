import 'package:coach_app/presentation/providers/loading_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  static const String name = 'loading_screen';
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

    return Scaffold(
      body: Center(
        child: Container(
          color: const Color.fromRGBO(255, 255, 255, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/subtract.png', cacheHeight: 280),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _CustomLinearProgressIndicator(
                  progressValue: effectiveProgress,
                ),
              ),
              const SizedBox(height: 20),
              const PrimaryTitleText(
                text: 'Cargando\ntu experiencia... ',
                spacingText: 1,
              ),
            ],
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
  const _CustomLinearProgressIndicator({required this.progressValue});

  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color.fromRGBO(11, 25, 38, 1)),
      ),
      padding: const EdgeInsets.all(1),
      child: LinearProgressIndicator(
        value: progressValue,
        color: const Color.fromRGBO(11, 25, 38, 1),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
