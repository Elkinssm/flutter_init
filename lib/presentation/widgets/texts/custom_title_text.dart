import 'package:flutter/material.dart';

class CustomTitleText extends StatelessWidget {
  final String text;
  final String? font;
  final double size;
  final Color? color;
  const CustomTitleText({
    super.key,
    required this.text,
    required this.size,
    this.color = Colors.white,
    this.font = 'Be Vietnam Pro',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        fontFamily: font,
        color: color,
      ),
    );
  }
}
