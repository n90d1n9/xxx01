import 'employee_payroll_run_console_command_models.dart';

/// Outcome category for a payroll run console audit event.
enum EmployeePayrollRunConsoleAuditStatus {
  completed('Completed'),
  warning('Review'),
  noChange('No change');

  final String label;

  const EmployeePayrollRunConsoleAuditStatus(this.label);
}

/// Close-readiness state derived from payroll console audit evidence.
enum EmployeePayrollRunConsoleAuditEvidenceStatus {
  empty('No evidence'),
  ready('Evidence ready'),
  reviewNeeded('Review needed'),
  noChange('No change');

  final String label;

  const EmployeePayrollRunConsoleAuditEvidenceStatus(this.label);
}

/// User-facing filter applied to payroll run console audit events.
enum EmployeePayrollRunConsoleAuditFilter {
  all('All'),
  completed('Completed'),
  attention('Review'),
  noChange('No change');

  final String label;

  const EmployeePayrollRunConsoleAuditFilter(this.label);

  bool matches(EmployeePayrollRunConsoleAuditEvent event) {
    return switch (this) {
      EmployeePayrollRunConsoleAuditFilter.all => true,
      EmployeePayrollRunConsoleAuditFilter.completed =>
        event.status == EmployeePayrollRunConsoleAuditStatus.completed,
      EmployeePayrollRunConsoleAuditFilter.attention =>
        event.status == EmployeePayrollRunConsoleAuditStatus.warning,
      EmployeePayrollRunConsoleAuditFilter.noChange =>
        event.status == EmployeePayrollRunConsoleAuditStatus.noChange,
    };
  }
}

/// Immutable audit event written when a payroll console command runs.
class EmployeePayrollRunConsoleAuditEvent {
  final String id;
  final String runReference;
  final EmployeePayrollRunConsoleCommandType commandType;
  final String scopeLabel;
  final String operatorName;
  final DateTime occurredAt;
  final int targetEmployeeCount;
  final int completedCount;
  final int skippedCount;
  final List<String> errors;
  final String message;

  const EmployeePayrollRunConsoleAuditEvent({
    required this.id,
    required this.runReference,
    required this.commandType,
    required this.scopeLabel,
    required this.operatorName,
    required this.occurredAt,
    required this.targetEmployeeCount,
    required this.completedCount,
    required this.skippedCount,
    required this.errors,
    required this.message,
  });

  factory EmployeePayrollRunConsoleAuditEvent.fromCommandResult({
    required String id,
    required EmployeePayrollRunConsoleCommandResult result,
    required EmployeePayrollRunConsoleCommandPlan plan,
    required String operatorName,
    required DateTime occurredAt,
  }) {
    return EmployeePayrollRunConsoleAuditEvent(
      id: id,
      runReference: plan.runReference,
      commandType: result.type,
      scopeLabel: plan.scopeLabel,
      operatorName: operatorName,
      occurredAt: occurredAt,
      targetEmployeeCount: plan.targetEmployeeCount,
      completedCount: result.completedCount,
      skippedCount: result.skippedCount,
      errors: result.errors,
      message: result.message,
    );
  }

  EmployeePayrollRunConsoleAuditStatus get status {
    if (errors.isNotEmpty) return EmployeePayrollRunConsoleAuditStatus.warning;
    if (completedCount > 0) {
      return EmployeePayrollRunConsoleAuditStatus.completed;
    }
    return EmployeePayrollRunConsoleAuditStatus.noChange;
  }

  String get title => commandType.label;

  String get coverageLabel {
    return '$completedCount completed, $skippedCount skipped';
  }

  String get detailLabel {
    return '$scopeLabel by $operatorName';
  }
}

/// Summary for the payroll run console audit event stream.
class EmployeePayrollRunConsoleAuditSummary {
  final List<EmployeePayrollRunConsoleAuditEvent> events;

  const EmployeePayrollRunConsoleAuditSummary({required this.events});

  int get eventCount => events.length;

  int get completedCount {
    return events
        .where(
          (event) =>
              event.status == EmployeePayrollRunConsoleAuditStatus.completed,
        )
        .length;
  }

  int get attentionCount {
    return events
        .where(
          (event) =>
              event.status == EmployeePayrollRunConsoleAuditStatus.warning,
        )
        .length;
  }

  int get noChangeCount {
    return events
        .where(
          (event) =>
              event.status == EmployeePayrollRunConsoleAuditStatus.noChange,
        )
        .length;
  }

  int get completedEmployeeActionCount {
    return events.fold(0, (total, event) => total + event.completedCount);
  }

  int get skippedEmployeeActionCount {
    return events.fold(0, (total, event) => total + event.skippedCount);
  }

  String get runReferenceLabel {
    final references =
        events
            .map((event) => event.runReference)
            .where((reference) => reference.isNotEmpty)
            .toSet();
    if (references.isEmpty) return 'No run';
    if (references.length == 1) return references.single;
    return '${references.length} payroll runs';
  }

  String get operatorLabel {
    final operators =
        events
            .map((event) => event.operatorName)
            .where((operator) => operator.isNotEmpty)
            .toSet();
    if (operators.isEmpty) return 'No operator';
    if (operators.length == 1) return operators.single;
    return '${operators.length} operators';
  }

  EmployeePayrollRunConsoleAuditEvent? get latestEvent {
    return events.isEmpty ? null : events.first;
  }

  int countFor(EmployeePayrollRunConsoleAuditFilter filter) {
    return events.where(filter.matches).length;
  }

  List<EmployeePayrollRunConsoleAuditEvent> eventsFor(
    EmployeePayrollRunConsoleAuditFilter filter,
  ) {
    return events.where(filter.matches).toList(growable: false);
  }

  String get summaryLabel {
    if (events.isEmpty) return 'No payroll console events yet.';
    final latest = latestEvent!;
    return '${latest.commandType.label} recorded for ${latest.runReference}.';
  }
}

/// Evidence summary used to support payroll close and audit review decisions.
class EmployeePayrollRunConsoleAuditEvidenceReport {
  final EmployeePayrollRunConsoleAuditSummary summary;

  const EmployeePayrollRunConsoleAuditEvidenceReport({required this.summary});

  EmployeePayrollRunConsoleAuditEvidenceStatus get status {
    if (summary.eventCount == 0) {
      return EmployeePayrollRunConsoleAuditEvidenceStatus.empty;
    }
    if (summary.attentionCount > 0) {
      return EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded;
    }
    if (summary.completedCount > 0) {
      return EmployeePayrollRunConsoleAuditEvidenceStatus.ready;
    }
    return EmployeePayrollRunConsoleAuditEvidenceStatus.noChange;
  }

  String get headline {
    return switch (status) {
      EmployeePayrollRunConsoleAuditEvidenceStatus.empty =>
        'No command evidence captured yet.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded =>
        'Review ${_plural(summary.attentionCount, 'payroll console event')}.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.ready =>
        'Payroll command evidence is ready for close sign-off.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.noChange =>
        'Commands ran without changing payroll records.',
    };
  }

  String get nextAction {
    return switch (status) {
      EmployeePayrollRunConsoleAuditEvidenceStatus.empty =>
        'Run a guided payroll action to build the evidence trail.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded =>
        'Resolve review items before closing this payroll run.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.ready =>
        'Attach the audit trail during payroll close sign-off.',
      EmployeePayrollRunConsoleAuditEvidenceStatus.noChange =>
        'Check command scope and run the next eligible payroll action.',
    };
  }

  String get latestLabel {
    final latest = summary.latestEvent;
    if (latest == null) return 'Latest: none';
    return 'Latest: ${latest.commandType.label} by ${latest.operatorName}';
  }

  String get coverageLabel {
    return '${_plural(summary.completedEmployeeActionCount, 'completed update')}, '
        '${summary.skippedEmployeeActionCount} skipped';
  }

  String get runReferenceLabel => summary.runReferenceLabel;

  String get operatorLabel => summary.operatorLabel;
}

String _plural(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
