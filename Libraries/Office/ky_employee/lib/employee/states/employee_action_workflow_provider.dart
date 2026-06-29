import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_action_workflow_models.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_next_action_models.dart';
import 'employee_directory_provider.dart';
import 'employee_next_action_provider.dart';

final employeeActionWorkflowProvider = StateNotifierProvider.family<
  EmployeeActionWorkflowNotifier,
  EmployeeActionWorkflowProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeActionWorkflowNotifier(null);
  }

  final recommendations = ref.watch(
    employeeNextActionProfileProvider(employeeId),
  );

  return EmployeeActionWorkflowNotifier(
    EmployeeActionWorkflowProfile(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: _dateOnly(asOfDate),
      tasks: _seedTasks(
        member: member,
        asOfDate: asOfDate,
        recommendations: recommendations?.topActions ?? const [],
      ),
    ),
  );
});

final employeeActionTaskDraftProvider = StateNotifierProvider.family<
  EmployeeActionTaskDraftNotifier,
  EmployeeActionTaskDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeActionTaskDraftNotifier(null);
  }

  return EmployeeActionTaskDraftNotifier(
    EmployeeActionTaskDraft.fromEmployee(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: asOfDate,
    ),
  );
});

class EmployeeActionWorkflowNotifier
    extends StateNotifier<EmployeeActionWorkflowProfile?> {
  EmployeeActionWorkflowNotifier(super.state);

  EmployeeActionTask addDraft(EmployeeActionTaskDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee action workflow is unavailable');
    }
    if (!draft.isReadyToAdd) {
      throw StateError(draft.validationErrors.first);
    }

    final task = draft.toTask(id: _nextTaskId(profile));
    state = profile.copyWith(tasks: [task, ...profile.tasks]);
    return task;
  }

  void startTask(String taskId) {
    _updateTask(taskId, (task) {
      if (!task.canStart) return task;
      return task.copyWith(
        status: EmployeeActionTaskStatus.inProgress,
        clearCompletedAt: true,
      );
    });
  }

  void markWaiting(String taskId) {
    _updateTask(taskId, (task) {
      if (!task.canWait) return task;
      return task.copyWith(
        status: EmployeeActionTaskStatus.waiting,
        clearCompletedAt: true,
      );
    });
  }

  void completeTask(String taskId) {
    final profile = state;
    if (profile == null) return;
    _updateTask(taskId, (task) {
      if (!task.canComplete) return task;
      return task.copyWith(
        status: EmployeeActionTaskStatus.completed,
        completedAt: profile.asOfDate,
      );
    });
  }

  void reopenTask(String taskId) {
    _updateTask(taskId, (task) {
      if (!task.canReopen) return task;
      return task.copyWith(
        status: EmployeeActionTaskStatus.open,
        clearCompletedAt: true,
      );
    });
  }

  void cancelTask(String taskId) {
    _updateTask(taskId, (task) {
      if (task.isClosed) return task;
      return task.copyWith(status: EmployeeActionTaskStatus.cancelled);
    });
  }

  void _updateTask(
    String taskId,
    EmployeeActionTask Function(EmployeeActionTask task) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      tasks:
          profile.tasks.map((task) {
            if (task.id != taskId) return task;
            return update(task);
          }).toList(),
    );
  }

  String _nextTaskId(EmployeeActionWorkflowProfile profile) {
    var index = profile.tasks.length + 1;
    while (true) {
      final id =
          'EAW-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.tasks.any((task) => task.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeActionTaskDraftNotifier
    extends StateNotifier<EmployeeActionTaskDraft?> {
  final EmployeeActionTaskDraft? _initialDraft;

  EmployeeActionTaskDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state?.copyWith(description: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setArea(EmployeeNextActionArea value) {
    state = state?.copyWith(area: value);
  }

  void setPriority(EmployeeNextActionPriority value) {
    state = state?.copyWith(priority: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(dueDate: _dateOnly(value));
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeActionTask> _seedTasks({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
  required List<EmployeeNextAction> recommendations,
}) {
  final tasks = <EmployeeActionTask>[];
  for (var index = 0; index < recommendations.length && index < 4; index++) {
    tasks.add(
      EmployeeActionTask.fromNextAction(
        id: 'EAW-${member.id}-${(index + 1).toString().padLeft(3, '0')}',
        action: recommendations[index],
        employeeId: member.id,
        employeeName: member.name,
        asOfDate: asOfDate,
      ),
    );
  }
  return tasks;
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

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
