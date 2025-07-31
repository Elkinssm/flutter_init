import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerScreen extends StatelessWidget {
  static const String name = '/player_screen';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 248, 247, 1),
      appBar: CustomAppbar(title: 'Jugador'),
      bottomNavigationBar: CustomBottomAppbar(),
      floatingActionButton: CustomFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _PlayerScreen(), // Tu contenido aquí
    );
  }
}

class _PlayerScreen extends StatelessWidget {
  const _PlayerScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Fila de categoría y resumen
          Row(
            children: [
              Expanded(
                child: _simpleCard('Categoría', '2012', 'Ver mi categoría'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _simpleCard('Los Tigres', '6 categorías', 'Ver resumen'),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/assistance_screen'),
            child: _asistenciaCard(),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _proximoPartidoCard()),
              SizedBox(width: 12),
              Expanded(
                child: _desempenoCard(
                  () => context.push('/performance_screen'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ejercicioCard(
                  Icons.fitness_center,
                  'Ejercicios\nde fuerza',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ejercicioCard(
                  Icons.directions_run,
                  'Ejercicios\nde velocidad',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleCard(String title, String subtitle, String buttonText) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFEFF8FB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14)),
          SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.teal[800],
              backgroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _asistenciaCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text('Asistencia', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text('Total'),
              SizedBox(width: 8),
              Text('90%', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.9,
            backgroundColor: Colors.grey[300],
            color: Colors.teal,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _proximoPartidoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    'SAT',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '20',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Text(
                'Próximo Partido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('Fecha: 12/02/2025'),
          Text('Rival: Los Tigres'),
          Text('Hora: 4:00 pm'),
        ],
      ),
    );
  }

  Widget _desempenoCard(VoidCallback? action) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: action,
            child: Row(
              children: const [
                Icon(Icons.show_chart, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Desempeño',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text('Velocidad: 8.4 km/h'),
          Text('Precisión tiros: 75%'),
          Text('Toques efectivos: 95%'),
        ],
      ),
    );
  }

  Widget _ejercicioCard(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
