import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color? color;
  const CustomText({super.key, required this.text, required this.fontWeight, required this.size, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: 'Input',
        fontWeight: fontWeight
      ),
    );
  }
}