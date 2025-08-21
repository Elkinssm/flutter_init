import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomInfoCard extends StatefulWidget {
  final IconData? icon;
  final String title;
  final List<String>? data;
  final int cacheHeight;
  final int cacheWidth;
  final String assetImage;
  final VoidCallback? onTap;

  const CustomInfoCard({
    super.key,
    this.icon,
    required this.title,
    this.data,
    required this.assetImage,
    this.onTap,
    required this.cacheHeight,
    required this.cacheWidth,
  });

  @override
  State<CustomInfoCard> createState() => _CustomInfoCardState();
}

class _CustomInfoCardState extends State<CustomInfoCard> {
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
        width: 166,
        height: 120,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 240, 246, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              _isPressed
                  ? []
                  : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 4),
                    ),
                  ],
        ),
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.assetImage,
                    cacheWidth: widget.cacheWidth,
                    cacheHeight: widget.cacheHeight,
                  ),
                  const SizedBox(width: 6),
                  CustomText(
                    text: widget.title,
                    fontWeight: FontWeight.w700,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.data != null && widget.data!.isNotEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        widget.data!
                            .map(
                              (item) => CustomText(
                                text: item,
                                size: 13,
                                fontWeight: FontWeight.w400,
                                spacingText: 1.4,
                              ),
                            )
                            .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
