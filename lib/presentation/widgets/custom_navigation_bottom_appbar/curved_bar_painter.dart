import 'package:flutter/material.dart';

class CurvedBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Color.fromRGBO(217, 73, 41, 1);
    final paint1 = Paint()..color = Colors.white;
    final path = Path();
    final path1 = Path();

    path.lineTo(0, 0);
    // path.quadraticBezierTo(0, 0, size.width * 0.50, 0);
    path.arcToPoint(
      Offset(size.width * -0.01, 0),
      radius: const Radius.circular(40),
      clockwise: false,
    );
    path1.lineTo(170, 0);
    // path1.quadraticBezierTo(size.width * 0.51, -75, size.width * 0.55, 0);
    path.close();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
