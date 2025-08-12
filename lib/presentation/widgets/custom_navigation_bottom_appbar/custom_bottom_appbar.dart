import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomAppbar extends ConsumerWidget {
  const CustomBottomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIconProvider); // Observa el estado

    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(double.infinity, 65),
            painter: BlockBarPainterOrange(),
          ),
          CustomPaint(
            size: Size(double.infinity, 94.5),
            painter: CurvedBarPainterOrange(),
          ),
          CustomPaint(
            size: Size(double.infinity, 92),
            painter: CurvedBarPainterwhite(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIcon(ref, 0, selectedIndex, 'home'),
                  _buildIcon(ref, 1, selectedIndex, 'winner'),
                  const SizedBox(width: 60), // Espacio del botón central
                  _buildIcon(ref, 2, selectedIndex, 'stadium'),
                  _buildIcon(ref, 3, selectedIndex, 'message'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Método que construye cada icono dinámicamente
  Widget _buildIcon(WidgetRef ref, int index, int selectedIndex, String name) {
    final isSelected = selectedIndex == index;
    final imagePath =
        isSelected
            ? 'assets/images/$name-100.png'
            : 'assets/images/$name-black-100.png';

    return InkWell(
      onTap: () {
        ref.read(selectedIconProvider.notifier).state = index; // Cambia estado
      },
      child: Image.asset(imagePath, height: 26, width: 26),
    );
  }
}
