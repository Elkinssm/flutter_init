import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/screens/selected_team_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTeamsScreen extends StatelessWidget {
  static const String name = '/my_teams_screen';
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: const CustomAppbar(title: 'Mis equipos'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: const _MyTeamsView(),
      ),
    );
  }
}

class _MyTeamsView extends StatefulWidget {
  const _MyTeamsView();

  @override
  State<_MyTeamsView> createState() => _MyTeamsViewState();
}

class _MyTeamsViewState extends State<_MyTeamsView> {
  String _selectedFilter = 'Todos';

  static final _mockTeams = [
    _TeamData(
      id: 1,
      image: 'assets/images/club_roma.png',
      name: 'Futbol Club Roma',
      players: 6,
      category: 'Sub-21',
    ),
    _TeamData(
      id: 2,
      image: 'assets/images/ajaz_fc.png',
      name: 'Ajax Fc',
      players: 6,
      category: 'Sub-21',
    ),
    _TeamData(
      id: 3,
      image: 'assets/images/manchester_icon.png',
      name: 'Manchester FC',
      players: 8,
      category: 'Sub-20',
    ),
    _TeamData(
      id: 4,
      image: 'assets/images/paris_icon.png',
      name: 'Paris Academy',
      players: 10,
      category: 'Sub-20',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final categoriasAsync = ref.watch(coachCategoriasProvider);
        final dashboardAsync = ref.watch(coachDashboardProvider);

        List<_TeamData> allTeams = Environment.useBackend ? <_TeamData>[] : _mockTeams;
        if (Environment.useBackend) {
          final raw = categoriasAsync.valueOrNull?['categorias'] as List<dynamic>? ?? const [];
          if (raw.isNotEmpty) {
            final mapped = raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .map((m) => _TeamData(
                      id: (m['id'] as num?)?.toInt() ?? 0,
                      image: _fallbackAssetForId((m['id'] as num?)?.toInt() ?? 0),
                      name: m['nombre']?.toString() ?? 'Equipo',
                      players: (m['total_miembros'] as num?)?.toInt() ?? 0,
                      category: m['categoria']?.toString() ?? 'Sin categoría',
                      logoUrl: _normalizeImageUrl(m['escudo_url']?.toString()),
                    ))
                .toList();
            if (mapped.isNotEmpty) {
              allTeams = mapped;
            }
          }
        }

        final categories = _buildCategories(allTeams);
        if (!categories.contains(_selectedFilter)) {
          _selectedFilter = 'Todos';
        }

        final teams = _selectedFilter == 'Todos'
            ? allTeams
            : allTeams.where((t) => t.category == _selectedFilter).toList();

        final totalPlayers = allTeams.fold<int>(0, (sum, t) => sum + t.players);
        final totalTeams = allTeams.length;
        final totalEntrenos = _extractEntrenos(
          dashboardAsync.valueOrNull,
          useBackend: Environment.useBackend,
        );

        if (Environment.useBackend &&
            categoriasAsync.isLoading &&
            categoriasAsync.valueOrNull == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (Environment.useBackend &&
            categoriasAsync.hasError &&
            categoriasAsync.valueOrNull == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 42),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    apiErrorMessage(
                      categoriasAsync.error,
                      defaultMessage:
                          'No se pudieron cargar los equipos. Intenta de nuevo.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.invalidate(coachCategoriasProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: maxWidthCenter(
            context: context,
            max: 880,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  _SummaryBanner(
                    totalTeams: totalTeams,
                    totalPlayers: totalPlayers,
                    totalEntrenos: totalEntrenos,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final isActive = cat == _selectedFilter;
                        return _FilterChip(
                          label: cat,
                          isActive: isActive,
                          onTap: () => setState(() => _selectedFilter = cat),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (teams.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No hay equipos en esta categoría',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teams.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (_, i) {
                        if (i == teams.length) {
                          return _CreateTeamCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Crear equipo (próximamente)'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        }

                        final t = teams[i];
                        return _TeamGridCard(
                          team: t,
                          onTap: () {
                            context.pushNamed(
                              SelectedTeamScreen.name,
                              extra: {
                                'teamName': t.name,
                                'equipoId': t.id,
                              },
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Modelo local ──
class _TeamData {
  final int id;
  final String image;
  final String name;
  final int players;
  final String category;
  final String? logoUrl;

  const _TeamData({
    required this.id,
    required this.image,
    required this.name,
    required this.players,
    required this.category,
    this.logoUrl,
  });
}

// ── Banner de resumen ──
class _SummaryBanner extends StatelessWidget {
  final int totalTeams;
  final int totalPlayers;
  final int totalEntrenos;

  const _SummaryBanner({
    required this.totalTeams,
    required this.totalPlayers,
    required this.totalEntrenos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD94929), Color(0xFFE86A4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD94929).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN DE TEMPORADA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Panel de Control',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryItem(value: '$totalTeams', label: 'Equipos'),
              _divider(),
              _SummaryItem(value: '$totalPlayers', label: 'Jugadores'),
              _divider(),
              _SummaryItem(value: '$totalEntrenos', label: 'Entrenos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white30,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// ── Chip de filtro ──
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD94929) : const Color(0xFFF5F0E6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFD94929) : const Color(0xFFE0D6C8),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFD94929).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF374957),
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta de equipo en grid ──
class _TeamGridCard extends StatelessWidget {
  final _TeamData team;
  final VoidCallback onTap;

  const _TeamGridCard({required this.team, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo del equipo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: (team.logoUrl ?? '').isNotEmpty
                      ? Image.network(
                          team.logoUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            team.image,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          team.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shield,
                            size: 32,
                            color: Color(0xFFD94929),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nombre del equipo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                team.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1926),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),

            // Jugadores
            Text(
              '${team.players} Jugadores',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),

            // Badge de categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD94929).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                team.category,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD94929),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _buildCategories(List<_TeamData> teams) {
  final cats = teams.map((t) => t.category).toSet().toList()..sort();
  return ['Todos', ...cats];
}

int _extractEntrenos(Map<String, dynamic>? dashboard, {required bool useBackend}) {
  final resumen = dashboard?['resumen'];
  if (resumen is Map) {
    final r = Map<String, dynamic>.from(resumen);
    final total = (r['total_entrenamientos'] as num?)?.toInt();
    if (total != null) return total;
  }
  final proximos = dashboard?['proximos_entrenamientos'];
  if (proximos is List) return proximos.length;
  return useBackend ? 0 : 4;
}

String _fallbackAssetForId(int id) {
  const assets = [
    'assets/images/club_roma.png',
    'assets/images/ajaz_fc.png',
    'assets/images/manchester_icon.png',
    'assets/images/paris_icon.png',
  ];
  return assets[id.abs() % assets.length];
}

String? _normalizeImageUrl(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty || v.toLowerCase() == 'null') return null;
  if (v.startsWith('http://localhost')) {
    return v.replaceFirst(
      'http://localhost',
      '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
    );
  }
  if (v.startsWith('https://localhost')) {
    return v.replaceFirst(
      'https://localhost',
      '${Environment.backendScheme}://${Environment.backendHost}:${Environment.backendPort}',
    );
  }
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  if (v.startsWith('/')) return '${Environment.baseUrl}$v';
  return '${Environment.baseUrl}/$v';
}

// ── Tarjeta para crear nuevo equipo ──
class _CreateTeamCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateTeamCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD94929).withValues(alpha: 0.4),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFD94929).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 30,
                color: Color(0xFFD94929),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crear equipo',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD94929),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
