import 'package:flutter/material.dart';

class CustomActionButton extends StatefulWidget {
  final String image;
  final String text;
  final VoidCallback? onTap;
  const CustomActionButton({
    super.key,
    required this.image,
    required this.text,
    this.onTap,
  });

  @override
  State<CustomActionButton> createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends State<CustomActionButton> {
  final bool _preseed = false;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(12);

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      scale: _preseed ? 0.97 : 1.0,
      child: Material(
        color: Colors.transparent,
        elevation: _preseed ? 2 : 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: border),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0F9), // azul claro
              borderRadius: border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(widget.image, height: 25, width: 28),
                const SizedBox(height: 8),
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
