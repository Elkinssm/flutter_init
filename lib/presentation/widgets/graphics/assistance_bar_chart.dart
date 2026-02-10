import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AssistanceChartPoint {
  const AssistanceChartPoint({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class AssistanceBarChart extends StatelessWidget {
  const AssistanceBarChart({super.key, this.data});

  final List<AssistanceChartPoint>? data;

  static const _fallbackData = <AssistanceChartPoint>[
    AssistanceChartPoint(
      label: 'Enero',
      value: 22,
      color: Color.fromRGBO(2, 99, 255, 1),
    ),
    AssistanceChartPoint(
      label: 'Febrero',
      value: 16,
      color: Color.fromRGBO(255, 119, 35, 1),
    ),
    AssistanceChartPoint(
      label: 'Marzo',
      value: 27,
      color: Color.fromRGBO(142, 48, 225, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final points = (data == null || data!.isEmpty) ? _fallbackData : data!;

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 30, interval: 7.5),
      series: <CartesianSeries<AssistanceChartPoint, String>>[
        ColumnSeries<AssistanceChartPoint, String>(
          dataSource: points,
          yValueMapper: (datum, _) => datum.value,
          xValueMapper: (datum, _) => datum.label,
          pointColorMapper: (datum, _) => datum.color,
          width: 0.3,
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}
