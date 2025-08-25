import 'package:coach_app/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

import 'transitions_config/custom_transition.dart';

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
      pageBuilder: (context, state) => CustomTransition.slideLeft(const WelcomeScreen()),
      // builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login_screen',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register_screen',
      name: RegisterScreen.name,
      pageBuilder: (context, state) => CustomTransition.slideLeft(const RegisterScreen()),
      // builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/player_screen',
      name: PlayerScreen.name,
      pageBuilder: (context, state) => CustomTransition.slideLeft(const PlayerScreen()),
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
    GoRoute(
      path: '/coach_screen',
      name: CoachScreen.name,
      builder: (context, state) => const CoachScreen(),
    ),
    GoRoute(
      path: '/category_screen',
      name: CategoryScreen.name,
      builder: (context, state) => const CategoryScreen(),
    ),
    GoRoute(
      path: '/selected_category_screen',
      name: SelectedCategoryScreen.name,
      builder: (context, state) {
        final year = state.extra as int;
        return SelectedCategoryScreen(year: year);
      },//=> const SelectedCategoryScreen(),
    ),
    GoRoute(
      path: '/daily_attendance_screen',
      name: DailyAttendanceScreen.name,
      builder: (context, state) => const DailyAttendanceScreen(),
    ),
    GoRoute(
      path: '/newPlayerScreen',
      name: NewPlayerScreen.name,
      builder: (context, state) => const NewPlayerScreen(),
    ),
  ],
);
