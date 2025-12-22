import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'dart:ui';

class RegisterScreen extends StatelessWidget {
  static const String name = '/register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            context.go('/login_screen');
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: const _RegisterView(),
          ),
        ),
      ),
    );
  }
}

class _RegisterView extends ConsumerStatefulWidget {
  const _RegisterView();

  @override
  ConsumerState<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<_RegisterView> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/register.jpg'), context);
      precacheImage(const AssetImage('assets/images/group6.png'), context);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Diccionario de correos permitidos para simular registro sin backend
  bool _isEmailAllowed(String email) {
    const allowedEmails = {
      'valid@mail.com',
      'demo@mail.com',
      'test@mail.com',
    };
    return allowedEmails.contains(email.toLowerCase().trim());
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
    final logoH =
        isLargeTablet(context)
            ? shp(context, 0.12)
            : isMediumTablet(context)
            ? shp(context, 0.12)
            : shp(context, 0.11);
    final titleSize =
        isLargeTablet(context)
            ? ts(context, 42)
            : isMediumTablet(context)
            ? ts(context, 38)
            : ts(context, 32);
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
                            // Botón de retroceso
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => context.go('/login_screen'),
                                ),
                              ],
                            ),
                            SizedBox(height: shp(context, 0.02)),
                            // Logo y título
                            Center(
                              child: Image.asset(
                                'assets/images/group6.png',
                                height: logoH,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: afterLogoSpace),
                            CustomTitleText(
                              text: 'Crear tu cuenta',
                              size: titleSize,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: afterTitleSpace),
                            // Campos de formulario
                            Column(
                              children: [
                                const LabelText(
                                  label: 'Correo Electrónico',
                                  colorIndex: 0,
                                ),
                                SizedBox(
                                  height: fieldH,
                                  child: CustomTextFormField(
                                    controller: emailController,
                                    hintText: 'ejemplo@correo.com',
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
                                    hintText: 'Ingresa tu Contraseña',
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
                            // Botón de registro
                            Center(
                              child: SizedBox(
                                width: buttonW,
                                height: buttonH,
                                child: OnboardingNextButton(
                                  text: 'Registrarse',
                                  isEnabled: isButtonEnabled,
                                  action: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;

                                    // Validar campos vacíos
                                    if (email.isEmpty || password.isEmpty) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Campos requeridos',
                                        message:
                                            'Por favor completa todos los campos.',
                                        type: ModalType.warning,
                                        buttonText: 'Entendido',
                                      );
                                      return;
                                    }

                                    // Validar formato de email básico
                                    if (!email.contains('@') || !email.contains('.')) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Email inválido',
                                        message:
                                            'Por favor ingresa un email válido.',
                                        type: ModalType.warning,
                                        buttonText: 'Entendido',
                                      );
                                      return;
                                    }

                                    // Validar contraseña mínima
                                    if (password.length < 6) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Contraseña muy corta',
                                        message:
                                            'La contraseña debe tener al menos 6 caracteres.',
                                        type: ModalType.warning,
                                        buttonText: 'Entendido',
                                      );
                                      return;
                                    }

                                    // Validar si el email está permitido
                                    final isAllowed = _isEmailAllowed(email);
                                    if (!isAllowed) {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Registro no permitido',
                                        message:
                                            'El email ingresado no está permitido para registro. Por favor contacta al administrador.',
                                        type: ModalType.error,
                                        buttonText: 'Entendido',
                                      );
                                      return;
                                    }

                                    // Si pasa todas las validaciones, registrar
                                    // Mostrar mensaje de éxito y navegar
                                    CustomModal.show(
                                      context: context,
                                      title: 'Registro exitoso',
                                      message:
                                          'Tu cuenta ha sido registrada correctamente. Bienvenido!',
                                      type: ModalType.success,
                                      buttonText: 'Continuar',
                                      onButtonPressed: () {
                                        Navigator.of(context).pop();
                                        context.go('/login_screen');
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: bottomCTA),
                            // Mensaje informativo
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: swp(context, 0.05)),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: shp(context, 0.016),
                                  horizontal: swp(context, 0.04),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: CustomSubtitleText(
                                    text: 'Una vez registrado, te pediremos completar tus datos para acceder a todas las funciones.',
                                    color: 3,
                                  ),
                                ),
                              ),
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
              child: Image.asset('assets/images/register.jpg', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.08)),
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

