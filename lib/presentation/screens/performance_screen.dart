import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PerformanceScreen extends StatelessWidget {
  static const String name = '/performance_screen';
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const _PerformanceView(),
    );
  }
}

class _PerformanceView extends StatelessWidget {
  const _PerformanceView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 16.0),
          const _DataSelector(),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 300,
            child: _LineChart(),
          ),
          const SizedBox(height: 16.0),
          const _DataSelector(),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 300,
            child: _BarChart(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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

class _DataSelector extends StatefulWidget {
  const _DataSelector();

  @override
  State<_DataSelector> createState() => _DataSelectorState();
}

class _DataSelectorState extends State<_DataSelector> {
  String _selectedValue = 'Seleccionar';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<String>(
          value: _selectedValue,
          items: const [
            DropdownMenuItem(value: 'Seleccionar', child: Text('Seleccionar')),
            DropdownMenuItem(value: 'Peso', child: Text('Peso')),
            DropdownMenuItem(value: 'IMC', child: Text('IMC')),
            DropdownMenuItem(value: 'Estatura', child: Text('Estatura')),
            DropdownMenuItem(value: 'Velocidad', child: Text('Velocidad')),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue ?? 'Seleccionar';
            });
          },
        ),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<_ChartData> data = [
      _ChartData('Enero', 75),
      _ChartData('Febrero', 80),
      _ChartData('Marzo', 70),
      _ChartData('Abril', 90),
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
          markerSettings: const MarkerSettings(isVisible: true, color: Colors.green),
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

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<_BarChartData> data = [
      _BarChartData('Categoría 1', 39, Colors.blue),
      _BarChartData('Categoría 2', 88, Colors.orange),
      _BarChartData('Categoría 3', 60, Colors.purple),
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

class _MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Peso'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: Colors.red),
          ListTile(
            title: const Text('IMC'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: Colors.red),
          ListTile(
            title: const Text('Estatura'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: Colors.red),
          ListTile(
            title: const Text('Velocidad'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}