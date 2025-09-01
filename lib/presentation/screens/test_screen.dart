import 'package:coach_app/config/domain/player.dart';
import 'package:coach_app/presentation/widgets/players/coach_card.dart';
import 'package:coach_app/presentation/widgets/players/player_list_item.dart';
import 'package:coach_app/presentation/widgets/players/player_photo_marker.dart';
import 'package:flutter/material.dart';

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
      left: 0.08,
    ),
    Player(
      id: '3',
      name: 'Van Dijk',
      number: '4',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      left: 0.35,
    ),
    Player(
      id: '4',
      name: 'Konaté',
      number: '5',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      right: 0.35,
    ),
    Player(
      id: '5',
      name: 'Arnold',
      number: '66',
      position: 'Lateral Derecho',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      right: 0.08,
    ),
    Player(
      id: '6',
      name: 'Thiago',
      number: '6',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      left: 0.25,
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
      right: 0.25,
    ),
    Player(
      id: '9',
      name: 'Díaz',
      number: '23',
      position: 'Delantero',
      photoPath: 'assets/images/player.png',
      top: 0.6,
      left: 0.1,
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
      right: 0.1,
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
      left: 0.08,
    ),
    Player(
      id: '3',
      name: 'Van Dijk',
      number: '4',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      left: 0.35,
    ),
    Player(
      id: '4',
      name: 'Konaté',
      number: '5',
      position: 'Central',
      photoPath: 'assets/images/player.png',
      top: 0.20,
      right: 0.35,
    ),
    Player(
      id: '5',
      name: 'Arnold',
      number: '66',
      position: 'Lateral Derecho',
      photoPath: 'assets/images/player.png',
      top: 0.22,
      right: 0.08,
    ),
    Player(
      id: '6',
      name: 'Thiago',
      number: '6',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.45,
      left: 0.15,
    ),
    Player(
      id: '7',
      name: 'Fabinho',
      number: '3',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      left: 0.4,
    ),
    Player(
      id: '8',
      name: 'Jones',
      number: '17',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.4,
      right: 0.4,
    ),
    Player(
      id: '9',
      name: 'Henderson',
      number: '14',
      position: 'Mediocampista',
      photoPath: 'assets/images/player.png',
      top: 0.45,
      right: 0.15,
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
    // ... El código de TestScreen se mantiene igual ...
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
  // VARIABLES DE ESTADO: Guardan la información que puede cambiar
  String _selectedFormation = '4-3-3';
  List<Player> _currentLineup = formations['4-3-3']!;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // REEMPLAZAMOS EL TEXTO POR UN DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButton<String>(
              value: _selectedFormation,
              underline: const SizedBox(), // quita la línea de abajo
              items:
                  formations.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // LA MAGIA OCURRE AQUÍ:
                  setState(() {
                    _selectedFormation = newValue;
                    _currentLineup = formations[newValue]!;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/campo_futbol.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // AHORA USAMOS LA LISTA DEL ESTADO: _currentLineup
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
          const SizedBox(height: 24),
          const CoachCard(),
          const SizedBox(height: 24),
          ...substitutes.map((player) => PlayerListItem(player: player)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
