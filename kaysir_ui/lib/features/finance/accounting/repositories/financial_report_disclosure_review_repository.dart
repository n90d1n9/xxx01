import '../models/financial_report_disclosure_review.dart';

abstract class FinancialReportDisclosureReviewRepository {
  Map<String, List<FinancialReportDisclosureResolution>> loadResolutions();

  void upsertResolution({
    required String periodKey,
    required FinancialReportDisclosureResolution resolution,
  });

  void removeResolution({
    required String periodKey,
    required String requirementId,
  });

  void clear();
}

abstract class HydratableFinancialReportDisclosureReviewRepository
    implements FinancialReportDisclosureReviewRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryFinancialReportDisclosureReviewRepository
    implements FinancialReportDisclosureReviewRepository {
  final Map<String, List<FinancialReportDisclosureResolution>>
  _resolutionsByPeriod;

  InMemoryFinancialReportDisclosureReviewRepository({
    Map<String, List<FinancialReportDisclosureResolution>>? resolutionsByPeriod,
  }) : _resolutionsByPeriod = _copy(resolutionsByPeriod ?? const {});

  @override
  Map<String, List<FinancialReportDisclosureResolution>> loadResolutions() {
    return _copy(_resolutionsByPeriod);
  }

  @override
  void upsertResolution({
    required String periodKey,
    required FinancialReportDisclosureResolution resolution,
  }) {
    final periodResolutions = List<FinancialReportDisclosureResolution>.of(
      _resolutionsByPeriod[periodKey] ??
          const <FinancialReportDisclosureResolution>[],
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
  }

  void replaceAll(
    Map<String, List<FinancialReportDisclosureResolution>> resolutionsByPeriod,
  ) {
    _resolutionsByPeriod
      ..clear()
      ..addAll(_copy(resolutionsByPeriod));
  }
}

Map<String, List<FinancialReportDisclosureResolution>> _copy(
  Map<String, List<FinancialReportDisclosureResolution>> source,
) {
  return source.map((key, value) {
    final sorted = [...value]..sort(_compareResolution);
    return MapEntry(key, sorted);
  });
}

int _compareResolution(
  FinancialReportDisclosureResolution left,
  FinancialReportDisclosureResolution right,
) {
  final requirementId = left.requirementId.compareTo(right.requirementId);
  if (requirementId != 0) {
    return requirementId;
  }
  final reviewedAt = left.reviewedAt.compareTo(right.reviewedAt);
  if (reviewedAt != 0) {
    return reviewedAt;
  }
  return left.reviewer.compareTo(right.reviewer);
}
