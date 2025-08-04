import 'package:flutter/material.dart';

class CustomInfoCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final List<String>? data;
  final String? assetImage;

  const CustomInfoCard({
    super.key,
    this.icon,
    required this.title,
    this.data,
    this.assetImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 120,
      child: Card(
        color: const Color.fromRGBO(229, 240, 246, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (assetImage != null)
                    Image.asset(assetImage!, cacheWidth: 24, cacheHeight: 24)
                  else if (icon != null)
                    Icon(icon, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (data != null && data!.isNotEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        data!
                            .map(
                              (item) => Text(
                                item,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
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
