import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/table/monthly_summaary.dart';

class HistoryScreen extends StatelessWidget {
  static const String name = '/history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Jugador'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: const _HistoryView(),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        const SizedBox(height: 18),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: size.height * 0.02),
            child: CustomTitleText(
              text: 'David\nBallesteros',
              size: 28,
              color: const Color.fromRGBO(11, 25, 38, 1),
              fontWeight: FontWeight.w800,
              spacingText: 0.9,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Card(
            color: const Color.fromRGBO(245, 240, 230, 1),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color.fromRGBO(212, 175, 55, 1),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: 80,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.amber.shade700,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          CustomText(
                            text: 'Asistencia',
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                          CustomText(
                            text: '90%',
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          CustomText(
                            text: 'Año',
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                          CustomText(
                            text: '2024',
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const MonthlySummaary(),
        const SizedBox(height: 28),
        const TableStats(),
      ],
    );
  }
}
