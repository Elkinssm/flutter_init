import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

final colors = <Color>[
  const Color.fromRGBO(0, 0, 0, 1),       // Negro
  const Color.fromRGBO(217, 73, 41, 1),   // Primario
  const Color.fromRGBO(255, 255, 255, 1), // Blanco
  const Color.fromRGBO(240, 240, 240, 1), // Gris muy claro para contrastes
];

class CustomSubtitleText extends StatelessWidget {
  final String text;
  final int color;
  CustomSubtitleText({super.key, required this.text, required this.color})
    : assert(color >= 0 && color < colors.length);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = colors[color];
    final fs = ts(context, 16.2);

    return Center(
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: selectedColor,
          fontWeight: FontWeight.w600,
          fontSize: fs,
        ),
      ),
    );
  }
}
