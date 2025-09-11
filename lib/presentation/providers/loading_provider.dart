import 'package:coach_app/presentation/providers/calendar_provider.dart';
import 'package:coach_app/presentation/providers/keyboard_visibility_provider.dart';
import 'package:coach_app/presentation/providers/register_player_provider.dart';
import 'package:coach_app/presentation/providers/register_user_provider.dart';
import 'package:coach_app/presentation/providers/selected_icon_provider.dart';
import 'package:coach_app/presentation/providers/selected_value_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final loadingProvider = StateNotifierProvider<LoadingNotifier, double>((ref) {
  return LoadingNotifier(ref);
});

class LoadingNotifier extends StateNotifier<double> {
  final Ref ref;
  LoadingNotifier(this.ref) : super(0.0);

  Future<void> initializeApp(BuildContext context) async {
    final tasks = [
      _preloadImages(context),
      _initializeProviders(),
      // _simulateApiCall(),
    ];

    for (int i = 0; i < tasks.length; i++) {
      await tasks[i];
      state = (i + 1) / tasks.length;
    }
  }

  Future<void> _preloadImages(BuildContext context) async {
    final images = [
      'assets/images/group5.png',
      'assets/images/group6.png',
      'assets/images/group14.png',
      'assets/images/home-black-100.png',
      'assets/images/home-100.png',
      'assets/images/image7.png',
      'assets/images/image8.png',
      'assets/images/message-100.png',
      'assets/images/message-black-100.png',
      'assets/images/player.png',
      'assets/images/stadium-100.png',
      'assets/images/stadium-black-100.png',
      'assets/images/subtract.png',
      'assets/images/whistle-96.png',
      'assets/images/winner-100.png',
      'assets/images/winner-black-100.png',
      'assets/images/coach.png',
      'assets/images/student-icon.png',
      'assets/images/edit-icon.png',
      'assets/images/calendar-icon.png',
      'assets/images/cup-icon.png',
      'assets/images/performance-icon.png',
      'assets/images/strong-icon.png',
      'assets/images/person-icon.png',
      'assets/images/members-icon.png',
      'assets/images/asistance-icon.png',
      'assets/images/bar-chart-icon.png',
      'assets/images/check-list-icon.png',
      'assets/images/tournaments-icon.png',
      'assets/images/plus-icon.png',
      'assets/images/tshirt-icon-blue.png',
      'assets/images/tshirt-icon-green.png',
      'assets/images/tshirt-icon-yellow.png',
      'assets/images/student-eg1-icon.png',
      'assets/images/student-eg2-icon.png',
      'assets/images/student-eg3-icon.png',
      'assets/images/student-eg4-icon.png',
      'assets/images/student-eg5-icon.png',
      'assets/images/student-eg6-icon.png',
      'assets/images/club_roma.png',
      'assets/images/ajaz_fc.png',
      'assets/images/manchester_icon.png',
      'assets/images/paris_icon.png',
      'assets/images/campo_futbol.png',
    ];

    for (final img in images) {
      await precacheImage(AssetImage(img), context);
    }
  }

  Future<void> _initializeProviders() async {
    ref.read(keyboardVisibilityProvider.notifier);
    ref.read(selectedIconProvider.notifier);
    // ref.read(formRegisterUserFieldsProvider);
    ref.read(assistanceProvider.notifier);
    ref.read(formFieldsRegisterPlayerProvider);
    ref.read(selectedValueLineChartProvider);
    ref.read(selectedValueBarChartProvider);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Future<void> _simulateApiCall() async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   // Aquí irían llamadas API reales
  // }
}
