import 'package:flutter/material.dart';

class MonthlySummaary extends StatelessWidget {
  const MonthlySummaary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(228, 242, 255, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Color.fromRGBO(212, 175, 55, 1)),
                left: BorderSide(color: Color.fromRGBO(212, 175, 55, 1)),
                right: BorderSide(color: Color.fromRGBO(212, 175, 55, 1)),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: const Center(
              child: Text(
                'Resumen Mensual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(228, 242, 255, 1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: const Color.fromRGBO(212, 175, 55, 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Table(
                border: TableBorder(
                  horizontalInside: const BorderSide(
                    color: Colors.black26,
                    width: 1,
                  ),
                  verticalInside: const BorderSide(
                    color: Colors.black26,
                    width: 1,
                  ),
                  top: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  _buildMonthRow(
                    month: 'Julio',
                    jornadas: '6',
                    asistencia: '5',
                    highlight: true,
                  ),
                  _buildMonthRow(
                    month: 'Agosto',
                    jornadas: '8',
                    asistencia: '8',
                  ),
                  _buildMonthRow(
                    month: 'Septiembre',
                    jornadas: '8',
                    asistencia: '8',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TableRow _buildMonthRow({
  required String month,
  required String jornadas,
  required String asistencia,
  bool highlight = false,
}) {
  return TableRow(
    children: [
      /// Columna Mes
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60), // altura mínima
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration:
              highlight
                  ? BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  )
                  : null,
          child: Center(
            child: Text(
              month,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      /// Columna combinada (Textos + Valores)
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60), // altura mínima igual
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              /// Textos
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jornadas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Asistencia',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// Valores
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      jornadas,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asistencia,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
