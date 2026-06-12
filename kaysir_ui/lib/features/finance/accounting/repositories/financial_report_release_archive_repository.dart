import '../models/financial_report_release_archive.dart';

abstract class FinancialReportReleaseArchiveRepository {
  Map<String, FinancialReportReleaseArchiveRecord> loadRecords();

  List<FinancialReportReleaseArchiveAuditEvent> loadAuditEvents();

  void upsertRecord(FinancialReportReleaseArchiveRecord record);

  void appendAuditEvent(FinancialReportReleaseArchiveAuditEvent event);

  void removeRecord(String periodKey);

  void clear();
}

abstract class HydratableFinancialReportReleaseArchiveRepository
    implements FinancialReportReleaseArchiveRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportReleaseArchiveRepository
    implements FinancialReportReleaseArchiveRepository {
  final Map<String, FinancialReportReleaseArchiveRecord> _recordsByPeriod;
  final List<FinancialReportReleaseArchiveAuditEvent> _auditEvents;

  InMemoryFinancialReportReleaseArchiveRepository({
    Map<String, FinancialReportReleaseArchiveRecord>? recordsByPeriod,
    Iterable<FinancialReportReleaseArchiveAuditEvent>? auditEvents,
  }) : _recordsByPeriod = Map.of(recordsByPeriod ?? const {}),
       _auditEvents = [...?auditEvents];

  @override
  Map<String, FinancialReportReleaseArchiveRecord> loadRecords() {
    return Map.unmodifiable(_recordsByPeriod);
  }

  @override
  List<FinancialReportReleaseArchiveAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertRecord(FinancialReportReleaseArchiveRecord record) {
    _recordsByPeriod[record.periodKey] = record;
  }

  @override
  void appendAuditEvent(FinancialReportReleaseArchiveAuditEvent event) {
    _auditEvents.add(event);
  }

  @override
  void removeRecord(String periodKey) {
    _recordsByPeriod.remove(periodKey);
  }

  @override
  void clear() {
    _recordsByPeriod.clear();
    _auditEvents.clear();
  }

  void replaceAll(
    Map<String, FinancialReportReleaseArchiveRecord> records, {
    Iterable<FinancialReportReleaseArchiveAuditEvent>? auditEvents,
  }) {
    _recordsByPeriod
      ..clear()
      ..addAll(records);
    if (auditEvents != null) {
      _auditEvents
        ..clear()
        ..addAll(auditEvents);
    }
  }
}
