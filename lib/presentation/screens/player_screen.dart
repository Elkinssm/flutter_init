import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerScreen extends StatelessWidget {
  static const String name = '/player_screen';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _PlayerScreen(), // Tu contenido aquí
    );
  }
}

class _PlayerScreen extends StatelessWidget {
  const _PlayerScreen();

  @override
  Widget build(BuildContext context) {
    final screenHeigth = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 25,
                      bottom: 60,
                      left: 5,
                    ),
                    child: CustomTitleText(
                      text: 'David\nBallesteros',
                      size: 28,
                      font: 'Inter',
                      color: Color.fromRGBO(11, 25, 38, 1),
                    ),
                  ),
                  Image.asset('assets/images/player.png', width: 160),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeigth * 0.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 9.5,
                children: [
                  CustomCards(
                    action: () => context.push('/performance_screen'),
                    title: 'Categoría',
                    subtitle: '2012',
                    textButton: 'Ver mi categoría',
                    sizeTextButton: 14,
                  ),
                  CustomCards(
                    action: () => context.push('/history_screen'),
                    title: 'Los Tigres',
                    subtitle: '6 categorías',
                    textButton: 'Ver resumen',
                    sizeTextButton: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        CustomSupportStats(),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 1,
          children: [
            CustomInfoCard(
              assetImage: 'assets/images/group14.png',
              title: "Próximo Partido",
              data: ["Fecha: 12/02/2025", "Rival: Los Tigres", "Hora: 4:00 pm"],
            ),
            const SizedBox(width: 10),
            CustomInfoCard(
              icon: Icons.speed,
              title: "Desempeño",
              data: [
                "Velocidad: 8.4 km/h",
                "Precisión tiros: 75%",
                "Toques efectivos: 95%",
              ],
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExerciseCard(
              title: 'Ejercicios\nde fuerza',
              icon: Icons.fitness_center,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            ExerciseCard(
              title: 'Ejercicios\nde velocidad',
              icon: Icons.directions_run,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
