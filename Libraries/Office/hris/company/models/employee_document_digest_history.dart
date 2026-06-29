import 'company_document_audit_event.dart';
import 'company_employee_document_workload.dart';
import 'company_employee_document_workload_digest_status.dart';

/// Recent owner digest dispatch history for employee document workloads.
class EmployeeDocumentDigestHistory {
  final List<EmployeeDocumentDigestHistoryItem> items;
  final int totalDigestCount;
  final int ownerCount;

  const EmployeeDocumentDigestHistory({
    required this.items,
    required this.totalDigestCount,
    required this.ownerCount,
  });

  bool get isEmpty => totalDigestCount == 0;

  DateTime? get latestSentAt => items.isEmpty ? null : items.first.happenedAt;

  String latestLabel(DateTime asOfDate) {
    final latest = latestSentAt;
    if (latest == null) return 'Not sent yet';
    return EmployeeDocumentDigestHistoryItem.relativeDateLabel(
      date: latest,
      asOfDate: asOfDate,
    );
  }
}

/// One audit-backed owner digest dispatch entry.
class EmployeeDocumentDigestHistoryItem {
  final String id;
  final String ownerName;
  final String entityName;
  final String actorName;
  final DateTime happenedAt;
  final String note;
  final String auditEventId;

  const EmployeeDocumentDigestHistoryItem({
    required this.id,
    required this.ownerName,
    required this.entityName,
    required this.actorName,
    required this.happenedAt,
    required this.note,
    required this.auditEventId,
  });

  String sentLabel(DateTime asOfDate) {
    return relativeDateLabel(date: happenedAt, asOfDate: asOfDate);
  }

  static String relativeDateLabel({
    required DateTime date,
    required DateTime asOfDate,
  }) {
    final days = _dateOnly(asOfDate).difference(_dateOnly(date)).inDays;
    if (days <= 0) return 'Sent today';
    if (days == 1) return 'Sent yesterday';
    return 'Sent ${days}d ago';
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

/// Builds recent owner digest history from company document audit events.
EmployeeDocumentDigestHistory buildEmployeeDocumentDigestHistory({
  required List<CompanyEmployeeDocumentWorkload> workloads,
  required List<CompanyDocumentAuditEvent> auditEvents,
  int limit = 5,
}) {
  final ownerByCorrelationId = {
    for (final workload in workloads)
      companyEmployeeDocumentOwnerDigestCorrelationId(workload.ownerName):
          workload.ownerName,
  };
  final ownerByDocumentId = {
    for (final workload in workloads)
      companyEmployeeDocumentOwnerDigestDocumentId(workload.ownerName):
          workload.ownerName,
  };
  final digestEvents =
      auditEvents
          .where(
            (event) =>
                event.type ==
                CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          )
          .toList()
        ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
  final ownerNames = <String>{};
  final items = <EmployeeDocumentDigestHistoryItem>[];

  for (final event in digestEvents) {
    final ownerName =
        ownerByCorrelationId[event.correlationId] ??
        ownerByDocumentId[event.documentId] ??
        _ownerNameFromTitle(event.documentTitle);
    ownerNames.add(ownerName);

    if (items.length >= limit) continue;
    items.add(
      EmployeeDocumentDigestHistoryItem(
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

  return EmployeeDocumentDigestHistory(
    items: items,
    totalDigestCount: digestEvents.length,
    ownerCount: ownerNames.length,
  );
}

String _ownerNameFromTitle(String documentTitle) {
  final suffix = ' - Employee document workload';
  if (documentTitle.endsWith(suffix)) {
    return documentTitle.substring(0, documentTitle.length - suffix.length);
  }
  return documentTitle.trim().isEmpty ? 'Unassigned' : documentTitle.trim();
}
