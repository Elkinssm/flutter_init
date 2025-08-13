import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class DailyAttendanceScreen extends StatelessWidget {
  static const String name = '/daily_attendance_screen';
  const DailyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Asistencia diaria'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _DailyAttendanceView(),
    );
  }
}

class _DailyAttendanceView extends StatelessWidget {
  const _DailyAttendanceView();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}