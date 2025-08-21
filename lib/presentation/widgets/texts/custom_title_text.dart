import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTitleText extends StatelessWidget {
  final String text;
  final double size;
  final double spacingText;
  final Color? color;
  final FontWeight? fontWeight;
  const CustomTitleText({
    super.key,
    required this.text,
    required this.size,
    this.color = Colors.white,
    this.fontWeight = FontWeight.w700,
    this.spacingText = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: fontWeight,
        color: color,
        height: spacingText,
      ),
    );
  }
}
