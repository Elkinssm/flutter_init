import 'dart:io';

import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatelessWidget {
  static const String name = '/history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Mi Asistencia'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: const _HistoryView(),
      ),
    );
  }
}

class _HistoryView extends ConsumerStatefulWidget {
  const _HistoryView();

  @override
  ConsumerState<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<_HistoryView> {
  late int _selectedYear;
  final _currentYear = DateTime.now().year;

  // Mock: datos por año
  static const _dataByYear = {
    2026: [
      {'month': 'Enero', 'jornadas': 7, 'asistencia': 7},
      {'month': 'Febrero', 'jornadas': 4, 'asistencia': 3},
    ],
    2025: [
      {'month': 'Julio', 'jornadas': 6, 'asistencia': 5},
      {'month': 'Agosto', 'jornadas': 8, 'asistencia': 8},
      {'month': 'Septiembre', 'jornadas': 8, 'asistencia': 8},
      {'month': 'Octubre', 'jornadas': 8, 'asistencia': 7},
      {'month': 'Noviembre', 'jornadas': 6, 'asistencia': 6},
    ],
    2024: [
      {'month': 'Marzo', 'jornadas': 8, 'asistencia': 6},
      {'month': 'Abril', 'jornadas': 7, 'asistencia': 7},
      {'month': 'Mayo', 'jornadas': 8, 'asistencia': 5},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedYear = _currentYear;
  }

  List<int> get _years => _dataByYear.keys.toList()..sort((a, b) => b.compareTo(a));

  List<Map<String, dynamic>> get _months =>
      (_dataByYear[_selectedYear] ?? []).cast<Map<String, dynamic>>();

  int get _totalJornadas =>
      _months.fold<int>(0, (s, m) => s + (m['jornadas'] as int));
  int get _totalAsistencias =>
      _months.fold<int>(0, (s, m) => s + (m['asistencia'] as int));
  int get _totalAusencias => _totalJornadas - _totalAsistencias;
  int get _percentTotal =>
      _totalJornadas > 0 ? ((_totalAsistencias / _totalJornadas) * 100).round() : 0;

  @override
  Widget build(BuildContext context) {
    final displayName = ref.watch(currentUserDisplayNameProvider);
    final resumenAsync = ref.watch(jugadorResumenProvider(null));
    final asistenciaPercent = _extractAsistenciaPercent(resumenAsync.valueOrNull);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header con nombre y resumen ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1926),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        icon: Icons.fact_check_rounded,
                        color: const Color(0xFF16A34A),
                        label: 'Asistencia',
                        value: '$asistenciaPercent%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryPill(
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xFFD94929),
                        label: 'Año',
                        value: '$_selectedYear',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Filtro por año ──
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _years.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final year = _years[i];
                final isActive = year == _selectedYear;
                return GestureDetector(
                  onTap: () => setState(() => _selectedYear = year),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD94929)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFD94929)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD94929).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '$year',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Resumen Mensual ──
          Text(
            'Resumen Mensual',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B1926),
            ),
          ),
          const SizedBox(height: 12),

          if (_months.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'No hay datos para $_selectedYear',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...List.generate(_months.length, (i) {
              final m = _months[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < _months.length - 1 ? 10 : 0),
                child: _MonthCard(
                  month: m['month'] as String,
                  jornadas: m['jornadas'] as int,
                  asistencia: m['asistencia'] as int,
                  isCurrent: _selectedYear == _currentYear && i == _months.length - 1,
                ),
              );
            }),

          const SizedBox(height: 24),

          // ── Totales ──
          if (_months.isNotEmpty) ...[
            Text(
              'Totales',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1926),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _TotalRow(
                    icon: Icons.sports_rounded,
                    label: 'Total Jornadas',
                    value: '$_totalJornadas',
                    color: const Color(0xFFD94929),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _TotalRow(
                    icon: Icons.check_circle_rounded,
                    label: 'Total Asistencias',
                    value: '$_totalAsistencias',
                    color: const Color(0xFF16A34A),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _TotalRow(
                    icon: Icons.cancel_rounded,
                    label: 'Total Ausencias',
                    value: '$_totalAusencias',
                    color: const Color(0xFFDC2626),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Botón compartir PDF ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _months.isEmpty ? null : () => _sharePdf(displayName),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: Text(
                'Compartir reporte',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94929),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractAsistenciaPercent(Map<String, dynamic>? resumen) {
    if (resumen == null) return '$_percentTotal';

    final direct = resumen['asistencia_percent'] ?? resumen['porcentaje'];
    if (direct is num) return direct.toStringAsFixed(0);
    final directParsed = num.tryParse(direct?.toString() ?? '');
    if (directParsed != null) return directParsed.toStringAsFixed(0);

    final asistenciaRaw = resumen['asistencia'];
    if (asistenciaRaw is Map) {
      final asistencia = Map<String, dynamic>.from(asistenciaRaw);
      final nested = asistencia['porcentaje'] ?? asistencia['asistencia_percent'];
      if (nested is num) return nested.toStringAsFixed(0);
      final nestedParsed = num.tryParse(nested?.toString() ?? '');
      if (nestedParsed != null) return nestedParsed.toStringAsFixed(0);
    }

    return '$_percentTotal';
  }

  Future<void> _sharePdf(String playerName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Reporte de Asistencia',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  playerName,
                  style: pw.TextStyle(fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Año: $_selectedYear  ·  Asistencia: $_percentTotal%',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Tabla mensual
              pw.Text(
                'Resumen Mensual',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                headers: ['Mes', 'Jornadas', 'Asistencias', 'Faltas', '%'],
                data: _months.map((m) {
                  final j = m['jornadas'] as int;
                  final a = m['asistencia'] as int;
                  final f = j - a;
                  final p = j > 0 ? ((a / j) * 100).round() : 0;
                  return [
                    m['month'].toString(),
                    '$j',
                    '$a',
                    '$f',
                    '$p%',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 24),

              // Totales
              pw.Text(
                'Totales',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _pdfTotalRow('Total Jornadas', '$_totalJornadas'),
              _pdfTotalRow('Total Asistencias', '$_totalAsistencias'),
              _pdfTotalRow('Total Ausencias', '$_totalAusencias'),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generado por Coach App · ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/asistencia_${playerName.replaceAll(' ', '_')}_$_selectedYear.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte de asistencia de $playerName - $_selectedYear',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }

  pw.Widget _pdfTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 13)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGETS PRIVADOS
// ══════════════════════════════════════════════════════════

/// Pill de resumen (Asistencia %, Año).
class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de mes con barra de progreso.
class _MonthCard extends StatelessWidget {
  final String month;
  final int jornadas;
  final int asistencia;
  final bool isCurrent;

  const _MonthCard({
    required this.month,
    required this.jornadas,
    required this.asistencia,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final percent = jornadas > 0 ? asistencia / jornadas : 0.0;
    final ausencias = jornadas - asistencia;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: const Color(0xFFD94929), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    month,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD94929).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACTUAL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD94929),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${(percent * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: percent >= 0.8
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFCA8A04),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 0.8
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFCA8A04),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(
                label: 'Jornadas',
                value: '$jornadas',
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 16),
              _MiniStat(
                label: 'Asistencias',
                value: '$asistencia',
                color: const Color(0xFF16A34A),
              ),
              if (ausencias > 0) ...[
                const SizedBox(width: 16),
                _MiniStat(
                  label: 'Faltas',
                  value: '$ausencias',
                  color: const Color(0xFFDC2626),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini stat inline.
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Fila de total con icono.
class _TotalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _TotalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1926),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
