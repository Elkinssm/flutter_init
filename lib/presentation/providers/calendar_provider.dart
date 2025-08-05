import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para el calendario
class AssistanceState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DateTime> attendedDays;

  AssistanceState({
    required this.focusedDay,
    this.selectedDay,
    this.attendedDays = const [],
  });

  AssistanceState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<DateTime>? attendedDays,
  }) {
    return AssistanceState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      attendedDays: attendedDays ?? this.attendedDays,
    );
  }
}

/// Notifier para manejar la lógica del calendario
class AssistanceNotifier extends StateNotifier<AssistanceState> {
  AssistanceNotifier()
    : super(
        AssistanceState(
          focusedDay: DateTime.now(),
          selectedDay: null,
          attendedDays: [
            DateTime(2025, 7, 5),
            DateTime(2025, 7, 6),
            DateTime(2025, 7, 12),
          ],
        ),
      );

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay);
  }

  void changeMonth(DateTime focusedDay) async {
    await Future.delayed(Duration(milliseconds: 100));
    state = state.copyWith(focusedDay: focusedDay);
  }
}

final assistanceProvider =
    StateNotifierProvider<AssistanceNotifier, AssistanceState>((ref) {
      return AssistanceNotifier();
    });
