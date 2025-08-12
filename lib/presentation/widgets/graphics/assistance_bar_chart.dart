import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AssistanceBarChart extends StatelessWidget {
  const AssistanceBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> data = [
      _ChartData('Enero', 22, Color.fromRGBO(2, 99, 255, 1)),
      _ChartData('Febrero', 16, Color.fromRGBO(255, 119, 35, 1)),
      _ChartData('Marzo', 27, Color.fromRGBO(142, 48, 225, 1)),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 30, interval: 7.5),
      series: <CartesianSeries<_ChartData, String>>[
        ColumnSeries<_ChartData, String>(
          dataSource: data,
          yValueMapper: (datum, _) => datum.y,
          xValueMapper: (datum, _) => datum.x,
          pointColorMapper: (datum, _) => datum.color,
          width: 0.3,
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
