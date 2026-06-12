import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_management_measure.dart';
import '../../repositories/financial_report_management_measure_repository_provider.dart';
import '../../services/financial_report_management_measure_audit_service.dart';
import '../../services/financial_report_management_measure_service.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';

final financialReportManagementMeasureServiceProvider =
    Provider<FinancialReportManagementMeasureService>((ref) {
      return const FinancialReportManagementMeasureService();
    });

final financialReportManagementMeasureAuditServiceProvider =
    Provider<FinancialReportManagementMeasureAuditService>((ref) {
      return FinancialReportManagementMeasureAuditService();
    });

final financialReportManagementMeasuresProvider = StateNotifierProvider<
  FinancialReportManagementMeasureNotifier,
  List<FinancialReportManagementMeasure>
>((ref) {
  final period = ref.watch(selectedFinancialPeriodProvider);
  return FinancialReportManagementMeasureNotifier(
    repository: ref.watch(financialReportManagementMeasureRepositoryProvider),
    auditService: ref.watch(
      financialReportManagementMeasureAuditServiceProvider,
    ),
    periodKey: ref.watch(
      currentFinancialReportManagementMeasurePeriodKeyProvider,
    ),
    periodLabel: period.label,
  );
});

final currentFinancialReportManagementMeasurePeriodKeyProvider =
    Provider<String>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      return ref
          .watch(financialPeriodCloseServiceProvider)
          .periodKey(
            periodLabel: period.label,
            periodStart: period.startDate,
            periodEnd: period.endDate,
          );
    });

final currentFinancialReportManagementMeasureAuditProvider =
    Provider<List<FinancialReportManagementMeasureAuditEvent>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportManagementMeasurePeriodKeyProvider,
      );
      final repository = ref.watch(
        financialReportManagementMeasureRepositoryProvider,
      );
      final auditService = ref.watch(
        financialReportManagementMeasureAuditServiceProvider,
      );
      ref.watch(financialReportManagementMeasuresProvider);

      return auditService.newestFirst(
        repository.loadAuditEvents().where(
          (event) => event.periodKey == periodKey,
        ),
      );
    });

class FinancialReportManagementMeasureNotifier
    extends StateNotifier<List<FinancialReportManagementMeasure>> {
  final FinancialReportManagementMeasureRepository repository;
  final FinancialReportManagementMeasureAuditService auditService;
  final String periodKey;
  final String periodLabel;
  var _isDisposed = false;

  FinancialReportManagementMeasureNotifier({
    required this.repository,
    required this.auditService,
    required this.periodKey,
    required this.periodLabel,
  }) : super(_measuresForPeriod(repository, periodKey)) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportManagementMeasureRepository) {
      return;
    }

    try {
      await repository.hydrate();
    } catch (_) {
      return;
    }

    if (!_isDisposed) {
      state = _measuresForPeriod(repository, periodKey);
    }
  }

  void upsert(FinancialReportManagementMeasure measure) {
    repository.upsertMeasure(periodKey: periodKey, measure: measure);
    repository.appendAuditEvent(
      auditService.measureSaved(
        periodKey: periodKey,
        periodLabel: periodLabel,
        measure: measure,
        actor: 'Current user',
      ),
    );
    state = _measuresForPeriod(repository, periodKey);
  }

  void updateStatus({
    required String id,
    required FinancialReportManagementMeasureApprovalStatus status,
    String? note,
  }) {
    final measure = _measureById(state, id);
    if (measure == null) {
      return;
    }

    final updated = measure.copyWith(
      approvalStatus: status,
      reviewedAt: DateTime.now(),
      reviewNote: note,
      clearReviewNote: note == null,
    );
    repository.upsertMeasure(periodKey: periodKey, measure: updated);
    repository.appendAuditEvent(
      auditService.statusChanged(
        periodKey: periodKey,
        periodLabel: periodLabel,
        measure: updated,
        actor: 'Current user',
        note: note ?? updated.approvalStatus.label,
      ),
    );
    state = _measuresForPeriod(repository, periodKey);
  }

  void resetDemoRegister() {
    repository.replaceMeasures(
      periodKey: periodKey,
      measures: _defaultMeasures,
    );
    repository.appendAuditEvent(
      auditService.reset(
        periodKey: periodKey,
        periodLabel: periodLabel,
        actor: 'Current user',
      ),
    );
    state = _measuresForPeriod(repository, periodKey);
  }

  void remove(String id) {
    final measure = _measureById(state, id);
    if (measure == null) {
      return;
    }

    repository.removeMeasure(periodKey: periodKey, measureId: id);
    repository.appendAuditEvent(
      auditService.removed(
        periodKey: periodKey,
        periodLabel: periodLabel,
        measure: measure,
        actor: 'Current user',
      ),
    );
    state = _measuresForPeriod(repository, periodKey);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

const _defaultMeasures = [
  FinancialReportManagementMeasure.defaultOperatingPerformance(),
];

List<FinancialReportManagementMeasure> _measuresForPeriod(
  FinancialReportManagementMeasureRepository repository,
  String periodKey,
) {
  final measures = repository.loadMeasures()[periodKey];
  if (measures == null || measures.isEmpty) {
    return _defaultMeasures;
  }
  return List.unmodifiable(measures);
}

FinancialReportManagementMeasure? _measureById(
  Iterable<FinancialReportManagementMeasure> measures,
  String id,
) {
  for (final measure in measures) {
    if (measure.id == id) {
      return measure;
    }
  }
  return null;
}
