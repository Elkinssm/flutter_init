import 'package:coach_app/presentation/helpers/globals.dart';
import 'package:coach_app/presentation/helpers/loading_observer.dart';
import 'package:coach_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';
import 'transitions_config/custom_transition.dart';

// Agregar esta variable global para manejar el estado del usuario
String? currentUserRole;

// Función para verificar si un email está registrado
bool _isEmailRegistered(String email) {
  final Map<String, String> registeredEmails = {
    'admin@mail.com': 'coach',
    'coach@mail.com': 'coach',
    'entrenador@mail.com': 'coach',
    'player1@mail.com': 'player',
    'player2@mail.com': 'player',
    'jugador@mail.com': 'player',
  };
  return registeredEmails.containsKey(email.toLowerCase());
}

// Función para obtener el rol del usuario
String _getUserRole(String email) {
  final Map<String, String> roleByEmail = {
    'admin@mail.com': 'coach',
    'coach@mail.com': 'coach',
    'entrenador@mail.com': 'coach',
    'player1@mail.com': 'player',
    'player2@mail.com': 'player',
    'jugador@mail.com': 'player',
  };
  return roleByEmail[email.toLowerCase()] ?? 'player';
}

// Función para establecer el rol del usuario (llamar desde login)
void setUserRole(String email) {
  if (_isEmailRegistered(email)) {
    currentUserRole = _getUserRole(email);
  } else {
    currentUserRole = null; // No permitir acceso si no está registrado
  }
}

// Función para limpiar el rol (llamar desde logout)
void clearUserRole() {
  currentUserRole = null;
}

final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  observers: [LoadingNavObserver()],
  initialLocation: '/loading_screen',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    // Pantallas que no requieren autenticación
    final publicRoutes = [
      '/loading_screen',
      '/welcome_screen',
      '/login_screen',
      '/register_screen',
    ];

    // Si está en una ruta pública, permitir acceso
    if (publicRoutes.contains(state.uri.path)) {
      return null;
    }

    // Si no hay rol de usuario, redirigir al login
    if (currentUserRole == null) {
      return '/login_screen';
    }

    // Protección por roles (solo para emails registrados)
    final coachOnlyRoutes = [
      '/coach_screen',
      '/category_screen',
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
    ];

    // Si es una ruta solo para coach y el usuario no es coach
    if (coachOnlyRoutes.contains(state.uri.path) &&
        currentUserRole != 'coach') {
      return '/login_screen'; // Redirigir al login si no es coach
    }

    // Si es una ruta solo para player y el usuario no es player
    if (playerOnlyRoutes.contains(state.uri.path) &&
        currentUserRole != 'player') {
      return '/login_screen'; // Redirigir al login si no es player
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
  ],
);
