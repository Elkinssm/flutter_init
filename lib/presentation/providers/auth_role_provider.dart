import 'package:coach_app/config/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rol actual del usuario: 'coach' o 'player'. Null si no hay sesión.
/// Se actualiza en login/register/loading al llamar setUserRoleFromBackend.
final currentUserRoleProvider = Provider<String?>((ref) => currentUserRole);
