import 'package:coach_app/infrastructure/services/session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});
