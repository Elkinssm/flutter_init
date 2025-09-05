import 'package:coach_app/presentation/helpers/hepler_aligment.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/selected_buttons_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SelectedTeamScreen extends StatelessWidget {
  static const String name = '/selected_team_screen';
  const SelectedTeamScreen({super.key, required this.teamName});
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: teamName),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _SelectedTeamView(),
      ),
    );
  }
}

class _SelectedTeamView extends ConsumerWidget {
  const _SelectedTeamView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider);

    Widget content;
    switch (selected) {
      case 'Inicio':
        content = const Expanded(child: SelectedListviewPlayers());
        break;
      case 'Alineación':
        content = Expanded(child: HeplerAligment());
        break;
      case 'Posiciones':
        content = const Expanded(
          child: Center(
            child: CustomText(
              text: 'Posiciones',
              size: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
      case 'Partidos':
        content = const Expanded(
          child: Center(
            child: CustomText(
              text: 'Partidos',
              size: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
      default:
        content = SizedBox();
    }

    return maxWidthCenter(
      context: context,
      max: 880,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                CustomActionButtonWidget(label: 'Inicio', onPressed: () {}),
                CustomActionButtonWidget(label: 'Alineación', onPressed: () {}),
                CustomActionButtonWidget(label: 'Posiciones', onPressed: () {}),
                CustomActionButtonWidget(label: 'Partidos', onPressed: () {}),
              ],
            ),
            SizedBox(height: 10),
            content,
            selected == 'Inicio'
                ? OnboardingNextButton(
                  text: 'Agregar Jugador',
                  action: () => context.push('/new_player_screen'),
                )
                : const SizedBox.shrink(),
            selected == 'Inicio'
                ? SizedBox(height: 90)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
