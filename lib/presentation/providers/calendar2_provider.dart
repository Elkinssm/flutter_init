import 'package:flutter_riverpod/flutter_riverpod.dart';

class Assistance2State {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DateTime> attendedDays;

  Assistance2State({
    required this.focusedDay,
    this.selectedDay,
    this.attendedDays = const [],
  });

  Assistance2State copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<DateTime>? attendedDays,
  }) {
    return Assistance2State(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      attendedDays: attendedDays ?? this.attendedDays,
    );
  }
}

class AssistanceNotifier extends StateNotifier<Assistance2State> {
  AssistanceNotifier()
    : super(
        Assistance2State(
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

final assistanceProvider2 =
    StateNotifierProvider<AssistanceNotifier, Assistance2State>((ref) {
      return AssistanceNotifier();
    });
