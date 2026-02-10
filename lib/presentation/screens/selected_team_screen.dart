import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/helpers/hepler_aligment.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/selected_buttons_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectedTeamScreen extends ConsumerStatefulWidget {
  static const String name = '/selected_team_screen';
  const SelectedTeamScreen({super.key, required this.teamName, this.equipoId});
  final String teamName;
  final int? equipoId;

  @override
  ConsumerState<SelectedTeamScreen> createState() => _SelectedTeamScreenState();
}

class _SelectedTeamScreenState extends ConsumerState<SelectedTeamScreen> {
  @override
  void initState() {
    super.initState();
    // Siempre arrancar en "Inicio" al entrar al equipo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedMenuProvider.notifier).state = 'Inicio';

      const avatars = [
        'assets/images/student-eg1-icon.png',
        'assets/images/student-eg2-icon.png',
        'assets/images/student-eg3-icon.png',
        'assets/images/student-eg4-icon.png',
        'assets/images/student-eg5-icon.png',
        'assets/images/student-eg6-icon.png',
      ];
      for (final a in avatars) {
        precacheImage(AssetImage(a), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: widget.teamName),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: _SelectedTeamView(teamName: widget.teamName, equipoId: widget.equipoId),
      ),
    );
  }
}

class _SelectedTeamView extends ConsumerWidget {
  const _SelectedTeamView({required this.teamName, this.equipoId});
  final String teamName;
  final int? equipoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMenuProvider);

    Widget content;
    switch (selected) {
      case 'Inicio':
        content = const _TeamOverviewSection();
        break;
      case 'Alineación':
        content = Expanded(child: HeplerAligment());
        break;
      case 'Partidos':
        content = _PartidosSection(equipoId: equipoId);
        break;
      default:
        content = const SizedBox();
    }

    return maxWidthCenter(
      context: context,
      max: 880,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(child: CustomActionButtonWidget(label: 'Inicio', onPressed: () {})),
                Expanded(child: CustomActionButtonWidget(label: 'Alineación', onPressed: () {})),
                Expanded(child: CustomActionButtonWidget(label: 'Partidos', onPressed: () {})),
              ],
            ),
            const SizedBox(height: 10),
            content,
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Sección combinada: detalles del equipo + listado de jugadores.
class _TeamOverviewSection extends StatelessWidget {
  const _TeamOverviewSection();

  @override
  Widget build(BuildContext context) {
    final count = SelectedListviewPlayers.playerCount;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            // ── Detalles del equipo ──
            const CustomText(
              text: 'Detalles del equipo',
              fontWeight: FontWeight.w700,
              size: 16,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButtonCard(
                    width: double.infinity,
                    height: 75,
                    titleText: '$count',
                    subtitleText: 'Integrantes',
                    titleTextSize: 18,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomButtonCard(
                    width: double.infinity,
                    height: 75,
                    titleText: 'Sub-21',
                    subtitleText: 'Categoría',
                    titleTextSize: 18,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Récord de temporada
            Row(
              children: [
                Expanded(
                  child: CustomButtonCard(
                    width: double.infinity,
                    height: 75,
                    titleText: '3V · 1E · 1D',
                    subtitleText: 'Récord',
                    titleTextSize: 16,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomButtonCard(
                    width: double.infinity,
                    height: 75,
                    titleText: 'Sáb 10 Abr',
                    subtitleText: 'Próximo partido',
                    titleTextSize: 16,
                    subtitleTextSize: 13,
                    fontWeightT2: FontWeight.w400,
                    isContentLeft: true,
                    spacing: 18,
                    isInfoCard: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Jugadores del equipo ──
            CustomText(
              text: 'Jugadores ($count)',
              fontWeight: FontWeight.w700,
              size: 16,
            ),
            const SizedBox(height: 8),
            const SelectedListviewPlayers(),
          ],
        ),
      ),
    );
  }
}

/// Sección de Partidos: crear partido + próximos + historial.
class _PartidosSection extends StatelessWidget {
  const _PartidosSection({this.equipoId});
  final int? equipoId;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final partidosAsync = equipoId == null
            ? ref.watch(coachPartidosProvider)
            : ref.watch(coachPartidosByEquipoProvider(equipoId!));

        final partidos = ((partidosAsync.valueOrNull?['partidos'] as List<dynamic>?) ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        final now = DateTime.now();
        final proximos = <Map<String, dynamic>>[];
        final historico = <Map<String, dynamic>>[];

        for (final p in partidos) {
          final fecha = DateTime.tryParse(p['fecha']?.toString() ?? '');
          final tieneResultado = (p['resultado']?.toString().trim().isNotEmpty ?? false);
          if (tieneResultado) {
            historico.add(p);
          } else if (fecha == null || !fecha.isBefore(now)) {
            proximos.add(p);
          } else {
            historico.add(p);
          }
        }

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => context.pushNamed('/new_match_screen', extra: equipoId),
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    label: Text(
                      'Crear partido',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94929),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const CustomText(text: 'Próximos partidos', fontWeight: FontWeight.w700, size: 16),
                const SizedBox(height: 10),
                if (partidosAsync.isLoading && partidosAsync.valueOrNull == null)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ))
                else if (proximos.isEmpty)
                  Text('No hay próximos partidos', style: GoogleFonts.inter(color: const Color(0xFF6B7280)))
                else ...proximos.take(5).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: CustomNextMatchCard(
                        image: 'assets/images/manchester_icon.png',
                        teamName: 'Vs ${p['rival'] ?? 'Rival'} (${(p['es_local'] == true) ? 'local' : 'visitante'})',
                        date: _formatPartidoDate(p['fecha']?.toString(), p['hora']?.toString()),
                      ),
                    )),
                const SizedBox(height: 24),
                const CustomText(text: 'Historial de partidos', fontWeight: FontWeight.w700, size: 16),
                const SizedBox(height: 10),
                if (historico.isEmpty)
                  Text('Sin historial todavía', style: GoogleFonts.inter(color: const Color(0xFF6B7280)))
                else ...historico.take(10).map((p) {
                  final resultado = p['resultado']?.toString() ?? '--';
                  final diff = _resultDiff(resultado);
                  bool? isVictory;
                  if (diff == null) {
                    isVictory = null;
                  } else if (diff > 0) {
                    isVictory = true;
                  } else if (diff < 0) {
                    isVictory = false;
                  } else {
                    isVictory = null;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MatchHistoryTile(
                      rival: 'Vs ${p['rival'] ?? 'Rival'}',
                      date: _formatShortDate(p['fecha']?.toString()),
                      resultado: resultado,
                      isVictory: isVictory,
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatPartidoDate(String? rawDate, String? rawHora) {
    final d = DateTime.tryParse(rawDate ?? '');
    if (d == null) return rawDate ?? 'Fecha por definir';
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    String hora = '';
    if ((rawHora ?? '').isNotEmpty) {
      final hh = rawHora!.split(':');
      if (hh.length >= 2) {
        var h = int.tryParse(hh[0]) ?? 0;
        final m = hh[1];
        final isPm = h >= 12;
        if (h == 0) h = 12;
        if (h > 12) h -= 12;
        hora = ', $h:$m ${isPm ? 'pm' : 'am'}';
      }
    }
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}$hora';
  }

  static String _formatShortDate(String? rawDate) {
    final d = DateTime.tryParse(rawDate ?? '');
    if (d == null) return rawDate ?? '--';
    const m = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  static int? _resultDiff(String resultado) {
    final parts = resultado.split('-').map((e) => e.trim()).toList();
    if (parts.length != 2) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) return null;
    return a - b;
  }
}

/// Tile de historial de un partido jugado.
class _MatchHistoryTile extends StatelessWidget {
  final String rival;
  final String date;
  final String resultado;
  final bool? isVictory; // true=victoria, false=derrota, null=empate

  const _MatchHistoryTile({
    required this.rival,
    required this.date,
    required this.resultado,
    required this.isVictory,
  });

  @override
  Widget build(BuildContext context) {
    final Color tagColor;
    final String tagLabel;

    if (isVictory == true) {
      tagColor = const Color(0xFF16A34A);
      tagLabel = 'Victoria';
    } else if (isVictory == false) {
      tagColor = const Color(0xFFDC2626);
      tagLabel = 'Derrota';
    } else {
      tagColor = const Color(0xFFF59E0B);
      tagLabel = 'Empate';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rival,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Resultado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                resultado,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1926),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tagLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
