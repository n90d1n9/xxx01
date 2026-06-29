import 'employee_next_action_models.dart';

enum EmployeeActionTaskStatus {
  open('Open'),
  inProgress('In progress'),
  waiting('Waiting'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const EmployeeActionTaskStatus(this.label);
}

class EmployeeActionTask {
  final String id;
  final String employeeId;
  final String employeeName;
  final String title;
  final String description;
  final String owner;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final EmployeeActionTaskStatus status;
  final String sourceLabel;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  const EmployeeActionTask({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.title,
    required this.description,
    required this.owner,
    required this.area,
    required this.priority,
    required this.status,
    required this.sourceLabel,
    required this.dueDate,
    required this.createdAt,
    required this.completedAt,
  });

  factory EmployeeActionTask.fromNextAction({
    required String id,
    required EmployeeNextAction action,
    required String employeeId,
    required String employeeName,
    required DateTime asOfDate,
  }) {
    return EmployeeActionTask(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      title: action.title,
      description: action.detail,
      owner: action.owner,
      area: action.area,
      priority: action.priority,
      status: EmployeeActionTaskStatus.open,
      sourceLabel: action.sourceLabel,
      dueDate: _dateOnly(
        action.dueDate ?? asOfDate.add(const Duration(days: 7)),
      ),
      createdAt: _dateOnly(asOfDate),
      completedAt: null,
    );
  }

  bool get isClosed {
    return status == EmployeeActionTaskStatus.completed ||
        status == EmployeeActionTaskStatus.cancelled;
  }

  bool get isActive => !isClosed;

  bool get canStart {
    return status == EmployeeActionTaskStatus.open ||
        status == EmployeeActionTaskStatus.waiting;
  }

  bool get canWait {
    return status == EmployeeActionTaskStatus.open ||
        status == EmployeeActionTaskStatus.inProgress;
  }

  bool get canComplete => isActive;

  bool get canReopen => isClosed;

  bool isOverdue(DateTime asOfDate) {
    return isActive && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeActionTask copyWith({
    String? title,
    String? description,
    String? owner,
    EmployeeNextActionArea? area,
    EmployeeNextActionPriority? priority,
    EmployeeActionTaskStatus? status,
    String? sourceLabel,
    DateTime? dueDate,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return EmployeeActionTask(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      title: title ?? this.title,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      area: area ?? this.area,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}

class EmployeeActionWorkflowProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeActionTask> tasks;

  const EmployeeActionWorkflowProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.tasks,
  });

  EmployeeActionWorkflowProfile copyWith({List<EmployeeActionTask>? tasks}) {
    return EmployeeActionWorkflowProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      tasks: tasks ?? this.tasks,
    );
  }

  List<EmployeeActionTask> get sortedTasks {
    final sorted = [...tasks]..sort((a, b) {
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;

      final overdueCompare = _overdueRank(
        a,
        asOfDate,
      ).compareTo(_overdueRank(b, asOfDate));
      if (overdueCompare != 0) return overdueCompare;

      final priorityCompare = _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority));
      if (priorityCompare != 0) return priorityCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  List<EmployeeActionTask> get activeTasks {
    return sortedTasks.where((task) => task.isActive).toList();
  }

  int get openCount {
    return tasks
        .where((task) => task.status == EmployeeActionTaskStatus.open)
        .length;
  }

  int get inProgressCount {
    return tasks
        .where((task) => task.status == EmployeeActionTaskStatus.inProgress)
        .length;
  }

  int get waitingCount {
    return tasks
        .where((task) => task.status == EmployeeActionTaskStatus.waiting)
        .length;
  }

  int get completedCount {
    return tasks
        .where((task) => task.status == EmployeeActionTaskStatus.completed)
        .length;
  }

  int get overdueCount {
    return tasks.where((task) => task.isOverdue(asOfDate)).length;
  }

  int get criticalCount {
    return tasks
        .where(
          (task) =>
              task.isActive &&
              task.priority == EmployeeNextActionPriority.critical,
        )
        .length;
  }

  double get completionRatio {
    if (tasks.isEmpty) return 0;
    return completedCount / tasks.length;
  }

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue employee task${overdueCount == 1 ? '' : 's'}.';
    }
    if (criticalCount > 0) {
      return 'Move $criticalCount critical employee task${criticalCount == 1 ? '' : 's'} forward.';
    }
    if (inProgressCount > 0) {
      return 'Complete $inProgressCount employee task${inProgressCount == 1 ? '' : 's'} in progress.';
    }
    if (openCount > 0) {
      return 'Start $openCount open employee task${openCount == 1 ? '' : 's'}.';
    }
    return 'Employee action workflow is clear.';
  }
}

class EmployeeActionTaskDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final String description;
  final String owner;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final DateTime? dueDate;

  const EmployeeActionTaskDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.description,
    required this.owner,
    required this.area,
    required this.priority,
    required this.dueDate,
  });

  factory EmployeeActionTaskDraft.fromEmployee({
    required String employeeId,
    required String employeeName,
    required DateTime asOfDate,
  }) {
    return EmployeeActionTaskDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: _dateOnly(asOfDate),
      title: '',
      description: '',
      owner: 'People Operations',
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.medium,
      dueDate: _dateOnly(asOfDate).add(const Duration(days: 7)),
    );
  }

  EmployeeActionTaskDraft copyWith({
    String? title,
    String? description,
    String? owner,
    EmployeeNextActionArea? area,
    EmployeeNextActionPriority? priority,
    DateTime? dueDate,
  }) {
    return EmployeeActionTaskDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      area: area ?? this.area,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    final trimmedOwner = owner.trim();
    final due = dueDate == null ? null : _dateOnly(dueDate!);

    if (trimmedTitle.isEmpty) {
      errors.add('Enter an action title');
    }
    if (trimmedDescription.length < 8) {
      errors.add('Describe the follow-up in at least 8 characters');
    }
    if (trimmedOwner.isEmpty) {
      errors.add('Assign an owner');
    }
    if (due == null) {
      errors.add('Select a due date');
    } else if (due.isBefore(_dateOnly(asOfDate))) {
      errors.add('Due date cannot be in the past');
    }

    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  EmployeeActionTask toTask({required String id}) {
    return EmployeeActionTask(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      title: title.trim(),
      description: description.trim(),
      owner: owner.trim(),
      area: area,
      priority: priority,
      status: EmployeeActionTaskStatus.open,
      sourceLabel: 'Manual follow-up',
      dueDate: _dateOnly(dueDate!),
      createdAt: _dateOnly(asOfDate),
      completedAt: null,
    );
  }
}

int _statusRank(EmployeeActionTaskStatus status) {
  return switch (status) {
    EmployeeActionTaskStatus.inProgress => 0,
    EmployeeActionTaskStatus.open => 1,
    EmployeeActionTaskStatus.waiting => 2,
    EmployeeActionTaskStatus.completed => 3,
    EmployeeActionTaskStatus.cancelled => 4,
  };
}

int _overdueRank(EmployeeActionTask task, DateTime asOfDate) {
  return task.isOverdue(asOfDate) ? 0 : 1;
}

int _priorityRank(EmployeeNextActionPriority priority) {
  return switch (priority) {
    EmployeeNextActionPriority.critical => 0,
    EmployeeNextActionPriority.high => 1,
    EmployeeNextActionPriority.medium => 2,
    EmployeeNextActionPriority.low => 3,
  };
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
