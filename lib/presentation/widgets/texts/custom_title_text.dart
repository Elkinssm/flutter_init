import 'package:flutter/material.dart';

class CustomTitleText extends StatelessWidget {
  final String text;
  final String? font;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;
  const CustomTitleText({
    super.key,
    required this.text,
    required this.size,
    this.color = Colors.white,
    this.font = 'Be Vietnam Pro', 
    this.fontWeight = FontWeight.w900,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: fontWeight,
        fontFamily: font,
        color: color,
      ),
    );
  }
}
