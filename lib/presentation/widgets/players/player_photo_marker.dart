import 'dart:async';

import 'package:flutter/material.dart';
import '../../../config/domain/player.dart'; // Importamos el modelo

class PlayerPhotoMarker extends StatefulWidget {
  final Player player;

  const PlayerPhotoMarker({super.key, required this.player});

  @override
  State<PlayerPhotoMarker> createState() => _PlayerPhotoMarkerState();
}

class _PlayerPhotoMarkerState extends State<PlayerPhotoMarker> {
  bool _showLabel = false;
  Timer? _hideTimer;

  void _handleTap() {
    setState(() => _showLabel = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showLabel = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _handleTap,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: AssetImage(widget.player.photoPath),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30, 
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: _showLabel ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.player.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
