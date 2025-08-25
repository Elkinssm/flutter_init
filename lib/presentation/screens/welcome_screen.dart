import 'package:coach_app/presentation/providers/carousel_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  static const String name = 'tutorial_screen';
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _WelcomeView());
  }
}

class _WelcomeView extends ConsumerWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // const indicatorColor = Color(0xFFE45738);
    final controller = ref.watch(pageControllerProvider);
    final page = ref.watch(pageIndexProvider);
    final images = const [
      'assets/images/image7.png',
      'assets/images/image7.png',
      'assets/images/image7.png',
    ];

    return SafeArea(
      top: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            itemCount: images.length,
            onPageChanged:
                (i) => ref.read(pageIndexProvider.notifier).state = i,
            itemBuilder: (_, i) => Image.asset(images[i], fit: BoxFit.cover),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 47),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Image.asset('assets/images/group5.png', width: 155),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 15, 0),
                    child: TextButton(
                      onPressed: () {
                        context.push('/login_screen');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(top: 10),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: PrimaryTitleText(
                        text: 'Omitir',
                        size: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 85),
              Center(child: CustomTitleText(text: 'Bienvenido', size: 50)),
              Spacer(),
              Center(
                child: CustomTitleText(
                  text: 'Toda la información\n en un solo lugar',
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: active ? 42 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(217, 73, 41, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              OnboardingNextButton(
                action: () => context.push('/login_screen'),
                text: 'Continuar',
              ),
              const SizedBox(height: 25),
            ],
          ),
        ],
      ),
    );
  }
}
