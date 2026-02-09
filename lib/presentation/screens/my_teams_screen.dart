import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/screens/selected_team_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
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

  // Datos mock de equipos (después se reemplaza con datos del backend)
  final _allTeams = [
    _TeamData(
      image: 'assets/images/club_roma.png',
      name: 'Futbol Club Roma',
      players: 6,
      category: 'Sub-21',
    ),
    _TeamData(
      image: 'assets/images/ajaz_fc.png',
      name: 'Ajax Fc',
      players: 6,
      category: 'Sub-21',
    ),
    _TeamData(
      image: 'assets/images/manchester_icon.png',
      name: 'Manchester FC',
      players: 8,
      category: 'Sub-20',
    ),
    _TeamData(
      image: 'assets/images/paris_icon.png',
      name: 'Paris Academy',
      players: 10,
      category: 'Sub-20',
    ),
  ];

  List<_TeamData> get _filteredTeams {
    if (_selectedFilter == 'Todos') return _allTeams;
    return _allTeams.where((t) => t.category == _selectedFilter).toList();
  }

  List<String> get _categories {
    final cats = _allTeams.map((t) => t.category).toSet().toList()..sort();
    return ['Todos', ...cats];
  }

  int get _totalPlayers =>
      _allTeams.fold<int>(0, (sum, t) => sum + t.players);

  @override
  Widget build(BuildContext context) {
    final teams = _filteredTeams;

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

              // ── Panel de Control ──
              _SummaryBanner(
                totalTeams: _allTeams.length,
                totalPlayers: _totalPlayers,
              ),

              const SizedBox(height: 18),

              // ── Filtros por categoría ──
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
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

              // ── Grid de equipos ──
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
                  itemCount: teams.length + 1, // +1 para la tarjeta "Crear"
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (_, i) {
                    // Última tarjeta = botón crear
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
                          extra: t.name,
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
  }
}

// ── Modelo local ──
class _TeamData {
  final String image;
  final String name;
  final int players;
  final String category;

  const _TeamData({
    required this.image,
    required this.name,
    required this.players,
    required this.category,
  });
}

// ── Banner de resumen ──
class _SummaryBanner extends StatelessWidget {
  final int totalTeams;
  final int totalPlayers;

  const _SummaryBanner({
    required this.totalTeams,
    required this.totalPlayers,
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
              const _SummaryItem(value: '4', label: 'Entrenos'),
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
                  child: Image.asset(
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
