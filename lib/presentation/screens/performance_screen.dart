import 'package:coach_app/presentation/providers/selected_value_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceScreen extends StatelessWidget {
  static const String name = '/performance_screen';
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'User'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const _PerformanceView(),
    );
  }
}

class _PerformanceView extends ConsumerWidget {
  const _PerformanceView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: CustomTitleText(
              text: 'David\nBallesteros',
              size: 28,
              color: const Color.fromRGBO(11, 25, 38, 1),
            ),
          ),
          const SizedBox(height: 35),
          DataSelector(provider: selectedValueLineChartProvider),
          const SizedBox(height: 20),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(245, 240, 230, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: LineChart(),
            ),
          ),
          const SizedBox(height: 20),
          DataSelector(provider: selectedValueBarChartProvider),
          const SizedBox(height: 20),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(229, 240, 246, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: BarChart(),
            ),
          ),
        ],
      ),
    );
  }
}
