import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachScreen extends StatelessWidget {
  static const String name = '/coach_screen';
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Coach Dashboard'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const _CoachView(),
    );
  }
}

class _CoachView extends StatelessWidget {
  const _CoachView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Image.asset('assets/images/coach.png', width: 160),
              Column(
                spacing: 10,
                children: [
                  CustomTitleText(
                    text: 'Jerome Bell',
                    size: 25,
                    font: 'Inter',
                    color: Color.fromRGBO(11, 25, 38, 1),
                  ),
                  CustomButtonCard(
                    width: 150,
                    height: 120,
                    titleText: 'Estudiantes',
                    subtitleText: '20',
                    titleTextSize: 22,
                    subtitleTextSize: 24,
                    spacing: 19,
                    onTap: () => context.push('/category_screen'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(229, 240, 246, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 5,
                right: 5,
                left: 5,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 3),
                  CustomText(
                    text: 'Asistencia',
                    fontWeight: FontWeight.bold,
                    size: 18,
                  ),
                  SizedBox(height: 120, child: AssistanceBarChart()),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(3, 4),
              ),
            ],
            color: Colors.black, // color del divider
          ),
          height: 3, // grosor del divider
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: CustomText(
              text: 'Acciones rapidas',
              fontWeight: FontWeight.bold,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomActionButton(
              image: 'assets/images/student-icon.png',
              text: 'Crear\nEstudiante',
            ),
            CustomActionButton(
              image: 'assets/images/edit-icon.png',
              text: 'Editar\nEquipo',
            ),
          ],
        ),
        const SizedBox(height: 15),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomActionButton(
                  image: 'assets/images/calendar-icon.png',
                  text: 'Programar\nPartido',
                ),
                CustomActionButton(
                  image: 'assets/images/cup-icon.png',
                  text: 'Torneos',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
