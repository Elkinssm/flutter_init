import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class OnboardingNextButton extends StatefulWidget {
  final String text;
  final VoidCallback? action;
  const OnboardingNextButton({super.key, this.action, required this.text});

  @override
  State<OnboardingNextButton> createState() => _OnboardingNextButtonState();
}

class _OnboardingNextButtonState extends State<OnboardingNextButton> {
  bool _isPressed = false;

  static const _normal = Color.fromRGBO(217, 73, 41, 1);
  static const _pressed = Color.fromRGBO(27, 71, 56, 1);

  Color get _bg => _isPressed ? _pressed : _normal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: FilledButton(
            onPressed: widget.action,
            style: ButtonStyle(
              animationDuration: const Duration(milliseconds: 150),
              backgroundColor: WidgetStateProperty.all(_bg),
              // foregroundColor: WidgetStateProperty.all(Colors.white),
              minimumSize: WidgetStateProperty.all(const Size(175, 39)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            child: CustomTitleText(
              text: widget.text,
              size: 13.5,
              font: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
