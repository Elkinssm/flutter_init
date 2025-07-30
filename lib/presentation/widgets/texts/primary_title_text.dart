import 'package:flutter/widgets.dart';

class PrimaryTitleText extends StatelessWidget {
  final String text;
  const PrimaryTitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromRGBO(13, 13, 13, 1),
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Be Vietnam Pro',
      ),
    );
  }
}
