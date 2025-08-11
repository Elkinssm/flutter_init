import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChart extends StatelessWidget {
  const LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> data = [
      _ChartData('Enero', 22),
      _ChartData('Febrero', 37),
      _ChartData('Marzo', 52),
      _ChartData('Abril', 38),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0, maximum: 100, interval: 25),
      series: <CartesianSeries<_ChartData, String>>[
        LineSeries<_ChartData, String>(
          dataSource: data,
          xValueMapper: (datum, _) => datum.x,
          yValueMapper: (datum, _) => datum.y,
          color: Colors.green,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: Colors.green,
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}
