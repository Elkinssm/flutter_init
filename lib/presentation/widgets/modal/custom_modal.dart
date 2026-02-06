import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:coach_app/presentation/widgets/texts/custom_title_text.dart';
import 'package:coach_app/presentation/widgets/texts/custom_subtitle_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

enum ModalType { success, error, warning, info }

class CustomModal extends StatelessWidget {
  final String title;
  final String message;
  final ModalType type;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool barrierDismissible;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final TextAlign messageAlign;

  const CustomModal({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.buttonText = 'Entendido',
    this.onButtonPressed,
    this.barrierDismissible = true,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.messageAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(height: 16),
            CustomTitleText(
              text: title,
              size: ts(context, 20),
              color: colors[0],
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            CustomText(
              text: message,
              size: ts(context, 16),
              fontWeight: FontWeight.w400,
              color: colors[0].withValues(alpha: 0.7),
              textAlign: messageAlign,
            ),
            const SizedBox(height: 24),
            _buildButton(context),
            if (secondaryButtonText != null && secondaryButtonText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSecondaryButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onSecondaryButtonPressed ?? () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: colors[0].withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          secondaryButtonText!,
          style: GoogleFonts.inter(
            fontSize: ts(context, 15),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    Color iconColor;
    IconData iconData;

    switch (type) {
      case ModalType.success:
        iconColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case ModalType.error:
        iconColor = colors[1]; // Naranja/Rojo de la app
        iconData = Icons.error_outline;
        break;
      case ModalType.warning:
        iconColor = Colors.orange;
        iconData = Icons.warning_outlined;
        break;
      case ModalType.info:
        iconColor = colors[1]; // Naranja/Rojo de la app
        iconData = Icons.info_outline;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
      child: Icon(iconData, color: Colors.white, size: 30),
    );
  }

  Widget _buildButton(BuildContext context) {
    Color buttonColor;

    switch (type) {
      case ModalType.success:
        buttonColor = Colors.green;
        break;
      case ModalType.error:
        buttonColor = colors[1]; // Naranja/Rojo de la app
        break;
      case ModalType.warning:
        buttonColor = Colors.orange;
        break;
      case ModalType.info:
        buttonColor = colors[1]; // Naranja/Rojo de la app
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.inter(
            fontSize: ts(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ModalType type,
    String buttonText = 'Entendido',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButtonPressed,
    TextAlign messageAlign = TextAlign.center,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return CustomModal(
          title: title,
          message: message,
          type: type,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
          barrierDismissible: barrierDismissible,
          secondaryButtonText: secondaryButtonText,
          onSecondaryButtonPressed: onSecondaryButtonPressed,
          messageAlign: messageAlign,
        );
      },
    );
  }

  /// Modal para avisar que el perfil de jugador está incompleto.
  static void showProfileIncomplete({
    required BuildContext context,
    VoidCallback? onCompleteProfile,
    VoidCallback? onSkip,
  }) {
    show(
      context: context,
      title: '¡Qué bueno verte!',
      message:
          'Para que tu experiencia sea única y el profe pueda conocerte mejor, cuéntanos un poco más sobre ti en tu perfil.',
      type: ModalType.info,
      buttonText: 'Completar Perfil',
      messageAlign: TextAlign.center,
      onButtonPressed: () {
        Navigator.of(context).pop();
        onCompleteProfile?.call();
      },
      secondaryButtonText: 'Después',
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
        onSkip?.call();
      },
      barrierDismissible: false,
    );
  }
}
