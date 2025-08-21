import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color? color;
  final double? spacingText;
  final TextAlign? textAlign;
  const CustomText({
    super.key,
    required this.text,
    required this.fontWeight,
    required this.size,
    this.color = Colors.black,
    this.spacingText = 0.9,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        height: spacingText,
      ),
    );
  }
}
