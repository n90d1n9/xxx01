import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_performance_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_performance_models.dart';
import 'employee_directory_provider.dart';

final employeePerformancePlanProvider = StateNotifierProvider.family<
  EmployeePerformancePlanNotifier,
  EmployeePerformancePlan?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePerformancePlanNotifier(null);
  }

  return EmployeePerformancePlanNotifier(
    buildEmployeePerformancePlan(member: member, asOfDate: asOfDate),
  );
});

final employeePerformanceCheckInDraftProvider = StateNotifierProvider.family<
  EmployeePerformanceCheckInDraftNotifier,
  EmployeePerformanceCheckInDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePerformanceCheckInDraftNotifier(null);
  }

  return EmployeePerformanceCheckInDraftNotifier(
    buildEmployeePerformanceCheckInDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeePerformancePlanNotifier
    extends StateNotifier<EmployeePerformancePlan?> {
  EmployeePerformancePlanNotifier(super.state);

  void updateGoalProgress(String goalId, double progress) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      goals:
          plan.goals.map((goal) {
            if (goal.id == goalId) {
              return goal.copyWith(progress: progress);
            }
            return goal;
          }).toList(),
    );
  }

  void updateGoalStatus(String goalId, EmployeePerformanceGoalStatus status) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      goals:
          plan.goals.map((goal) {
            if (goal.id == goalId) {
              final progress =
                  status == EmployeePerformanceGoalStatus.complete
                      ? 1.0
                      : goal.progress;
              return goal.copyWith(progress: progress, status: status);
            }
            return goal;
          }).toList(),
    );
  }

  EmployeePerformanceCheckIn addCheckIn(EmployeePerformanceCheckInDraft draft) {
    final plan = state;
    if (plan == null) {
      throw StateError('Employee performance plan is unavailable');
    }

    final checkIn = draft.toCheckIn(id: _nextCheckInId(plan));
    state = plan.copyWith(checkIns: [checkIn, ...plan.checkIns]);
    return checkIn;
  }

  String _nextCheckInId(EmployeePerformancePlan plan) {
    return 'EPI-${plan.employeeId}-${(plan.checkIns.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeePerformanceCheckInDraftNotifier
    extends StateNotifier<EmployeePerformanceCheckInDraft?> {
  final EmployeePerformanceCheckInDraft? _initialDraft;

  EmployeePerformanceCheckInDraftNotifier(super.state) : _initialDraft = state;

  void setSentiment(EmployeePerformanceCheckInSentiment value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(sentiment: value);
  }

  void setSummary(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(summary: value);
  }

  void setNextStep(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(nextStep: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
