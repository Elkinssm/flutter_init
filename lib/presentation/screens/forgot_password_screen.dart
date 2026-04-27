import 'dart:ui';

import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

enum _ResetStep { email, code, password, success }

class ForgotPasswordScreen extends StatefulWidget {
  static const String name = '/forgot_password_screen';
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _brand = Color.fromRGBO(217, 73, 41, 1);
  static const _text = Color(0xFF0B1926);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _success = Color(0xFF43A047);

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _auth = AuthService();

  _ResetStep _step = _ResetStep.email;
  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail?.trim() ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();
  String get _code => _codeController.text.trim();
  String get _password => _passwordController.text;
  String get _confirm => _confirmController.text;

  Future<void> _requestCode() async {
    if (_loading) return;
    if (!_isValidEmail(_email)) {
      _showError('Correo inválido', 'Ingresa un correo electrónico válido.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.forgotPassword(email: _email);
      if (!mounted) return;
      setState(() => _step = _ResetStep.code);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError('No se pudo enviar el código', error.message);
    } catch (_) {
      if (!mounted) return;
      _showError(
        'Sin conexión',
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_loading) return;
    if (_code.length != 6) {
      _showError('Código inválido', 'Ingresa el código de 6 dígitos.');
      return;
    }
    setState(() => _loading = true);
    try {
      final valid = await _auth.verifyResetCode(email: _email, code: _code);
      if (!mounted) return;
      if (!valid) {
        _showError(
          'Código inválido',
          'El código de recuperación ha expirado o es inválido.',
        );
        return;
      }
      setState(() => _step = _ResetStep.password);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError('Código inválido', error.message);
    } catch (_) {
      if (!mounted) return;
      _showError(
        'Sin conexión',
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePassword() async {
    if (_loading) return;
    if (_password.length < 8) {
      _showError(
        'Contraseña insegura',
        'La contraseña debe tener al menos 8 caracteres.',
      );
      return;
    }
    if (_password != _confirm) {
      _showError(
        'Las contraseñas no coinciden',
        'Confirma la contraseña exactamente igual.',
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.resetPassword(
        email: _email,
        code: _code,
        password: _password,
        passwordConfirmation: _confirm,
      );
      if (!mounted) return;
      setState(() => _step = _ResetStep.success);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError('No se pudo cambiar la contraseña', error.message);
    } catch (_) {
      if (!mounted) return;
      _showError(
        'Sin conexión',
        'No se pudo conectar con el servidor. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String title, String message) {
    CustomModal.show(
      context: context,
      title: title,
      message: message,
      type: ModalType.error,
      buttonText: 'Entendido',
    );
  }

  void _goLogin() => context.go('/login_screen');

  void _back() {
    if (_loading) return;
    switch (_step) {
      case _ResetStep.email:
        context.pop();
        break;
      case _ResetStep.code:
        setState(() => _step = _ResetStep.email);
        break;
      case _ResetStep.password:
        setState(() => _step = _ResetStep.code);
        break;
      case _ResetStep.success:
        _goLogin();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _RecoveryBackground()),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: swp(context, 0.045),
                        vertical: 18,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 520,
                          minHeight: constraints.maxHeight * 0.78,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                                blurRadius: 30,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: swp(context, 0.045),
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                _TopBar(
                                  onBack: _back,
                                  showBack: _step != _ResetStep.success,
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: _buildStep(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _ResetStep.email:
        return _EmailStep(
          key: const ValueKey('email'),
          emailController: _emailController,
          loading: _loading,
          onSubmit: _requestCode,
          onCancel: _goLogin,
        );
      case _ResetStep.code:
        return _CodeStep(
          key: const ValueKey('code'),
          email: _email,
          codeController: _codeController,
          loading: _loading,
          onVerify: _verifyCode,
          onResend: _requestCode,
          onLogin: _goLogin,
        );
      case _ResetStep.password:
        return _PasswordStep(
          key: const ValueKey('password'),
          passwordController: _passwordController,
          confirmController: _confirmController,
          loading: _loading,
          showPassword: _showPassword,
          showConfirm: _showConfirm,
          onTogglePassword: () => setState(() => _showPassword = !_showPassword),
          onToggleConfirm: () => setState(() => _showConfirm = !_showConfirm),
          onSubmit: _savePassword,
        );
      case _ResetStep.success:
        return _SuccessStep(key: const ValueKey('success'), onLogin: _goLogin);
    }
  }

  static bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}

class _RecoveryBackground extends StatelessWidget {
  const _RecoveryBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/image8.png', fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(6, 17, 28, 0.72),
                  Color.fromRGBO(217, 73, 41, 0.58),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.showBack});

  final VoidCallback onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Image.asset('assets/images/group6.png', height: 42),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    super.key,
    required this.emailController,
    required this.loading,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController emailController;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Recuperar contraseña',
      subtitle:
          'Ingresa tu correo electrónico y te enviaremos un código para restablecer tu contraseña.',
      children: [
        const _FieldLabel('Correo electrónico'),
        _Input(
          controller: emailController,
          hintText: 'usuario@ejemplo.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 26),
        _PrimaryButton(
          text: loading ? 'Enviando...' : 'Enviar código',
          onPressed: loading ? null : onSubmit,
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: loading ? null : onCancel,
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    super.key,
    required this.email,
    required this.codeController,
    required this.loading,
    required this.onVerify,
    required this.onResend,
    required this.onLogin,
  });

  final String email;
  final TextEditingController codeController;
  final bool loading;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: const _StatusIcon(icon: Icons.mark_email_read_outlined),
      title: 'Código enviado',
      subtitle:
          'Te enviamos un código de 6 dígitos para restablecer tu contraseña.',
      children: [
        _EmailBadge(email: email),
        const SizedBox(height: 20),
        const _FieldLabel('Código de recuperación'),
        _Input(
          controller: codeController,
          hintText: '123456',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          text: loading ? 'Validando...' : 'Validar código',
          onPressed: loading ? null : onVerify,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: loading ? null : onResend,
          child: const Text('Reenviar código'),
        ),
        TextButton(
          onPressed: loading ? null : onLogin,
          child: const Text('Volver al inicio de sesión'),
        ),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.loading,
    required this.showPassword,
    required this.showConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool loading;
  final bool showPassword;
  final bool showConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Nueva contraseña',
      subtitle: 'Crea una nueva contraseña segura para tu cuenta.',
      children: [
        const _FieldLabel('Nueva contraseña'),
        _Input(
          controller: passwordController,
          hintText: 'Ingresa tu nueva contraseña',
          icon: Icons.lock_outline_rounded,
          obscureText: !showPassword,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              showPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Confirmar contraseña'),
        _Input(
          controller: confirmController,
          hintText: 'Confirma tu nueva contraseña',
          icon: Icons.lock_outline_rounded,
          obscureText: !showConfirm,
          suffix: IconButton(
            onPressed: onToggleConfirm,
            icon: Icon(
              showConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          text: loading ? 'Guardando...' : 'Guardar contraseña',
          onPressed: loading ? null : onSubmit,
        ),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: const _StatusIcon(icon: Icons.check_rounded, success: true),
      title: 'Contraseña actualizada',
      subtitle: 'Tu contraseña fue cambiada correctamente.',
      children: [
        const SizedBox(height: 80),
        _PrimaryButton(text: 'Ir al inicio de sesión', onPressed: onLogin),
      ],
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final Widget? icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Center(child: icon),
            const SizedBox(height: 26),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: ts(context, 24),
              fontWeight: FontWeight.w900,
              color: _ForgotPasswordScreenState._text,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: ts(context, 15),
              height: 1.35,
              color: _ForgotPasswordScreenState._muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 34),
          ...children,
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: GoogleFonts.inter(
        fontSize: ts(context, 15),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: _ForgotPasswordScreenState._muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _ForgotPasswordScreenState._border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _ForgotPasswordScreenState._brand,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: ts(context, 13),
          color: _ForgotPasswordScreenState._text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _ForgotPasswordScreenState._brand,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: ts(context, 15),
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.icon, this.success = false});

  final IconData icon;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color =
        success
            ? _ForgotPasswordScreenState._success
            : _ForgotPasswordScreenState._brand;
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _EmailBadge extends StatelessWidget {
  const _EmailBadge({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(225, 246, 217, 1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          email,
          style: GoogleFonts.inter(
            color: _ForgotPasswordScreenState._success,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
