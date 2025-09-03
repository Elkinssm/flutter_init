// Widget reutilizable para cada jugador
import 'package:flutter/material.dart';

class PlayerMarker extends StatelessWidget {
  final String number;
  final String name;

  // El constructor para recibir los datos
  const PlayerMarker({super.key, required this.number, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Para que la columna no ocupe espacio extra
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.red.withOpacity(0.9), // Color del equipo
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
