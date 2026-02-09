import 'dart:ui';

import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:coach_app/presentation/helpers/nav_loading.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/providers/session_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _backgroundImageReady = false;
  bool _isLoading = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      // Precargar imágenes (no necesitan await)
      precacheImage(const AssetImage('assets/images/group6.png'), context);
      await precacheImage(
        const AssetImage('assets/images/register.jpg'),
        context,
      );
      if (!mounted) return;
      setState(() => _backgroundImageReady = true);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // En modo local (sin backend) cualquier email con formato válido puede registrarse.
  // No es necesario limitar a una lista fija ya que son datos mock.

  @override
  Widget build(BuildContext context) {
    if (!_backgroundImageReady) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        body: Center(child: AppLoadingContent()),
      );
    }

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
                                  text:
                                      _isLoading
                                          ? 'Cargando...'
                                          : 'Registrarse',
                                  isEnabled: isButtonEnabled && !_isLoading,
                                  action: () async {
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
                                    if (!email.contains('@') ||
                                        !email.contains('.')) {
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

                                    // Tanto con backend como en modo local, llamamos AuthService.register
                                    // (que internamente usa mock si useBackend == false).
                                    setState(() => _isLoading = true);
                                    try {
                                      final auth = await AuthService().register(
                                        email: email,
                                        password: password,
                                        passwordConfirmation: password,
                                      );
                                      if (!mounted) return;
                                      if (auth.token != null &&
                                          auth.token!.isNotEmpty) {
                                        await ref
                                            .read(sessionServiceProvider)
                                            .saveSession(
                                              token: auth.token!,
                                              user: auth.user,
                                              expiresAt: auth.expiresAt,
                                            );
                                      }
                                      setUserRoleFromBackend(auth.user.rol);
                                      ref
                                          .read(
                                            currentUserProfileCompleteProvider
                                                .notifier,
                                          )
                                          .state = auth.user.profileComplete;
                                      final n = auth.user.nombre.trim();
                                      final a = auth.user.apellido.trim();
                                      final initials =
                                          (n.isNotEmpty && a.isNotEmpty)
                                              ? '${n[0]}${a[0]}'.toUpperCase()
                                              : (n.isNotEmpty
                                                  ? n[0].toUpperCase()
                                                  : '?');
                                      ref
                                          .read(
                                            currentUserInitialsProvider
                                                .notifier,
                                          )
                                          .state = initials;
                                      final displayName =
                                          '${auth.user.nombre} ${auth.user.apellido}'
                                              .trim();
                                      ref
                                          .read(
                                            currentUserDisplayNameProvider
                                                .notifier,
                                          )
                                          .state = displayName.isEmpty
                                              ? 'Usuario'
                                              : displayName;
                                      if (!auth.user.profileComplete &&
                                          currentUserRole == 'player') {
                                        ref
                                            .read(
                                              showProfileIncompleteModalProvider
                                                  .notifier,
                                            )
                                            .state = true;
                                      }
                                      final destination =
                                          !auth.user.profileComplete &&
                                                  currentUserRole == 'player'
                                              ? '/new_player_screen'
                                              : '/player_screen';
                                      if (!context.mounted) return;
                                      context.go(destination);
                                    } on AuthException catch (e) {
                                      if (!context.mounted) return;
                                      CustomModal.show(
                                        context: context,
                                        title: 'Error de registro',
                                        message: e.message,
                                        type: ModalType.error,
                                        buttonText: 'Entendido',
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      CustomModal.showNetworkError(
                                        context,
                                        detail:
                                            e.toString().length > 80
                                                ? null
                                                : e.toString(),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: bottomCTA),
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

  static const _overlayOrange = Color.fromRGBO(217, 73, 41, 1);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Gradiente naranja como base (se ve de inmediato, sin parpadeo)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(0, 0, 0, 0), _overlayOrange],
                  stops: [0.0, 1.8],
                  begin: Alignment.center,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // 2) Imagen con fade-in cuando termina de cargar (evita “color primero, imagen después”)
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                'assets/images/register.jpg',
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null && !wasSynchronouslyLoaded) {
                    return const SizedBox.shrink();
                  }
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder:
                        (context, value, child) =>
                            Opacity(opacity: value, child: child),
                    child: child,
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: const Color.fromRGBO(0, 0, 0, 0.08)),
              ),
            ),
          ),
          // 3) Overlay naranja encima para unificar el tono
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(0, 0, 0, 0), _overlayOrange],
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
