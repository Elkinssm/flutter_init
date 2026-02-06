import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Si es true, la pantalla del jugador debe mostrar el modal de perfil incompleto.
final showProfileIncompleteModalProvider = StateProvider<bool>((ref) => false);

/// Si es false, mostrar vista simplificada (avatar) en lugar de la info completa del jugador.
final currentUserProfileCompleteProvider = StateProvider<bool>((ref) => true);

/// Iniciales del usuario actual para el avatar (ej: "DB"). Vacío o "?" si no hay nombre.
final currentUserInitialsProvider = StateProvider<String>((ref) => '?');

/// Nombre completo para mostrar en el menú de perfil (ej: "Juan Pérez").
final currentUserDisplayNameProvider = StateProvider<String>((ref) => 'Usuario');

/// Si es true, la pantalla principal (player/coach) debe abrir el drawer de perfil al construir.
final openProfileDrawerProvider = StateProvider<bool>((ref) => false);
