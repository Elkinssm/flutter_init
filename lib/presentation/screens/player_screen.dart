import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerScreen extends StatelessWidget {
  static const String name = '/player_screen';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(
          title: 'Jugador',
          backgroundColor: Colors.transparent,
        ),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _PlayerScreen(),
      ),
    );
  }
}

class _PlayerScreen extends StatefulWidget {
  const _PlayerScreen();

  @override
  State<_PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<_PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Precache commonly used images to avoid jank when they appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/player.png'), context);
      precacheImage(const AssetImage('assets/images/group14.png'), context);
      precacheImage(const AssetImage('assets/images/performance-icon.png'), context);
      precacheImage(const AssetImage('assets/images/strong-icon.png'), context);
      precacheImage(const AssetImage('assets/images/person-icon.png'), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeigth = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 20,
                left: 20,
                top: screenHeigth * 0.065,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: CustomText(
                      text: 'David\nBallesteros',
                      size: 28,
                      color: Color.fromRGBO(11, 25, 38, 1),
                      fontWeight: FontWeight.w800,
                      spacingText: 0.9,
                    ),
                  ),
                  Image.asset('assets/images/player.png', width: 175, cacheWidth: 175),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeigth * 0.28, left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: RepaintBoundary(
                      child: CustomCards(
                        action: () => context.push('/category_screen'),
                        title: 'Categoría',
                        subtitle: '2012',
                        textButton: 'Ver mi categoría',
                        sizeTextButton: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RepaintBoundary(
                      child: CustomCards(
                        action: () => context.push('/history_screen'),
                        title: 'Los Tigres',
                        subtitle: '6 categorías',
                        textButton: 'Ver resumen',
                        sizeTextButton: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const CustomSupportStats(),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: CustomInfoCard(
                    cacheHeight: 24,
                    cacheWidth: 24,
                    assetImage: 'assets/images/group14.png',
                    title: "Próximo Partido",
                    data: ["Fecha: 12/02/2025", "Rival: Los Tigres", "Hora: 4:00 pm"],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RepaintBoundary(
                  child: CustomInfoCard(
                    cacheHeight: 20,
                    cacheWidth: 22,
                    assetImage: 'assets/images/performance-icon.png',
                    title: "Desempeño",
                    data: [
                      "Velocidad: 8.4 km/h",
                      "Precisión tiros: 75%",
                      "Toques efectivos: 95%",
                    ],
                    onTap: () => context.push('/performance_screen'),
                    isDisabled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 3,
          children: [
            ExerciseCard(
              title: 'Ejercicios\nde fuerza',
              assetImage: 'assets/images/strong-icon.png',
            ),
            const SizedBox(width: 12),
            ExerciseCard(
              title: 'Ejercicios\nde velocidad',
              assetImage: 'assets/images/person-icon.png',
            ),
          ],
        ),
      ],
    );
  }
}
