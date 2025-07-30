import 'package:flutter/material.dart';

Widget infoCard({
  required IconData icon,
  required String title,
  required String subtitle,
  Color bgColor = Colors.white,
}) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, size: 32),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ],
    ),
  );
}
