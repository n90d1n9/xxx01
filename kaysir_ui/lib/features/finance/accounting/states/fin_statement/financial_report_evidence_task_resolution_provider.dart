import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_evidence_close_task.dart';
import '../../repositories/financial_report_evidence_task_resolution_repository_provider.dart';
import '../../services/financial_report_evidence_task_audit_service.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';

final financialReportEvidenceTaskAuditServiceProvider =
    Provider<FinancialReportEvidenceTaskAuditService>((ref) {
      return FinancialReportEvidenceTaskAuditService();
    });

final financialReportEvidenceTaskResolutionProvider = StateNotifierProvider<
  FinancialReportEvidenceTaskResolutionNotifier,
  Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
>((ref) {
  return FinancialReportEvidenceTaskResolutionNotifier(
    repository: ref.watch(
      financialReportEvidenceTaskResolutionRepositoryProvider,
    ),
    auditService: ref.watch(financialReportEvidenceTaskAuditServiceProvider),
  );
});

final currentFinancialReportEvidenceTaskResolutionPeriodKeyProvider =
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

final currentFinancialReportEvidenceTaskResolutionsProvider =
    Provider<List<FinancialReportEvidenceCloseTaskResolution>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportEvidenceTaskResolutionPeriodKeyProvider,
      );
      final resolutions = ref.watch(
        financialReportEvidenceTaskResolutionProvider,
      );
      return List.unmodifiable(resolutions[periodKey] ?? const []);
    });

final currentFinancialReportEvidenceTaskAuditProvider =
    Provider<List<FinancialReportEvidenceTaskAuditEvent>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportEvidenceTaskResolutionPeriodKeyProvider,
      );
      final repository = ref.watch(
        financialReportEvidenceTaskResolutionRepositoryProvider,
      );
      final auditService = ref.watch(
        financialReportEvidenceTaskAuditServiceProvider,
      );
      ref.watch(financialReportEvidenceTaskResolutionProvider);
      return auditService.newestFirst(
        repository.loadAuditEvents().where(
          (event) => event.periodKey == periodKey,
        ),
      );
    });

class FinancialReportEvidenceTaskResolutionNotifier
    extends
        StateNotifier<
          Map<String, List<FinancialReportEvidenceCloseTaskResolution>>
        > {
  final FinancialReportEvidenceTaskResolutionRepository repository;
  final FinancialReportEvidenceTaskAuditService auditService;
  var _isDisposed = false;

  FinancialReportEvidenceTaskResolutionNotifier({
    required this.repository,
    required this.auditService,
  }) : super(repository.loadResolutions()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository
        is! HydratableFinancialReportEvidenceTaskResolutionRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadResolutions();
    }
  }

  void upsertResolution({
    required String periodKey,
    required FinancialReportEvidenceCloseTaskResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    state = repository.loadResolutions();
  }

  FinancialReportEvidenceTaskAuditEvent recordResolution({
    required String periodKey,
    required String periodLabel,
    required FinancialReportEvidenceCloseTask task,
    required FinancialReportEvidenceCloseTaskResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    final event = auditService.evidenceSaved(
      periodKey: periodKey,
      periodLabel: periodLabel,
      task: task,
      resolution: resolution,
    );
    repository.appendAuditEvent(event);
    state = repository.loadResolutions();
    return event;
  }

  void removeResolution({required String periodKey, required String taskId}) {
    repository.removeResolution(periodKey: periodKey, taskId: taskId);
    state = repository.loadResolutions();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
