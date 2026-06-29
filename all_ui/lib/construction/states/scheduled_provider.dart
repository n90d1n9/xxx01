// Schedule Provider
import 'package:flutter_riverpod/legacy.dart';

import '../models/schedule.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<Schedule>>(
      (ref) => ScheduleNotifier(),
    );

class ScheduleNotifier extends StateNotifier<List<Schedule>> {
  ScheduleNotifier() : super([]);

  void addSchedule(Schedule schedule) {
    state = [...state, schedule];
  }

  void updateSchedule(Schedule schedule) {
    state = [
      for (final s in state)
        if (s.id == schedule.id) schedule else s,
    ];
  }

  void deleteSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  List<Schedule> getByProject(String projectId) {
    return state.where((s) => s.projectId == projectId).toList();
  }
}
