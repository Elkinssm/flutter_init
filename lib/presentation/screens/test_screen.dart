import 'package:coach_app/config/domain/player.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/widgets/players/coach_card.dart';
import 'package:coach_app/presentation/widgets/players/player_photo_marker.dart';
import 'package:coach_app/presentation/widgets/texts/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MOCK DATA: Ahora organizado por formación ---
final Map<String, List<Player>> formations = {
  '4-3-3': [
    Player(
      id: '1',
      name: 'Alisson',
      number: '1',
      position: 'Portero',
      photoPath: 'assets/images/player.png',
      top: 0.05,
      left: 0,
      right: 0,
    ),
    Player(
      id: '2',
      name: 'Robertson',
      number: '26',
      position: 'Lateral Izquierdo',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      left: 0.25,
    ),
    Player(
      id: '3',
      name: 'Van Dijk',
      number: '4',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      left: 0.38,
    ),
    Player(
      id: '4',
      name: 'Konaté',
      number: '5',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      right: 0.38,
    ),
    Player(
      id: '5',
      name: 'Arnold',
      number: '66',
      position: 'Lateral Derecho',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      right: 0.25,
    ),
    Player(
      id: '6',
      name: 'Thiago',
      number: '6',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      left: 0.31,
    ),
    Player(
      id: '7',
      name: 'Fabinho',
      number: '3',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.45,
      left: 0,
      right: 0,
    ),
    Player(
      id: '8',
      name: 'Jones',
      number: '17',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      right: 0.31,
    ),
    Player(
      id: '9',
      name: 'Díaz',
      number: '23',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.6,
      left: 0.25,
    ),
    Player(
      id: '10',
      name: 'Núñez',
      number: '9',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.65,
      left: 0,
      right: 0,
    ),
    Player(
      id: '11',
      name: 'Salah',
      number: '11',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.6,
      right: 0.25,
    ),
  ],
  '4-4-2': [
    Player(
      id: '1',
      name: 'Alisson',
      number: '1',
      position: 'Portero',
      photoPath: 'assets/images/player.png',
      top: 0.05,
      left: 0,
      right: 0,
    ),
    Player(
      id: '2',
      name: 'Robertson',
      number: '26',
      position: 'Lateral Izquierdo',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      left: 0.25,
    ),
    Player(
      id: '3',
      name: 'Van Dijk',
      number: '4',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      left: 0.38,
    ),
    Player(
      id: '4',
      name: 'Konaté',
      number: '5',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      right: 0.38,
    ),
    Player(
      id: '5',
      name: 'Arnold',
      number: '66',
      position: 'Lateral Derecho',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      right: 0.25,
    ),
    Player(
      id: '6',
      name: 'Thiago',
      number: '6',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.45,
      left: 0.225,
    ),
    Player(
      id: '7',
      name: 'Fabinho',
      number: '3',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      left: 0.485,
    ),
    Player(
      id: '8',
      name: 'Jones',
      number: '17',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      right: 0.485,
    ),
    Player(
      id: '9',
      name: 'Henderson',
      number: '14',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.45,
      right: 0.225,
    ),
    Player(
      id: '10',
      name: 'Núñez',
      number: '9',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.65,
      left: 0.3,
    ),
    Player(
      id: '11',
      name: 'Salah',
      number: '11',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.65,
      right: 0.3,
    ),
  ],
};

final substitutes = [
  Player(
    id: '12',
    name: 'Adrián',
    number: '13',
    position: 'Portero',
    photoPath: 'assets/images/player.png',
  ),
  Player(
    id: '13',
    name: 'Gomez',
    number: '12',
    position: 'Defensa',
    photoPath: 'assets/images/player.png',
  ),
  Player(
    id: '14',
    name: 'Firmino',
    number: '9',
    position: 'Delantero',
    photoPath: 'assets/images/player.png',
  ),
];
// --------------------------------------------------------------------

class TestScreen extends StatelessWidget {
  static const String name = '/test_screen';
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text(
            'Ajax Fc',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.red.shade700,
            ),
            tabs: const [
              Tab(text: 'Inicio'),
              Tab(text: 'Alineación'),
              Tab(text: 'Posiciones'),
              Tab(text: 'Partidos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Contenido de Inicio')),
            AlignmentTab(),
            Center(child: Text('Contenido de Posiciones')),
            Center(child: Text('Contenido de Partidos')),
          ],
        ),
      ),
    );
  }
}

// Widget específico para el contenido de la pestaña "Alineación"
// AHORA ES UN STATEFULWIDGET
class AlignmentTab extends StatefulWidget {
  const AlignmentTab({super.key});

  @override
  State<AlignmentTab> createState() => _AlignmentTabState();
}

class _AlignmentTabState extends State<AlignmentTab> {
  String _selectedFormation = '4-3-3';
  List<Player> _currentLineup = formations['4-3-3']!;

  // Orden de los grupos de posición
  static const _groupOrder = ['PORTERO', 'DEFENSAS', 'MEDIOCAMPISTAS', 'DELANTEROS'];

  Map<String, List<Player>> get _groupedLineup {
    final map = <String, List<Player>>{};
    for (final p in _currentLineup) {
      map.putIfAbsent(p.positionGroup, () => []).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedLineup;

    return Column(
      children: [
        const SizedBox(height: 6),

        // ── Header: "ESTRATEGIA" + Selector de formación ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTRATEGIA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Formación ',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B1926),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 8, right: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD94929),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFormation,
                          underline: const SizedBox.shrink(),
                          isExpanded: false,
                          isDense: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: const Color(0xFFD94929),
                          menuWidth: 80,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                          items:
                              formations.keys.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: CustomText(
                                    text: value,
                                    size: ts(context, 14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFormation = newValue;
                                _currentLineup = formations[newValue]!;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Campo de fútbol con jugadores ──
        Container(
          height: 350,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/campo_futbol.png"),
              fit: BoxFit.contain,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children:
                    _currentLineup.map((player) {
                      return Positioned(
                        top: constraints.maxHeight * (player.top ?? 0),
                        left:
                            player.left != null
                                ? constraints.maxWidth * player.left!
                                : null,
                        right:
                            player.right != null
                                ? constraints.maxWidth * player.right!
                                : null,
                        child: PlayerPhotoMarker(player: player),
                      );
                    }).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Entrenador ──
        const CoachCard(),

        const SizedBox(height: 16),

        // ── Lista agrupada por posición ──
        ..._groupOrder
            .where((g) => grouped.containsKey(g))
            .expand((group) => [
                  // Título del grupo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        group,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Jugadores del grupo
                  ...grouped[group]!.map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      child: _PlayerRow(player: p),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),

        // ── Sección Banquillo ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Banquillo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1926),
                ),
              ),
              Text(
                'Ver todos',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD94929),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: substitutes.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              if (i == 0) return _AddPlayerChip();
              return _BenchPlayerChip(player: substitutes[i - 1]);
            },
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}

/// Fila de jugador titular agrupada por posición.
class _PlayerRow extends StatelessWidget {
  final Player player;
  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(player.photoPath),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dorsal ${player.number} · ${player.position}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
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

/// Chip de jugador suplente en el banquillo.
class _BenchPlayerChip extends StatelessWidget {
  final Player player;
  const _BenchPlayerChip({required this.player});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFD5E5F4),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(player.photoPath),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1926),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    player.number,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            player.name.split(' ').first.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B1926),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Botón circular para añadir jugadores al banquillo.
class _AddPlayerChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 26,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Añadir',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
