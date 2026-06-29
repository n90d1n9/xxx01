import 'employee_action_workflow_models.dart';

enum EmployeeActionActivityType {
  note('Note'),
  blocker('Blocker'),
  decision('Decision'),
  escalation('Escalation'),
  system('System');

  final String label;

  const EmployeeActionActivityType(this.label);
}

enum EmployeeActionActivityVisibility {
  team('Team'),
  private('Private');

  final String label;

  const EmployeeActionActivityVisibility(this.label);
}

class EmployeeActionActivityEntry {
  final String id;
  final String employeeId;
  final String taskId;
  final String taskTitle;
  final String author;
  final DateTime createdAt;
  final EmployeeActionActivityType type;
  final EmployeeActionActivityVisibility visibility;
  final String body;
  final bool acknowledged;

  const EmployeeActionActivityEntry({
    required this.id,
    required this.employeeId,
    required this.taskId,
    required this.taskTitle,
    required this.author,
    required this.createdAt,
    required this.type,
    required this.visibility,
    required this.body,
    required this.acknowledged,
  });

  bool get requiresAcknowledgement {
    return !acknowledged &&
        (type == EmployeeActionActivityType.blocker ||
            type == EmployeeActionActivityType.escalation);
  }

  bool get isPrivate {
    return visibility == EmployeeActionActivityVisibility.private;
  }

  EmployeeActionActivityEntry copyWith({bool? acknowledged}) {
    return EmployeeActionActivityEntry(
      id: id,
      employeeId: employeeId,
      taskId: taskId,
      taskTitle: taskTitle,
      author: author,
      createdAt: createdAt,
      type: type,
      visibility: visibility,
      body: body,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }
}

class EmployeeActionActivityProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeActionTask> tasks;
  final List<EmployeeActionActivityEntry> entries;

  const EmployeeActionActivityProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.tasks,
    required this.entries,
  });

  EmployeeActionActivityProfile copyWith({
    List<EmployeeActionActivityEntry>? entries,
  }) {
    return EmployeeActionActivityProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      tasks: tasks,
      entries: entries ?? this.entries,
    );
  }

  List<EmployeeActionActivityEntry> get sortedEntries {
    final sorted = [...entries]..sort((a, b) {
      final acknowledgementCompare = _acknowledgementRank(
        a,
      ).compareTo(_acknowledgementRank(b));
      if (acknowledgementCompare != 0) return acknowledgementCompare;

      final typeCompare = _typeRank(a.type).compareTo(_typeRank(b.type));
      if (typeCompare != 0) return typeCompare;

      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  List<EmployeeActionActivityEntry> get latestEntries {
    return sortedEntries.take(6).toList();
  }

  List<EmployeeActionTask> get activeTasks {
    return tasks.where((task) => task.isActive).toList();
  }

  int get noteCount {
    return entries
        .where((entry) => entry.type == EmployeeActionActivityType.note)
        .length;
  }

  int get blockerCount {
    return entries
        .where((entry) => entry.type == EmployeeActionActivityType.blocker)
        .length;
  }

  int get decisionCount {
    return entries
        .where((entry) => entry.type == EmployeeActionActivityType.decision)
        .length;
  }

  int get escalationCount {
    return entries
        .where((entry) => entry.type == EmployeeActionActivityType.escalation)
        .length;
  }

  int get privateCount {
    return entries.where((entry) => entry.isPrivate).length;
  }

  int get pendingAcknowledgementCount {
    return entries.where((entry) => entry.requiresAcknowledgement).length;
  }

  String get nextAction {
    if (pendingAcknowledgementCount > 0) {
      return 'Acknowledge $pendingAcknowledgementCount blocker or escalation update${pendingAcknowledgementCount == 1 ? '' : 's'}.';
    }
    if (blockerCount > 0) {
      return 'Keep blocker updates visible until resolved.';
    }
    if (activeTasks.isNotEmpty && noteCount == 0) {
      return 'Add collaboration notes for active employee tasks.';
    }
    return 'Employee action activity is current.';
  }
}

class EmployeeActionActivityDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String taskId;
  final String author;
  final String body;
  final EmployeeActionActivityType type;
  final EmployeeActionActivityVisibility visibility;

  const EmployeeActionActivityDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.taskId,
    required this.author,
    required this.body,
    required this.type,
    required this.visibility,
  });

  factory EmployeeActionActivityDraft.fromWorkflow({
    required EmployeeActionWorkflowProfile workflow,
  }) {
    final defaultTask =
        workflow.activeTasks.isEmpty ? '' : workflow.activeTasks.first.id;

    return EmployeeActionActivityDraft(
      employeeId: workflow.employeeId,
      employeeName: workflow.employeeName,
      asOfDate: workflow.asOfDate,
      taskId: defaultTask,
      author: 'People Operations',
      body: '',
      type: EmployeeActionActivityType.note,
      visibility: EmployeeActionActivityVisibility.team,
    );
  }

  EmployeeActionActivityDraft copyWith({
    String? taskId,
    String? author,
    String? body,
    EmployeeActionActivityType? type,
    EmployeeActionActivityVisibility? visibility,
  }) {
    return EmployeeActionActivityDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      taskId: taskId ?? this.taskId,
      author: author ?? this.author,
      body: body ?? this.body,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (taskId.trim().isEmpty) {
      errors.add('Select a workflow task');
    }
    if (author.trim().isEmpty) {
      errors.add('Enter an author');
    }
    if (body.trim().length < 8) {
      errors.add('Add an activity note with at least 8 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  EmployeeActionActivityEntry toEntry({
    required String id,
    required EmployeeActionTask task,
  }) {
    return EmployeeActionActivityEntry(
      id: id,
      employeeId: employeeId,
      taskId: task.id,
      taskTitle: task.title,
      author: author.trim(),
      createdAt: asOfDate,
      type: type,
      visibility: visibility,
      body: body.trim(),
      acknowledged:
          type != EmployeeActionActivityType.blocker &&
          type != EmployeeActionActivityType.escalation,
    );
  }
}

int _acknowledgementRank(EmployeeActionActivityEntry entry) {
  return entry.requiresAcknowledgement ? 0 : 1;
}

int _typeRank(EmployeeActionActivityType type) {
  return switch (type) {
    EmployeeActionActivityType.escalation => 0,
    EmployeeActionActivityType.blocker => 1,
    EmployeeActionActivityType.decision => 2,
    EmployeeActionActivityType.note => 3,
    EmployeeActionActivityType.system => 4,
  };
}
