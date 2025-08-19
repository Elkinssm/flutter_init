import 'package:coach_app/presentation/providers/calendar_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AssistanceScreen extends StatelessWidget {
  static const String name = '/assistance_screen';
  const AssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _AssitanceView(),
    );
  }
}

class _AssitanceView extends ConsumerWidget {
  const _AssitanceView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final assistanceState = ref.watch(assistanceProvider);
    final assistanceNotifier = ref.read(assistanceProvider.notifier);

    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: size.height * 0.02),
            child: CustomTitleText(
              text: 'David\nBallesteros',
              size: 28,
              color: const Color.fromRGBO(11, 25, 38, 1),
              spacingText: 0.9,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            CustomCards(
              action: () => context.push('/history_screen'),
              title: 'Categoría',
              subtitle: '2012',
              textButton: 'Ver historico',
              sizeTextButton: 14,
            ),
            SizedBox(
              height: 120,
              width: 175,
              child: Card(
                color: const Color.fromRGBO(229, 240, 246, 1),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        CustomTitleText(
                          text: 'Total\nAsistencia',
                          size: 18,
                          color: const Color.fromRGBO(11, 25, 38, 1),
                        ),
                        const SizedBox(height: 12),
                        const CustomText(
                          text: '90%',
                          size: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Calendar(
          assistanceState: assistanceState,
          assistanceNotifier: assistanceNotifier,
        ),
      ],
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.assistanceState,
    required this.assistanceNotifier,
  });

  final AssistanceState assistanceState;
  final AssistanceNotifier assistanceNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4C77F), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: CustomText(
              text: 'Asistencia',
              fontWeight: FontWeight.bold,
              size: 18,
            ),
          ),
          TableCalendar(
            pageAnimationEnabled: true,
            pageAnimationDuration: Duration(milliseconds: 300),
            pageAnimationCurve: Curves.easeInOut,
            rowHeight: 38,
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: assistanceState.focusedDay,
            selectedDayPredicate:
                (day) => isSameDay(assistanceState.selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: Colors.black,
              ),
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1926),
              ),
              titleTextFormatter:
                  (date, locale) =>
                      '${toBeginningOfSentenceCase(DateFormat.MMMM(locale).format(date))} ${date.year}',
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0B1926),
              ),
              weekendTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0B1926),
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF55A06F),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF55A06F),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final isAttended = assistanceState.attendedDays.any(
                  (d) =>
                      d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day,
                );
                if (isAttended) {
                  return Center(
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Color(0xFF55A06F),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              assistanceNotifier.selectDay(selectedDay, focusedDay);
            },
            onPageChanged: (focusedDay) {
              assistanceNotifier.changeMonth(focusedDay);
            },
          ),
        ],
      ),
    );
  }
}
