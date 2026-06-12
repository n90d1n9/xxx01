import '../models/financial_report_release_signoff.dart';

abstract class FinancialReportReleaseSignOffRepository {
  Map<String, List<FinancialReportReleaseSignOffResolution>> loadResolutions();

  List<FinancialReportReleaseSignOffAuditEvent> loadAuditEvents();

  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseSignOffResolution resolution,
  });

  void appendAuditEvent(FinancialReportReleaseSignOffAuditEvent event);

  void removeResolution({
    required String periodKey,
    required String requirementId,
  });

  void clear();
}

abstract class HydratableFinancialReportReleaseSignOffRepository
    implements FinancialReportReleaseSignOffRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportReleaseSignOffRepository
    implements FinancialReportReleaseSignOffRepository {
  final Map<String, List<FinancialReportReleaseSignOffResolution>>
  _resolutionsByPeriod;
  final List<FinancialReportReleaseSignOffAuditEvent> _auditEvents;

  InMemoryFinancialReportReleaseSignOffRepository({
    Map<String, List<FinancialReportReleaseSignOffResolution>>?
    resolutionsByPeriod,
    Iterable<FinancialReportReleaseSignOffAuditEvent>? auditEvents,
  }) : _resolutionsByPeriod = _copy(resolutionsByPeriod ?? const {}),
       _auditEvents = [...?auditEvents];

  @override
  Map<String, List<FinancialReportReleaseSignOffResolution>> loadResolutions() {
    return _copy(_resolutionsByPeriod);
  }

  @override
  List<FinancialReportReleaseSignOffAuditEvent> loadAuditEvents() {
    return List.unmodifiable(_auditEvents);
  }

  @override
  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseSignOffResolution resolution,
  }) {
    final periodResolutions = List<FinancialReportReleaseSignOffResolution>.of(
      _resolutionsByPeriod[periodKey] ??
          const <FinancialReportReleaseSignOffResolution>[],
    );
    final index = periodResolutions.indexWhere(
      (item) => item.requirementId == resolution.requirementId,
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
  void appendAuditEvent(FinancialReportReleaseSignOffAuditEvent event) {
    _auditEvents.add(event);
  }

  @override
  void removeResolution({
    required String periodKey,
    required String requirementId,
  }) {
    final periodResolutions = _resolutionsByPeriod[periodKey];
    if (periodResolutions == null) {
      return;
    }

    final updated =
        periodResolutions
            .where((item) => item.requirementId != requirementId)
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
    Map<String, List<FinancialReportReleaseSignOffResolution>>
    resolutionsByPeriod, {
    Iterable<FinancialReportReleaseSignOffAuditEvent>? auditEvents,
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

Map<String, List<FinancialReportReleaseSignOffResolution>> _copy(
  Map<String, List<FinancialReportReleaseSignOffResolution>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareResolution);
    return MapEntry(key, sorted);
  });
}

int _compareResolution(
  FinancialReportReleaseSignOffResolution left,
  FinancialReportReleaseSignOffResolution right,
) {
  final requirementId = left.requirementId.compareTo(right.requirementId);
  if (requirementId != 0) {
    return requirementId;
  }
  final signedAt = left.signedAt.compareTo(right.signedAt);
  if (signedAt != 0) {
    return signedAt;
  }
  return left.signer.compareTo(right.signer);
}
