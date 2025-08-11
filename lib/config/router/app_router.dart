import 'package:Coach_App/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/loading_screen',
  routes: [
    GoRoute(
      path: '/loading_screen',
      name: LoadingScreen.name,
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/welcome_screen',
      name: WelcomeScreen.name,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login_screen',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register_screen',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/player_screen',
      name: PlayerScreen.name,
      builder: (context, state) => const PlayerScreen(),
    ),
    GoRoute(
      path: '/assistance_screen',
      name: AssistanceScreen.name,
      builder: (context, state) => const AssistanceScreen(),
    ),
    GoRoute(
      path: '/history_screen',
      name: HistoryScreen.name,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/performance_screen',
      name: PerformanceScreen.name,
      builder: (context, state) => const PerformanceScreen(),
    ),
  ],
);
