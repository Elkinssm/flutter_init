import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:flutter/material.dart';

class CurvedBarPainterWhite extends CustomPainter {
  final BuildContext context;

  CurvedBarPainterWhite({super.repaint, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromRGBO(249, 248, 247, 1)
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final double dy = 0.09;
    final num radius = 0.074;
    final double lowerLimit = 24.0;
    final double upperLimit = 38.0;

    final notchR = (w * radius).clamp(lowerLimit, upperLimit);
    final center = Offset(w / 2, h * dy);

    final path = Path();

    path.addArc(Rect.fromCircle(center: center, radius: notchR), 2.55, 6.283);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedBarPainterOrange extends CustomPainter {
  final BuildContext context;
  CurvedBarPainterOrange({super.repaint, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final double dy = 0.10;
    final num radius = 0.078;
    final double lowerLimit = 24.0;
    final double upperLimit = 38.0;

    final notchR = (w * radius).clamp(lowerLimit, upperLimit);
    final center = Offset(w / 2, h * dy);

    final path = Path();

    path.addArc(Rect.fromCircle(center: center, radius: notchR), 2.55, 6.283);

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
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedLinePainterOrange extends CustomPainter {
  final BuildContext context;
  CurvedLinePainterOrange({super.repaint, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 =
        Paint()
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path1 = Path();
    final paint2 =
        Paint()
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path2 = Path();

    final w = size.width;

    // moveto1
    final double movetoX1 = isSmallPhone(context) ? (w / 3) + 14 : (w / 3) + 24;
    final double movetoY1 = 0;

    // cubicto1
    final double x1 = isSmallPhone(context) ? 140 : 171;
    final double y1 = isSmallPhone(context) ? 0 : -4;
    final double x2 = isSmallPhone(context) ? w * 0.472 : w * 0.443;
    final double y2 = isSmallPhone(context) ? -21 : -25;
    final double x3 = isSmallPhone(context) ? (w / 2) - 20 : (w / 2) - 28;
    final double y3 = 0;

    // moveto2
    final double movetoX2 = (w / 2) - 14;
    final double movetoY2 = 0;

    // cubicto2
    final double cx1 = 154;
    final double cy1 = -6;
    final double cx2 = w * 0.475;
    final double cy2 = -28;
    final double cx3 = (w / 2) - 31;
    final double cy3 = 0;

    // moveto1
    path1.moveTo(movetoX1, movetoY1);
    // cubicto1
    path1.cubicTo(x1, y1, x2, y2, x3, y3);

    // moveto2
    path2.moveTo(movetoX2, movetoY2);
    // cubicto2
    path2.cubicTo(cx1, cy1, cx2, cy2, cx3, cy3);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedLine2PainterOrange extends CustomPainter {
  final BuildContext context;
  CurvedLine2PainterOrange({super.repaint, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 =
        Paint()
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path1 = Path();
    final paint2 =
        Paint()
          ..color = const Color.fromRGBO(217, 73, 41, 1)
          ..style = PaintingStyle.fill;
    final path2 = Path();

    final w = size.width;

    // moveto1
    final double movetoX1 = (w / 2) + 25;
    final double movetoY1 = 0;

    // cubicto1
    final double x1 = 218;
    final double y1 = -18;
    final double x2 = w * 0.56;
    final double y2 = -5;
    final double x3 = (w / 2) + 38;
    final double y3 = 0;

    // moveto2
    final double movetoX2 = (w / 2) + 14;
    final double movetoY2 = 0;

    // cubicto2
    final double cx1 = 224;
    final double cy1 = -2;
    final double cx2 = w * 0.56;
    final double cy2 = -18;
    final double cx3 = (w / 2) + 27;
    final double cy3 = 0;

    // moveto1
    path1.moveTo(movetoX1, movetoY1);
    // cubicto1
    path1.cubicTo(x1, y1, x2, y2, x3, y3);

    // moveto2
    path2.moveTo(movetoX2, movetoY2);
    // cubicto2
    path2.cubicTo(cx1, cy1, cx2, cy2, cx3, cy3);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
