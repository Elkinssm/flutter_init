import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Override local en desarrollo para fotos de jugadores cuando el backend
/// aún no persiste foto_url correctamente.
final playerPhotoOverridesProvider =
    StateProvider<Map<int, String>>((ref) => <int, String>{});
