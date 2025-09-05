import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class OnboardingNextButton extends StatefulWidget {
  final String text;
  final VoidCallback? action;
  final bool? isEnabled;
  const OnboardingNextButton({super.key, this.action, required this.text, this.isEnabled = true});

  @override
  State<OnboardingNextButton> createState() => _OnboardingNextButtonState();
}

class _OnboardingNextButtonState extends State<OnboardingNextButton> {
  bool _isPressed = false;

  static const _normal = Color.fromRGBO(217, 73, 41, 1);
  static const _pressed = Color.fromRGBO(27, 71, 56, 1);

  Color get _bg => widget.isEnabled! ? (_isPressed ? _pressed : _normal) : Colors.grey;

  @override
  Widget build(BuildContext context) {
    final radius = isPhone(context) ? 15.0 : 18.0;
    final textSize = ts(context, 13.5);

    return MouseRegion(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: FilledButton(
          onPressed: widget.isEnabled! ? widget.action : null,
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 150),
            backgroundColor: WidgetStateProperty.all(_bg),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            ),
          ),
          child: CustomTitleText(
            text: widget.text,
            size: textSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
