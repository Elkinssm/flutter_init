import 'package:flutter/material.dart';

class TableStats extends StatelessWidget {
  const TableStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(250, 244, 234, 1),
          border: Border.all(color: const Color.fromRGBO(212, 175, 55, 1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: const [
            _TotalRow(label: 'Total Jornadas', value: '14', isLast: false),
            _TotalRow(label: 'Total Asistencias', value: '10', isLast: false),
            _TotalRow(label: 'Total ausencias', value: '4', isLast: true),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : const Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(212, 175, 55, 1),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
