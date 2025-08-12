import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? assetImage;
  final VoidCallback? onTap;
  const ExerciseCard({
    super.key,
    required this.title,
    this.icon,
    this.assetImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 175,
        height: 85,
        child: Card(
          color: const Color.fromRGBO(249, 245, 236, 1),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (assetImage != null)
                  Image.asset(assetImage!, width: 28, height: 28)
                else if (icon != null)
                  Icon(icon, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
