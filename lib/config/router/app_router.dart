import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/helpers/loading_observer.dart';
import 'package:coach_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';
import 'transitions_config/custom_transition.dart';

// Variable global para manejar el estado del usuario
String? currentUserRole;

// Establecer el rol recibido del backend
void setUserRoleFromBackend(String role) {
  final normalized = role.toLowerCase();
  if (normalized.contains('admin') || normalized.contains('coach')) {
    currentUserRole = 'coach';
  } else if (normalized.contains('player') || normalized.contains('jugador')) {
    currentUserRole = 'player';
  } else {
    currentUserRole = 'player';
  }
}

// Limpiar rol (llamar desde logout)
void clearUserRole() {
  currentUserRole = null;
}

final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  observers: [LoadingNavObserver()],
  initialLocation: '/loading_screen',
  // initialLocation: '/health_check',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    // Pantallas que no requieren autenticaci¢n
    final publicRoutes = [
      '/loading_screen',
      '/welcome_screen',
      '/login_screen',
      '/register_screen',
      '/health_check',
    ];

    // Si est  en una ruta p£blica, permitir acceso
    if (publicRoutes.contains(state.uri.path)) {
      return null;
    }

    // Si no hay rol de usuario, redirigir al login
    if (currentUserRole == null) {
      return '/login_screen';
    }

    // Protecci¢n por roles
    final coachOnlyRoutes = [
      '/coach_screen',
      '/selected_category_screen',
      '/daily_attendance_screen',
      '/new_player_screen',
      '/player_status_screen',
      '/my_teams_screen',
      '/selected_team_screen',
    ];

    final playerOnlyRoutes = [
      '/player_screen',
      '/assistance_screen',
      '/history_screen',
      '/performance_screen',
      // Allow players to see category view
      '/category_screen',
    ];

    // Si es una ruta solo para coach y el usuario no es coach
    if (coachOnlyRoutes.contains(state.uri.path) &&
        currentUserRole != 'coach') {
      return '/login_screen';
    }

    // Si es una ruta solo para player y el usuario no es player
    if (playerOnlyRoutes.contains(state.uri.path) &&
        currentUserRole != 'player') {
      return '/login_screen';
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
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const DailyAttendanceScreen()),
    ),
    GoRoute(
      path: '/new_player_screen',
      name: NewPlayerScreen.name,
      pageBuilder:
          (context, state) =>
              CustomTransition.slideLeft(const NewPlayerScreen()),
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
  ],
);
