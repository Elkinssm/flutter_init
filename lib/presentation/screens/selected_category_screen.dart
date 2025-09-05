import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectedCategoryScreen extends StatelessWidget {
  static const String name = '/selected_category_screen';
  final int year;
  const SelectedCategoryScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Categoria $year'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: _SelectedCategoryView(),
      ),
    );
  }
}

class _SelectedCategoryView extends StatelessWidget {
  const _SelectedCategoryView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Asistencia\nPromedio',
                subtitleText: '87%',
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Promedio\nfísico',
                subtitleText: '38kg',
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Torneos\nactivos',
                subtitleText: '2',
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconCard(
                  width: 82,
                  height: 96,
                  titleText: 'Ver\nestadísticas',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/bar-chart-icon.png',
                  imageSize: 24,
                  onTap: () => context.pushNamed('/performance_screen'),
                ),
                CustomIconCard(
                  width: 82,
                  height: 96,
                  titleText: 'Ver\ntorneos',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/tournaments-icon.png',
                  imageSize: 24,
                  onTap: () => context.pushNamed('/my_teams_screen'),
                ),
                CustomIconCard(
                  width: 82,
                  height: 96,
                  titleText: 'Ver\nasistencias',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/check-list-icon.png',
                  imageSize: 24,
                  onTap: () => context.pushNamed('/daily_attendance_screen'),
                ),
                CustomIconCard(
                  width: 82,
                  height: 96,
                  titleText: 'Ingresar\ndatos',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/plus-icon.png',
                  imageSize: 24,
                  onTap: () => context.pushNamed('/new_player_screen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
              color: Colors.black,
            ),
            height: 3,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Estudiantes',
                fontWeight: FontWeight.w700,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: ListViewStudent()),
        ],
      ),
    );
  }
}
