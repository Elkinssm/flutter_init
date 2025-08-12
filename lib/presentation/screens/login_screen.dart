import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _LoginView(),
      ),
    );
  }
}

class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKeyboardVisible = ref.watch(keyboardVisibilityProvider);

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SizedBox(
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
              ),
              SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 25),
                        Image.asset('assets/images/group6.png'),
                        const SizedBox(height: 30),
                        CustomTitleText(text: 'Descubrir más', size: 48),
                        const SizedBox(height: 70),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              LabelText(
                                label: 'Correo electrónico',
                                colorIndex: 0,
                              ),
                              CustomTextFormField(
                                hintText: 'subject@example.com',
                                icon: Icons.mail_outline_sharp,
                              ),
                              const SizedBox(height: 25),
                              LabelText(label: 'Contraseña', colorIndex: 0),
                              CustomTextFormField(
                                hintText: '********',
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        isKeyboardVisible
                            ? const SizedBox(height: 62)
                            : const Spacer(),
                        OnboardingNextButton(
                          text: 'Continuar',
                          action: () => context.push('/coach_screen'),
                        ),
                        const SizedBox(height: 70),
                        Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomSubtitleText(
                              text: '¿No tienes una cuenta?',
                              color: 0,
                            ),
                            TextButton(
                              onPressed: () => context.push('/register_screen'),
                              child: CustomSubtitleText(
                                text: 'Regístrate aquí',
                                color: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                      ],
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
