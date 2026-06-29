import 'company_document_audit_event.dart';
import 'company_employee_document_workload.dart';
import 'company_employee_document_workload_digest_status.dart';

/// Tracks escalation cadence and audit handoff for one owner workload lane.
class EmployeeDocumentEscalationStatus {
  final String ownerName;
  final int escalationCount;
  final DateTime? lastEscalatedAt;
  final String lastAuditEventId;

  const EmployeeDocumentEscalationStatus({
    required this.ownerName,
    required this.escalationCount,
    required this.lastEscalatedAt,
    required this.lastAuditEventId,
  });

  bool get hasEscalation => escalationCount > 0 && lastEscalatedAt != null;

  bool isCoolingDown(DateTime asOfDate) {
    final escalatedAt = lastEscalatedAt;
    if (escalatedAt == null) return false;
    return _daysSince(date: escalatedAt, asOfDate: asOfDate) <= 0;
  }

  String freshnessLabel(DateTime asOfDate) {
    final escalatedAt = lastEscalatedAt;
    if (escalatedAt == null) return 'Not escalated';
    return EmployeeDocumentEscalationHistoryItem.relativeDateLabel(
      date: escalatedAt,
      asOfDate: asOfDate,
    );
  }
}

/// Recent owner escalation history for employee document workloads.
class EmployeeDocumentEscalationHistory {
  final List<EmployeeDocumentEscalationHistoryItem> items;
  final int totalEscalationCount;
  final int ownerCount;

  const EmployeeDocumentEscalationHistory({
    required this.items,
    required this.totalEscalationCount,
    required this.ownerCount,
  });

  bool get isEmpty => totalEscalationCount == 0;

  DateTime? get latestEscalatedAt {
    return items.isEmpty ? null : items.first.happenedAt;
  }

  String latestLabel(DateTime asOfDate) {
    final latest = latestEscalatedAt;
    if (latest == null) return 'Not escalated';
    return EmployeeDocumentEscalationHistoryItem.relativeDateLabel(
      date: latest,
      asOfDate: asOfDate,
    );
  }
}

/// One audit-backed owner escalation entry.
class EmployeeDocumentEscalationHistoryItem {
  final String id;
  final String ownerName;
  final String entityName;
  final String actorName;
  final DateTime happenedAt;
  final String note;
  final String auditEventId;

  const EmployeeDocumentEscalationHistoryItem({
    required this.id,
    required this.ownerName,
    required this.entityName,
    required this.actorName,
    required this.happenedAt,
    required this.note,
    required this.auditEventId,
  });

  String escalatedLabel(DateTime asOfDate) {
    return relativeDateLabel(date: happenedAt, asOfDate: asOfDate);
  }

  static String relativeDateLabel({
    required DateTime date,
    required DateTime asOfDate,
  }) {
    final days = _daysSince(date: date, asOfDate: asOfDate);
    if (days <= 0) return 'Escalated today';
    if (days == 1) return 'Escalated yesterday';
    return 'Escalated ${days}d ago';
  }
}

/// Builds owner escalation freshness from company document audit events.
List<EmployeeDocumentEscalationStatus> buildEmployeeDocumentEscalationStatuses({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  return [
    for (final workload in workloads)
      _statusForWorkload(workload: workload, auditEvents: auditEvents),
  ];
}

/// Builds recent owner escalation history from company document audit events.
EmployeeDocumentEscalationHistory buildEmployeeDocumentEscalationHistory({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyDocumentAuditEvent> auditEvents,
  int limit = 5,
}) {
  final ownerByCorrelationId = {
    for (final workload in workloads)
      companyEmployeeDocumentOwnerEscalationCorrelationId(workload.ownerName):
          workload.ownerName,
  };
  final ownerByDocumentId = {
    for (final workload in workloads)
      companyEmployeeDocumentOwnerDigestDocumentId(workload.ownerName):
          workload.ownerName,
  };
  final escalationEvents =
      auditEvents
          .where(
            (event) =>
                event.type ==
                CompanyDocumentAuditEventType.employeeOwnerEscalated,
          )
          .toList()
        ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
  final ownerNames = <String>{};
  final items = <EmployeeDocumentEscalationHistoryItem>[];

  for (final event in escalationEvents) {
    final ownerName =
        ownerByCorrelationId[event.correlationId] ??
        ownerByDocumentId[event.documentId] ??
        _ownerNameFromTitle(event.documentTitle);
    ownerNames.add(ownerName);

    if (items.length >= limit) continue;
    items.add(
      EmployeeDocumentEscalationHistoryItem(
        id: event.id,
        ownerName: ownerName,
        entityName: event.entityName,
        actorName: event.actorName,
        happenedAt: event.happenedAt,
        note: event.note,
        auditEventId: event.id,
      ),
    );
  }

  return EmployeeDocumentEscalationHistory(
    items: items,
    totalEscalationCount: escalationEvents.length,
    ownerCount: ownerNames.length,
  );
}

EmployeeDocumentEscalationStatus _statusForWorkload({
  required CompanyEmployeeDocumentWorkload workload,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  final matchingEvents =
      auditEvents
          .where(
            (event) =>
                event.type ==
                    CompanyDocumentAuditEventType.employeeOwnerEscalated &&
                _matchesOwnerEscalation(
                  event: event,
                  ownerName: workload.ownerName,
                ),
          )
          .toList()
        ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));

  final latestEvent = matchingEvents.firstOrNull;
  return EmployeeDocumentEscalationStatus(
    ownerName: workload.ownerName,
    escalationCount: matchingEvents.length,
    lastEscalatedAt: latestEvent?.happenedAt,
    lastAuditEventId: latestEvent?.id ?? '',
  );
}

bool _matchesOwnerEscalation({
  required CompanyDocumentAuditEvent event,
  required String ownerName,
}) {
  return event.correlationId ==
          companyEmployeeDocumentOwnerEscalationCorrelationId(ownerName) ||
      event.documentId ==
          companyEmployeeDocumentOwnerDigestDocumentId(ownerName);
}

String _ownerNameFromTitle(String documentTitle) {
  final suffix = ' - Employee document workload';
  if (documentTitle.endsWith(suffix)) {
    return documentTitle.substring(0, documentTitle.length - suffix.length);
  }
  return documentTitle.trim().isEmpty ? 'Unassigned' : documentTitle.trim();
}

int _daysSince({required DateTime date, required DateTime asOfDate}) {
  return _dateOnly(asOfDate).difference(_dateOnly(date)).inDays;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
