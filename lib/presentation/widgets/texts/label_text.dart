import 'package:flutter/material.dart';

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
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selectedColors[colorIndex];

    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontFamily: 'Input',
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
