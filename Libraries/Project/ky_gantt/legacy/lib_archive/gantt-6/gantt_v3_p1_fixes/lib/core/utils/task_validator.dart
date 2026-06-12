import '../models/task_model.dart';

/// Centralised validation for [Task] creation and updates.
///
/// Used by [TasksNotifier.addTask] and the task-form UI to provide
/// consistent error messages before any state mutation occurs.
class TaskValidationError {
  final String field;
  final String message;
  const TaskValidationError({required this.field, required this.message});

  @override
  String toString() => '$field: $message';
}

class TaskValidationResult {
  final List<TaskValidationError> errors;
  const TaskValidationResult(this.errors);

  bool get isValid => errors.isEmpty;

  /// Returns the first error for [field], or null if field is valid.
  String? errorFor(String field) {
    try {
      return errors.firstWhere((e) => e.field == field).message;
    } catch (_) {
      return null;
    }
  }

  /// Throws a [TaskValidationException] if invalid, otherwise does nothing.
  void throwIfInvalid() {
    if (!isValid) throw TaskValidationException(errors);
  }
}

class TaskValidationException implements Exception {
  final List<TaskValidationError> errors;
  const TaskValidationException(this.errors);

  @override
  String toString() => 'TaskValidationException: ${errors.map((e) => e.toString()).join(', ')}';
}

class TaskValidator {
  TaskValidator._();

  /// Validates all fields on a [Task] before creation or update.
  static TaskValidationResult validate(Task task, {List<Task> existingTasks = const []}) {
    final errors = <TaskValidationError>[];

    // ── Title ──────────────────────────────────────────────────────────────
    final title = task.title.trim();
    if (title.isEmpty) {
      errors.add(const TaskValidationError(
          field: 'title', message: 'Title is required'));
    } else if (title.length < 2) {
      errors.add(const TaskValidationError(
          field: 'title', message: 'Title must be at least 2 characters'));
    } else if (title.length > 200) {
      errors.add(const TaskValidationError(
          field: 'title', message: 'Title must be 200 characters or fewer'));
    }

    // ── Dates ──────────────────────────────────────────────────────────────
    if (task.startDate.isAfter(task.endDate)) {
      errors.add(const TaskValidationError(
          field: 'endDate', message: 'End date must be on or after start date'));
    }

    // Warn on excessively long tasks (>5 years) — likely a data entry error
    final durationYears = task.endDate.difference(task.startDate).inDays / 365.0;
    if (durationYears > 5) {
      errors.add(const TaskValidationError(
          field: 'endDate', message: 'Duration exceeds 5 years — check dates'));
    }

    // ── Dependency cycles ──────────────────────────────────────────────────
    if (existingTasks.isNotEmpty) {
      for (final dep in task.dependencies) {
        if (dep.predecessorId == task.id) {
          errors.add(const TaskValidationError(
              field: 'dependencies', message: 'A task cannot depend on itself'));
        }
        // Check for simple 2-node cycle: A→B and B→A
        final pred = existingTasks.where((t) => t.id == dep.predecessorId).firstOrNull;
        if (pred != null) {
          final cycle = pred.dependencies.any((d) => d.predecessorId == task.id);
          if (cycle) {
            errors.add(TaskValidationError(
                field: 'dependencies',
                message: 'Circular dependency with "${pred.title}"'));
          }
        }
      }
    }

    // ── Estimated hours ────────────────────────────────────────────────────
    if (task.estimatedHours < 0) {
      errors.add(const TaskValidationError(
          field: 'estimatedHours', message: 'Estimated hours cannot be negative'));
    }
    if (task.estimatedHours > 100000) {
      errors.add(const TaskValidationError(
          field: 'estimatedHours', message: 'Estimated hours seems unreasonably large'));
    }

    // ── Monte Carlo 3-point estimates ──────────────────────────────────────
    if (task.optimisticDays > 0 && task.pessimisticDays > 0) {
      if (task.optimisticDays > task.durationDays) {
        errors.add(const TaskValidationError(
            field: 'optimisticDays',
            message: 'Optimistic estimate should be ≤ likely (duration)'));
      }
      if (task.pessimisticDays < task.durationDays) {
        errors.add(const TaskValidationError(
            field: 'pessimisticDays',
            message: 'Pessimistic estimate should be ≥ likely (duration)'));
      }
    }

    // ── Progress ───────────────────────────────────────────────────────────
    if (task.progress < 0.0 || task.progress > 1.0) {
      errors.add(const TaskValidationError(
          field: 'progress', message: 'Progress must be between 0% and 100%'));
    }

    // ── Constraint date required for certain constraints ───────────────────
    final requiresDate = {
      TaskConstraint.mustStartOn,
      TaskConstraint.mustFinishOn,
      TaskConstraint.startNoEarlierThan,
      TaskConstraint.finishNoLaterThan,
    };
    if (requiresDate.contains(task.constraint) && task.constraintDate == null) {
      errors.add(TaskValidationError(
          field: 'constraintDate',
          message: '${task.constraint.label} requires a constraint date'));
    }

    return TaskValidationResult(errors);
  }

  /// Quick title-only check used by the inline rename handler.
  static String? validateTitle(String title) {
    final t = title.trim();
    if (t.isEmpty) return 'Title is required';
    if (t.length < 2) return 'At least 2 characters';
    if (t.length > 200) return 'Max 200 characters';
    return null;
  }
}
