import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachScreen extends StatefulWidget {
  static const String name = '/coach_screen';
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        precacheImage(const AssetImage('assets/images/coach.png'), context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(openProfileDrawerProvider)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(openProfileDrawerProvider.notifier).state = false;
            _scaffoldKey.currentState?.openEndDrawer();
          });
        }
        return SafeArea(
          top: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
            appBar: CustomAppbar(
              title: 'Coach Dashboard',
              showBackButton: false,
            ),
            endDrawer: const ProfileDrawer(),
            bottomNavigationBar: const CustomBottomAppbar(),
            floatingActionButton: const CustomFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: const _CoachView(),
          ),
        );
      },
    );
  }
}

class _CoachView extends ConsumerWidget {
  const _CoachView();

  static const _chartColors = <Color>[
    Color.fromRGBO(2, 99, 255, 1),
    Color.fromRGBO(255, 119, 35, 1),
    Color.fromRGBO(142, 48, 225, 1),
    Color.fromRGBO(29, 185, 84, 1),
    Color.fromRGBO(255, 99, 132, 1),
    Color.fromRGBO(54, 162, 235, 1),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(coachDashboardProvider);

    if (dashboardAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardAsync.hasError) {
      final errorText = apiErrorMessage(
        dashboardAsync.error,
        defaultMessage: 'No se pudo cargar el dashboard. Intenta nuevamente.',
        forbiddenMessage: 'No tienes permisos para acceder a esta vista.',
      );
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(coachDashboardProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final dashboard = dashboardAsync.valueOrNull;
    final coachData = dashboard?['coach'] ?? dashboard?['entrenador'];
    final coachName = coachData is Map ? coachData['nombre']?.toString() : null;
    final resumen = dashboard?['resumen'] as Map<String, dynamic>?;
    final totalJugadores = resumen?['total_jugadores']?.toString() ?? '2';
    final totalEquipos = resumen?['total_equipos']?.toString() ?? '2';
    final totalCategorias =
        resumen?['total_categorias']?.toString() ?? totalEquipos;

    final asistenciaMesRaw =
        ((dashboard?['asistencia_por_mes'] ?? dashboard?['asistencia_mensual'])
            as List<dynamic>?) ??
        const [];
    final asistenciaSeries =
        asistenciaMesRaw.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final m =
              item is Map
                  ? Map<String, dynamic>.from(item)
                  : <String, dynamic>{};
          final mesRaw = m['mes']?.toString() ?? 'Mes';
          final mesLabel = _toMonthLabel(mesRaw);
          final percentageRaw = m['porcentaje_asistencia'] ?? m['porcentaje'];
          final value =
              (percentageRaw is num)
                  ? percentageRaw.toDouble()
                  : double.tryParse(percentageRaw?.toString() ?? '') ?? 0;
          return AssistanceChartPoint(
            label: mesLabel,
            value: value,
            color: _chartColors[idx % _chartColors.length],
          );
        }).toList();

    final mediaAsistencia =
        asistenciaSeries.isNotEmpty
            ? asistenciaSeries.map((e) => e.value).reduce((a, b) => a + b) /
                asistenciaSeries.length
            : 92.0;
    final mediaText = '${mediaAsistencia.toStringAsFixed(0)}%';
    final trend = _computeTrend(asistenciaSeries);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: maxWidthCenter(
        context: context,
        max: 880,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Saludo + foto del coach ──
                  _CoachGreeting(coachName: coachName ?? 'Jerome Bell'),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // ── Tu temporada: métricas con iconos ──
                  Text(
                    'Tu temporada',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.groups_rounded,
                          value: totalEquipos,
                          label: 'EQUIPOS',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.person_rounded,
                          value: totalJugadores,
                          label: 'JUGADORES',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.category_rounded,
                          value: totalCategorias,
                          label: 'CATEGORÍAS',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // ── Asistencia Semanal ──
                  _AsistenciaCard(
                    mediaText: mediaText,
                    trendText: trend.text,
                    trendColor: trend.color,
                    chartData: asistenciaSeries,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // ── Acciones Rápidas (grid 2×2 cuadradas) ──
                  Text(
                    'Acciones rápidas',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 14),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1,
                    children: [
                      _QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'Crear\njugador',
                        onTap: () => _showCategoryPicker(context, ref),
                      ),
                      _QuickAction(
                        icon: Icons.shield_rounded,
                        label: 'Mis\nequipos',
                        onTap: () => context.push('/my_teams_screen'),
                      ),
                      _QuickAction(
                        icon: Icons.category_rounded,
                        label: 'Categorías',
                        onTap: () => context.push('/category_screen'),
                      ),
                      _QuickAction(
                        icon: Icons.fact_check_rounded,
                        label: 'Asistencia',
                        onTap: () => context.push('/category_screen'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _toMonthLabel(String raw) {
    const monthNames = <String, String>{
      '01': 'Enero',
      '02': 'Febrero',
      '03': 'Marzo',
      '04': 'Abril',
      '05': 'Mayo',
      '06': 'Junio',
      '07': 'Julio',
      '08': 'Agosto',
      '09': 'Septiembre',
      '10': 'Octubre',
      '11': 'Noviembre',
      '12': 'Diciembre',
    };

    // Soporta "2026-02" o "2026-02-01"
    final parts = raw.split('-');
    if (parts.length >= 2) {
      return monthNames[parts[1]] ?? raw;
    }
    return raw;
  }

  static _TrendData _computeTrend(List<AssistanceChartPoint> points) {
    if (points.length < 2) {
      return const _TrendData(text: '+0.0%', color: Color(0xFF6B7280));
    }
    final last = points[points.length - 1].value;
    final prev = points[points.length - 2].value;
    final diff = last - prev;
    final sign = diff >= 0 ? '+' : '';
    final color = diff >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return _TrendData(text: '$sign${diff.toStringAsFixed(1)}%', color: color);
  }

  Future<void> _showCategoryPicker(BuildContext context, WidgetRef ref) async {
    List<Map<String, dynamic>> items = [];

    if (Environment.useBackend) {
      var loaderShown = false;
      try {
        loaderShown = true;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final data = await ref.read(coachApiServiceProvider).getCategorias();
        final list = data?['categorias'] as List<dynamic>? ?? [];
        items =
            list.map((e) {
              final m =
                  e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
              return m;
            }).toList();
      } catch (_) {
        // Si falla backend, usar fallback local
      } finally {
        if (loaderShown && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }

    if (items.isEmpty) {
      items = [
        {'id': 1, 'categoria': '2015', 'jugadores_count': 32},
        {'id': 2, 'categoria': '2014', 'jugadores_count': 27},
        {'id': 3, 'categoria': '2013', 'jugadores_count': 40},
        {'id': 4, 'categoria': '2012', 'jugadores_count': 55},
        {'id': 5, 'categoria': '2011', 'jugadores_count': 36},
      ];
    }

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const CustomText(
                text: 'Selecciona la categoría',
                fontWeight: FontWeight.w800,
                size: 18,
                color: Color.fromRGBO(11, 25, 38, 1),
              ),
              const SizedBox(height: 4),
              Text(
                '¿A qué categoría pertenecerá el nuevo estudiante?',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ...items.map((cat) {
                final label =
                    cat['categoria']?.toString() ??
                    cat['nombre']?.toString() ??
                    '—';
                final count =
                    cat['total_miembros'] ?? cat['jugadores_count'] ?? 0;
                final equipoId = cat['id'] ?? 0;
                return ListTile(
                  leading: const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFFD94929),
                  ),
                  title: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('$count miembros'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/new_player_screen', extra: equipoId);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGETS PRIVADOS
// ══════════════════════════════════════════════════════════

/// Saludo con énfasis: foto grande + card sutil de fondo.
class _CoachGreeting extends StatelessWidget {
  final String coachName;
  const _CoachGreeting({required this.coachName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = '¡Buenos días';
    } else if (hour < 18) {
      greeting = '¡Buenas tardes';
    } else {
      greeting = '¡Buenas noches';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto del coach grande con borde naranja
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD94929), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD94929).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/coach.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          // Saludo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coachName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1926),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD94929).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'TEMPORADA 2026',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD94929),
                      letterSpacing: 0.8,
                    ),
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

/// Tarjeta de métrica individual con icono.
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD94929).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD94929), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B1926),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de Asistencia Semanal.
class _AsistenciaCard extends StatelessWidget {
  const _AsistenciaCard({
    required this.mediaText,
    required this.trendText,
    required this.trendColor,
    required this.chartData,
  });

  final String mediaText;
  final String trendText;
  final Color trendColor;
  final List<AssistanceChartPoint> chartData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
                  Icon(
                    Icons.bar_chart_rounded,
                    color: const Color(0xFFD94929),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Asistencia Semanal',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trendText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$mediaText  Media de asistencia',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 130, child: AssistanceBarChart(data: chartData)),
        ],
      ),
    );
  }
}

class _TrendData {
  const _TrendData({required this.text, required this.color});
  final String text;
  final Color color;
}

/// Card cuadrada de acción rápida con icono grande y sombra.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD94929).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1926),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
