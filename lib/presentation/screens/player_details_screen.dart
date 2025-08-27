import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PlayerDetailsScreen extends StatelessWidget {
  static const String name = '/player_details_screen';
  const PlayerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Asistencia diaria'),
        bottomNavigationBar: CustomBottomAppbar(),
        floatingActionButton: CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _PlayerDetailsView(),
      ),
    );
  }
}

class _PlayerDetailsView extends StatelessWidget {
  const _PlayerDetailsView();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
