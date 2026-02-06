import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Altura de la barra (CustomBottomAppbar) + margen para que el panel NUNCA tape el footer.
const double _kBottomBarHeight = 64;
const double _kExtraPaddingAboveBar = 56;

/// Menú lateral que se abre desde la derecha (endDrawer): perfil, Editar perfil y Cerrar sesión.
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        top: false,
        child: _ProfilePanelContent(
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Panel de perfil que se desliza desde la derecha y deja la barra inferior siempre visible.
class ProfilePanelOverlay extends ConsumerStatefulWidget {
  const ProfilePanelOverlay({super.key});

  @override
  ConsumerState<ProfilePanelOverlay> createState() => _ProfilePanelOverlayState();
}

class _ProfilePanelOverlayState extends ConsumerState<ProfilePanelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(openProfileDrawerProvider);
    ref.listen(openProfileDrawerProvider, (prev, next) {
      if (next == true) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    if (isOpen && _controller.value == 0 && !_controller.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
    }
    if (!isOpen && !_controller.isAnimating && _controller.value == 0) {
      return const SizedBox.shrink();
    }

    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final screenHeight = media.size.height;
    final panelBottom = _kBottomBarHeight + _kExtraPaddingAboveBar + bottomInset;
    final panelHeight = screenHeight - panelBottom;
    final width = media.size.width * 0.85;

    if (panelHeight <= 0) return const SizedBox.shrink();

    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: panelHeight,
            child: GestureDetector(
              onTap: () => ref.read(openProfileDrawerProvider.notifier).state = false,
              child: AnimatedOpacity(
                opacity: isOpen || _controller.value > 0 ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black54),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            height: panelHeight,
            width: width,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 16,
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  bottom: false,
                  child: _ProfilePanelContent(
                    onClose: () => ref.read(openProfileDrawerProvider.notifier).state = false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePanelContent extends ConsumerWidget {
  const _ProfilePanelContent({required this.onClose});

  final VoidCallback onClose;

  static const _orange = Color(0xFFD94929);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(currentUserDisplayNameProvider);
    final initials = ref.watch(currentUserInitialsProvider);

    return Column(
      children: [
        // Cabecera naranja
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: _orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Training Once+',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ajustes de cuenta',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sección central: Editar perfil arriba, espacio flexible, botón y versión abajo
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: _orange,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Editar Perfil',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B1926),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                  ),
                  onTap: () {
                    onClose();
                    context.push('/new_player_screen');
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      onClose();
                      clearUserRole();
                      if (context.mounted) {
                        context.go('/login_screen');
                      }
                    },
                    icon: const Icon(Icons.logout, size: 20, color: Colors.white),
                    label: const Text('Cerrar Sesión'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Versión 2.4.0 (Build 88)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
