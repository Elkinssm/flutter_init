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

    final topSpacing = shp(context, 0.06);
    final bottomSafe = shp(context, 0.025);
    final padLeftLogo =
        isMediumTablet(context)
            ? swp(context, 0.0)
            : isLargeTablet(context)
            ? swp(context, 0.0)
            : swp(context, 0.05);
    final logoWidth =
        isPhone(context)
            ? swp(context, 0.41)
            : isBigPhone(context)
            ? swp(context, 0.42)
            : isMediumTablet(context)
            ? swp(context, 0.4)
            : isLargeTablet(context)
            ? swp(context, 0.2)
            : swp(context, 0.32);
    final skipTopPad =
        isSmallPhone(context) ? shp(context, 0.02) : shp(context, 0.02);
    final skipRightPad =
        isMediumTablet(context)
            ? swp(context, 0.14)
            : isLargeTablet(context)
            ? swp(context, 0.055)
            : swp(context, 0.025);
    final skipTP = shp(context, 0.018);
    final skipSize = ts(context, 17);
    final titleSize = ts(context, 50);
    final subtitleSize = ts(context, 29);
    final spacingDown1 = shp(context, 0.015);
    final indicatorHeight = shp(context, 0.01);
    final indicatorGap = isPhone(context) ? 6.0 : 8.0;
    final middleSpacing = shp(context, 0.1);
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
            itemBuilder:
                (_, i) => Image.asset(
                  images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
          ),
          maxWidthCenter(
            context: context,
            max: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: swp(context, 0.03)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: padLeftLogo),
                        child: Image.asset(
                          'assets/images/group5.png',
                          width: logoWidth,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          skipTopPad,
                          skipRightPad,
                          0,
                        ),
                        child: TextButton(
                          onPressed: () => context.push('/login_screen'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(top: skipTP),
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
                SizedBox(height: spacingDown1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == page;
                    final width =
                        active
                            ? (isPhone(context)
                                ? swp(context, 0.11)
                                : isBigPhone(context)
                                ? swp(context, 0.11)
                                : isMediumTablet(context)
                                ? swp(context, 0.10)
                                : isLargeTablet(context)
                                ? swp(context, 0.15)
                                : swp(context, 0.05))
                            : (isPhone(context)
                                ? swp(context, 0.034)
                                : isBigPhone(context)
                                ? swp(context, 0.035)
                                : isMediumTablet(context)
                                ? swp(context, 0.03)
                                : isLargeTablet(context)
                                ? swp(context, 0.04)
                                : swp(context, 0.05));
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
                Padding(
                  padding: EdgeInsets.only(bottom: bottomSafe),
                  child: Center(
                    child: SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: OnboardingNextButton(
                        action: () => context.push('/login_screen'),
                        text: 'Continuar',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
