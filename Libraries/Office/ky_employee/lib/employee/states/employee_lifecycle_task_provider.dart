import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_lifecycle_task_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_lifecycle_task_models.dart';
import 'employee_directory_provider.dart';

final employeeLifecyclePlanProvider = StateNotifierProvider.family<
  EmployeeLifecyclePlanNotifier,
  EmployeeLifecyclePlan?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeLifecyclePlanNotifier(null, null, asOfDate);
  }

  return EmployeeLifecyclePlanNotifier(
    buildEmployeeLifecyclePlan(member: member, asOfDate: asOfDate),
    member,
    asOfDate,
  );
});

final employeeLifecycleTaskDraftProvider = StateNotifierProvider.family<
  EmployeeLifecycleTaskDraftNotifier,
  EmployeeLifecycleTaskDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeLifecycleTaskDraftNotifier(null);
  }

  return EmployeeLifecycleTaskDraftNotifier(
    EmployeeLifecycleTaskDraft.fromMember(member: member, asOfDate: asOfDate),
  );
});

class EmployeeLifecyclePlanNotifier
    extends StateNotifier<EmployeeLifecyclePlan?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeeLifecyclePlanNotifier(super.state, this._member, this._asOfDate);

  void setPlanType(EmployeeLifecyclePlanType type) {
    final member = _member;
    if (member == null) return;

    state = buildEmployeeLifecyclePlan(
      member: member,
      asOfDate: _asOfDate,
      type: type,
    );
  }

  EmployeeLifecycleTask addTask(EmployeeLifecycleTaskDraft draft) {
    final plan = state;
    if (plan == null) {
      throw StateError('Employee lifecycle plan is unavailable');
    }

    final task = draft.toTask(id: _nextTaskId(plan));
    state = plan.copyWith(tasks: [...plan.tasks, task]);
    return task;
  }

  void updateTaskStatus(String taskId, EmployeeLifecycleTaskStatus status) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      tasks:
          plan.tasks.map((task) {
            if (task.id == taskId) {
              return task.copyWith(status: status);
            }
            return task;
          }).toList(),
    );
  }

  void removeTask(String taskId) {
    final plan = state;
    if (plan == null) return;

    state = plan.copyWith(
      tasks: plan.tasks.where((task) => task.id != taskId).toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    final plan = state;
    if (member == null || plan == null) return;

    state = buildEmployeeLifecyclePlan(
      member: member,
      asOfDate: _asOfDate,
      type: plan.type,
    );
  }

  String _nextTaskId(EmployeeLifecyclePlan plan) {
    var index = plan.tasks.length + 1;
    while (true) {
      final id = 'ELT-${plan.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!plan.tasks.any((task) => task.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeLifecycleTaskDraftNotifier
    extends StateNotifier<EmployeeLifecycleTaskDraft?> {
  final EmployeeLifecycleTaskDraft? _initialDraft;

  EmployeeLifecycleTaskDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(title: value);
  }

  void setOwner(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setPriority(EmployeeLifecycleTaskPriority value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(priority: value);
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
