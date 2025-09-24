import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:flutter/material.dart';

class CustomButtonCard extends StatefulWidget {
  final double width;
  final double height;
  final String titleText;
  final String subtitleText;
  final double titleTextSize;
  final double subtitleTextSize;
  final FontWeight? fontWeightT1;
  final FontWeight? fontWeightT2;
  final bool? isContentLeft;
  final double spacing;
  final VoidCallback? onTap;
  final bool? isInfoCard;
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
    this.fontWeightT1 = FontWeight.w800,
    this.fontWeightT2 = FontWeight.w700,
    this.isContentLeft = false,
    this.isInfoCard = true,
  });

  @override
  State<CustomButtonCard> createState() => _CustomButtonCardState();
}

class _CustomButtonCardState extends State<CustomButtonCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.isInfoCard == true) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isInfoCard == true) return;
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.isInfoCard == true) return;
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
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
        ),
        margin: EdgeInsets.only(top: _isPressed ? 1 : 0),
        child: Padding(
          padding:
              widget.isContentLeft!
                  ? const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 8,
                    )
                  : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                widget.isContentLeft!
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              widget.isContentLeft! ? const SizedBox.shrink() : const SizedBox(height: 0),
              // Usar Text con overflow controlado
              Text(
                widget.titleText,
                style: TextStyle(
                  fontSize: widget.titleTextSize,
                  fontWeight: widget.fontWeightT1!,
                  color: const Color.fromRGBO(11, 25, 38, 1),
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(
                height: (widget.height < 80 ? widget.spacing * 0.6 : widget.spacing * 0.8)
                    .clamp(6, 16),
              ),
              Text(
                widget.subtitleText,
                style: TextStyle(
                  fontSize: widget.subtitleTextSize,
                  fontWeight: widget.fontWeightT2!,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
