import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';

class CustomActionButton extends StatefulWidget {
  final String image;
  final String text;
  final VoidCallback? onTap;

  final double? textSize;
  final double? iconH;
  final double? iconW;
  final double? radius;
  final bool? isDisabled;

  const CustomActionButton({
    super.key,
    required this.image,
    required this.text,
    this.onTap,
    this.textSize,
    this.iconH,
    this.iconW,
    this.radius,
    this.isDisabled = true,
  });

  @override
  State<CustomActionButton> createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends State<CustomActionButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.isDisabled == true) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isDisabled == true) return;
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.isDisabled == true) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? (isPhone(context) ? 12.0 : 14.0);
    final textSize = widget.textSize ?? ts(context, 16);
    final iconH = widget.iconH ?? (isPhone(context) ? 24.0 : 28.0);
    final iconW = widget.iconW ?? (isPhone(context) ? 27.0 : 31.0);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0F9),
          borderRadius: BorderRadius.circular(radius),
          boxShadow:
              _isPressed
                  ? []
                  : const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
        ),
        margin: EdgeInsets.only(top: _isPressed ? 1 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(widget.image, height: iconH, width: iconW),
            // SizedBox(width: isPhone(context) ? 6 : 12),
            Flexible(
              child: Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: textSize,
                  height: 0.98,
                  fontWeight: FontWeight.w700,
                  color: widget.isDisabled! ? Colors.grey : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
