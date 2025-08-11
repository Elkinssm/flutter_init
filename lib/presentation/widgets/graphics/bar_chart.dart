import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarChart extends StatelessWidget {
  const BarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_BarChartData> data = [
      _BarChartData('40', 60, Color.fromRGBO(142, 48, 225, 1)),
      _BarChartData('20', 88, Color.fromRGBO(255, 119, 35, 1)),
      _BarChartData('10', 39, Color.fromRGBO(2, 99, 255, 1)),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 100, interval: 25),
      series: <CartesianSeries<_BarChartData, String>>[
        BarSeries<_BarChartData, String>(
          dataSource: data,
          xValueMapper: (datum, _) => datum.x,
          yValueMapper: (datum, _) => datum.y,
          pointColorMapper: (datum, _) => datum.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class _BarChartData {
  _BarChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
