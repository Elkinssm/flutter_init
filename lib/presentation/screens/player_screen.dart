import 'package:coach_app/infrastructure/services/dashboard_service.dart';
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
      _precacheImages();
      _checkProfileIncomplete();
    });
  }

  void _precacheImages() {
    precacheImage(const AssetImage('assets/images/player.png'), context);
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

  @override
  Widget build(BuildContext context) {
    final profileComplete = ref.watch(currentUserProfileCompleteProvider);
    final initials = ref.watch(currentUserInitialsProvider);
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

    if (!profileComplete) {
      return _IncompleteProfileView(
        initials: initials,
        onCompleteProfile: () => context.push('/new_player_screen'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Perfil del jugador ──
            _PlayerProfileCard(
              name: jugadorName ?? 'David Ballesteros',
            ),

            const SizedBox(height: 16),

            // ── Info rápida: Categoría y Equipo ──
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.category_rounded,
                    title: _dashboardCategoria(dashboardData) ?? '2012',
                    subtitle: 'Categoría',
                    actionLabel: 'Ver categoría',
                    onTap: () => context.push('/category_screen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.bar_chart_rounded,
                    title: _dashboardEquipo(dashboardData) ?? 'Los Tigres',
                    subtitle: 'Mi equipo',
                    actionLabel: 'Ver asistencia',
                    onTap: () => context.push('/history_screen'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Asistencia (tocable) ──
            _AttendanceCard(
              onTap: () => context.push('/category_screen'),
            ),

            const SizedBox(height: 16),

            // ── Próximo Encuentro ──
            const _NextMatchCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════

String? _dashboardCategoria(Map<String, dynamic>? d) {
  if (d == null) return null;
  final eq = d['equipo'] as Map<String, dynamic>?;
  return eq?['categoria']?.toString() ?? eq?['nombre']?.toString();
}

String? _dashboardEquipo(Map<String, dynamic>? d) {
  if (d == null) return null;
  final eq = d['equipo'] as Map<String, dynamic>?;
  return eq?['nombre']?.toString();
}


int? _dashboardCategoriaId(Map<String, dynamic>? d) {
  if (d == null) return null;
  final eq = d['equipo'] as Map<String, dynamic>?;
  final cat = eq?['categoria_id'] ?? eq?['categoria'];
  if (cat is int) return cat;
  return int.tryParse(cat?.toString() ?? '');
}

// ══════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════

/// Card de perfil del jugador con foto y nombre.
class _PlayerProfileCard extends StatelessWidget {
  final String name;
  const _PlayerProfileCard({required this.name});

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
              child: Image.asset(
                'assets/images/player.png',
                fit: BoxFit.cover,
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
  final VoidCallback? onTap;
  const _AttendanceCard({this.onTap});

  @override
  Widget build(BuildContext context) {
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
                        value: 0.90,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Porcentaje
              Text(
                '90%',
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
  const _NextMatchCard();

  @override
  Widget build(BuildContext context) {
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
            value: 'Partido de Liga',
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
                  value: 'Sáb, 14 Oct',
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF0B1926),
                  label: 'HORA',
                  value: '10:30 AM',
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
            value: 'Cancha Principal - Sede Norte',
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

/// Vista simplificada cuando el perfil está incompleto.
class _IncompleteProfileView extends StatelessWidget {
  const _IncompleteProfileView({
    required this.initials,
    required this.onCompleteProfile,
  });

  final String initials;
  final VoidCallback onCompleteProfile;

  static const _avatarColor = Color(0xFFD94929);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: _avatarColor,
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Completa tu perfil',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1926),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Cuéntanos un poco más sobre ti para que el profe te conozca mejor.',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCompleteProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: _avatarColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Completar perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
