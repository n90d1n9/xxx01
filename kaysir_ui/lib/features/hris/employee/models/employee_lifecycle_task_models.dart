import 'employee_directory_models.dart';

enum EmployeeLifecyclePlanType {
  onboarding('Onboarding'),
  probationReview('Probation review'),
  offboarding('Offboarding'),
  contractReview('Contract review');

  final String label;

  const EmployeeLifecyclePlanType(this.label);
}

enum EmployeeLifecycleTaskStatus {
  open('Open'),
  inProgress('In progress'),
  blocked('Blocked'),
  done('Done');

  final String label;

  const EmployeeLifecycleTaskStatus(this.label);
}

enum EmployeeLifecycleTaskPriority {
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeLifecycleTaskPriority(this.label);
}

class EmployeeLifecycleTask {
  final String id;
  final String employeeId;
  final String title;
  final String owner;
  final DateTime dueDate;
  final EmployeeLifecycleTaskStatus status;
  final EmployeeLifecycleTaskPriority priority;

  const EmployeeLifecycleTask({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.priority,
  });

  bool get isComplete => status == EmployeeLifecycleTaskStatus.done;

  bool get needsAttention {
    return status == EmployeeLifecycleTaskStatus.open ||
        status == EmployeeLifecycleTaskStatus.inProgress ||
        status == EmployeeLifecycleTaskStatus.blocked;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isComplete && dueDate.isBefore(_dateOnly(asOfDate));
  }

  EmployeeLifecycleTask copyWith({
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeLifecycleTaskStatus? status,
    EmployeeLifecycleTaskPriority? priority,
  }) {
    return EmployeeLifecycleTask(
      id: id,
      employeeId: employeeId,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}

class EmployeeLifecyclePlan {
  final String employeeId;
  final String employeeName;
  final EmployeeLifecyclePlanType type;
  final DateTime launchedAt;
  final DateTime asOfDate;
  final List<EmployeeLifecycleTask> tasks;

  const EmployeeLifecyclePlan({
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.launchedAt,
    required this.asOfDate,
    required this.tasks,
  });

  EmployeeLifecyclePlan copyWith({
    EmployeeLifecyclePlanType? type,
    DateTime? launchedAt,
    DateTime? asOfDate,
    List<EmployeeLifecycleTask>? tasks,
  }) {
    return EmployeeLifecyclePlan(
      employeeId: employeeId,
      employeeName: employeeName,
      type: type ?? this.type,
      launchedAt: launchedAt ?? this.launchedAt,
      asOfDate: asOfDate ?? this.asOfDate,
      tasks: tasks ?? this.tasks,
    );
  }

  int get openCount {
    return tasks
        .where((task) => task.status == EmployeeLifecycleTaskStatus.open)
        .length;
  }

  int get blockedCount {
    return tasks
        .where((task) => task.status == EmployeeLifecycleTaskStatus.blocked)
        .length;
  }

  int get doneCount {
    return tasks.where((task) => task.isComplete).length;
  }

  int get activeCount {
    return tasks.where((task) => task.needsAttention).length;
  }

  int get overdueCount {
    return tasks.where((task) => task.isOverdue(asOfDate)).length;
  }

  double get completionRatio {
    if (tasks.isEmpty) return 0;
    return doneCount / tasks.length;
  }

  EmployeeLifecycleTask? get nextDueTask {
    final activeTasks =
        tasks.where((task) => !task.isComplete).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (activeTasks.isEmpty) return null;
    return activeTasks.first;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Clear $blockedCount blocked lifecycle task${blockedCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue lifecycle task${overdueCount == 1 ? '' : 's'}.';
    }
    final nextTask = nextDueTask;
    if (nextTask == null) {
      return '${type.label} lifecycle plan is complete.';
    }
    return 'Next: ${nextTask.title}.';
  }
}

class EmployeeLifecycleTaskDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String title;
  final String owner;
  final DateTime? dueDate;
  final EmployeeLifecycleTaskPriority priority;

  const EmployeeLifecycleTaskDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.priority,
  });

  factory EmployeeLifecycleTaskDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    return EmployeeLifecycleTaskDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: _dateOnly(asOfDate),
      title: '',
      owner: 'HR Operations',
      dueDate: _dateOnly(asOfDate).add(const Duration(days: 7)),
      priority: EmployeeLifecycleTaskPriority.medium,
    );
  }

  EmployeeLifecycleTaskDraft copyWith({
    String? title,
    String? owner,
    DateTime? dueDate,
    EmployeeLifecycleTaskPriority? priority,
  }) {
    return EmployeeLifecycleTaskDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Task title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Task owner is required');
    }
    if (dueDate == null) {
      errors.add('Due date is required');
    } else if (dueDate!.isBefore(asOfDate)) {
      errors.add('Due date cannot be before today');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var completed = 0;
    if (title.trim().length >= 4) completed++;
    if (owner.trim().length >= 3) completed++;
    if (dueDate != null && !dueDate!.isBefore(asOfDate)) completed++;
    return completed / 3;
  }

  EmployeeLifecycleTask toTask({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeLifecycleTask(
      id: id,
      employeeId: employeeId,
      title: title.trim(),
      owner: owner.trim(),
      dueDate: dueDate!,
      status: EmployeeLifecycleTaskStatus.open,
      priority: priority,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
