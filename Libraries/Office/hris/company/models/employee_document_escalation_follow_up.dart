import 'company_document_audit_event.dart';
import 'company_employee_document_workload_digest_status.dart';
import 'employee_document_escalation_plan.dart';

/// Follow-up state for an owner escalation after the initial handoff.
enum EmployeeDocumentEscalationFollowUpState {
  overdue('Overdue'),
  dueToday('Due today'),
  scheduled('Scheduled');

  final String label;

  const EmployeeDocumentEscalationFollowUpState(this.label);

  int get sortRank {
    switch (this) {
      case EmployeeDocumentEscalationFollowUpState.overdue:
        return 0;
      case EmployeeDocumentEscalationFollowUpState.dueToday:
        return 1;
      case EmployeeDocumentEscalationFollowUpState.scheduled:
        return 2;
    }
  }
}

/// SLA-backed next-touch item for an escalated employee document owner lane.
class EmployeeDocumentEscalationFollowUp {
  final String ownerName;
  final String entitySummary;
  final EmployeeDocumentEscalationPriority priority;
  final String actionLabel;
  final String primaryEmployeeName;
  final int workloadScore;
  final int missingDocumentCount;
  final int openRequestCount;
  final String lastEscalationAuditEventId;
  final DateTime lastEscalatedAt;
  final String lastFollowUpAuditEventId;
  final DateTime? lastFollowedUpAt;
  final int followUpCount;
  final DateTime nextTouchDate;
  final EmployeeDocumentEscalationFollowUpState state;
  final String rationale;

  const EmployeeDocumentEscalationFollowUp({
    required this.ownerName,
    required this.entitySummary,
    required this.priority,
    required this.actionLabel,
    required this.primaryEmployeeName,
    required this.workloadScore,
    required this.missingDocumentCount,
    required this.openRequestCount,
    required this.lastEscalationAuditEventId,
    required this.lastEscalatedAt,
    this.lastFollowUpAuditEventId = '',
    this.lastFollowedUpAt,
    this.followUpCount = 0,
    required this.nextTouchDate,
    required this.state,
    required this.rationale,
  });

  String get primaryEmployeeLabel {
    if (primaryEmployeeName.trim().isEmpty) return 'Owner lane';
    return primaryEmployeeName;
  }

  String nextTouchLabel(DateTime asOfDate) {
    final days =
        _dateOnly(nextTouchDate).difference(_dateOnly(asOfDate)).inDays;
    if (days < 0) return '${days.abs()}d overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in ${days}d';
  }

  String lastEscalatedLabel(DateTime asOfDate) {
    final days =
        _dateOnly(asOfDate).difference(_dateOnly(lastEscalatedAt)).inDays;
    if (days <= 0) return 'Escalated today';
    if (days == 1) return 'Escalated yesterday';
    return 'Escalated ${days}d ago';
  }

  String lastTouchLabel(DateTime asOfDate) {
    final followedUpAt = lastFollowedUpAt;
    if (followedUpAt == null) return lastEscalatedLabel(asOfDate);

    final days = _dateOnly(asOfDate).difference(_dateOnly(followedUpAt)).inDays;
    if (days <= 0) return 'Followed up today';
    if (days == 1) return 'Followed up yesterday';
    return 'Followed up ${days}d ago';
  }
}

/// Builds follow-up SLA items for owner lanes that have escalation history.
List<EmployeeDocumentEscalationFollowUp>
buildEmployeeDocumentEscalationFollowUps({
  required List<EmployeeDocumentEscalationPlan> plans,
  List<CompanyDocumentAuditEvent> auditEvents = const [],
  required DateTime asOfDate,
  int limit = 5,
}) {
  if (limit <= 0) return const [];

  final followUps = <EmployeeDocumentEscalationFollowUp>[];
  for (final plan in plans) {
    final lastEscalatedAt = plan.lastEscalatedAt;
    if (lastEscalatedAt == null ||
        plan.lastEscalationAuditEventId.trim().isEmpty) {
      continue;
    }

    final followUpEvents = _followUpEventsForPlan(
      plan: plan,
      auditEvents: auditEvents,
    );
    final latestFollowUp = followUpEvents.firstOrNull;
    final baseDate =
        latestFollowUp != null &&
                !latestFollowUp.happenedAt.isBefore(lastEscalatedAt)
            ? latestFollowUp.happenedAt
            : lastEscalatedAt;
    final nextTouchDate = _dateOnly(
      baseDate,
    ).add(Duration(days: _followUpCadenceDays(plan.priority)));
    final state = _stateFor(nextTouchDate: nextTouchDate, asOfDate: asOfDate);

    followUps.add(
      EmployeeDocumentEscalationFollowUp(
        ownerName: plan.ownerName,
        entitySummary: plan.entitySummary,
        priority: plan.priority,
        actionLabel: plan.actionLabel,
        primaryEmployeeName: plan.primaryEmployeeName,
        workloadScore: plan.workloadScore,
        missingDocumentCount: plan.missingDocumentCount,
        openRequestCount: plan.openRequestCount,
        lastEscalationAuditEventId: plan.lastEscalationAuditEventId,
        lastEscalatedAt: lastEscalatedAt,
        lastFollowUpAuditEventId: latestFollowUp?.id ?? '',
        lastFollowedUpAt: latestFollowUp?.happenedAt,
        followUpCount: followUpEvents.length,
        nextTouchDate: nextTouchDate,
        state: state,
        rationale: _rationaleFor(plan: plan, state: state),
      ),
    );
  }

  followUps.sort(_compareFollowUps);
  return followUps.take(limit).toList(growable: false);
}

List<CompanyDocumentAuditEvent> _followUpEventsForPlan({
  required EmployeeDocumentEscalationPlan plan,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  return auditEvents
      .where(
        (event) =>
            event.type ==
                CompanyDocumentAuditEventType.employeeOwnerFollowedUp &&
            _matchesOwnerFollowUp(event: event, ownerName: plan.ownerName),
      )
      .toList()
    ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
}

bool _matchesOwnerFollowUp({
  required CompanyDocumentAuditEvent event,
  required String ownerName,
}) {
  return event.correlationId ==
          companyEmployeeDocumentOwnerFollowUpCorrelationId(ownerName) ||
      event.documentId ==
          companyEmployeeDocumentOwnerDigestDocumentId(ownerName);
}

int _followUpCadenceDays(EmployeeDocumentEscalationPriority priority) {
  switch (priority) {
    case EmployeeDocumentEscalationPriority.critical:
      return 1;
    case EmployeeDocumentEscalationPriority.high:
      return 2;
    case EmployeeDocumentEscalationPriority.watchlist:
      return 3;
  }
}

EmployeeDocumentEscalationFollowUpState _stateFor({
  required DateTime nextTouchDate,
  required DateTime asOfDate,
}) {
  final days = _dateOnly(nextTouchDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return EmployeeDocumentEscalationFollowUpState.overdue;
  if (days == 0) return EmployeeDocumentEscalationFollowUpState.dueToday;
  return EmployeeDocumentEscalationFollowUpState.scheduled;
}

int _compareFollowUps(
  EmployeeDocumentEscalationFollowUp a,
  EmployeeDocumentEscalationFollowUp b,
) {
  final stateComparison = a.state.sortRank.compareTo(b.state.sortRank);
  if (stateComparison != 0) return stateComparison;

  final dateComparison = a.nextTouchDate.compareTo(b.nextTouchDate);
  if (dateComparison != 0) return dateComparison;

  final priorityComparison = a.priority.sortRank.compareTo(b.priority.sortRank);
  if (priorityComparison != 0) return priorityComparison;

  final scoreComparison = b.workloadScore.compareTo(a.workloadScore);
  if (scoreComparison != 0) return scoreComparison;

  return a.ownerName.compareTo(b.ownerName);
}

String _rationaleFor({
  required EmployeeDocumentEscalationPlan plan,
  required EmployeeDocumentEscalationFollowUpState state,
}) {
  final base =
      '${plan.priority.label} owner lane with ${plan.missingDocumentCount} missing evidence item'
      '${plan.missingDocumentCount == 1 ? '' : 's'} and '
      '${plan.openRequestCount} open request'
      '${plan.openRequestCount == 1 ? '' : 's'}.';
  switch (state) {
    case EmployeeDocumentEscalationFollowUpState.overdue:
      return '$base Follow-up is overdue.';
    case EmployeeDocumentEscalationFollowUpState.dueToday:
      return '$base Follow-up is due today.';
    case EmployeeDocumentEscalationFollowUpState.scheduled:
      return '$base Follow-up is scheduled.';
  }
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
