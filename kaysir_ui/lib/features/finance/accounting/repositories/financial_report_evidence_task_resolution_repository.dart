import '../models/financial_report_evidence_close_task.dart';

abstract class FinancialReportEvidenceTaskResolutionRepository {
  Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
  loadResolutions();

  List<FinancialReportEvidenceTaskAuditEvent> loadAuditEvents();

  void upsertResolution({
    required String periodKey,
    required FinancialReportEvidenceCloseTaskResolution resolution,
  });

  void appendAuditEvent(FinancialReportEvidenceTaskAuditEvent event);

  void removeResolution({required String periodKey, required String taskId});

  void clear();
}

abstract class HydratableFinancialReportEvidenceTaskResolutionRepository
    implements FinancialReportEvidenceTaskResolutionRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportEvidenceTaskResolutionRepository
    implements FinancialReportEvidenceTaskResolutionRepository {
  final Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
  _resolutionsByPeriod;
  final List<FinancialReportEvidenceTaskAuditEvent> _auditEvents;

  InMemoryFinancialReportEvidenceTaskResolutionRepository({
    Map<String, List<FinancialReportEvidenceCloseTaskResolution>>?
    resolutionsByPeriod,
    Iterable<FinancialReportEvidenceTaskAuditEvent>? auditEvents,
  }) : _resolutionsByPeriod = _copy(resolutionsByPeriod ?? const {}),
       _auditEvents = [...?auditEvents];

  @override
  Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
  loadResolutions() {
    return _copy(_resolutionsByPeriod);
  }

  @override
  List<FinancialReportEvidenceTaskAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertResolution({
    required String periodKey,
    required FinancialReportEvidenceCloseTaskResolution resolution,
  }) {
    final periodResolutions =
        List<FinancialReportEvidenceCloseTaskResolution>.of(
          _resolutionsByPeriod[periodKey] ??
              const <FinancialReportEvidenceCloseTaskResolution>[],
        );
    final index = periodResolutions.indexWhere(
      (item) => item.taskId == resolution.taskId,
    );
    if (index == -1) {
      periodResolutions.add(resolution);
    } else {
      periodResolutions[index] = resolution;
    }
    periodResolutions.sort(_compareResolution);
    _resolutionsByPeriod[periodKey] = periodResolutions;
  }

  @override
  void appendAuditEvent(FinancialReportEvidenceTaskAuditEvent event) {
    _auditEvents.add(event);
  }

  @override
  void removeResolution({required String periodKey, required String taskId}) {
    final periodResolutions = _resolutionsByPeriod[periodKey];
    if (periodResolutions == null) {
      return;
    }

    final updated =
        periodResolutions.where((item) => item.taskId != taskId).toList();
    if (updated.isEmpty) {
      _resolutionsByPeriod.remove(periodKey);
    } else {
      _resolutionsByPeriod[periodKey] = updated;
    }
  }

  @override
  void clear() {
    _resolutionsByPeriod.clear();
    _auditEvents.clear();
  }

  void replaceAll(
    Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
    resolutionsByPeriod, {
    Iterable<FinancialReportEvidenceTaskAuditEvent>? auditEvents,
  }) {
    _resolutionsByPeriod
      ..clear()
      ..addAll(_copy(resolutionsByPeriod));
    if (auditEvents != null) {
      _auditEvents
        ..clear()
        ..addAll(auditEvents);
    }
  }
}

Map<String, List<FinancialReportEvidenceCloseTaskResolution>> _copy(
  Map<String, List<FinancialReportEvidenceCloseTaskResolution>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareResolution);
    return MapEntry(key, sorted);
  });
}

int _compareResolution(
  FinancialReportEvidenceCloseTaskResolution left,
  FinancialReportEvidenceCloseTaskResolution right,
) {
  final taskId = left.taskId.compareTo(right.taskId);
  if (taskId != 0) {
    return taskId;
  }
  final resolvedAt = left.resolvedAt.compareTo(right.resolvedAt);
  if (resolvedAt != 0) {
    return resolvedAt;
  }
  return left.reviewer.compareTo(right.reviewer);
}
