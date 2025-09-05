import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/screens/selected_team_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyTeamsScreen extends StatelessWidget {
  static const String name = '/my_teams_screen';
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Mis equipos'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: _MyTeamsView(),
      ),
    );
  }
}

class _MyTeamsView extends StatefulWidget {
  const _MyTeamsView();

  @override
  State<_MyTeamsView> createState() => _MyTeamsViewState();
}

class _MyTeamsViewState extends State<_MyTeamsView> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: maxWidthCenter(
        context: context,
        max: 880,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              CustomTeamCard(
                image: 'assets/images/club_roma.png',
                teamName: 'Futbol Club Roma',
                totalPlayers: 6,
                teamClass: 'Sub-21',
                isSelected: selectedIndex == 0,
                onTapCard: () {
                  setState(() => selectedIndex = 0);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    // ignore: use_build_context_synchronously
                    context.pushNamed(
                      SelectedTeamScreen.name,
                      extra: 'Futbol Club Roma',
                    );
                  });
                },
              ),
              SizedBox(height: 15),
              CustomTeamCard(
                image: 'assets/images/ajaz_fc.png',
                teamName: 'Ajax Fc',
                totalPlayers: 6,
                teamClass: 'Sub-21',
                isSelected: selectedIndex == 1,
                onTapCard: () {
                  setState(() => selectedIndex = 1);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    // ignore: use_build_context_synchronously
                    context.pushNamed(
                      SelectedTeamScreen.name,
                      extra: 'Ajax Fc',
                    );
                  });
                },
              ),
              SizedBox(height: 15),
              CustomText(
                text: 'Detalles del equipo',
                fontWeight: FontWeight.w700,
                size: 15,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  CustomButtonCard(
                    width: 174.5,
                    height: 75,
                    titleText: '22',
                    subtitleText: 'Integrantes',
                    titleTextSize: 18,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                  CustomButtonCard(
                    width: 174.5,
                    height: 75,
                    titleText: 'Sub-21',
                    subtitleText: 'Categoría',
                    titleTextSize: 18,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomButtonCard(
                width: double.infinity,
                height: 80,
                titleText: 'Sub-21',
                subtitleText: 'Categoría',
                titleTextSize: 18,
                subtitleTextSize: 13,
                fontWeightT2: FontWeight.w400,
                isContentLeft: true,
                spacing: 18,
                isInfoCard: true,
              ),
              SizedBox(height: 15),
              CustomText(
                text: 'Próximos partidos',
                fontWeight: FontWeight.w700,
                size: 15,
              ),
              SizedBox(height: 15),
              CustomNextMatchCard(
                image: 'assets/images/manchester_icon.png',
                teamName: 'Vs Manchester (local)',
                date: 'Sábado 10 Abril, 4:00 pm',
              ),
              SizedBox(height: 3),
              CustomNextMatchCard(
                image: 'assets/images/paris_icon.png',
                teamName: 'Vs Paris (visitante)',
                date: 'Sábado 22 Abril, 2:00 pm',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
