import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomIconCard extends StatefulWidget {
  final double width;
  final double height;
  final String titleText;
  final double titleTextSize;
  final String imagePath;
  final double imageSize;
  final double spacing;
  final VoidCallback? onTap;
  const CustomIconCard({
    super.key,
    required this.width,
    required this.height,
    required this.titleText,
    required this.titleTextSize,
    required this.spacing,
    this.onTap,
    required this.imagePath,
    required this.imageSize,
  });

  @override
  State<CustomIconCard> createState() => _CustomIconCardState();
}

class _CustomIconCardState extends State<CustomIconCard> {
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
          color: const Color.fromRGBO(245, 240, 230, 1),
          borderRadius: BorderRadius.circular(12),
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
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(widget.imagePath, width: widget.imageSize),
                SizedBox(height: widget.spacing), //17
                CustomText(
                  text: widget.titleText,
                  size: widget.titleTextSize,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
