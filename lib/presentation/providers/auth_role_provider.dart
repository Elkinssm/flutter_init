import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rol actual del usuario: 'coach' o 'player'. Null si no hay sesión.
/// Debe mantenerse sincronizado en login/register/loading/logout.
final currentUserRoleProvider = StateProvider<String?>((ref) => null);
