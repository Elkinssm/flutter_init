import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final paddingGreenButton = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(top: paddingGreenButton * 0.10, left: 1),
      child: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          backgroundColor: Color.fromRGBO(79, 166, 38, 1),
          child: Image.asset(
            'assets/images/whistle-96.png',
            height: 26,
            width: 26,
          ),
        ),
      ),
    );
  }
}
