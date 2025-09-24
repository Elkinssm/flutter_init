import 'package:coach_app/presentation/providers/calendar2_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PlayerStatusScreen extends StatelessWidget {
  static const String name = '/player_status_screen';
  final String names;
  final String image;
  const PlayerStatusScreen({
    super.key,
    required this.names,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Detalles del jugador'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _PlayerStatusView(playerName: names, playerImage: image),
      ),
    );
  }
}

class _PlayerStatusView extends ConsumerWidget {
  final String playerName;
  final String playerImage;
  const _PlayerStatusView({
    required this.playerName,
    required this.playerImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistanceState = ref.watch(assistanceProvider2);
    final assistanceNotifier = ref.read(assistanceProvider2.notifier);

    return SingleChildScrollView(
      child: maxWidthCenter(
        context: context,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(27, 71, 56, 1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 89,
                    height: 96,
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.5),
                        child: Image.asset(
                          playerImage,
                          fit: BoxFit.cover,
                          cacheWidth: 128,
                          cacheHeight: 128,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: hp(context, 0.015)),
              CustomText(
                text: playerName,
                textAlign: TextAlign.center,
                size: ts(context, 22),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B1926),
              ),
              SizedBox(height: hp(context, 0.01)),
              CustomText(
                text: 'U12 - Mes Actual',
                size: ts(context, 13),
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: hp(context, 0.02)),
              CustomText(
                text:
                    'Total sesiones: 9  ·  Asistencia: 7  ·  % Asistencia: 77%',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
                size: ts(context, 13),
                color: Colors.black87,
              ),
              SizedBox(height: hp(context, 0.05)),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomText(
                  text: 'Asistencia',
                  size: ts(context, 18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1926),
                ),
              ),
              SizedBox(height: 25),
              _Calendar(
                assistanceState: assistanceState,
                assistanceNotifier: assistanceNotifier,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.assistanceState,
    required this.assistanceNotifier,
  });

  final Assistance2State assistanceState;
  final AssistanceNotifier assistanceNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(203, 213, 225, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
          TableCalendar(
            pageAnimationEnabled: true,
            pageAnimationDuration: const Duration(milliseconds: 300),
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
              titleTextStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              titleTextFormatter:
                  (date, locale) =>
                      '${toBeginningOfSentenceCase(DateFormat.MMMM(locale).format(date))} ${date.year}',
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0B1926),
              ),
              weekendTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0B1926),
              ),
              todayDecoration: const BoxDecoration(
                color: Color(0xFF55A06F),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color.fromRGBO(232, 64, 54, 1),
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
                      width: 27,
                      height: 27,
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
