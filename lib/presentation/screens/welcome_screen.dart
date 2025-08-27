import 'package:coach_app/presentation/providers/carousel_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

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
    final controller = ref.watch(pageControllerProvider);
    final page = ref.watch(pageIndexProvider);
    final images = const [
      'assets/images/image7.png',
      'assets/images/image7.png',
      'assets/images/image7.png',
    ];

    final topSafe = MediaQuery.of(context).padding.top;

    final logoWidth = isPhone(context) ? wp(context, 0.42) : wp(context, 0.28);
    final skipRightPad = isPhone(context) ? 15.0 : 24.0;

    final titleSize = ts(context, 50);
    final subtitleSize = ts(context, 30);
    final skipSize = ts(context, 14);
    final indicatorHeight = isPhone(context) ? 8.0 : 10.0;
    final indicatorGap = isPhone(context) ? 6.0 : 8.0;

    final topSpacing = hp(context, 0.027) + topSafe;
    final middleSpacing = hp(context, 0.093);
    final bottomSpacing = hp(context, 0.03);

    final buttonWidth =
        isPhone(context) ? wp(context, 0.56) : wp(context, 0.40);
    final buttonHeight = isPhone(context) ? 45.0 : 52.0;

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
          maxWidthCenter(
            context: context,
            max: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: wp(context, 0.03)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Image.asset(
                          'assets/images/group5.png',
                          width: logoWidth,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, skipRightPad, 0),
                        child: TextButton(
                          onPressed: () => context.push('/login_screen'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: PrimaryTitleText(
                            text: 'Omitir',
                            size: skipSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: middleSpacing),
                Center(
                  child: CustomTitleText(text: 'Bienvenido', size: titleSize),
                ),
                const Spacer(),
                Center(
                  child: CustomTitleText(
                    text: 'Toda la información\n en un solo lugar',
                    size: subtitleSize,
                  ),
                ),
                SizedBox(height: hp(context, 0.02)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == page;
                    final width =
                        active
                            ? (isPhone(context) ? 42.0 : 54.0)
                            : (isPhone(context) ? 10.0 : 12.0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: EdgeInsets.symmetric(horizontal: indicatorGap),
                      width: width,
                      height: indicatorHeight,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(217, 73, 41, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),
                SizedBox(height: hp(context, 0.02)),
                Center(
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: OnboardingNextButton(
                      action: () => context.push('/login_screen'),
                      text: 'Continuar',
                    ),
                  ),
                ),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
