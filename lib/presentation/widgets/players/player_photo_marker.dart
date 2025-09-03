import 'package:flutter/material.dart';
import '../../../config/domain/player.dart'; // Importamos el modelo

class PlayerPhotoMarker extends StatelessWidget {
  final Player player;

  const PlayerPhotoMarker({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: AssetImage(player.photoPath),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
