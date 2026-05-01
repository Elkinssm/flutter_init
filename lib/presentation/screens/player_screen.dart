import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/infrastructure/services/mi_perfil_service.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerScreen extends StatefulWidget {
  static const String name = '/player_screen';
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenPageState();
}

class _PlayerScreenPageState extends State<PlayerScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(openProfileDrawerProvider)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(openProfileDrawerProvider.notifier).state = false;
            _scaffoldKey.currentState?.openEndDrawer();
          });
        }
        return SafeArea(
          top: false,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color.fromRGBO(249, 248, 247, 1),
            appBar: const CustomAppbar(title: 'Jugador'),
            endDrawer: const ProfileDrawer(),
            bottomNavigationBar: const CustomBottomAppbar(),
            floatingActionButton: const CustomFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: const _PlayerScreen(),
          ),
        );
      },
    );
  }
}

class _PlayerScreen extends ConsumerStatefulWidget {
  const _PlayerScreen();

  @override
  ConsumerState<_PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<_PlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileIncomplete();
    });
  }

  void _checkProfileIncomplete() {
    if (ref.read(showProfileIncompleteModalProvider)) {
      ref.read(showProfileIncompleteModalProvider.notifier).state = false;
      if (!context.mounted) return;
      CustomModal.showProfileIncomplete(
        context: context,
        onCompleteProfile: () => context.push('/new_player_screen'),
        onSkip: () {},
      );
    }
  }

  void _requireCompleteProfile({
    required bool profileComplete,
    required VoidCallback onAllowed,
  }) {
    if (profileComplete) {
      onAllowed();
      return;
    }
    if (!context.mounted) return;
    CustomModal.showProfileIncomplete(
      context: context,
      onCompleteProfile: () => context.push('/new_player_screen'),
      onSkip: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileComplete = ref.watch(currentUserProfileCompleteProvider);
    final displayName = ref.watch(currentUserDisplayNameProvider).trim();
    final miPerfilData = ref.watch(miPerfilProvider).valueOrNull;
    final dashboardAsync = ref.watch(jugadorDashboardProvider);
    final partidosAsync = ref.watch(jugadorPartidosProvider);
    final dashboardValue = dashboardAsync.valueOrNull;
    final jugadorMap = _dashboardJugador(dashboardValue);
    String? jugadorName;
    if (jugadorMap != null) {
      jugadorName =
          (jugadorMap['nombre'] ?? jugadorMap['nombre_completo'])?.toString();
    }
    final dashboardData = dashboardValue;
    final resolvedName =
        (jugadorName ?? '').trim().isNotEmpty
            ? jugadorName!.trim()
            : (displayName.isNotEmpty && displayName != 'Usuario'
                ? displayName
                : 'Jugador');
    final photoUrl = _resolvePlayerPhotoUrl(
      dashboardData: dashboardData,
      miPerfilData: miPerfilData,
    );
    final dorsal = _extractText(jugadorMap, const [
      'dorsal',
      'numero',
      'numero_camiseta',
    ]);
    final posicion = _extractText(jugadorMap, const [
      'posicion',
      'posicion_nombre',
      'posicion_codigo',
    ]);
    final categoria =
        profileComplete
            ? (_dashboardCategoria(dashboardData) ?? '--')
            : 'Completa perfil';
    final equipo =
        profileComplete
            ? (_dashboardEquipo(dashboardData) ?? '--')
            : 'Completa perfil';
    final latestResults =
        profileComplete
            ? _extractLatestResults(partidosAsync.valueOrNull).take(3).toList()
            : const <_PlayerResult>[];

    final asistencia = _dashboardAttendancePercent(dashboardData);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!profileComplete)
                _ProfileIncompleteBanner(
                  onCompleteProfile: () => context.push('/new_player_screen'),
                  onDismiss: () {
                    ref
                        .read(showProfileIncompleteModalProvider.notifier)
                        .state = false;
                  },
                ),
              if (!profileComplete) const SizedBox(height: 18),

              _PlayerProfileCard(
                name: resolvedName,
                photoUrl: photoUrl,
                dorsal: dorsal,
                position: posicion,
              ),

              const SizedBox(height: 22),
              _PlayerFactsStrip(
                categoria: categoria,
                equipo: equipo,
                asistencia: asistencia,
                onCategoryTap:
                    () => _requireCompleteProfile(
                      profileComplete: profileComplete,
                      onAllowed: () => context.push('/category_screen'),
                    ),
                onAttendanceTap:
                    () => _requireCompleteProfile(
                      profileComplete: profileComplete,
                      onAllowed: () => context.push('/history_screen'),
                    ),
              ),

              const SizedBox(height: 34),
              const _SectionTitle('Próximo encuentro'),
              const SizedBox(height: 14),
              _NextMatchCard(
                isPreview: !profileComplete,
                dashboardData: dashboardData,
              ),

              if (latestResults.isNotEmpty) ...[
                const SizedBox(height: 34),
                _LatestResultsSection(results: latestResults),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileIncompleteBanner extends StatelessWidget {
  const _ProfileIncompleteBanner({
    required this.onCompleteProfile,
    required this.onDismiss,
  });

  final VoidCallback onCompleteProfile;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(224, 214, 200, 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD94929).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFD94929),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Casi estas listo',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1926),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa tu perfil para desbloquear toda la experiencia.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF6B7280),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onCompleteProfile,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Completar ahora',
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
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: const Color(0xFF9CA3AF),
            splashRadius: 18,
            tooltip: 'Ocultar',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════

Map<String, dynamic>? _dashboardJugador(Map<String, dynamic>? d) {
  if (d == null) return null;
  final raw = d['jugador'] ?? d['player'];
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

String? _extractText(Map<String, dynamic>? source, List<String> keys) {
  if (source == null) return null;
  for (final key in keys) {
    final value = source[key];
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }
  return null;
}

String? _dashboardCategoria(Map<String, dynamic>? d) {
  if (d == null) return null;
  final rawEq = d['equipo_actual'] ?? d['equipo'];
  if (rawEq is! Map) return null;
  final eq = Map<String, dynamic>.from(rawEq);
  return (eq['categoria'] ?? eq['categoria_nombre'] ?? eq['nombre_categoria'])
      ?.toString();
}

String? _dashboardEquipo(Map<String, dynamic>? d) {
  if (d == null) return null;
  final rawEq = d['equipo_actual'] ?? d['equipo'];
  if (rawEq is! Map) return null;
  final eq = Map<String, dynamic>.from(rawEq);
  return (eq['nombre'] ?? eq['equipo'] ?? eq['nombre_equipo'])?.toString();
}

int? _dashboardAttendancePercent(Map<String, dynamic>? d) {
  if (d == null) return null;
  final asistencia = d['asistencia'];
  if (asistencia is num) return asistencia.round();
  if (asistencia is Map) {
    final map = Map<String, dynamic>.from(asistencia);
    final raw =
        map['porcentaje'] ??
        map['porcentaje_asistencia'] ??
        map['asistencia_porcentaje'];
    if (raw is num) return raw.round();
    return int.tryParse(raw?.toString() ?? '');
  }
  final raw = d['porcentaje_asistencia'] ?? d['asistencia_porcentaje'];
  if (raw is num) return raw.round();
  return int.tryParse(raw?.toString() ?? '');
}

Map<String, String?> _dashboardNextMatch(Map<String, dynamic>? d) {
  if (d == null) {
    return {'evento': null, 'fecha': null, 'hora': null, 'lugar': null};
  }
  final raw =
      d['proximo_encuentro'] ??
      d['proximo_partido'] ??
      d['proximo_entrenamiento'];
  if (raw is! Map) {
    return {'evento': null, 'fecha': null, 'hora': null, 'lugar': null};
  }
  final m = Map<String, dynamic>.from(raw);
  return {
    'evento':
        (m['evento'] ?? m['titulo'] ?? m['nombre'] ?? m['competencia'])
            ?.toString(),
    'fecha': m['fecha']?.toString(),
    'hora': (m['hora'] ?? m['hora_inicio'])?.toString(),
    'lugar': (m['lugar'] ?? m['cancha'] ?? m['estadio'])?.toString(),
  };
}

List<_PlayerResult> _extractLatestResults(Map<String, dynamic>? data) {
  if (data == null) return const [];
  final source =
      data['partidos'] ??
      data['items'] ??
      data['resultados'] ??
      data['ultimos_resultados'];
  if (source is! List) return const [];

  final results = <_PlayerResult>[];
  for (final item in source) {
    if (item is! Map) continue;
    final row = Map<String, dynamic>.from(item);

    final estadoRaw =
        row['resultado'] ??
        row['estado_resultado'] ??
        row['resultado_propio'] ??
        row['estado'];
    final estado = estadoRaw?.toString().toUpperCase();
    if (estado == null ||
        (!estado.contains('GAN') &&
            !estado.contains('VICTOR') &&
            !estado.contains('EMP') &&
            !estado.contains('PER') &&
            !estado.contains('DER'))) {
      continue;
    }

    final golesPropio = _extractInt(row, const [
      'goles_propio',
      'goles_favor',
      'marcador_propio',
    ]);
    final golesRival = _extractInt(row, const [
      'goles_rival',
      'goles_contra',
      'marcador_rival',
    ]);

    results.add(
      _PlayerResult(
        result: estado,
        score:
            golesPropio != null && golesRival != null
                ? '$golesPropio-$golesRival'
                : null,
      ),
    );
  }
  return results;
}

int? _extractInt(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

class _PlayerResult {
  const _PlayerResult({required this.result, this.score});

  final String result;
  final String? score;

  bool get isWin => result.contains('GAN') || result.contains('VICTOR');
  bool get isDraw => result.contains('EMP');
  bool get isLoss => result.contains('PER') || result.contains('DER');

  String get letter {
    if (isWin) return 'V';
    if (isDraw) return 'E';
    if (isLoss) return 'D';
    return '-';
  }

  String get label {
    if (isWin) return 'Victoria';
    if (isDraw) return 'Empate';
    if (isLoss) return 'Derrota';
    return 'Resultado';
  }

  Color get color {
    if (isWin) return const Color.fromRGBO(79, 166, 38, 1);
    if (isDraw) return const Color(0xFF34495E);
    if (isLoss) return const Color(0xFFD94929);
    return const Color(0xFFD94929);
  }
}

// ══════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.beVietnamPro(
        color: const Color(0xFF34495E),
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        height: 1,
      ),
    );
  }
}

/// Card de perfil del jugador con foto y nombre.
class _PlayerProfileCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? dorsal;
  final String? position;

  const _PlayerProfileCard({
    required this.name,
    this.photoUrl,
    this.dorsal,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      (photoUrl ?? '').isNotEmpty
                          ? Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _initialsAvatar(name),
                          )
                          : _initialsAvatar(name),
                ),
              ),
              if ((dorsal ?? '').isNotEmpty)
                Positioned(
                  right: 0,
                  bottom: 8,
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(19, 124, 8, 1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      dorsal!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            name,
            style: GoogleFonts.beVietnamPro(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF9F1F0A),
              letterSpacing: -1,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          if ((position ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(139, 230, 112, 1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(79, 166, 38, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    position!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color.fromRGBO(27, 100, 18, 1),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'JG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Widget _initialsAvatar(String name) {
    return Container(
      color: const Color.fromRGBO(214, 229, 239, 1),
      alignment: Alignment.center,
      child: Text(
        _initialsFromName(name),
        style: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF22423A),
        ),
      ),
    );
  }
}

String? _resolvePlayerPhotoUrl({
  required Map<String, dynamic>? dashboardData,
  required Map<String, dynamic>? miPerfilData,
}) {
  String? raw;

  final jug = dashboardData?['jugador'];
  if (jug is Map) {
    raw = jug['foto_url']?.toString();
  }

  if ((raw ?? '').trim().isEmpty) {
    final user = miPerfilData?['usuario'];
    if (user is Map) {
      raw = user['foto_url']?.toString();
    }
  }

  if ((raw ?? '').trim().isEmpty) {
    final jugador = miPerfilData?['jugador'];
    if (jugador is Map) {
      raw = jugador['foto_url']?.toString();
    }
  }

  return _normalizeImageUrl(raw);
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

class _PlayerFactsStrip extends StatelessWidget {
  const _PlayerFactsStrip({
    required this.categoria,
    required this.equipo,
    required this.asistencia,
    required this.onCategoryTap,
    required this.onAttendanceTap,
  });

  final String categoria;
  final String equipo;
  final int? asistencia;
  final VoidCallback onCategoryTap;
  final VoidCallback onAttendanceTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FactChip(
            icon: Icons.category_rounded,
            label: 'Categoría',
            value: categoria,
            onTap: onCategoryTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FactChip(
            icon: Icons.shield_outlined,
            label: 'Equipo',
            value: equipo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FactChip(
            icon: Icons.fact_check_rounded,
            label: 'Asistencia',
            value: asistencia == null ? '--' : '$asistencia%',
            onTap: onAttendanceTap,
          ),
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(235, 228, 214, 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFD94929), size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF0B1926),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestResultsSection extends StatelessWidget {
  const _LatestResultsSection({required this.results});

  final List<_PlayerResult> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos resultados',
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF0B1926),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < results.length; i++) ...[
              Expanded(child: _ResultCard(result: results[i])),
              if (i < results.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final _PlayerResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: result.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: result.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: result.color,
              shape: BoxShape.circle,
            ),
            child: Text(
              result.letter,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: result.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          if ((result.score ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              result.score!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.beVietnamPro(
                color: result.color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de Próximo Encuentro.
class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard({this.isPreview = false, this.dashboardData});

  final bool isPreview;
  final Map<String, dynamic>? dashboardData;

  @override
  Widget build(BuildContext context) {
    final next = _dashboardNextMatch(dashboardData);
    final evento = next['evento'];
    final fecha = next['fecha'];
    final hora = next['hora'];
    final lugar = next['lugar'];
    final hasMatchData = [
      evento,
      fecha,
      hora,
      lugar,
    ].any((value) => (value ?? '').trim().isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Próximo Encuentro',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B1926),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: Color(0xFFD94929),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasMatchData)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(249, 248, 247, 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isPreview
                    ? 'Completa tu perfil para ver tu próximo encuentro.'
                    : 'No hay próximos encuentros disponibles.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            )
          else ...[
            if ((evento ?? '').trim().isNotEmpty)
              _buildInfoRow(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFD94929),
                label: 'EVENTO',
                value: evento!,
              ),
            if ((evento ?? '').trim().isNotEmpty)
              Divider(color: Colors.grey.shade100, height: 24),
            Row(
              children: [
                if ((fecha ?? '').trim().isNotEmpty)
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFFD94929),
                      label: 'FECHA',
                      value: fecha!,
                    ),
                  ),
                if ((fecha ?? '').trim().isNotEmpty &&
                    (hora ?? '').trim().isNotEmpty)
                  const SizedBox(width: 10),
                if ((hora ?? '').trim().isNotEmpty)
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFF0B1926),
                      label: 'HORA',
                      value: hora!,
                    ),
                  ),
              ],
            ),
            if ((lugar ?? '').trim().isNotEmpty) ...[
              Divider(color: Colors.grey.shade100, height: 24),
              _buildInfoRow(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFD94929),
                label: 'UBICACIÓN',
                value: lugar!,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B1926),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
