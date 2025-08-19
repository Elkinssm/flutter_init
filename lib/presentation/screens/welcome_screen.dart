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

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller,
          physics: const ClampingScrollPhysics(),
          itemCount: images.length,
          onPageChanged: (i) => ref.read(pageIndexProvider.notifier).state = i,
          itemBuilder: (_, i) => Image.asset(images[i], fit: BoxFit.cover),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/group5.png', width: 155),
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
                      child: const Text(
                        'Omitir',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 75),
              Center(child: CustomTitleText(text: 'Bienvenido', size: 55)),
              Spacer(),
              Center(
                child: CustomTitleText(
                  text: 'Toda la informacion\n en un solo lugar',
                  size: 34,
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
        ),
      ],
    );
  }
}

//******************************************************************************** */
          // child: Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Image.asset('assets/images/group5.png', height: 26),
          //           TextButton(
          //             onPressed: () => context.push('/login_screen'),
          //             style: TextButton.styleFrom(
          //               padding: EdgeInsets.zero,
          //               minimumSize: Size.zero,
          //               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             ),
          //             child: const Text(
          //               'Omitir',
          //               style: TextStyle(color: Colors.white),
          //             ),
          //           ),
          //         ],
          //       ),
          //       const Spacer(),
          //       const Text(
          //         'Bienvenido',
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 48,
          //           fontWeight: FontWeight.w800,
          //         ),
          //       ),
          //       const SizedBox(height: 12),
          //       const Text(
          //         'Toda la información\nen un solo lugar',
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 24,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //       const SizedBox(height: 24),

          //       // Indicador (pastilla + puntos)
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: List.generate(images.length, (i) {
          //           final active = i == page;
          //           return AnimatedContainer(
          //             duration: const Duration(milliseconds: 250),
          //             margin: const EdgeInsets.symmetric(horizontal: 6),
          //             width: active ? 42 : 10,
          //             height: 10,
          //             decoration: BoxDecoration(
          //               color: indicatorColor,
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //           );
          //         }),
          //       ),

          //       const SizedBox(height: 16),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 20),
          //         child: SizedBox(
          //           height: 48,
          //           child: ElevatedButton(
          //             onPressed: nextOrFinish,
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: indicatorColor,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //             child: Text(
          //               page == images.length - 1 ? 'Continuar' : 'Siguiente',
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(height: 20),
          //     ],
          //   ),
          // ),



// ****************************************************************************************
    // return Container(
    //   decoration: const BoxDecoration(
    //     image: DecorationImage(
    //       image: AssetImage('assets/images/image7.png'),
    //       fit: BoxFit.cover,
    //     ),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       SizedBox(height: 10),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Image.asset('assets/images/group5.png'),
    //             Padding(
    //               padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
    //               child: TextButton(
    //                 onPressed: () {
    //                   context.push('/login_screen');
    //                 },
    //                 style: TextButton.styleFrom(
    //                   padding: EdgeInsets.zero,
    //                   minimumSize: Size(0, 0),
    //                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //                 ),
    //                 child: const Text(
    //                   'Omitir',
    //                   style: TextStyle(color: Colors.white),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       SizedBox(height: 40),
    //       Center(child: CustomTitleText(text: 'Bienvenido', size: 64)),
    //       Spacer(),
    //       Center(
    //         child: CustomTitleText(
    //           text: 'Toda la informacion\n en un solo lugar',
    //           size: 36,
    //         ),
    //       ),
    //       SizedBox(height: 20),
    //       OnboardingNextButton(
    //         action: () => context.push('/login_screen'),
    //         text: 'Continuar',
    //       ),
    //       SizedBox(height: 40),
    //     ],
    //   ),
    // );