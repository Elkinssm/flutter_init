import 'package:coach_app/presentation/helpers/nav_loading.dart';
import 'package:coach_app/presentation/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  static const String name = '/loading_screen';
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final minSplash = Future<void>.delayed(
        const Duration(milliseconds: 1900),
      );
      final init = ref.read(loadingProvider.notifier).initializeApp(context);
      await Future.wait([init, minSplash]);
      if (mounted) context.go('/welcome_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: const AppLoadingContent(),
      ),
    );
  }
}
