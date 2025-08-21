import 'package:coach_app/presentation/widgets/widgets.dart';
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
              child: CustomText(
                text: 'Resumen Mensual',
                size: 18,
                fontWeight: FontWeight.w700,
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
                  blurRadius: 8,
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
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
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
            child: CustomText(
              text: month,
              size: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomText(
                      text: 'Jornadas',
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'Asistencia',
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: jornadas,
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: asistencia,
                      size: 15,
                      fontWeight: FontWeight.w700,
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
