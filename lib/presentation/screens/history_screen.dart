import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  static const String name = '/history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _HistoryView(), // Tu
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          const SizedBox(height: 16.0),

          _GeneralAttendanceSection(),
          const SizedBox(height: 16.0),

          _MonthlySummary(),
          const SizedBox(height: 16.0),

          _TotalsSection(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Davith',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          'Ballesteros',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}

class _GeneralAttendanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5E5A1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistencia',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                '90%',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Año',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                '2024',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Mensual',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        DataTable(
          headingRowColor: MaterialStateProperty.all(Color(0xFFECF7FF)),
          columns: const [
            DataColumn(label: Text('Mes')),
            DataColumn(label: Text('Jornadas')),
            DataColumn(label: Text('Asistencia')),
          ],
          rows: [
            _DataRow('Julio', '6', '5'),
            _DataRow('Agosto', '8', '8'),
            _DataRow('Septiembre', '8', '8'),
          ],
        ),
      ],
    );
  }
}

class _DataRow extends DataRow {
  _DataRow(String month, String matches, String attendance)
    : super(
        cells: [
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: month == 'Julio' ? Colors.orange : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                month,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: month == 'Julio' ? Colors.white : null,
                ),
              ),
            ),
          ),
          DataCell(Text(matches)),
          DataCell(Text(attendance)),
        ],
      );
}

class _TotalsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TotalItem('Total Jornadas', '14'),
        const SizedBox(height: 8.0),
        _TotalItem('Total Asistencias', '10'),
        const SizedBox(height: 8.0),
        _TotalItem('Total ausencias', '4'),
      ],
    );
  }
}

class _TotalItem extends StatelessWidget {
  final String label;
  final String value;

  const _TotalItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
