import '../models/financial_report_exception_resolution.dart';

abstract class FinancialReportExceptionResolutionRepository {
  Map<String, List<FinancialReportExceptionResolution>> loadResolutions();

  void upsertResolution({
    required String periodKey,
    required FinancialReportExceptionResolution resolution,
  });

  void removeResolution({
    required String periodKey,
    required String exceptionId,
  });

  void clear();
}

abstract class HydratableFinancialReportExceptionResolutionRepository
    implements FinancialReportExceptionResolutionRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportExceptionResolutionRepository
    implements FinancialReportExceptionResolutionRepository {
  final Map<String, List<FinancialReportExceptionResolution>>
  _resolutionsByPeriod;

  InMemoryFinancialReportExceptionResolutionRepository({
    Map<String, List<FinancialReportExceptionResolution>>? resolutionsByPeriod,
  }) : _resolutionsByPeriod = _copy(resolutionsByPeriod ?? const {});

  @override
  Map<String, List<FinancialReportExceptionResolution>> loadResolutions() {
    return _copy(_resolutionsByPeriod);
  }

  @override
  void upsertResolution({
    required String periodKey,
    required FinancialReportExceptionResolution resolution,
  }) {
    final periodResolutions = List<FinancialReportExceptionResolution>.of(
      _resolutionsByPeriod[periodKey] ??
          const <FinancialReportExceptionResolution>[],
    );
    final index = periodResolutions.indexWhere(
      (item) => item.exceptionId == resolution.exceptionId,
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
  void removeResolution({
    required String periodKey,
    required String exceptionId,
  }) {
    final periodResolutions = _resolutionsByPeriod[periodKey];
    if (periodResolutions == null) {
      return;
    }

    final updated =
        periodResolutions
            .where((item) => item.exceptionId != exceptionId)
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
  }

  void replaceAll(
    Map<String, List<FinancialReportExceptionResolution>> resolutionsByPeriod,
  ) {
    _resolutionsByPeriod
      ..clear()
      ..addAll(_copy(resolutionsByPeriod));
  }
}

Map<String, List<FinancialReportExceptionResolution>> _copy(
  Map<String, List<FinancialReportExceptionResolution>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareResolution);
    return MapEntry(key, sorted);
  });
}

int _compareResolution(
  FinancialReportExceptionResolution left,
  FinancialReportExceptionResolution right,
) {
  final exceptionId = left.exceptionId.compareTo(right.exceptionId);
  if (exceptionId != 0) {
    return exceptionId;
  }
  final resolvedAt = left.resolvedAt.compareTo(right.resolvedAt);
  if (resolvedAt != 0) {
    return resolvedAt;
  }
  return left.reviewer.compareTo(right.reviewer);
}
