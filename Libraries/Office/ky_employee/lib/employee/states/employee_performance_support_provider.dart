import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_performance_support_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_performance_support_models.dart';
import 'employee_directory_provider.dart';

final employeePerformanceSupportPlanProvider = StateNotifierProvider.family<
  EmployeePerformanceSupportPlanNotifier,
  EmployeePerformanceSupportPlan?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePerformanceSupportPlanNotifier(null, null, asOfDate);
  }

  return EmployeePerformanceSupportPlanNotifier(
    buildEmployeePerformanceSupportPlan(member: member, asOfDate: asOfDate),
    member,
    asOfDate,
  );
});

final employeePerformanceSupportMilestoneDraftProvider =
    StateNotifierProvider.family<
      EmployeePerformanceSupportMilestoneDraftNotifier,
      EmployeePerformanceSupportMilestoneDraft?,
      String
    >((ref, employeeId) {
      final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
      final member = _findMember(
        ref.watch(employeeDirectoryMembersProvider),
        employeeId,
      );
      if (member == null) {
        return EmployeePerformanceSupportMilestoneDraftNotifier(null);
      }

      return EmployeePerformanceSupportMilestoneDraftNotifier(
        buildEmployeePerformanceSupportMilestoneDraft(
          member: member,
          asOfDate: asOfDate,
        ),
      );
    });

class EmployeePerformanceSupportPlanNotifier
    extends StateNotifier<EmployeePerformanceSupportPlan?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeePerformanceSupportPlanNotifier(
    super.state,
    this._member,
    this._asOfDate,
  );

  void setStatus(EmployeePerformanceSupportStatus status) {
    final plan = state;
    if (plan == null) return;
    state = plan.copyWith(status: status);
  }

  void setTitle(String value) {
    final plan = state;
    if (plan == null) return;
    state = plan.copyWith(title: value);
  }

  void setHrPartner(String value) {
    final plan = state;
    if (plan == null) return;
    state = plan.copyWith(hrPartner: value);
  }

  void setEndDate(DateTime value) {
    final plan = state;
    if (plan == null) return;
    state = plan.copyWith(endDate: _dateOnly(value));
  }

  EmployeePerformanceSupportMilestone addMilestone(
    EmployeePerformanceSupportMilestoneDraft draft,
  ) {
    final plan = state;
    if (plan == null) {
      throw StateError('Employee performance support plan is unavailable');
    }

    final milestone = draft.toMilestone(id: _nextMilestoneId(plan));
    state = plan.copyWith(milestones: [milestone, ...plan.milestones]);
    return milestone;
  }

  void updateMilestoneStatus(
    String milestoneId,
    EmployeePerformanceMilestoneStatus status,
  ) {
    _updateMilestone(
      milestoneId,
      (milestone) => milestone.copyWith(status: status),
    );
  }

  void updateMilestoneRisk(
    String milestoneId,
    EmployeePerformanceSupportRisk risk,
  ) {
    _updateMilestone(
      milestoneId,
      (milestone) => milestone.copyWith(risk: risk),
    );
  }

  void scheduleMilestone(String milestoneId, DateTime dueDate) {
    _updateMilestone(
      milestoneId,
      (milestone) => milestone.copyWith(dueDate: _dateOnly(dueDate)),
    );
  }

  void completeMilestone(String milestoneId) {
    updateMilestoneStatus(
      milestoneId,
      EmployeePerformanceMilestoneStatus.completed,
    );
  }

  void waiveMilestone(String milestoneId) {
    updateMilestoneStatus(
      milestoneId,
      EmployeePerformanceMilestoneStatus.waived,
    );
  }

  void removeMilestone(String milestoneId) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      milestones:
          plan.milestones
              .where((milestone) => milestone.id != milestoneId)
              .toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    if (member == null) return;
    state = buildEmployeePerformanceSupportPlan(
      member: member,
      asOfDate: _asOfDate,
    );
  }

  void _updateMilestone(
    String milestoneId,
    EmployeePerformanceSupportMilestone Function(
      EmployeePerformanceSupportMilestone milestone,
    )
    update,
  ) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      milestones:
          plan.milestones.map((milestone) {
            if (milestone.id != milestoneId) return milestone;
            return update(milestone);
          }).toList(),
    );
  }

  String _nextMilestoneId(EmployeePerformanceSupportPlan plan) {
    var index = plan.milestones.length + 1;
    while (true) {
      final id = 'EPS-${plan.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!plan.milestones.any((milestone) => milestone.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeePerformanceSupportMilestoneDraftNotifier
    extends StateNotifier<EmployeePerformanceSupportMilestoneDraft?> {
  final EmployeePerformanceSupportMilestoneDraft? _initialDraft;

  EmployeePerformanceSupportMilestoneDraftNotifier(super.state)
    : _initialDraft = state;

  void setType(EmployeePerformanceMilestoneType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(dueDate: _dateOnly(value));
  }

  void setRisk(EmployeePerformanceSupportRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setSuccessMetric(String value) {
    state = state?.copyWith(successMetric: value);
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
