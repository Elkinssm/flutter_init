import 'package:coach_app/config/router/app_router.dart';
import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomBottomAppbar extends ConsumerWidget {
  const CustomBottomAppbar({super.key});

  static const _orange = Color.fromRGBO(217, 73, 41, 1);
  static const _greenFab = Color.fromRGBO(79, 166, 38, 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              decoration: const BoxDecoration(
                color: _orange,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 6),
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
                          final route = currentUserRole == 'coach'
                              ? '/coach_screen'
                              : '/player_screen';
                          context.go(route);
                        },
                      ),
                      _NavItem(
                        label: 'EQUIPO',
                        icon: Icons.groups_rounded,
                        isSelected: selectedIndex == 1,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 1;
                          context.push('/my_teams_screen');
                        },
                      ),
                      const SizedBox(width: 72),
                      _NavItem(
                        label: 'CALENDARIO',
                        icon: Icons.calendar_month_rounded,
                        isSelected: selectedIndex == 2,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 2;
                          context.push('/category_screen');
                        },
                      ),
                      _NavItem(
                        label: 'PERFIL',
                        icon: Icons.person_outline_rounded,
                        isSelected: selectedIndex == 3,
                        onTap: () {
                          ref.read(selectedIconProvider.notifier).state = 3;
                          final route = currentUserRole == 'coach'
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
            child: const Center(
              child: _CenterFab(),
            ),
          ),
        ],
      ),
    );
  }
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
            Icon(
              icon,
              size: 26,
              color: Colors.white,
            ),
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

class _CenterFab extends StatelessWidget {
  const _CenterFab();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => context.push('/selected_team_screen', extra: 'Equipo'),
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
