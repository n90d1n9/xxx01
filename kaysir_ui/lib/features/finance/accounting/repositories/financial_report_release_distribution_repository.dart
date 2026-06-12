import '../models/financial_report_release_distribution.dart';

abstract class FinancialReportReleaseDistributionRepository {
  Map<String, List<FinancialReportReleaseDistributionResolution>>
  loadResolutions();

  List<FinancialReportReleaseDistributionAuditEvent> loadAuditEvents();

  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseDistributionResolution resolution,
  });

  void appendAuditEvent(FinancialReportReleaseDistributionAuditEvent event);

  void removeResolution({
    required String periodKey,
    required String recipientId,
  });

  void clear();
}

abstract class HydratableFinancialReportReleaseDistributionRepository
    implements FinancialReportReleaseDistributionRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportReleaseDistributionRepository
    implements FinancialReportReleaseDistributionRepository {
  final Map<String, List<FinancialReportReleaseDistributionResolution>>
  _resolutionsByPeriod;
  final List<FinancialReportReleaseDistributionAuditEvent> _auditEvents;

  InMemoryFinancialReportReleaseDistributionRepository({
    Map<String, List<FinancialReportReleaseDistributionResolution>>?
    resolutionsByPeriod,
    Iterable<FinancialReportReleaseDistributionAuditEvent>? auditEvents,
  }) : _resolutionsByPeriod = _copy(resolutionsByPeriod ?? const {}),
       _auditEvents = [...?auditEvents];

  @override
  Map<String, List<FinancialReportReleaseDistributionResolution>>
  loadResolutions() {
    return _copy(_resolutionsByPeriod);
  }

  @override
  List<FinancialReportReleaseDistributionAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseDistributionResolution resolution,
  }) {
    final periodResolutions =
        List<FinancialReportReleaseDistributionResolution>.of(
          _resolutionsByPeriod[periodKey] ??
              const <FinancialReportReleaseDistributionResolution>[],
        );
    final index = periodResolutions.indexWhere(
      (item) => item.recipientId == resolution.recipientId,
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
  void appendAuditEvent(FinancialReportReleaseDistributionAuditEvent event) {
    _auditEvents.add(event);
  }

  @override
  void removeResolution({
    required String periodKey,
    required String recipientId,
  }) {
    final periodResolutions = _resolutionsByPeriod[periodKey];
    if (periodResolutions == null) {
      return;
    }

    final updated =
        periodResolutions
            .where((item) => item.recipientId != recipientId)
            .toList();
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
    Map<String, List<FinancialReportReleaseDistributionResolution>>
    resolutionsByPeriod, {
    Iterable<FinancialReportReleaseDistributionAuditEvent>? auditEvents,
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

Map<String, List<FinancialReportReleaseDistributionResolution>> _copy(
  Map<String, List<FinancialReportReleaseDistributionResolution>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareResolution);
    return MapEntry(key, sorted);
  });
}

int _compareResolution(
  FinancialReportReleaseDistributionResolution left,
  FinancialReportReleaseDistributionResolution right,
) {
  final recipientId = left.recipientId.compareTo(right.recipientId);
  if (recipientId != 0) {
    return recipientId;
  }
  final updatedAt = left.updatedAt.compareTo(right.updatedAt);
  if (updatedAt != 0) {
    return updatedAt;
  }
  return left.owner.compareTo(right.owner);
}
