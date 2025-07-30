import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomBottomAppbar extends StatelessWidget {
  const CustomBottomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(double.infinity, 80),
            painter: CurvedBarPainter(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    'assets/images/home-black-100.png',
                    height: 26,
                    width: 26,
                  ),
                  Image.asset(
                    'assets/images/winner-black-100.png',
                    height: 26,
                    width: 26,
                  ),
                  const SizedBox(width: 60), // Espacio del botón central
                  Image.asset(
                    'assets/images/stadium-black-100.png',
                    height: 26,
                    width: 26,
                  ),
                  Image.asset(
                    'assets/images/message-black-100.png',
                    height: 26,
                    width: 26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
