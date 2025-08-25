import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryTitleText extends StatelessWidget {
  final String text;
  final double? spacingText;
  final FontWeight? fontWeight;
  final Color color;
  final double size;
  const PrimaryTitleText({
    super.key,
    required this.text,
    this.spacingText = 1.2,
    this.fontWeight = FontWeight.w700, 
    this.color = const Color.fromRGBO(13, 13, 13, 1), 
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.beVietnamPro(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        height: spacingText,
      ),
    );
  }
}
