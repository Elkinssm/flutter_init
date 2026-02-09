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
  const SelectedTeamScreen({super.key, required this.teamName});
  final String teamName;

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
        body: _SelectedTeamView(),
      ),
    );
  }
}

class _SelectedTeamView extends ConsumerWidget {
  const _SelectedTeamView();

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
        content = const _PartidosSection();
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
  const _PartidosSection();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            // ── Botón crear partido ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed('/new_match_screen');
                },
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: Text(
                  'Crear partido',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94929),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Próximos partidos ──
            const CustomText(
              text: 'Próximos partidos',
              fontWeight: FontWeight.w700,
              size: 16,
            ),
            const SizedBox(height: 10),
            CustomNextMatchCard(
              image: 'assets/images/manchester_icon.png',
              teamName: 'Vs Manchester (local)',
              date: 'Sábado 10 Abril, 4:00 pm',
            ),
            const SizedBox(height: 3),
            CustomNextMatchCard(
              image: 'assets/images/paris_icon.png',
              teamName: 'Vs Paris (visitante)',
              date: 'Sábado 22 Abril, 2:00 pm',
            ),

            const SizedBox(height: 24),

            // ── Historial de partidos ──
            const CustomText(
              text: 'Historial de partidos',
              fontWeight: FontWeight.w700,
              size: 16,
            ),
            const SizedBox(height: 10),

            _MatchHistoryTile(
              rival: 'Vs Real Madrid',
              date: '12 Mar 2026',
              resultado: '2 - 1',
              isVictory: true,
            ),
            const SizedBox(height: 8),
            _MatchHistoryTile(
              rival: 'Vs Bayern Munich',
              date: '28 Feb 2026',
              resultado: '0 - 3',
              isVictory: false,
            ),
            const SizedBox(height: 8),
            _MatchHistoryTile(
              rival: 'Vs Juventus',
              date: '14 Feb 2026',
              resultado: '1 - 1',
              isVictory: null, // Empate
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
