import 'company_employee_document_workload.dart';
import 'company_employee_document_workload_digest_status.dart';
import 'employee_document_escalation_history.dart';

/// Priority level used to rank employee document owner escalation lanes.
enum EmployeeDocumentEscalationPriority {
  critical('Critical'),
  high('High'),
  watchlist('Watchlist');

  final String label;

  const EmployeeDocumentEscalationPriority(this.label);

  int get sortRank {
    switch (this) {
      case EmployeeDocumentEscalationPriority.critical:
        return 0;
      case EmployeeDocumentEscalationPriority.high:
        return 1;
      case EmployeeDocumentEscalationPriority.watchlist:
        return 2;
    }
  }
}

/// Summarizes one employee document owner lane that needs HR escalation.
class EmployeeDocumentEscalationPlan {
  final String ownerName;
  final String entitySummary;
  final EmployeeDocumentEscalationPriority priority;
  final int workloadScore;
  final int gapCount;
  final int criticalCount;
  final int highCount;
  final int overdueCount;
  final int dueSoonCount;
  final int missingDocumentCount;
  final int openRequestCount;
  final String actionLabel;
  final String primaryEmployeeName;
  final String digestFreshnessLabel;
  final String digestCadenceLabel;
  final bool digestDue;
  final String escalationFreshnessLabel;
  final String lastEscalationAuditEventId;
  final DateTime? lastEscalatedAt;
  final int escalationCount;
  final bool escalationCoolingDown;
  final String rationale;

  const EmployeeDocumentEscalationPlan({
    required this.ownerName,
    required this.entitySummary,
    required this.priority,
    required this.workloadScore,
    required this.gapCount,
    required this.criticalCount,
    required this.highCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.missingDocumentCount,
    required this.openRequestCount,
    required this.actionLabel,
    required this.primaryEmployeeName,
    required this.digestFreshnessLabel,
    required this.digestCadenceLabel,
    required this.digestDue,
    this.escalationFreshnessLabel = 'Not escalated',
    this.lastEscalationAuditEventId = '',
    this.lastEscalatedAt,
    this.escalationCount = 0,
    this.escalationCoolingDown = false,
    required this.rationale,
  });

  String get primaryEmployeeLabel {
    if (primaryEmployeeName.trim().isEmpty) return 'Owner lane';
    return primaryEmployeeName;
  }
}

/// Builds ranked employee document escalation plans from owner workloads.
List<EmployeeDocumentEscalationPlan> buildEmployeeDocumentEscalationPlans({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyEmployeeDocumentWorkloadDigestStatus> digestStatuses,
  List<EmployeeDocumentEscalationStatus> escalationStatuses = const [],
  required DateTime asOfDate,
  int limit = 4,
}) {
  if (limit <= 0) return const [];

  final statusByOwner = {
    for (final status in digestStatuses) status.ownerName: status,
  };
  final escalationStatusByOwner = {
    for (final status in escalationStatuses) status.ownerName: status,
  };
  final plans = <EmployeeDocumentEscalationPlan>[];

  for (final workload in workloads) {
    final status =
        statusByOwner[workload.ownerName] ??
        CompanyEmployeeDocumentWorkloadDigestStatus(
          ownerName: workload.ownerName,
          digestCount: 0,
          lastSentAt: null,
          lastAuditEventId: '',
        );
    final digestDue = status.isDueFor(workload: workload, asOfDate: asOfDate);
    final escalationStatus = escalationStatusByOwner[workload.ownerName];
    final priority = _priorityFor(workload: workload, digestDue: digestDue);
    if (priority == null) continue;

    plans.add(
      EmployeeDocumentEscalationPlan(
        ownerName: workload.ownerName,
        entitySummary: workload.entitySummary,
        priority: priority,
        workloadScore: workload.score,
        gapCount: workload.gapCount,
        criticalCount: workload.criticalCount,
        highCount: workload.highCount,
        overdueCount: workload.overdueCount,
        dueSoonCount: workload.dueSoonCount,
        missingDocumentCount: workload.missingDocumentCount,
        openRequestCount: workload.openRequestCount,
        actionLabel: workload.primaryAction,
        primaryEmployeeName: workload.primaryEmployeeName,
        digestFreshnessLabel: status.freshnessLabel(
          workload: workload,
          asOfDate: asOfDate,
        ),
        digestCadenceLabel: status.cadenceLabel(workload),
        digestDue: digestDue,
        escalationFreshnessLabel:
            escalationStatus?.freshnessLabel(asOfDate) ?? 'Not escalated',
        lastEscalationAuditEventId: escalationStatus?.lastAuditEventId ?? '',
        lastEscalatedAt: escalationStatus?.lastEscalatedAt,
        escalationCount: escalationStatus?.escalationCount ?? 0,
        escalationCoolingDown:
            escalationStatus?.isCoolingDown(asOfDate) ?? false,
        rationale: _rationaleFor(
          workload: workload,
          priority: priority,
          digestDue: digestDue,
        ),
      ),
    );
  }

  plans.sort(_comparePlans);
  return plans.take(limit).toList(growable: false);
}

EmployeeDocumentEscalationPriority? _priorityFor({
  required CompanyEmployeeDocumentWorkload workload,
  required bool digestDue,
}) {
  if (workload.criticalCount > 0 || workload.overdueCount > 0) {
    return EmployeeDocumentEscalationPriority.critical;
  }
  if (workload.highCount > 0 ||
      workload.rejectedDocumentCount > 0 ||
      workload.missingDocumentCount >= 5) {
    return EmployeeDocumentEscalationPriority.high;
  }
  if (digestDue && (workload.gapCount > 0 || workload.openRequestCount > 0)) {
    return EmployeeDocumentEscalationPriority.watchlist;
  }
  return null;
}

int _comparePlans(
  EmployeeDocumentEscalationPlan a,
  EmployeeDocumentEscalationPlan b,
) {
  final priorityComparison = a.priority.sortRank.compareTo(b.priority.sortRank);
  if (priorityComparison != 0) return priorityComparison;

  final scoreComparison = b.workloadScore.compareTo(a.workloadScore);
  if (scoreComparison != 0) return scoreComparison;

  final overdueComparison = b.overdueCount.compareTo(a.overdueCount);
  if (overdueComparison != 0) return overdueComparison;

  final missingComparison = b.missingDocumentCount.compareTo(
    a.missingDocumentCount,
  );
  if (missingComparison != 0) return missingComparison;

  return a.ownerName.compareTo(b.ownerName);
}

String _rationaleFor({
  required CompanyEmployeeDocumentWorkload workload,
  required EmployeeDocumentEscalationPriority priority,
  required bool digestDue,
}) {
  switch (priority) {
    case EmployeeDocumentEscalationPriority.critical:
      if (workload.criticalCount > 0 && workload.overdueCount > 0) {
        return '${workload.criticalCount} critical and '
            '${workload.overdueCount} overdue document gap'
            '${workload.overdueCount == 1 ? '' : 's'} need owner escalation.';
      }
      if (workload.criticalCount > 0) {
        return '${workload.criticalCount} critical document gap'
            '${workload.criticalCount == 1 ? '' : 's'} need owner escalation.';
      }
      return '${workload.overdueCount} overdue document gap'
          '${workload.overdueCount == 1 ? '' : 's'} need owner escalation.';
    case EmployeeDocumentEscalationPriority.high:
      if (workload.highCount > 0) {
        return '${workload.highCount} high-risk document gap'
            '${workload.highCount == 1 ? '' : 's'} need owner follow-up.';
      }
      if (workload.rejectedDocumentCount > 0) {
        return '${workload.rejectedDocumentCount} rejected evidence item'
            '${workload.rejectedDocumentCount == 1 ? '' : 's'} need review.';
      }
      return '${workload.missingDocumentCount} missing evidence items '
          'need owner follow-up.';
    case EmployeeDocumentEscalationPriority.watchlist:
      return digestDue
          ? 'Digest is due for active follow-up before the lane drifts.'
          : 'Owner lane needs proactive HR monitoring.';
  }
}
