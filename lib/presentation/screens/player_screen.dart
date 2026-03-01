import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
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
    final dashboardValue = dashboardAsync.valueOrNull;
    String? jugadorName;
    if (dashboardValue != null && dashboardValue['jugador'] != null) {
      final jug = dashboardValue['jugador'];
      if (jug is Map) {
        jugadorName = jug['nombre']?.toString();
      }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (!profileComplete)
              _ProfileIncompleteBanner(
                onCompleteProfile: () => context.push('/new_player_screen'),
                onDismiss: () {
                  ref.read(showProfileIncompleteModalProvider.notifier).state =
                      false;
                },
              ),
            if (!profileComplete) const SizedBox(height: 14),

            // ── Perfil del jugador ──
            _PlayerProfileCard(name: resolvedName, photoUrl: photoUrl),

            const SizedBox(height: 16),

            // ── Info rápida: Categoría y Equipo ──
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.category_rounded,
                    title:
                        profileComplete
                            ? (_dashboardCategoria(dashboardData) ?? '--')
                            : 'Completa perfil',
                    subtitle:
                        profileComplete
                            ? 'Categoría'
                            : 'Verás tu categoría asignada',
                    actionLabel:
                        profileComplete ? 'Ver categoría' : 'Completar perfil',
                    onTap:
                        () => _requireCompleteProfile(
                          profileComplete: profileComplete,
                          onAllowed: () => context.push('/category_screen'),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.bar_chart_rounded,
                    title:
                        profileComplete
                            ? (_dashboardEquipo(dashboardData) ?? '--')
                            : 'Completa perfil',
                    subtitle:
                        profileComplete
                            ? 'Mi equipo'
                            : 'Verás tu equipo y asistencias',
                    actionLabel:
                        profileComplete ? 'Ver asistencia' : 'Completar perfil',
                    onTap:
                        () => _requireCompleteProfile(
                          profileComplete: profileComplete,
                          onAllowed: () => context.push('/history_screen'),
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Asistencia (tocable) ──
            _AttendanceCard(
              isPreview: !profileComplete,
              percentage: _dashboardAttendancePercent(dashboardData),
              onTap:
                  () => _requireCompleteProfile(
                    profileComplete: profileComplete,
                    onAllowed: () => context.push('/category_screen'),
                  ),
            ),

            const SizedBox(height: 16),

            // ── Próximo Encuentro ──
            _NextMatchCard(
              isPreview: !profileComplete,
              dashboardData: dashboardData,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
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

// ══════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════

/// Card de perfil del jugador con foto y nombre.
class _PlayerProfileCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  const _PlayerProfileCard({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD94929), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD94929).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
          const SizedBox(height: 14),
          // Nombre
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B1926),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD94929).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'JUGADOR',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD94929),
                letterSpacing: 1,
              ),
            ),
          ),
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

/// Card de info (Categoría / Equipo) con más énfasis.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel = 'Ver detalle',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD94929).withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Icono grande naranja sólido
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD94929).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              // Título grande
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1926),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Botón "Ver detalle"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD94929).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD94929),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de asistencia modernizada y tocable.
class _AttendanceCard extends StatelessWidget {
  final bool isPreview;
  final int? percentage;
  final VoidCallback? onTap;
  const _AttendanceCard({this.isPreview = false, this.percentage, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (percentage != null) ? percentage!.clamp(0, 100) : null;
    final progress = (pct ?? 0) / 100;
    final rightText = isPreview ? '---' : (pct != null ? '$pct%' : '--');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistencia',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B1926),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: isPreview ? 0.0 : progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    if (isPreview) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Completa tu perfil para ver tu porcentaje real.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Porcentaje
              Text(
                rightText,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
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
    final evento =
        next['evento'] ?? (isPreview ? 'Disponible al completar perfil' : '--');
    final fecha = next['fecha'] ?? (isPreview ? '--' : '--');
    final hora = next['hora'] ?? (isPreview ? '--' : '--');
    final lugar =
        next['lugar'] ??
        (isPreview ? 'Completa perfil para desbloquear' : '--');

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
          // Evento
          _buildInfoRow(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFD94929),
            label: 'EVENTO',
            value: evento,
          ),
          Divider(color: Colors.grey.shade100, height: 24),
          // Fecha y Hora
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFFD94929),
                  label: 'FECHA',
                  value: fecha,
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF0B1926),
                  label: 'HORA',
                  value: hora,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade100, height: 24),
          // Ubicación
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFD94929),
            label: 'UBICACIÓN',
            value: lugar,
          ),
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
        Column(
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
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1926),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
