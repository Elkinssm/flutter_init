import 'package:coach_app/config/router/app_router.dart';
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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            context.go('/welcome_screen');
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _LoginView(),
          ),
        ),
      ),
    );
  }
}

class _LoginView extends ConsumerStatefulWidget {
  const _LoginView();

  @override
  ConsumerState<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<_LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isButtonEnabled = false;

  void _checkFields() {
    setState(() {
      isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = ref.watch(keyboardVisibilityProvider);

    final sidePad =
        isLargeTablet(context) ? swp(context, 0.01) : swp(context, 0.08);
    final topLogoSpace =
        isKeyboardVisible ? shp(context, 0.03) : shp(context, 0.07);
    final afterLogoSpace =
        isKeyboardVisible ? shp(context, 0.03) : shp(context, 0.05);
    final afterTitleSpace =
        isKeyboardVisible ? shp(context, 0.04) : shp(context, 0.07);
    final betweenFields = shp(context, 0.022);
    final bottomCTA =
        isKeyboardVisible ? shp(context, 0.02) : shp(context, 0.05);
    final logoH = isPhone(context) ? shp(context, 0.12) : shp(context, 0.12);
    final titleSize = ts(context, 39.5);
    final buttonW =
        isPhone(context)
            ? swp(context, 0.43)
            : isBigPhone(context)
            ? swp(context, 0.43)
            : isLargeTablet(context)
            ? swp(context, 0.35)
            : isMediumTablet(context)
            ? swp(context, 0.35)
            : swp(context, 0.40);
    final buttonH = shp(context, 0.048);
    final fieldH = shp(context, 0.052);
    final bottomSpace =
        isPhone(context)
            ? shp(context, 0.001)
            : isBigPhone(context)
            ? shp(context, 0.001)
            : shp(context, 0.01);

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
                                  child: CustomTextFormField(
                                    controller: emailController,
                                    hintText: 'usuario@ejemplo.com',
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
                                  child: CustomTextFormField(
                                    controller: passwordController,
                                    hintText: 'Ingresa tu contraseña',
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
                                  isEnabled: isButtonEnabled,
                                  action: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                            
                                    if (!_isEmailRegistered(
                                      emailController.text,
                                    )) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Email no registrado',
                                        message:
                                            'El email ingresado no está registrado en el sistema. ¿Te gustaría registrarte?',
                                        type: ModalType.error,
                                        buttonText: 'Registrarse',
                                        onButtonPressed: () {
                                          Navigator.of(context).pop();
                                          context.push('/register_screen');
                                        },
                                      );
                                      return;
                                    }

                                    // Verificar si la contraseña no está vacía
                                    if (passwordController.text.isEmpty) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Contraseña requerida',
                                        message:
                                            'Por favor ingresa tu contraseña para continuar.',
                                        type: ModalType.warning,
                                        buttonText: 'Entendido',
                                      );
                                      return;
                                    }

                                    // Establecer el rol del usuario solo si está registrado
                                    setUserRole(emailController.text);

                              
                                    final userRole = currentUserRole;
                                    if (userRole == 'coach') {
                                      context.push('/coach_screen');
                                    } else {
                                      context.push('/player_screen');
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: bottomCTA),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSubtitleText(
                                  text: '¿No tienes cuenta?',
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
                            SizedBox(height: bottomSpace),
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

  // Función para verificar si un email está registrado
  bool _isEmailRegistered(String email) {
    final Map<String, String> registeredEmails = {
      'admin@mail.com': 'coach',
      'coach@mail.com': 'coach',
      'entrenador@mail.com': 'coach',
      'player1@mail.com': 'player',
      'player2@mail.com': 'player',
      'jugador@mail.com': 'player',
    };
    return registeredEmails.containsKey(email.toLowerCase());
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
              child: Image.asset('assets/images/image8.png', fit: BoxFit.cover),
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
