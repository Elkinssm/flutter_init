import 'package:flutter/material.dart';

class CoachCard extends StatelessWidget {
  const CoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(213, 229, 244, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage(
                'assets/images/player.png',
              ), // Foto del coach
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jerome Bell',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Entrenador',
                  style: TextStyle(color: Color.fromRGBO(217, 73, 41, 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
