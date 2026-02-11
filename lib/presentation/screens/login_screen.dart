import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/helpers/nav_loading.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/providers/session_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            child: const _LoginView(),
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
  bool isLoading = false;

  Future<void> _submit() async {
    if (!isButtonEnabled || isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();
    NavLoading.instance.begin(thresholdMs: 0);
    var loginSucceeded = false;

    setState(() {
      isLoading = true;
      isButtonEnabled = false;
    });

    try {
      final auth = await AuthService()
          .login(
            email: emailController.text.trim(),
            password: passwordController.text,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout:
                () =>
                    throw AuthException(
                      'El servidor no respondió a tiempo. Revisa que el backend esté encendido y la URL en Environment.',
                    ),
          );

      setUserRoleFromBackend(auth.user.rol);
      ref.read(currentUserRoleProvider.notifier).state = currentUserRole;
      final userRole = currentUserRole;
      if (!mounted) return;

      if (Environment.useBackend &&
          auth.token != null &&
          auth.token!.isNotEmpty) {
        await ref
            .read(sessionServiceProvider)
            .saveSession(
              token: auth.token!,
              user: auth.user,
              expiresAt: auth.expiresAt,
            )
            .timeout(const Duration(seconds: 5));
      }
      ref.read(currentUserProfileCompleteProvider.notifier).state =
          auth.user.profileComplete;
      final n = auth.user.nombre.trim();
      final a = auth.user.apellido.trim();
      final initials =
          (n.isNotEmpty && a.isNotEmpty)
              ? '${n[0]}${a[0]}'.toUpperCase()
              : (n.isNotEmpty ? n[0].toUpperCase() : '?');
      ref.read(currentUserInitialsProvider.notifier).state = initials;
      final displayName = '${auth.user.nombre} ${auth.user.apellido}'.trim();
      ref.read(currentUserDisplayNameProvider.notifier).state =
          displayName.isEmpty ? 'Usuario' : displayName;

      if (!auth.user.profileComplete && userRole == 'player') {
        ref.read(showProfileIncompleteModalProvider.notifier).state = true;
      }

      final destination =
          userRole == 'coach' ? '/coach_screen' : '/player_screen';
      loginSucceeded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavKey.currentContext;
        if (ctx != null && ctx.mounted) {
          GoRouter.of(ctx).go(destination);
          NavLoading.instance.end();
        } else {
          NavLoading.instance.end();
        }
      });
    } on AuthException catch (error) {
      NavLoading.instance.end();
      if (!mounted) return;
      CustomModal.show(
        context: context,
        title: 'Error de acceso',
        message: error.message,
        type: ModalType.error,
        buttonText: 'Entendido',
      );
    } catch (error, _) {
      NavLoading.instance.end();
      if (!mounted) return;
      CustomModal.showNetworkError(
        context,
        detail: error.toString().length > 80 ? null : error.toString(),
        onRetry: () => _submit(),
      );
    } finally {
      if (!loginSucceeded) {
        NavLoading.instance.end();
      }
      if (mounted) {
        setState(() {
          isLoading = false;
          _checkFields();
        });
      }
    }
  }

  Future<void> _submitTestLogin() async {
    if (isLoading) return;
    emailController.text = Environment.testLoginEmail;
    passwordController.text = Environment.testLoginPassword;
    _checkFields();
    await _submit();
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/image8.png'), context);
      precacheImage(const AssetImage('assets/images/group6.png'), context);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      isButtonEnabled =
          !isLoading &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
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
    final logoH = shp(context, 0.12);
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
                            Center(
                              child: SizedBox(
                                width: buttonW,
                                height: buttonH,
                                child: OnboardingNextButton(
                                  text: isLoading ? 'Cargando...' : 'Continuar',
                                  isEnabled: isButtonEnabled && !isLoading,
                                  action: _submit,
                                ),
                              ),
                            ),
                            if (!isKeyboardVisible) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: isLoading ? null : _submitTestLogin,
                                  child: const Text('Probar login rápido'),
                                ),
                              ),
                            ],
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
                                    padding: const EdgeInsets.only(left: 2),
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
