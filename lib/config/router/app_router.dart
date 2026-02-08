import 'package:coach_app/infrastructure/services/auth_service.dart';
import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/helpers/loading_observer.dart';
import 'package:coach_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';
import 'transitions_config/custom_transition.dart';

// Estado de rol devuelto por backend
String? currentUserRole;

/// Asigna [currentUserRole] según el rol devuelto por la API (ADMIN, ENTRENADOR, JUGADOR).
void setUserRoleFromBackend(String role) {
  final r = role.toUpperCase();
  if (r == 'ADMIN' || r == 'ENTRENADOR') {
    currentUserRole = 'coach';
  } else if (r == 'JUGADOR') {
    currentUserRole = 'player';
  } else {
    currentUserRole = 'player';
  }
}

void clearUserRole() {
  currentUserRole = null;
}

final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  observers: [LoadingNavObserver()],
  initialLocation: '/loading_screen',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    // Pantallas públicas
    final publicRoutes = [
      '/loading_screen',
      '/welcome_screen',
      '/login_screen',
      '/register_screen',
      '/health_check',
      '/auth_info_screen',
    ];

    if (publicRoutes.contains(state.uri.path)) {
      return null;
    }

    if (currentUserRole == null) {
      return '/login_screen';
    }

    // El coach puede acceder a TODAS las pantallas
    if (currentUserRole == 'coach') {
      return null; // Permitir acceso total
    }

    // El player solo puede acceder a sus pantallas específicas
    final playerAllowedRoutes = [
      '/player_screen',
      '/assistance_screen',
      '/history_screen',
      '/performance_screen',
      '/category_screen',
      '/selected_category_screen',
      '/new_player_screen', // Completar perfil de jugador
    ];

    if (!playerAllowedRoutes.contains(state.uri.path)) {
      return '/player_screen'; // Redirigir a su pantalla principal
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/loading_screen',
      name: LoadingScreen.name,
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/welcome_screen',
      name: WelcomeScreen.name,
      pageBuilder:
          (context, state) => CustomTransition.slideLeft(const WelcomeScreen()),
    ),
    GoRoute(
      path: '/login_screen',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register_screen',
      name: RegisterScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const RegisterScreen()),
    ),
    GoRoute(
      path: '/player_screen',
      name: PlayerScreen.name,
      pageBuilder:
          (context, state) => CustomTransition.slideLeft(const PlayerScreen()),
    ),
    GoRoute(
      path: '/assistance_screen',
      name: AssistanceScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const AssistanceScreen()),
    ),
    GoRoute(
      path: '/history_screen',
      name: HistoryScreen.name,
      pageBuilder:
          (context, state) => CustomTransition.slideLeft(const HistoryScreen()),
    ),
    GoRoute(
      path: '/performance_screen',
      name: PerformanceScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const PerformanceScreen()),
    ),
    GoRoute(
      path: '/coach_screen',
      name: CoachScreen.name,
      pageBuilder:
          (context, state) => CustomTransition.slideLeft(const CoachScreen()),
    ),
    GoRoute(
      path: '/category_screen',
      name: CategoryScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const CategoryScreen()),
    ),
    GoRoute(
      path: '/selected_category_screen',
      name: SelectedCategoryScreen.name,
      pageBuilder: (context, state) {
        final year = state.extra as int;
        return CustomTransition.slideLeft(SelectedCategoryScreen(year: year));
      },
    ),
    GoRoute(
      path: '/daily_attendance_screen',
      name: DailyAttendanceScreen.name,
      pageBuilder: (context, state) {
        final equipoId = state.extra as int?;
        return CustomTransition.slideLeft(DailyAttendanceScreen(equipoId: equipoId));
      },
    ),
    GoRoute(
      path: '/new_player_screen',
      name: NewPlayerScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const NewPlayerScreen()),
    ),
    GoRoute(
      path: '/new_match_screen',
      name: NewMatchScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const NewMatchScreen()),
    ),
    GoRoute(
      path: '/player_status_screen',
      name: PlayerStatusScreen.name,
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final name = data['name'] ?? '';
        final image = data['image'] ?? '';

        return CustomTransition.slideLeft(
          PlayerStatusScreen(names: name, image: image),
        );
      },
    ),
    GoRoute(
      path: '/my_teams_screen',
      name: MyTeamsScreen.name,
      pageBuilder:
          (context, state) => CustomTransition.slideLeft(const MyTeamsScreen()),
    ),
    GoRoute(
      path: '/selected_team_screen',
      name: SelectedTeamScreen.name,
      pageBuilder: (context, state) {
        final teamName = state.extra as String;
        return CustomTransition.slideLeft(
          SelectedTeamScreen(teamName: teamName),
        );
      },
    ),
    GoRoute(
      path: '/test_screen',
      name: TestScreen.name,
      builder: (context, state) => const TestScreen(),
    ),
    GoRoute(
      path: '/health_check',
      name: HealthCheckScreen.name,
      builder: (context, state) => const HealthCheckScreen(),
    ),
    GoRoute(
      path: '/auth_info_screen',
      name: AuthInfoScreen.name,
      builder: (context, state) =>
          AuthInfoScreen(extra: state.extra as AuthResult?),
    ),
  ],
);
