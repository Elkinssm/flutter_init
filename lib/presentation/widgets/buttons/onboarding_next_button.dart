import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class OnboardingNextButton extends StatelessWidget {
  final String text;
  final VoidCallback? action;
  const OnboardingNextButton({super.key, this.action, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: action,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Color.fromRGBO(217, 73, 41, 1),
          ),
          minimumSize: WidgetStateProperty.all(Size(196, 46)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: CustomTitleText(text: text, size: 14, font: 'Inter'),
      ),
    );
  }
}
