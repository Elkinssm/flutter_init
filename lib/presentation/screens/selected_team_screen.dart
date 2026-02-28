import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/presentation/helpers/api_error_message.dart';
import 'package:coach_app/presentation/helpers/responsive.dart';
import 'package:coach_app/presentation/providers/selected_buttons_provider.dart';
import 'package:coach_app/presentation/screens/player_status_screen.dart';
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
    final selected = ref.watch(selectedMenuProvider) ?? 'Inicio';

    Widget content;
    switch (selected) {
      case 'Inicio':
        content = _TeamOverviewSection(equipoId: equipoId);
        break;
      case 'Alineación':
        content = const _LineupComingSoonSection();
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TopSegmentTabs(
              selected: selected,
              onChanged: (value) {
                ref.read(selectedMenuProvider.notifier).state = value;
              },
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

class _LineupComingSoonSection extends ConsumerWidget {
  const _LineupComingSoonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 54,
                color: Color(0xFFD94929),
              ),
              const SizedBox(height: 14),
              const Text(
                'Alineación en construcción',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estamos ajustando esta sección para conectar la alineación real del equipo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(selectedMenuProvider.notifier).state = 'Inicio';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94929),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Volver a Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSegmentTabs extends StatelessWidget {
  const _TopSegmentTabs({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = ['Inicio', 'Alineación', 'Partidos'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 240, 230, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Row(
        children: items.map((item) {
          final active = item == selected;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFD94929) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? Colors.white
                        : const Color.fromRGBO(55, 73, 87, 1),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Sección combinada: detalles del equipo + listado de jugadores.
class _TeamOverviewSection extends ConsumerWidget {
  const _TeamOverviewSection({this.equipoId});
  final int? equipoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (equipoId == null) {
      return const Expanded(
        child: Center(
          child: Text('No se encontró el equipo seleccionado.'),
        ),
      );
    }

    final jugadoresAsync = ref.watch(coachJugadoresProvider(equipoId!));
    final equipoAsync = ref.watch(coachEquipoProvider(equipoId!));
    final partidosAsync = ref.watch(coachPartidosByEquipoProvider(equipoId!));

    if (Environment.useBackend &&
        (jugadoresAsync.isLoading || equipoAsync.isLoading) &&
        jugadoresAsync.valueOrNull == null &&
        equipoAsync.valueOrNull == null) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (Environment.useBackend &&
        (jugadoresAsync.hasError || equipoAsync.hasError) &&
        jugadoresAsync.valueOrNull == null &&
        equipoAsync.valueOrNull == null) {
      final error = jugadoresAsync.error ?? equipoAsync.error;
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 42),
                const SizedBox(height: 10),
                Text(
                  apiErrorMessage(
                    error,
                    defaultMessage:
                        'No se pudo cargar la información del equipo.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(coachJugadoresProvider(equipoId!));
                    ref.invalidate(coachEquipoProvider(equipoId!));
                    ref.invalidate(coachPartidosByEquipoProvider(equipoId!));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final jugadoresData = jugadoresAsync.valueOrNull ?? <String, dynamic>{};
    final equipoData = equipoAsync.valueOrNull ?? <String, dynamic>{};
    final partidosData = partidosAsync.valueOrNull ?? <String, dynamic>{};

    final equipoFromJugadores = (jugadoresData['equipo'] is Map)
        ? Map<String, dynamic>.from(jugadoresData['equipo'])
        : <String, dynamic>{};
    final equipo = (equipoData['equipo'] is Map)
        ? Map<String, dynamic>.from(equipoData['equipo'])
        : equipoFromJugadores;

    final jugadoresRaw = (jugadoresData['jugadores'] as List<dynamic>?) ?? const [];
    final jugadores = jugadoresRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final totalJugadores = (jugadoresData['total'] as num?)?.toInt() ?? jugadores.length;
    final hasMoreJugadores = jugadores.length > 3;
    final visibleJugadores = hasMoreJugadores ? jugadores.take(3).toList() : jugadores;
    final categoria = equipo['categoria']?.toString() ?? 'Sin categoría';
    final teamName = (equipo['nombre']?.toString().trim().isNotEmpty ?? false)
        ? equipo['nombre'].toString()
        : 'Equipo';

    final partidosRaw = (partidosData['partidos'] as List<dynamic>?) ?? const [];
    final partidos = partidosRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final record = _buildRecord(partidos);
    final proximoPartido = _nextMatchShort(partidos);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Detalle del equipo',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: const Color.fromRGBO(173, 111, 57, 1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              teamName,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B1926),
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.05,
              children: [
                _OverviewMetricCard(
                  icon: Icons.groups_rounded,
                  title: '$totalJugadores',
                  subtitle: 'Integrantes',
                  tone: 0,
                ),
                _OverviewMetricCard(
                  icon: Icons.category_rounded,
                  title: categoria,
                  subtitle: 'Categoría',
                  tone: 1,
                ),
                _OverviewMetricCard(
                  icon: Icons.emoji_events_outlined,
                  title: record,
                  subtitle: 'Récord',
                  tone: 2,
                ),
                _OverviewMetricCard(
                  icon: Icons.event_rounded,
                  title: proximoPartido,
                  subtitle: 'Próximo partido',
                  tone: 3,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Plantilla ($totalJugadores)',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    ref.read(selectedMenuProvider.notifier).state = 'Alineación';
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Ver todos',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD94929),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFFD94929),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasMoreJugadores)
              Text(
                'Mostrando ${visibleJugadores.length} de $totalJugadores',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            const SizedBox(height: 8),
            if (jugadores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No hay jugadores registrados en este equipo.',
                  style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                ),
              )
            else
              ListView.separated(
                itemCount: visibleJugadores.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                separatorBuilder: (_, __) => Divider(
                  height: 10,
                  thickness: 0,
                  color: Colors.transparent,
                ),
                itemBuilder: (_, i) => _TeamPlayerTile(
                  jugador: visibleJugadores[i],
                  equipoId: equipoId!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamPlayerTile extends StatelessWidget {
  const _TeamPlayerTile({required this.jugador, required this.equipoId});
  final Map<String, dynamic> jugador;
  final int equipoId;

  @override
  Widget build(BuildContext context) {
    final jugadorId = (jugador['id'] as num?)?.toInt();
    final nombre = _displayName(jugador);
    final dorsal = (jugador['dorsal'] ??
            jugador['dorsal_actual'] ??
            jugador['numero_camiseta'])?.toString() ??
        '--';
    final posicion = _positionAbbr(jugador);
    final photo = _normalizeImageUrl(jugador['foto_url']?.toString());
    final estadoColor = _playerStateColor(jugador);

    return InkWell(
      onTap: jugadorId == null
          ? null
          : () => context.pushNamed(
                PlayerStatusScreen.name,
                extra: {
                  'name': nombre,
                  'image': photo ?? '',
                  'jugador_id': jugadorId,
                  'equipo_id': equipoId,
                },
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0D6C8),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: (photo ?? '').isNotEmpty
                    ? Image.network(
                        photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _initialsAvatar(nombre),
                      )
                    : _initialsAvatar(nombre),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        dorsal,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4FA626),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9CA3AF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(217, 73, 41, 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          posicion,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD94929),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: estadoColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(55, 73, 87, 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _displayName(Map<String, dynamic> j) {
    final full = j['nombre_completo']?.toString().trim() ?? '';
    if (full.isNotEmpty) return full;
    final nombre = j['nombre']?.toString().trim() ?? '';
    final apellido = j['apellido']?.toString().trim() ?? '';
    final composed = '$nombre $apellido'.trim();
    return composed.isEmpty ? 'Jugador' : composed;
  }

  static String _positionAbbr(Map<String, dynamic> j) {
    final pos = j['posicion'];
    if (pos is Map) {
      final m = Map<String, dynamic>.from(pos);
      return (m['abreviatura'] ?? m['codigo'] ?? m['nombre'] ?? '--')
          .toString()
          .toUpperCase();
    }
    final direct = (j['posicion_abreviatura'] ??
            j['posicion_codigo'] ??
            j['posicion_nombre'])
        ?.toString();
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.toUpperCase();
    }
    return '--';
  }

  static String? _normalizeImageUrl(String? raw) {
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

  static Widget _initialsAvatar(String name) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      color: const Color(0xFFD6E5EF),
      child: Center(
        child: Text(
          initials.isEmpty ? 'JG' : initials,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF22423A),
          ),
        ),
      ),
    );
  }

  static Color _playerStateColor(Map<String, dynamic> j) {
    final pct = (j['asistencia_porcentaje'] as num?)?.toDouble();
    if (pct == null) return const Color.fromRGBO(156, 163, 175, 1);
    if (pct >= 80) return const Color.fromRGBO(79, 166, 38, 1);
    if (pct >= 60) return const Color.fromRGBO(245, 158, 11, 1);
    return const Color.fromRGBO(220, 38, 38, 1);
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tone = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int tone;

  @override
  Widget build(BuildContext context) {
    const backgrounds = [
      Color.fromRGBO(255, 245, 236, 1),
      Color.fromRGBO(239, 248, 255, 1),
      Color.fromRGBO(244, 245, 255, 1),
      Color.fromRGBO(241, 250, 244, 1),
    ];
    const accents = [
      Color(0xFFD94929),
      Color.fromRGBO(30, 136, 229, 1),
      Color.fromRGBO(92, 107, 192, 1),
      Color.fromRGBO(79, 166, 38, 1),
    ];
    final bg = backgrounds[tone % backgrounds.length];
    final accent = accents[tone % accents.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromRGBO(55, 73, 87, 1),
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

String _buildRecord(List<Map<String, dynamic>> partidos) {
  var v = 0;
  var e = 0;
  var d = 0;
  for (final p in partidos) {
    final resultado = p['resultado']?.toString() ?? '';
    final diff = _PartidosSectionState._resultDiff(resultado);
    if (diff == null) continue;
    if (diff > 0) {
      v++;
    } else if (diff < 0) {
      d++;
    } else {
      e++;
    }
  }
  return '$v V · $e E · $d D';
}

String _nextMatchShort(List<Map<String, dynamic>> partidos) {
  final now = DateTime.now();
  Map<String, dynamic>? next;
  DateTime? nextDt;

  for (final p in partidos) {
    final raw = p['fecha']?.toString() ?? '';
    final dt = DateTime.tryParse(raw);
    final hasResult = (p['resultado']?.toString().trim().isNotEmpty ?? false);
    if (dt == null || hasResult || dt.isBefore(now)) continue;
    if (nextDt == null || dt.isBefore(nextDt)) {
      nextDt = dt;
      next = p;
    }
  }

  if (next == null || nextDt == null) return '--';

  const wd = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const mo = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  return '${wd[nextDt.weekday - 1]} ${nextDt.day} ${mo[nextDt.month - 1]}';
}

/// Sección de Partidos: crear partido + próximos + historial.
class _PartidosSection extends ConsumerStatefulWidget {
  const _PartidosSection({this.equipoId});
  final int? equipoId;

  @override
  ConsumerState<_PartidosSection> createState() => _PartidosSectionState();
}

class _PartidosSectionState extends ConsumerState<_PartidosSection> {
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final partidosAsync = widget.equipoId == null
        ? ref.watch(coachPartidosProvider)
        : ref.watch(coachPartidosByEquipoProvider(widget.equipoId!));

    if (partidosAsync.hasError && partidosAsync.valueOrNull == null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 42),
                const SizedBox(height: 10),
                Text(
                  apiErrorMessage(
                    partidosAsync.error,
                    defaultMessage: 'No se pudieron cargar los partidos.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (widget.equipoId == null) {
                      ref.invalidate(coachPartidosProvider);
                    } else {
                      ref.invalidate(coachPartidosByEquipoProvider(widget.equipoId!));
                    }
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final raw = ((partidosAsync.valueOrNull?['partidos'] as List<dynamic>?) ?? const []);
    final partidos = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final now = DateTime.now();
    final month = _selectedMonth ?? now.month;
    final monthPartidos = partidos.where((p) {
      final dt = DateTime.tryParse(p['fecha']?.toString() ?? '');
      return dt != null && dt.month == month && dt.year == now.year;
    }).toList();

    monthPartidos.sort((a, b) {
      final ad = DateTime.tryParse(a['fecha']?.toString() ?? '') ?? DateTime(2100);
      final bd = DateTime.tryParse(b['fecha']?.toString() ?? '') ?? DateTime(2100);
      return ad.compareTo(bd);
    });

    final hoy = <Map<String, dynamic>>[];
    final proximos = <Map<String, dynamic>>[];
    final pasados = <Map<String, dynamic>>[];
    for (final p in monthPartidos) {
      final d = DateTime.tryParse(p['fecha']?.toString() ?? '');
      final hasResult = (p['resultado']?.toString().trim().isNotEmpty ?? false);
      if (d == null) continue;
      final only = DateTime(d.year, d.month, d.day);
      final today = DateTime(now.year, now.month, now.day);
      if (only == today) {
        hoy.add(p);
      } else if (hasResult || only.isBefore(today)) {
        pasados.add(p);
      } else {
        proximos.add(p);
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CALENDARIO DE PARTIDOS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.pushNamed('/new_match_screen', extra: widget.equipoId),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Crear partido',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94929),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MonthChipsRow(
              selectedMonth: month,
              onMonthSelected: (m) => setState(() => _selectedMonth = m),
            ),
            const SizedBox(height: 14),
            _AgendaSectionHeader(
              title: _todayHeader(now),
              count: hoy.length,
            ),
            const SizedBox(height: 10),
            if (partidosAsync.isLoading && partidosAsync.valueOrNull == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hoy.isEmpty)
              _emptyDayCard()
            else
              ...hoy.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MatchAgendaCard(partido: p, isToday: true),
                  )),
            const SizedBox(height: 16),
            const _SectionMiniTitle(title: 'Próximos'),
            const SizedBox(height: 10),
            if (proximos.isEmpty)
              _emptyHint('No hay próximos partidos en este mes')
            else
              ...proximos.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MatchAgendaCard(partido: p),
                  )),
            const SizedBox(height: 16),
            const _SectionMiniTitle(title: 'Pasados'),
            const SizedBox(height: 10),
            if (pasados.isEmpty)
              _emptyHintCard('Sin partidos finalizados en este periodo')
            else
              ...pasados.take(5).map((p) {
                final resultado = p['resultado']?.toString() ?? '--';
                final diff = _PartidosSectionState._resultDiff(resultado);
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
                    rival: 'Vs ${p['rival_nombre'] ?? p['rival'] ?? 'Rival'}',
                    date: _PartidosSectionState._formatShortDate(p['fecha']?.toString()),
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
  }

  Widget _emptyHint(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
    );
  }

  Widget _emptyDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(213, 229, 244, 1)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(217, 73, 41, 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_soccer, color: Color(0xFFD94929)),
          ),
          const SizedBox(height: 10),
          Text(
            'Día de descanso',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B1926),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No hay partidos programados para hoy.',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyHintCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
      ),
    );
  }

  static String _todayHeader(DateTime date) {
    const m = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return 'Hoy, ${date.day.toString().padLeft(2, '0')} de ${m[date.month - 1]}';
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

class _MonthChipsRow extends StatelessWidget {
  const _MonthChipsRow({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final int selectedMonth;
  final ValueChanged<int> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final month = i + 1;
          final active = month == selectedMonth;
          return InkWell(
            onTap: () => onMonthSelected(month),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFD94929)
                    : const Color.fromRGBO(245, 240, 230, 1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active
                      ? const Color(0xFFD94929)
                      : const Color.fromRGBO(224, 214, 200, 1),
                  width: 1.2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD94929).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AgendaSectionHeader extends StatelessWidget {
  const _AgendaSectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color.fromRGBO(55, 73, 87, 1),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(245, 240, 230, 1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count PARTIDO${count == 1 ? '' : 'S'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94929),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionMiniTitle extends StatelessWidget {
  const _SectionMiniTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        color: const Color.fromRGBO(55, 73, 87, 1),
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _MatchAgendaCard extends StatelessWidget {
  const _MatchAgendaCard({
    required this.partido,
    this.isToday = false,
  });

  final Map<String, dynamic> partido;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final rival = (partido['rival_nombre'] ?? partido['rival'] ?? 'Rival por definir').toString();
    final esLocal = partido['es_local'] == true;
    final competencia = (partido['competencia'] ?? 'Amistoso').toString();
    final lugar = (partido['lugar'] ?? partido['estadio'] ?? 'Lugar por definir').toString();
    final hora = _hourText(partido['hora']?.toString());
    final fecha = _datePretty(partido['fecha']?.toString());
    final heading = isToday ? 'Próximo encuentro' : competencia;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  heading.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: const Color.fromRGBO(173, 111, 57, 1),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  esLocal ? 'LOCAL' : 'VISITANTE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vs $rival',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B1926),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final colWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: colWidth,
                    child: _agendaMeta(
                      icon: Icons.emoji_events_outlined,
                      label: 'Competencia',
                      value: competencia,
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _agendaMeta(
                      icon: Icons.calendar_today_rounded,
                      label: 'Fecha',
                      value: fecha,
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _agendaMeta(
                      icon: Icons.schedule_rounded,
                      label: 'Hora',
                      value: hora,
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _agendaMeta(
                      icon: Icons.location_on_rounded,
                      label: 'Lugar',
                      value: lugar,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _agendaMeta({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD94929)),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1926),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _hourText(String? raw) {
    if ((raw ?? '').isEmpty) return '--:--';
    final hh = raw!.split(':');
    if (hh.length < 2) return raw;
    final h = int.tryParse(hh[0]) ?? 0;
    final m = hh[1];
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  static String _datePretty(String? rawDate) {
    final d = DateTime.tryParse(rawDate ?? '');
    if (d == null) return rawDate ?? '--';
    const mo = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day.toString().padLeft(2, '0')} ${mo[d.month - 1]} ${d.year}';
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
