import 'package:flutter/material.dart';

class CurvedBarPainterwhite extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color.fromRGBO(249, 248, 247, 1)
          ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, size.height / 2);
    path.arcTo(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height * 0.30),
        radius: 30,
      ),
      3.50,
      33.80,
      false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedBarPainterOrange extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, size.height / 2 + 10);
    path.arcTo(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height * 0.30),
        radius: 30.5,
      ),
      2.0,
      350.99,
      false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlockBarPainterOrange extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.54, 0);
    path.cubicTo(210, -54, size.width * 0.52, 0, size.width - 125, 0);
    path.moveTo(size.width * 0.31, 0);
    path.cubicTo(size.width * 0.50, 0, 178, -52, size.width - 210, 0);
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
