import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/config/constants/environment.dart';
import 'package:coach_app/infrastructure/services/api_client.dart';
import 'package:coach_app/infrastructure/services/coach_api_service.dart';
import 'package:coach_app/infrastructure/services/dashboard_service.dart';
import 'package:coach_app/infrastructure/services/jugador_api_service.dart';
import 'package:coach_app/infrastructure/services/mi_perfil_service.dart';
import 'package:coach_app/infrastructure/services/public_api_service.dart';
import 'package:coach_app/presentation/providers/profile_incomplete_provider.dart';
import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomBottomAppbar extends ConsumerWidget {
  const CustomBottomAppbar({super.key});

  static const _orange = Color.fromRGBO(217, 73, 41, 1);
  static const _greenFab = Color.fromRGBO(79, 166, 38, 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCoach = currentUserRole == 'coach';
    final selectedIndex = ref.watch(selectedIconProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;
    final totalHeight = barHeight + bottomInset;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Barra naranja con esquinas redondeadas abajo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight + bottomInset,
              decoration: const BoxDecoration(color: _orange),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: bottomInset > 0 ? bottomInset : 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _NavItem(
                        label: 'INICIO',
                        icon: Icons.home_rounded,
                        isSelected: selectedIndex == 0,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 0;
                          final route =
                              currentUserRole == 'coach'
                                  ? '/coach_screen'
                                  : '/player_screen';
                          context.go(route);
                        },
                      ),
                      _NavItem(
                        label: isCoach ? 'EQUIPO' : 'ASISTENCIA',
                        icon:
                            isCoach
                                ? Icons.groups_rounded
                                : Icons.fact_check_rounded,
                        isSelected: selectedIndex == 1,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 1;
                          if (isCoach) {
                            context.push('/my_teams_screen');
                          } else {
                            context.push('/assistance_screen');
                          }
                        },
                      ),
                      const SizedBox(width: 72),
                      _NavItem(
                        label: isCoach ? 'CALENDARIO' : 'HISTORIAL',
                        icon:
                            isCoach
                                ? Icons.calendar_month_rounded
                                : Icons.history_rounded,
                        isSelected: selectedIndex == 2,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 2;
                          if (isCoach) {
                            context.push('/category_screen');
                          } else {
                            context.push('/history_screen');
                          }
                        },
                      ),
                      _NavItem(
                        label: 'PERFIL',
                        icon: Icons.person_outline_rounded,
                        isSelected: selectedIndex == 3,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 3;
                          ref.read(openProfileDrawerProvider.notifier).state =
                              true;
                          final route =
                              currentUserRole == 'coach'
                                  ? '/coach_screen'
                                  : '/player_screen';
                          context.go(route);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // FAB central (balón) que sobresale por encima de la barra
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + barHeight - 36,
            child: Center(child: _CenterFab(isCoach: isCoach)),
          ),
          if (kDebugMode && Environment.showForceReloadButton)
            Positioned(
              right: 8,
              top: 6,
              child: _DebugReloadMini(
                onTap: () => _forceDebugReload(context, ref),
              ),
            ),
        ],
      ),
    );
  }
}

void _forceDebugReload(BuildContext context, WidgetRef ref) {
  debugPrint('[DEBUG][RELOAD] Forzando invalidación de providers');
  ref.invalidate(apiClientProvider);
  ref.invalidate(dashboardServiceProvider);
  ref.invalidate(coachApiServiceProvider);
  ref.invalidate(jugadorApiServiceProvider);
  ref.invalidate(miPerfilServiceProvider);
  ref.invalidate(publicApiServiceProvider);

  ref.invalidate(coachDashboardProvider);
  ref.invalidate(jugadorDashboardProvider);
  ref.invalidate(coachCategoriasProvider);
  ref.invalidate(coachPartidosProvider);
  ref.invalidate(coachPosicionesProvider);
  ref.invalidate(jugadorCategoriasProvider);
  ref.invalidate(jugadorCategoriaActualProvider);
  ref.invalidate(jugadorResumenProvider);
  ref.invalidate(jugadorEstadisticasProvider);
  ref.invalidate(jugadorMedicionesProvider);
  ref.invalidate(jugadorLogrosProvider);
  ref.invalidate(jugadorPartidosProvider);
  ref.invalidate(miPerfilProvider);
  ref.invalidate(publicEscuelasProvider);
  ref.invalidate(publicPosicionesProvider);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Recarga forzada de datos (debug)'),
      duration: Duration(seconds: 1),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterFab extends ConsumerWidget {
  const _CenterFab({required this.isCoach});

  final bool isCoach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          if (isCoach) {
            ref.read(selectedIconProvider.notifier).state = 1;
            context.go('/my_teams_screen');
          } else {
            ref.read(selectedIconProvider.notifier).state = 2;
            context.go('/category_screen');
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomBottomAppbar._greenFab,
            border: Border.all(color: Colors.white, width: 5),
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _DebugReloadMini extends StatelessWidget {
  const _DebugReloadMini({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: const Icon(Icons.refresh, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
