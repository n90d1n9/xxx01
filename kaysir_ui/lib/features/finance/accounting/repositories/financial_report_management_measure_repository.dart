import '../models/financial_report_management_measure.dart';

abstract class FinancialReportManagementMeasureRepository {
  Map<String, List<FinancialReportManagementMeasure>> loadMeasures();

  List<FinancialReportManagementMeasureAuditEvent> loadAuditEvents();

  void upsertMeasure({
    required String periodKey,
    required FinancialReportManagementMeasure measure,
  });

  void appendAuditEvent(FinancialReportManagementMeasureAuditEvent event);

  void replaceMeasures({
    required String periodKey,
    required List<FinancialReportManagementMeasure> measures,
  });

  void removeMeasure({required String periodKey, required String measureId});

  void clear();
}

abstract class HydratableFinancialReportManagementMeasureRepository
    implements FinancialReportManagementMeasureRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportManagementMeasureRepository
    implements FinancialReportManagementMeasureRepository {
  final Map<String, List<FinancialReportManagementMeasure>> _measuresByPeriod;
  final List<FinancialReportManagementMeasureAuditEvent> _auditEvents;

  InMemoryFinancialReportManagementMeasureRepository({
    Map<String, List<FinancialReportManagementMeasure>>? measuresByPeriod,
    Iterable<FinancialReportManagementMeasureAuditEvent>? auditEvents,
  }) : _measuresByPeriod = _copy(measuresByPeriod ?? const {}),
       _auditEvents = [...?auditEvents];

  @override
  Map<String, List<FinancialReportManagementMeasure>> loadMeasures() {
    return _copy(_measuresByPeriod);
  }

  @override
  List<FinancialReportManagementMeasureAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertMeasure({
    required String periodKey,
    required FinancialReportManagementMeasure measure,
  }) {
    final periodMeasures = List<FinancialReportManagementMeasure>.of(
      _measuresByPeriod[periodKey] ??
          const <FinancialReportManagementMeasure>[],
    );
    final index = periodMeasures.indexWhere((item) => item.id == measure.id);
    if (index == -1) {
      periodMeasures.add(measure);
    } else {
      periodMeasures[index] = measure;
    }
    periodMeasures.sort(_compareMeasure);
    _measuresByPeriod[periodKey] = periodMeasures;
  }

  @override
  void appendAuditEvent(FinancialReportManagementMeasureAuditEvent event) {
    _auditEvents.add(event);
  }

  @override
  void replaceMeasures({
    required String periodKey,
    required List<FinancialReportManagementMeasure> measures,
  }) {
    if (measures.isEmpty) {
      _measuresByPeriod.remove(periodKey);
      return;
    }
    _measuresByPeriod[periodKey] = [...measures]..sort(_compareMeasure);
  }

  @override
  void removeMeasure({required String periodKey, required String measureId}) {
    final periodMeasures = _measuresByPeriod[periodKey];
    if (periodMeasures == null) {
      return;
    }

    final updated =
        periodMeasures.where((item) => item.id != measureId).toList();
    if (updated.isEmpty) {
      _measuresByPeriod.remove(periodKey);
    } else {
      _measuresByPeriod[periodKey] = updated;
    }
  }

  @override
  void clear() {
    _measuresByPeriod.clear();
    _auditEvents.clear();
  }

  void replaceAll(
    Map<String, List<FinancialReportManagementMeasure>> measuresByPeriod, {
    Iterable<FinancialReportManagementMeasureAuditEvent>? auditEvents,
  }) {
    _measuresByPeriod
      ..clear()
      ..addAll(_copy(measuresByPeriod));
    if (auditEvents != null) {
      _auditEvents
        ..clear()
        ..addAll(auditEvents);
    }
  }
}

Map<String, List<FinancialReportManagementMeasure>> _copy(
  Map<String, List<FinancialReportManagementMeasure>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareMeasure);
    return MapEntry(key, sorted);
  });
}

int _compareMeasure(
  FinancialReportManagementMeasure left,
  FinancialReportManagementMeasure right,
) {
  final label = left.label.compareTo(right.label);
  if (label != 0) {
    return label;
  }
  return left.id.compareTo(right.id);
}
