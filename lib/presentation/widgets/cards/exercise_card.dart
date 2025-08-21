import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatefulWidget {
  final String title;
  final String assetImage;
  final VoidCallback? onTap;
  const ExerciseCard({
    super.key,
    required this.title,
    required this.assetImage,
    this.onTap,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
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
        height: 85,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(249, 245, 236, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              _isPressed
                  ? []
                  : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
        ),
        margin: EdgeInsets.only(top: _isPressed ? 1 : 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomText(
                text: widget.title,
                fontWeight: FontWeight.w600,
                size: 16,
              ),
              Image.asset(widget.assetImage, width: 35, height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
