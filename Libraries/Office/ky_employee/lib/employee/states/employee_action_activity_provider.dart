import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_action_activity_models.dart';
import '../models/employee_action_workflow_models.dart';
import 'employee_action_workflow_provider.dart';

final employeeActionActivityProvider = StateNotifierProvider.family<
  EmployeeActionActivityNotifier,
  EmployeeActionActivityProfile?,
  String
>((ref, employeeId) {
  final workflow = ref.watch(employeeActionWorkflowProvider(employeeId));
  if (workflow == null) {
    return EmployeeActionActivityNotifier(null);
  }

  return EmployeeActionActivityNotifier(
    EmployeeActionActivityProfile(
      employeeId: workflow.employeeId,
      employeeName: workflow.employeeName,
      asOfDate: workflow.asOfDate,
      tasks: workflow.sortedTasks,
      entries: _seedEntries(workflow),
    ),
  );
});

final employeeActionActivityDraftProvider = StateNotifierProvider.family<
  EmployeeActionActivityDraftNotifier,
  EmployeeActionActivityDraft?,
  String
>((ref, employeeId) {
  final workflow = ref.watch(employeeActionWorkflowProvider(employeeId));
  if (workflow == null) {
    return EmployeeActionActivityDraftNotifier(null);
  }

  return EmployeeActionActivityDraftNotifier(
    EmployeeActionActivityDraft.fromWorkflow(workflow: workflow),
  );
});

class EmployeeActionActivityNotifier
    extends StateNotifier<EmployeeActionActivityProfile?> {
  EmployeeActionActivityNotifier(super.state);

  EmployeeActionActivityEntry addDraft(EmployeeActionActivityDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee action activity is unavailable');
    }
    if (!draft.isReadyToAdd) {
      throw StateError(draft.validationErrors.first);
    }

    final task = _findTask(profile.tasks, draft.taskId);
    if (task == null) {
      throw StateError('Selected workflow task is unavailable');
    }

    final entry = draft.toEntry(id: _nextEntryId(profile), task: task);
    state = profile.copyWith(entries: [entry, ...profile.entries]);
    return entry;
  }

  void acknowledge(String entryId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      entries:
          profile.entries.map((entry) {
            if (entry.id != entryId) return entry;
            return entry.copyWith(acknowledged: true);
          }).toList(),
    );
  }

  String _nextEntryId(EmployeeActionActivityProfile profile) {
    var index = profile.entries.length + 1;
    while (true) {
      final id =
          'EAA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.entries.any((entry) => entry.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeActionActivityDraftNotifier
    extends StateNotifier<EmployeeActionActivityDraft?> {
  final EmployeeActionActivityDraft? _initialDraft;

  EmployeeActionActivityDraftNotifier(super.state) : _initialDraft = state;

  void setTaskId(String value) {
    state = state?.copyWith(taskId: value);
  }

  void setAuthor(String value) {
    state = state?.copyWith(author: value);
  }

  void setBody(String value) {
    state = state?.copyWith(body: value);
  }

  void setType(EmployeeActionActivityType value) {
    state = state?.copyWith(type: value);
  }

  void setVisibility(EmployeeActionActivityVisibility value) {
    state = state?.copyWith(visibility: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeActionActivityEntry> _seedEntries(
  EmployeeActionWorkflowProfile workflow,
) {
  final entries = <EmployeeActionActivityEntry>[];
  final tasks = workflow.activeTasks.take(2).toList();

  for (var index = 0; index < tasks.length; index++) {
    final task = tasks[index];
    entries.add(
      EmployeeActionActivityEntry(
        id: 'EAA-${workflow.employeeId}-S${index + 1}',
        employeeId: workflow.employeeId,
        taskId: task.id,
        taskTitle: task.title,
        author: 'System',
        createdAt: workflow.asOfDate,
        type: EmployeeActionActivityType.system,
        visibility: EmployeeActionActivityVisibility.team,
        body: 'Task opened from ${task.sourceLabel}.',
        acknowledged: true,
      ),
    );
  }

  return entries;
}

EmployeeActionTask? _findTask(List<EmployeeActionTask> tasks, String taskId) {
  for (final task in tasks) {
    if (task.id == taskId) return task;
  }
  return null;
}
