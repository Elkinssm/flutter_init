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
                    top: 13,
                    bottom: 10,
                  )
                  : EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                widget.isContentLeft!
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              widget.isContentLeft!
                  ? const SizedBox.shrink()
                  : SizedBox(
                    height:
                        isPhone(context)
                            ? hp(context, 0.02)
                            : hp(context, 0.01),
                  ),
              CustomText(
                text: widget.titleText,
                size: widget.titleTextSize,
                fontWeight: widget.fontWeightT1!,
                color: const Color.fromRGBO(11, 25, 38, 1),
                spacingText: 1.0,
              ),
              SizedBox(height: widget.spacing),
              CustomText(
                text: widget.subtitleText,
                size: widget.subtitleTextSize,
                fontWeight: widget.fontWeightT2!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
