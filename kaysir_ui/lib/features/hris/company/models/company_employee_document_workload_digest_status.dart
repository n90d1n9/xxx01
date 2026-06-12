import 'company_document_audit_event.dart';
import 'company_employee_document_workload.dart';

/// Tracks digest cadence and freshness for one employee document owner lane.
class CompanyEmployeeDocumentWorkloadDigestStatus {
  final String ownerName;
  final int digestCount;
  final DateTime? lastSentAt;
  final String lastAuditEventId;

  const CompanyEmployeeDocumentWorkloadDigestStatus({
    required this.ownerName,
    required this.digestCount,
    required this.lastSentAt,
    required this.lastAuditEventId,
  });

  bool get hasDigest => digestCount > 0 && lastSentAt != null;

  int cadenceDaysFor(CompanyEmployeeDocumentWorkload workload) {
    if (workload.requiresEscalation) return 1;
    if (workload.highCount > 0 || workload.dueSoonCount > 0) return 3;
    return 7;
  }

  String cadenceLabel(CompanyEmployeeDocumentWorkload workload) {
    final days = cadenceDaysFor(workload);
    if (days == 1) return 'Daily';
    if (days == 3) return 'Every 3d';
    return 'Weekly';
  }

  bool isDueFor({
    required CompanyEmployeeDocumentWorkload workload,
    required DateTime asOfDate,
  }) {
    final sentAt = lastSentAt;
    if (sentAt == null) return true;
    return _daysSince(sentAt: sentAt, asOfDate: asOfDate) >=
        cadenceDaysFor(workload);
  }

  String freshnessLabel({
    required CompanyEmployeeDocumentWorkload workload,
    required DateTime asOfDate,
  }) {
    final sentAt = lastSentAt;
    if (sentAt == null) return 'Digest due';

    final remainingDays =
        cadenceDaysFor(workload) -
        _daysSince(sentAt: sentAt, asOfDate: asOfDate);
    if (remainingDays <= 0) return 'Digest due';
    if (remainingDays == 1) return 'Due tomorrow';
    return 'Due in ${remainingDays}d';
  }

  String label(DateTime asOfDate) {
    final sentAt = lastSentAt;
    if (sentAt == null) return 'Not sent yet';

    final days = _dateOnly(asOfDate).difference(_dateOnly(sentAt)).inDays;
    if (days <= 0) return 'Sent today';
    if (days == 1) return 'Sent yesterday';
    return 'Sent ${days}d ago';
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int _daysSince({
    required DateTime sentAt,
    required DateTime asOfDate,
  }) {
    return _dateOnly(asOfDate).difference(_dateOnly(sentAt)).inDays;
  }
}

List<CompanyEmployeeDocumentWorkloadDigestStatus>
buildCompanyEmployeeDocumentWorkloadDigestStatuses({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  return [
    for (final workload in workloads)
      _statusForWorkload(workload: workload, auditEvents: auditEvents),
  ];
}

CompanyEmployeeDocumentWorkloadDigestStatus _statusForWorkload({
  required CompanyEmployeeDocumentWorkload workload,
  required List<CompanyDocumentAuditEvent> auditEvents,
}) {
  final matchingEvents =
      auditEvents
          .where(
            (event) =>
                event.type ==
                    CompanyDocumentAuditEventType.employeeOwnerDigestSent &&
                _matchesOwnerDigest(
                  event: event,
                  ownerName: workload.ownerName,
                ),
          )
          .toList()
        ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));

  final latestEvent = matchingEvents.firstOrNull;
  return CompanyEmployeeDocumentWorkloadDigestStatus(
    ownerName: workload.ownerName,
    digestCount: matchingEvents.length,
    lastSentAt: latestEvent?.happenedAt,
    lastAuditEventId: latestEvent?.id ?? '',
  );
}

bool _matchesOwnerDigest({
  required CompanyDocumentAuditEvent event,
  required String ownerName,
}) {
  return event.correlationId ==
          companyEmployeeDocumentOwnerDigestCorrelationId(ownerName) ||
      event.documentId ==
          companyEmployeeDocumentOwnerDigestDocumentId(ownerName);
}

String companyEmployeeDocumentOwnerDigestDocumentId(String ownerName) {
  return 'employee-doc-workload-${companyEmployeeDocumentOwnerSlug(ownerName)}';
}

String companyEmployeeDocumentOwnerDigestCorrelationId(String ownerName) {
  return 'owner-workload-${companyEmployeeDocumentOwnerSlug(ownerName)}';
}

String companyEmployeeDocumentOwnerEscalationCorrelationId(String ownerName) {
  return 'owner-escalation-${companyEmployeeDocumentOwnerSlug(ownerName)}';
}

String companyEmployeeDocumentOwnerFollowUpCorrelationId(String ownerName) {
  return 'owner-follow-up-${companyEmployeeDocumentOwnerSlug(ownerName)}';
}

String companyEmployeeDocumentOwnerSlug(String ownerName) {
  final slug = ownerName
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'unassigned' : slug;
}
