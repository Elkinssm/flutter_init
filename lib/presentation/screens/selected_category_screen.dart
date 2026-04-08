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
import 'package:google_fonts/google_fonts.dart';

class SelectedCategoryScreen extends ConsumerWidget {
  static const String name = '/selected_category_screen';
  final int year;

  const SelectedCategoryScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final isCoach = role == 'coach';
    final jugadoresAsync =
        isCoach
            ? ref.watch(coachJugadoresProvider(year))
            : ref.watch(jugadorCategoriaByIdProvider(year));
    final title = _resolveCategoryTitle(jugadoresAsync.valueOrNull, year);

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
        appBar: CustomAppbar(title: title),
        bottomNavigationBar: const CustomBottomAppbar(),
        floatingActionButton: const CustomFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        body: _SelectedCategoryView(equipoId: year),
      ),
    );
  }

  static String _resolveCategoryTitle(Map<String, dynamic>? data, int fallback) {
    final payload = data ?? const <String, dynamic>{};
    final equipoRaw = payload['equipo'];
    if (equipoRaw is Map) {
      final equipo = Map<String, dynamic>.from(equipoRaw);
      final categoria = equipo['categoria']?.toString().trim() ?? '';
      if (categoria.isNotEmpty) return categoria;
      final nombre = equipo['nombre']?.toString().trim() ?? '';
      if (nombre.isNotEmpty) return nombre;
    }

    final categoria = payload['categoria']?.toString().trim() ?? '';
    if (categoria.isNotEmpty) return categoria;

    return 'Categoría $fallback';
  }
}

class _SelectedCategoryView extends ConsumerWidget {
  const _SelectedCategoryView({required this.equipoId});

  final int equipoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final isCoach = role == 'coach';
    final jugadoresAsync =
        isCoach
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
        (data['equipo'] is Map)
            ? Map<String, dynamic>.from(data['equipo'])
            : <String, dynamic>{};
    final estadisticas =
        (data['estadisticas'] is Map)
            ? Map<String, dynamic>.from(data['estadisticas'])
            : <String, dynamic>{};
    final jugadoresRaw = data['jugadores'] as List<dynamic>? ?? const [];
    final jugadores =
        jugadoresRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    final total = (data['total'] as num?)?.toInt() ?? jugadores.length;
    final asistencia =
        (estadisticas['asistencia_porcentaje'] as num?)?.toDouble();
    final pesoProm = (estadisticas['peso_promedio_kg'] as num?)?.toDouble();

    final asistenciaText =
        asistencia == null ? '--' : '${asistencia.toStringAsFixed(0)}%';
    final pesoText =
        pesoProm == null ? '--' : '${pesoProm.toStringAsFixed(1)}kg';
    final tituloEquipo = 'Estudiantes ${_equipoSuffix(equipo)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              _StatTopCard(label: 'ASISTENCIA', value: asistenciaText),
              _StatTopCard(label: 'PROMEDIO', value: pesoText),
              _StatTopCard(label: 'JUGADORES', value: '$total'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.groups_2_outlined,
                  label: 'Ver equipos',
                  onTap: () => context.push('/my_teams_screen'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.fact_check_outlined,
                  label: isCoach ? 'Ver asistencias' : 'Mi asistencia',
                  onTap:
                      () => context.push(
                        isCoach
                            ? '/daily_attendance_screen'
                            : '/history_screen',
                        extra: isCoach ? equipoId : null,
                      ),
                ),
              ),
              if (isCoach) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Crear jugador',
                    onTap:
                        () => context.push('/new_player_screen', extra: equipoId),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tituloEquipo,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B1B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                !Environment.useBackend
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
                      separatorBuilder:
                          (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
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

    final displayName =
        (nombreCompleto != null && nombreCompleto.isNotEmpty)
            ? nombreCompleto
            : [nombre, apellido]
                .where((e) => e != null && e.isNotEmpty)
                .join(' ')
                .trim();

    final dorsal = jugador['dorsal']?.toString() ?? '--';
    final posicion =
        jugador['posicion_codigo']?.toString() ??
        jugador['posicion']?.toString() ??
        '--';
    final peso = jugador['peso_kg']?.toString();
    final asistencia = (jugador['asistencia_porcentaje'] as num?)?.toDouble();
    final asistenciaText =
        asistencia == null ? '--' : '${asistencia.toStringAsFixed(0)}%';
    final accentColor = _accentFromAttendance(asistencia);
    final posicionTag = _positionTag(posicion);

    return InkWell(
      onTap:
          !canOpenDetail
              ? null
              : () => context.pushNamed(
                PlayerStatusScreen.name,
                extra: {
                  'name': displayName.isEmpty ? 'Jugador' : displayName,
                  'image':
                      _normalizeFotoUrl(jugador['foto_url']?.toString()) ??
                      'assets/images/student-eg1-icon.png',
                  'jugador_id': (jugador['id'] as num?)?.toInt(),
                },
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 54,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
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
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B1B1B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _metaChip('#$dorsal', const Color(0xFFE3503B)),
                                const SizedBox(width: 6),
                                _metaChip(posicionTag.$1, posicionTag.$2),
                                if ((peso ?? '').isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  _weightChip('${_formatPeso(peso!)}kg'),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            asistenciaText,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ASISTENCIA',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  Widget _metaChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFD5E5F4),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _weightChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFD5E5F4),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color.fromRGBO(212, 175, 55, 1),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAvatar({required String nombre, String? fotoUrl}) {
    const borderColor = Color.fromRGBO(27, 71, 56, 1);
    final normalizedUrl = _normalizeFotoUrl(fotoUrl);
    final hasPhoto = normalizedUrl != null && normalizedUrl.isNotEmpty;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipOval(
        child:
            hasPhoto
                ? Image.network(
                  normalizedUrl,
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
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B4738),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static Color _accentFromAttendance(double? asistencia) {
    if (asistencia == null) return const Color(0xFF8D9AA5);
    if (asistencia >= 85) return const Color(0xFF2F8F3A);
    if (asistencia >= 60) return const Color(0xFF6C8194);
    return const Color(0xFFE3503B);
  }

  static (String, Color) _positionTag(String posicion) {
    switch (posicion.toUpperCase()) {
      case 'PO':
      case 'GK':
        return ('PO', const Color(0xFF6D89D8));
      case 'MC':
      case 'MCO':
      case 'MCD':
        return ('MC', const Color(0xFFD7AE52));
      case 'DEL':
      case 'DC':
      case 'ST':
        return ('DEL', const Color(0xFFDB74A0));
      case 'DF':
      case 'DEF':
        return ('DF', const Color(0xFF6C8194));
      default:
        return (posicion.toUpperCase(), const Color(0xFF6C8194));
    }
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
      if ((uAvatar ?? '').trim().isNotEmpty && uAvatar != 'null') {
        return uAvatar;
      }
    }
    return null;
  }
}

class _StatTopCard extends StatelessWidget {
  const _StatTopCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD94929),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7A8087),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(251, 248, 241, 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: const Color(0xFF7A8087)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
