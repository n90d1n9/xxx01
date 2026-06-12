import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';

abstract class FinancialPeriodCloseRepository {
  Map<String, FinancialPeriodCloseRecord> loadRecords();

  List<FinancialPeriodCloseAuditEvent> loadAuditEvents();

  void upsertRecord(FinancialPeriodCloseRecord record);

  void appendAuditEvent(FinancialPeriodCloseAuditEvent event);

  void clear();
}

abstract class HydratableFinancialPeriodCloseRepository
    implements FinancialPeriodCloseRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialPeriodCloseRepository
    implements FinancialPeriodCloseRepository {
  final Map<String, FinancialPeriodCloseRecord> _records;
  final List<FinancialPeriodCloseAuditEvent> _auditEvents;

  InMemoryFinancialPeriodCloseRepository({
    Map<String, FinancialPeriodCloseRecord>? records,
    Iterable<FinancialPeriodCloseAuditEvent>? auditEvents,
  }) : _records = {...?records},
       _auditEvents = [...?auditEvents];

  @override
  Map<String, FinancialPeriodCloseRecord> loadRecords() {
    return Map.unmodifiable(_records);
  }

  @override
  List<FinancialPeriodCloseAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertRecord(FinancialPeriodCloseRecord record) {
    _records[record.periodKey] = record;
  }

  @override
  void appendAuditEvent(FinancialPeriodCloseAuditEvent event) {
    _auditEvents.add(event);
  }

  void replaceAll({
    Map<String, FinancialPeriodCloseRecord>? records,
    Iterable<FinancialPeriodCloseAuditEvent>? auditEvents,
  }) {
    if (records != null) {
      _records
        ..clear()
        ..addAll(records);
    }

    if (auditEvents != null) {
      _auditEvents
        ..clear()
        ..addAll(auditEvents);
    }
  }

  @override
  void clear() {
    _records.clear();
    _auditEvents.clear();
  }
}
