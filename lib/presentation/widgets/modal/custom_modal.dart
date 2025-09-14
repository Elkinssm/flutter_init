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

  const CustomModal({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.buttonText = 'Entendido',
    this.onButtonPressed,
    this.barrierDismissible = true,
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
            // Icono según el tipo
            _buildIcon(context),
            const SizedBox(height: 16),

            // Título usando CustomTitleText
            CustomTitleText(
              text: title,
              size: ts(context, 20),
              color: colors[0], // Negro
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),

            // Mensaje usando CustomText
            CustomText(
              text: message,
              size: ts(context, 16),
              fontWeight: FontWeight.w400,
              color: colors[0].withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botón
            _buildButton(context),
          ],
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

  // Método estático para mostrar el modal fácilmente
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required ModalType type,
    String buttonText = 'Entendido',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
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
        );
      },
    );
  }
}
