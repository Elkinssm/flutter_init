import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryTitleText extends StatelessWidget {
  final String text;
  final double? spacingText;
  final FontWeight? fontWeight;
  const PrimaryTitleText({
    super.key,
    required this.text,
    this.spacingText = 1.2,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.beVietnamPro(
        color: Color.fromRGBO(13, 13, 13, 1),
        fontSize: 32,
        fontWeight: fontWeight,
        height: spacingText,
      ),
    );
  }
}
