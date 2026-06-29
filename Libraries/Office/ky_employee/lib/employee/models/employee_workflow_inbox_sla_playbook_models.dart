import 'employee_workflow_inbox_models.dart';

/// Recovery step category for an employee workflow inbox SLA playbook.
enum EmployeeWorkflowInboxSlaPlaybookStepType {
  leadershipEscalation('Leadership escalation'),
  managerEscalation('Manager escalation'),
  readyClearance('Ready clearance'),
  overdueRecovery('Overdue recovery'),
  ownerRebalance('Owner rebalance'),
  dueSoonWatch('Due-soon watch');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookStepType(this.label);
}

/// Recovery urgency assigned to one workflow inbox SLA playbook step.
enum EmployeeWorkflowInboxSlaPlaybookUrgency {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookUrgency(this.label);
}

/// One prioritized recovery step derived from workflow inbox SLA signals.
class EmployeeWorkflowInboxSlaPlaybookStep {
  final String id;
  final EmployeeWorkflowInboxSlaPlaybookStepType type;
  final EmployeeWorkflowInboxSlaPlaybookUrgency urgency;
  final String title;
  final String detail;
  final String owner;
  final List<String> signalIds;
  final List<EmployeeWorkflowInboxSource> sources;
  final DateTime dueDate;

  const EmployeeWorkflowInboxSlaPlaybookStep({
    required this.id,
    required this.type,
    required this.urgency,
    required this.title,
    required this.detail,
    required this.owner,
    required this.signalIds,
    required this.sources,
    required this.dueDate,
  });

  int get itemCount => signalIds.length;

  bool get isCritical =>
      urgency == EmployeeWorkflowInboxSlaPlaybookUrgency.critical;

  String get sourceLabel {
    if (sources.isEmpty) return 'No source';
    if (sources.length == 1) return sources.first.label;
    return '${sources.length} sources';
  }

  String get countLabel {
    return '$itemCount item${itemCount == 1 ? '' : 's'}';
  }
}

/// Prioritized recovery plan for one employee workflow inbox SLA profile.
class EmployeeWorkflowInboxSlaPlaybook {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxSlaPlaybookStep> steps;

  const EmployeeWorkflowInboxSlaPlaybook({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.steps,
  });

  List<EmployeeWorkflowInboxSlaPlaybookStep> get sortedSteps {
    final sorted = [...steps]..sort((a, b) {
      final urgencyCompare = _urgencyRank(
        a.urgency,
      ).compareTo(_urgencyRank(b.urgency));
      if (urgencyCompare != 0) return urgencyCompare;

      final typeCompare = _typeRank(a.type).compareTo(_typeRank(b.type));
      if (typeCompare != 0) return typeCompare;

      final countCompare = b.itemCount.compareTo(a.itemCount);
      if (countCompare != 0) return countCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  List<EmployeeWorkflowInboxSlaPlaybookStep> get topSteps {
    return sortedSteps.take(3).toList();
  }

  int get totalCount => steps.length;

  int get criticalCount {
    return steps.where((step) => step.isCritical).length;
  }

  int get recoveryItemCount {
    return steps.fold<int>(0, (total, step) => total + step.itemCount);
  }

  bool get isClear => steps.isEmpty;

  String get nextAction {
    if (criticalCount > 0) {
      return 'Run $criticalCount critical inbox SLA recovery step${criticalCount == 1 ? '' : 's'}.';
    }
    if (totalCount > 0) {
      return 'Work ${topSteps.first.type.label.toLowerCase()} for ${topSteps.first.countLabel}.';
    }
    return 'No SLA recovery playbook needed.';
  }
}

int _urgencyRank(EmployeeWorkflowInboxSlaPlaybookUrgency urgency) {
  return switch (urgency) {
    EmployeeWorkflowInboxSlaPlaybookUrgency.critical => 0,
    EmployeeWorkflowInboxSlaPlaybookUrgency.high => 1,
    EmployeeWorkflowInboxSlaPlaybookUrgency.medium => 2,
    EmployeeWorkflowInboxSlaPlaybookUrgency.low => 3,
  };
}

int _typeRank(EmployeeWorkflowInboxSlaPlaybookStepType type) {
  return switch (type) {
    EmployeeWorkflowInboxSlaPlaybookStepType.leadershipEscalation => 0,
    EmployeeWorkflowInboxSlaPlaybookStepType.managerEscalation => 1,
    EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance => 2,
    EmployeeWorkflowInboxSlaPlaybookStepType.overdueRecovery => 3,
    EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance => 4,
    EmployeeWorkflowInboxSlaPlaybookStepType.dueSoonWatch => 5,
  };
}
