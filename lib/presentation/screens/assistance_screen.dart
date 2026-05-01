import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/presentation/providers/calendar_provider.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AssistanceScreen extends StatelessWidget {
  static const String name = '/assistance_screen';
  const AssistanceScreen({super.key});

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
        body: const _AssitanceView(),
      ),
    );
  }
}

class _AssitanceView extends ConsumerWidget {
  const _AssitanceView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(currentUserDisplayNameProvider);
    final assistanceState = ref.watch(assistanceProvider);
    final assistanceNotifier = ref.read(assistanceProvider.notifier);
    final categoriaAsync = ref.watch(jugadorCategoriaActualProvider);
    final resumenAsync = ref.watch(jugadorResumenProvider(null));
    final categoriaData = categoriaAsync.valueOrNull;
    final resumenData = resumenAsync.valueOrNull;
    final categoria = _extractCategoria(categoriaData) ?? '--';
    final asistencia =
        _extractAsistenciaPercent(resumenData) ??
        _extractAsistenciaPercent(categoriaData);
    final asistenciaLabel =
        asistencia == null ? '--' : '${asistencia.toStringAsFixed(0)}%';
    final asistenciaProgress =
        asistencia == null ? null : asistencia.clamp(0, 100) / 100;
    final monthTitle =
        '${toBeginningOfSentenceCase(DateFormat.MMMM('es_ES').format(assistanceState.focusedDay)).toUpperCase()} ${assistanceState.focusedDay.year}';
    final presentDays = _presentDaysForMonth(
      assistanceState.attendedDays,
      assistanceState.focusedDay,
    );
    final elapsedDays = _elapsedDaysForMonth(assistanceState.focusedDay);
    final unmarkedDays = (elapsedDays - presentDays).clamp(0, elapsedDays);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              displayName.trim().isEmpty ? 'Jugador' : displayName.trim(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF0B1926),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              Expanded(
                child: _PlayerMetricCard(
                  title: 'CATEGORÍA',
                  value: categoria,
                  accentColor: const Color(0xFFD94929),
                  icon: Icons.emoji_events_outlined,
                  actionLabel: 'VER HISTÓRICO',
                  onTap: () => context.push('/history_screen'),
                  isLoading: categoriaAsync.isLoading,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PlayerMetricCard(
                  title: 'TOTAL ASISTENCIA',
                  value: asistenciaLabel,
                  accentColor: const Color.fromRGBO(79, 166, 38, 1),
                  icon: Icons.fact_check_outlined,
                  progress: asistenciaProgress,
                  isLoading: resumenAsync.isLoading || categoriaAsync.isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            monthTitle,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF0B1926),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 22),
          _Calendar(
            assistanceState: assistanceState,
            assistanceNotifier: assistanceNotifier,
          ),
          const SizedBox(height: 18),
          _MonthlySummaryCard(
            presentDays: presentDays,
            unmarkedDays: unmarkedDays,
            registeredDays: presentDays,
          ),
        ],
      ),
    );
  }

  static String? _extractCategoria(Map<String, dynamic>? data) {
    if (data == null) return null;
    final direct = data['categoria'] ?? data['categoria_nombre'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    if (direct is Map) {
      final value = direct['nombre'] ?? direct['codigo'] ?? direct['categoria'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    final equipo = data['equipo'] ?? data['equipo_actual'];
    if (equipo is Map) {
      final value = equipo['categoria'] ?? equipo['categoria_nombre'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static double? _extractAsistenciaPercent(Map<String, dynamic>? data) {
    if (data == null) return null;
    const keys = [
      'porcentaje_asistencia',
      'asistencia_porcentaje',
      'ratio_asistencia',
      'total_asistencia',
      'porcentaje',
    ];
    for (final key in keys) {
      final value = data[key];
      final parsed = _asDouble(value);
      if (parsed != null) return parsed;
    }
    final asistencia = data['asistencia'];
    if (asistencia is Map) {
      for (final key in keys) {
        final parsed = _asDouble(asistencia[key]);
        if (parsed != null) return parsed;
      }
    }
    final resumen = data['resumen'];
    if (resumen is Map) {
      for (final key in keys) {
        final parsed = _asDouble(resumen[key]);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll('%', '').trim());
    }
    return null;
  }

  static int _presentDaysForMonth(List<DateTime> days, DateTime month) {
    return days
        .where((day) => day.year == month.year && day.month == month.month)
        .length;
  }

  static int _elapsedDaysForMonth(DateTime month) {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0).day;
    if (month.year == now.year && month.month == now.month) {
      return now.day.clamp(1, lastDayOfMonth);
    }
    final currentMonth = DateTime(now.year, now.month);
    final targetMonth = DateTime(month.year, month.month);
    if (targetMonth.isAfter(currentMonth)) {
      return 0;
    }
    return lastDayOfMonth;
  }
}

class _PlayerMetricCard extends StatelessWidget {
  const _PlayerMetricCard({
    required this.title,
    required this.value,
    required this.accentColor,
    required this.icon,
    this.actionLabel,
    this.onTap,
    this.progress,
    this.isLoading = false,
  });

  final String title;
  final String value;
  final Color accentColor;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onTap;
  final double? progress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(235, 228, 214, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 15, color: accentColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF0B1926),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                    if (progress != null) ...[
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          color: accentColor,
                          backgroundColor: const Color.fromRGBO(
                            231,
                            226,
                            216,
                            1,
                          ),
                        ),
                      ),
                    ] else if (actionLabel != null) ...[
                      const Spacer(),
                      InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD94929),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFD94929,
                                ).withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            actionLabel!,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
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

  final AssistanceState assistanceState;
  final AssistanceNotifier assistanceNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(235, 228, 214, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            headerVisible: false,
            pageAnimationEnabled: true,
            pageAnimationDuration: const Duration(milliseconds: 300),
            pageAnimationCurve: Curves.easeInOut,
            rowHeight: 37,
            daysOfWeekHeight: 28,
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: assistanceState.focusedDay,
            selectedDayPredicate: (_) => false,
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
                color: Color(0xFF55A06F),
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              weekendStyle: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
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
            onDaySelected: null,
            onPageChanged: (focusedDay) {
              assistanceNotifier.changeMonth(focusedDay);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: const [
              _LegendItem(label: 'Presente', color: Color(0xFF55A06F)),
              _LegendItem(label: 'Ausente', color: Color(0xFFD2AF35)),
              _LegendItem(label: 'Pendiente', color: Color(0xFF34495E)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.presentDays,
    required this.unmarkedDays,
    required this.registeredDays,
  });

  final int presentDays;
  final int unmarkedDays;
  final int registeredDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(235, 228, 214, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(79, 166, 38, 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Color.fromRGBO(79, 166, 38, 1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen del mes',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF0B1926),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryPill(
                  label: 'Presentes',
                  value: '$presentDays',
                  color: const Color.fromRGBO(79, 166, 38, 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryPill(
                  label: 'Registrados',
                  value: '$registeredDays',
                  color: const Color(0xFFD94929),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryPill(
                  label: 'Sin marca',
                  value: '$unmarkedDays',
                  color: const Color(0xFF34495E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(249, 248, 247, 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Los registros se actualizan cuando tu entrenador marca asistencia.',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.beVietnamPro(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
