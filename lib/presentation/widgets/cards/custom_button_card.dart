import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:flutter/material.dart';

class CustomButtonCard extends StatefulWidget {
  final double width;
  final double height;
  final String titleText;
  final String subtitleText;
  final double titleTextSize;
  final double subtitleTextSize;
  final double spacing;
  final VoidCallback? onTap;
  const CustomButtonCard({
    super.key,
    required this.width,
    required this.height,
    required this.titleText,
    required this.subtitleText,
    required this.titleTextSize,
    required this.subtitleTextSize,
    required this.spacing,
    this.onTap,
  });

  @override
  State<CustomButtonCard> createState() => _CustomButtonCardState();
}

class _CustomButtonCardState extends State<CustomButtonCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final radius = isPhone(context) ? 12.0 : 14.0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 240, 246, 1),
          borderRadius: BorderRadius.circular(radius),
          boxShadow:
              _isPressed
                  ? []
                  : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
        ),
        margin: EdgeInsets.only(top: _isPressed ? 1 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: isPhone(context) ? 8 : 2),
            CustomText(
              text: widget.titleText,
              size: widget.titleTextSize,
              fontWeight: FontWeight.w800,
              color: const Color.fromRGBO(11, 25, 38, 1),
              spacingText: 1.0,
            ),
            SizedBox(height: widget.spacing),
            CustomText(
              text: widget.subtitleText,
              size: widget.subtitleTextSize,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
