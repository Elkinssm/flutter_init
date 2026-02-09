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
            extendBodyBehindAppBar: true,
            backgroundColor: Color.fromRGBO(249, 248, 247, 1),
            appBar: const CustomAppbar(
              title: 'Jugador',
              backgroundColor: Colors.transparent,
            ),
            endDrawer: const ProfileDrawer(),
            bottomNavigationBar: CustomBottomAppbar(),
            floatingActionButton: CustomFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: _PlayerScreen(),
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
    precacheImage(const AssetImage('assets/images/group14.png'), context);
    precacheImage(
      const AssetImage('assets/images/performance-icon.png'),
      context,
    );
    precacheImage(const AssetImage('assets/images/strong-icon.png'), context);
    precacheImage(const AssetImage('assets/images/person-icon.png'), context);
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
    final screenHeigth = MediaQuery.of(context).size.height;
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

    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 20,
                left: 20,
                top: screenHeigth * 0.065,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: CustomText(
                      text: jugadorName ?? 'David\nBallesteros',
                      size: 28,
                      color: Color.fromRGBO(11, 25, 38, 1),
                      fontWeight: FontWeight.w800,
                      spacingText: 0.9,
                    ),
                  ),
                  Image.asset(
                    'assets/images/player.png',
                    width: 175,
                    cacheWidth: 175,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeigth * 0.28,
                left: 20,
                right: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RepaintBoundary(
                      child: CustomCards(
                        action: () => context.push('/category_screen'),
                        title: 'Categoría',
                        subtitle: _dashboardCategoria(dashboardData) ?? '2012',
                        textButton: 'Ver mi categoría',
                        sizeTextButton: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RepaintBoundary(
                      child: CustomCards(
                        action: () => context.push('/history_screen'),
                        title: _dashboardEquipo(dashboardData) ?? 'Los Tigres',
                        subtitle:
                            _dashboardEquipoSubtitle(dashboardData) ??
                            '6 categorías',
                        textButton: 'Ver resumen',
                        sizeTextButton: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const CustomSupportStats(),
        const SizedBox(height: 18),
        // Tarjeta de Próximo Encuentro
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _NextMatchCard(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

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

String? _dashboardEquipoSubtitle(Map<String, dynamic>? d) {
  if (d == null) return null;
  final eq = d['equipo'] as Map<String, dynamic>?;
  final count = eq?['categorias'] ?? eq?['jugadores_count'];
  if (count != null) return '$count categorías';
  return null;
}

/// Vista simplificada cuando el perfil está incompleto: avatar con iniciales y CTA.
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

class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD94929),
                ),
              ),
              Icon(
                Icons.sports_soccer_outlined,
                color: const Color.fromRGBO(217, 73, 41, 0.4),
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Evento
          _buildInfoRow(
            icon: Icons.exit_to_app_outlined,
            iconColor: const Color(0xFFD94929),
            label: 'EVENTO',
            value: 'Partido de Liga',
          ),
          const SizedBox(height: 16),
          // Fecha y Hora
          Row(
            children: [
              _buildInfoRow(
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFFD94929),
                label: 'FECHA',
                value: 'Sábado, 14 Oct',
              ),
              const SizedBox(width: 24),
              _buildInfoRow(
                icon: Icons.access_time,
                iconColor: const Color(0xFF0B1926),
                label: 'HORA',
                value: '10:30 AM',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Ubicación
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFD94929),
            label: 'UBICACIÓN',
            value: 'Cancha Principal - Sede Norte',
          ),
          const SizedBox(height: 20),
          // Confirmados
          Row(
            children: [
              // Avatares apilados
              SizedBox(
                width: 70,
                height: 32,
                child: Stack(
                  children: [
                    _buildAvatar(0, Colors.green),
                    _buildAvatar(1, Colors.orange),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+12',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Confirmados para asistir',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
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
            const SizedBox(height: 2),
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

  Widget _buildAvatar(int index, Color color) {
    return Positioned(
      left: index * 20.0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.person, size: 18, color: color),
      ),
    );
  }
}
