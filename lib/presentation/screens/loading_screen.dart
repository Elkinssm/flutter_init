import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatelessWidget {
  static const String name = 'loading_screen';
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _LoadingView());
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Color.fromRGBO(255, 255, 255, 1),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/subtract.png', height: 280),
                SizedBox(height: 20),
                _ControllerProgressIndicator(),
                SizedBox(height: 20),
                PrimaryTitleText(text: 'Cargando\ntu experiencia . . . '),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControllerProgressIndicator extends StatelessWidget {
  const _ControllerProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 125), (value) {
        final progress = (value % 51) / 50;
        return progress;
      }).takeWhile((value) => value < 100),
      builder: (context, snapshot) {
        final progressValue = snapshot.data ?? 0;
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (progressValue >= 1.0) {
          Future.delayed(const Duration(milliseconds: 1), () {
            if (context.mounted) {
              context.go('/welcome_screen');
            }
          });
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _CustomLinearProgressIndicator(progressValue: progressValue),
        );
      },
    );
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
        color: Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color.fromRGBO(11, 25, 38, 1)),
      ),
      padding: const EdgeInsets.all(1),
      child: LinearProgressIndicator(
        value: progressValue,
        color: Color.fromRGBO(11, 25, 38, 1),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
