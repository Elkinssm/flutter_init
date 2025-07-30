import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssistanceScreen extends StatelessWidget {
  static const String name = '/assistance_screen';
  const AssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _AssitanceView(),
    );
  }
}

class _AssitanceView extends StatelessWidget {
  const _AssitanceView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Davith\nBallesteros',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _CategoryCard()),
              SizedBox(width: 16),
              Expanded(child: _TotalAssistanceCard()),
            ],
          ),
          const SizedBox(height: 20),
          const _AssistanceCalendarCard(),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: const Color(0xFFEAF6FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Categoría',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('2012', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/history_screen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Ver historico'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalAssistanceCard extends StatelessWidget {
  const _TotalAssistanceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: const Color(0xFFEAF6FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text(
              'Total\nAsistencia',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              '90%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistanceCalendarCard extends StatelessWidget {
  const _AssistanceCalendarCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEADCA7), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asistencia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Julio 2025',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
            const Divider(height: 20),
            Image.asset(
              'assets/calendar_placeholder.png', // reemplaza por un widget real de calendario si lo deseas
              height: 240,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
