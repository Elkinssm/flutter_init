import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

const selectedColors = <Color>[
  Color.fromRGBO(255, 255, 255, 1),
  Color.fromRGBO(0, 0, 0, 1),
];

class LabelText extends StatelessWidget {
  final String label;
  final int colorIndex;
  final FontWeight? fontWeight;

  const LabelText({
    super.key,
    required this.label,
    required this.colorIndex,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selectedColors[colorIndex];
    final fs = ts(context, 16);

    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: GoogleFonts.inter(
          color: color,
          fontSize: fs,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
