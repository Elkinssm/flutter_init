import 'package:flutter/material.dart';

/// El FAB central ahora está integrado en [CustomBottomAppbar].
/// Este widget se deja vacío para no duplicar el botón en el Scaffold.
class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
