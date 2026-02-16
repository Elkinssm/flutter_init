import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/providers/auth_role_provider.dart';
import 'package:coach_app/presentation/providers/player_photo_overrides_provider.dart';
import 'package:coach_app/presentation/screens/player_status_screen.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SelectedCategoryScreen extends StatelessWidget {
  static const String name = '/selected_category_screen';
  final int year;
  const SelectedCategoryScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: 'Categoria $year'),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: _SelectedCategoryView(equipoId: year),
      ),
    );
  }
}

class _SelectedCategoryView extends ConsumerWidget {
  final int equipoId;
  const _SelectedCategoryView({required this.equipoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final isCoach = role == 'coach';
    final jugadoresAsync = isCoach
        ? ref.watch(coachJugadoresProvider(equipoId))
        : ref.watch(jugadorCategoriaByIdProvider(equipoId));
    final photoOverrides = ref.watch(playerPhotoOverridesProvider);

    if (jugadoresAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jugadoresAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 44, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                'No se pudo cargar la categoría.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                apiErrorMessage(
                  jugadoresAsync.error,
                  defaultMessage:
                      'No se pudo cargar la categoría. Intenta de nuevo.',
                  forbiddenMessage:
                      'No tienes permisos para ver esta categoría.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  isCoach
                      ? coachJugadoresProvider(equipoId)
                      : jugadorCategoriaByIdProvider(equipoId),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final data = jugadoresAsync.valueOrNull ?? <String, dynamic>{};
    final equipo =
        (data['equipo'] is Map) ? Map<String, dynamic>.from(data['equipo']) : <String, dynamic>{};
    final estadisticas = (data['estadisticas'] is Map)
        ? Map<String, dynamic>.from(data['estadisticas'])
        : <String, dynamic>{};
    final jugadoresRaw = data['jugadores'] as List<dynamic>? ?? const [];
    final jugadores = jugadoresRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final total = (data['total'] as num?)?.toInt() ?? jugadores.length;
    final asistencia = (estadisticas['asistencia_porcentaje'] as num?)?.toDouble();
    final pesoProm = (estadisticas['peso_promedio_kg'] as num?)?.toDouble();

    final asistenciaText = asistencia == null ? '--' : '${asistencia.toStringAsFixed(0)}%';
    final pesoText = pesoProm == null ? '--' : '${pesoProm.toStringAsFixed(1)}kg';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Asistencia\nPromedio',
                subtitleText: asistenciaText,
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Promedio\nfísico',
                subtitleText: pesoText,
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
              CustomButtonCard(
                width: 110,
                height: 110,
                titleText: 'Jugadores',
                subtitleText: '$total',
                titleTextSize: 17,
                subtitleTextSize: 22,
                spacing: 10,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconCard(
                  width: 100,
                  height: 96,
                  titleText: 'Ver\nequipos',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/tournaments-icon.png',
                  imageSize: 24,
                  onTap: () => context.push('/my_teams_screen'),
                ),
                CustomIconCard(
                  width: 100,
                  height: 96,
                  titleText: isCoach ? 'Ver\nasistencias' : 'Mi\nasistencia',
                  titleTextSize: 12,
                  spacing: 4,
                  imagePath: 'assets/images/check-list-icon.png',
                  imageSize: 24,
                  onTap: () => context.push(
                    isCoach ? '/daily_attendance_screen' : '/history_screen',
                    extra: isCoach ? equipoId : null,
                  ),
                ),
                if (isCoach)
                  CustomIconCard(
                    width: 100,
                    height: 96,
                    titleText: 'Crear\njugador',
                    titleTextSize: 12,
                    spacing: 4,
                    imagePath: 'assets/images/plus-icon.png',
                    imageSize: 24,
                    onTap: () => context.push('/new_player_screen', extra: equipoId),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(3, 4),
                ),
              ],
              color: Colors.black,
            ),
            height: 3,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Estudiantes ${_equipoSuffix(equipo)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: !Environment.useBackend
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Activa backend para ver jugadores reales de la categoría.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : jugadores.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay jugadores en esta categoría.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: jugadores.length,
                        padding: const EdgeInsets.only(bottom: 88),
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            color: const Color(0xFFE3503B),
                          ),
                        ),
                        itemBuilder: (_, i) {
                          final j = jugadores[i];
                          final id = (j['id'] as num?)?.toInt();
                          final overrideUrl = id == null ? null : photoOverrides[id];
                          return _JugadorTile(
                            jugador: j,
                            photoOverride: overrideUrl,
                            canOpenDetail: isCoach,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  static String _equipoSuffix(Map<String, dynamic> equipo) {
    final nombre = equipo['nombre']?.toString() ?? '';
    if (nombre.isEmpty) return '';
    return '- $nombre';
  }
}

class _JugadorTile extends StatelessWidget {
  const _JugadorTile({
    required this.jugador,
    this.photoOverride,
    this.canOpenDetail = true,
  });

  final Map<String, dynamic> jugador;
  final String? photoOverride;
  final bool canOpenDetail;

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = jugador['nombre_completo']?.toString().trim();
    final nombre = jugador['nombre']?.toString().trim();
    final apellido = jugador['apellido']?.toString().trim();

    final displayName = (nombreCompleto != null && nombreCompleto.isNotEmpty)
        ? nombreCompleto
        : [nombre, apellido]
            .where((e) => e != null && e.isNotEmpty)
            .join(' ')
            .trim();

    final dorsal = jugador['dorsal']?.toString() ?? '--';
    final posicion = jugador['posicion_codigo']?.toString() ?? jugador['posicion']?.toString() ?? '--';
    final peso = jugador['peso_kg']?.toString();
    final asistencia = (jugador['asistencia_porcentaje'] as num?)?.toDouble();

    return InkWell(
      onTap: !canOpenDetail
          ? null
          : () => context.pushNamed(
                PlayerStatusScreen.name,
                extra: {
                  'name': displayName.isEmpty ? 'Jugador' : displayName,
                  'image': _normalizeFotoUrl(jugador['foto_url']?.toString()) ??
                      'assets/images/student-eg1-icon.png',
                  'jugador_id': (jugador['id'] as num?)?.toInt(),
                },
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _buildAvatar(
                nombre: displayName.isEmpty ? 'Jugador' : displayName,
                fotoUrl: photoOverride ?? _extractFotoUrl(jugador),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty ? 'Jugador' : displayName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip('$dorsal', const Color.fromRGBO(79, 166, 38, 1)),
                        const SizedBox(width: 6),
                        _chip(posicion, const Color.fromRGBO(173, 111, 57, 1)),
                        if ((peso ?? '').isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _pill('${_formatPeso(peso!)}kg', const Color.fromRGBO(212, 175, 55, 1)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    asistencia == null ? '--' : '${asistencia.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Asistencia',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPeso(String raw) {
    final n = double.tryParse(raw);
    if (n == null) return raw;
    return n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  }

  Widget _chip(String text, Color color) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFD5E5F4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E5F4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAvatar({required String nombre, String? fotoUrl}) {
    const borderColor = Color.fromRGBO(27, 71, 56, 1);
    final normalizedUrl = _normalizeFotoUrl(fotoUrl);
    final hasPhoto = normalizedUrl != null && normalizedUrl.isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                normalizedUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsAvatar(nombre),
              )
            : _initialsAvatar(nombre),
      ),
    );
  }

  Widget _initialsAvatar(String nombre) {
    final initials = _initials(nombre);
    return Container(
      color: const Color(0xFFD5E5F4),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1B4738),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static String? _normalizeFotoUrl(String? raw) {
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

  static String? _extractFotoUrl(Map<String, dynamic> jugador) {
    final direct = jugador['foto_url']?.toString();
    if ((direct ?? '').trim().isNotEmpty && direct != 'null') return direct;

    final alt1 = jugador['foto']?.toString();
    if ((alt1 ?? '').trim().isNotEmpty && alt1 != 'null') return alt1;

    final alt2 = jugador['avatar_url']?.toString();
    if ((alt2 ?? '').trim().isNotEmpty && alt2 != 'null') return alt2;

    final usuario = jugador['usuario'];
    if (usuario is Map) {
      final u = Map<String, dynamic>.from(usuario);
      final uFoto = u['foto_url']?.toString();
      if ((uFoto ?? '').trim().isNotEmpty && uFoto != 'null') return uFoto;
      final uAvatar = u['avatar_url']?.toString();
      if ((uAvatar ?? '').trim().isNotEmpty && uAvatar != 'null') return uAvatar;
    }
    return null;
  }
}
