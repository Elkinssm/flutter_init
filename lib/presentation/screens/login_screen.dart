import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class LoginScreen extends StatelessWidget {
  static const String name = '/login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: _LoginView(),
        ),
      ),
    );
  }
}

class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKeyboardVisible = ref.watch(keyboardVisibilityProvider);

    final sidePad = wp(context, isPhone(context) ? 0.06 : 0.08);
    final topLogoSpace =
        isKeyboardVisible ? hp(context, 0.03) : hp(context, 0.06);
    final afterLogoSpace =
        isKeyboardVisible ? hp(context, 0.03) : hp(context, 0.05);
    final afterTitleSpace =
        isKeyboardVisible ? hp(context, 0.04) : hp(context, 0.07);
    final betweenFields = hp(context, 0.022);
    final bottomCTA = isKeyboardVisible ? hp(context, 0.02) : hp(context, 0.05);

    final logoH = isPhone(context) ? hp(context, 0.08) : hp(context, 0.10);
    final titleSize = ts(context, 40);
    final buttonW = isPhone(context) ? wp(context, 0.56) : wp(context, 0.42);
    final buttonH = isPhone(context) ? 45.0 : 52.0;
    final fieldH = isPhone(context) ? 46.0 : 52.0;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const _Background(),
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: maxWidthCenter(
                      context: context,
                      max: 720,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sidePad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: topLogoSpace),
                            Center(
                              child: Image.asset(
                                'assets/images/group6.png',
                                height: logoH,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: afterLogoSpace),
                            CustomTitleText(
                              text: 'Descubrir más',
                              size: titleSize,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: afterTitleSpace),
                            Column(
                              children: [
                                const LabelText(
                                  label: 'Correo electrónico',
                                  colorIndex: 0,
                                ),
                                SizedBox(
                                  height: fieldH,
                                  child: const CustomTextFormField(
                                    hintText: 'test@gmail.com',
                                    icon: Icons.mail_outline_sharp,
                                  ),
                                ),
                                SizedBox(height: betweenFields),
                                const LabelText(
                                  label: 'Contraseña',
                                  colorIndex: 0,
                                ),
                                SizedBox(
                                  height: fieldH,
                                  child: const CustomTextFormField(
                                    hintText: '**********',
                                    obscureText: true,
                                    isPassword: true,
                                  ),
                                ),
                              ],
                            ),
                            if (!isKeyboardVisible)
                              const Spacer()
                            else
                              SizedBox(height: hp(context, 0.04)),
                            Center(
                              child: SizedBox(
                                width: buttonW,
                                height: buttonH,
                                child: OnboardingNextButton(
                                  text: 'Continuar',
                                  action: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    context.push('/coach_screen');
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: bottomCTA),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSubtitleText(
                                  text: '¿No tienes una cuenta?',
                                  color: 0,
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.only(left: 2),
                                  ),
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    context.push('/register_screen');
                                  },
                                  child: CustomSubtitleText(
                                    text: 'Regístrate aquí',
                                    color: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                'assets/images/image8.png',
                fit: BoxFit.cover,
                cacheWidth: MediaQuery.of(context).size.width.toInt(),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0),
                    Color.fromRGBO(217, 73, 41, 1),
                  ],
                  stops: [0.0, 1.8],
                  begin: Alignment.center,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
