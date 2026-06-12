import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_release_control.dart';
import '../../models/financial_report_release_distribution.dart';
import '../../repositories/financial_report_release_distribution_repository_provider.dart';
import '../../services/financial_report_release_control_service.dart';
import '../../services/financial_report_release_distribution_audit_service.dart';
import '../../services/financial_report_release_distribution_service.dart';
import '../../services/financial_report_release_gate_service.dart';
import 'financial_report_package_integrity_provider.dart';
import 'financial_report_management_measure_reconciliation_provider.dart';
import 'financial_report_pack_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportReleaseDistributionServiceProvider =
    Provider<FinancialReportReleaseDistributionService>((ref) {
      return const FinancialReportReleaseDistributionService();
    });

final financialReportReleaseDistributionAuditServiceProvider =
    Provider<FinancialReportReleaseDistributionAuditService>((ref) {
      return FinancialReportReleaseDistributionAuditService();
    });

final financialReportReleaseGateServiceProvider =
    Provider<FinancialReportReleaseGateService>((ref) {
      return const FinancialReportReleaseGateService();
    });

final financialReportReleaseControlServiceProvider =
    Provider<FinancialReportReleaseControlService>((ref) {
      return const FinancialReportReleaseControlService();
    });

final financialReportReleaseDistributionProvider = StateNotifierProvider<
  FinancialReportReleaseDistributionNotifier,
  Map<String, List<FinancialReportReleaseDistributionResolution>>
>((ref) {
  return FinancialReportReleaseDistributionNotifier(
    repository: ref.watch(financialReportReleaseDistributionRepositoryProvider),
    auditService: ref.watch(
      financialReportReleaseDistributionAuditServiceProvider,
    ),
  );
});

final currentFinancialReportReleaseDistributionRecipientsProvider =
    Provider<List<FinancialReportReleaseDistributionRecipient>>((ref) {
      return ref
          .watch(financialReportReleaseDistributionServiceProvider)
          .buildRecipients(pack: ref.watch(financialReportPackProvider));
    });

final currentFinancialReportReleaseDistributionResolutionsProvider =
    Provider<List<FinancialReportReleaseDistributionResolution>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportReleaseSignOffPeriodKeyProvider,
      );
      final resolutions = ref.watch(financialReportReleaseDistributionProvider);
      return List.unmodifiable(resolutions[periodKey] ?? const []);
    });

final currentFinancialReportReleaseDistributionItemsProvider =
    Provider<List<FinancialReportReleaseDistributionItem>>((ref) {
      return ref
          .watch(financialReportReleaseDistributionServiceProvider)
          .buildItems(
            recipients: ref.watch(
              currentFinancialReportReleaseDistributionRecipientsProvider,
            ),
            resolutions: ref.watch(
              currentFinancialReportReleaseDistributionResolutionsProvider,
            ),
          );
    });

final currentFinancialReportReleaseDistributionAuditProvider =
    Provider<List<FinancialReportReleaseDistributionAuditEvent>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportReleaseSignOffPeriodKeyProvider,
      );
      final repository = ref.watch(
        financialReportReleaseDistributionRepositoryProvider,
      );
      final auditService = ref.watch(
        financialReportReleaseDistributionAuditServiceProvider,
      );
      ref.watch(financialReportReleaseDistributionProvider);
      return auditService.newestFirst(
        repository.loadAuditEvents().where(
          (event) => event.periodKey == periodKey,
        ),
      );
    });

final currentFinancialReportReleaseDistributionLockedReasonProvider =
    Provider<String?>((ref) {
      return ref
          .watch(financialReportReleaseGateServiceProvider)
          .distributionLockedReason(
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            managementMeasureReconciliations: ref.watch(
              currentFinancialReportManagementMeasureReconciliationsProvider,
            ),
          );
    });

final currentFinancialReportReleaseControlSummaryProvider =
    Provider<FinancialReportReleaseControlSummary>((ref) {
      return ref
          .watch(financialReportReleaseControlServiceProvider)
          .summarize(
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
            ),
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            managementMeasureReconciliations: ref.watch(
              currentFinancialReportManagementMeasureReconciliationsProvider,
            ),
            asOf: DateTime.now(),
          );
    });

class FinancialReportReleaseDistributionNotifier
    extends
        StateNotifier<
          Map<String, List<FinancialReportReleaseDistributionResolution>>
        > {
  final FinancialReportReleaseDistributionRepository repository;
  final FinancialReportReleaseDistributionAuditService auditService;
  var _isDisposed = false;

  FinancialReportReleaseDistributionNotifier({
    required this.repository,
    required this.auditService,
  }) : super(repository.loadResolutions()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportReleaseDistributionRepository) {
      return;
    }

    try {
      await repository.hydrate();
    } catch (_) {
      return;
    }
    if (!_isDisposed) {
      state = repository.loadResolutions();
    }
  }

  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseDistributionResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    state = repository.loadResolutions();
  }

  FinancialReportReleaseDistributionAuditEvent recordResolution({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseDistributionItem item,
    required FinancialReportReleaseDistributionResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    final event = auditService.resolutionSaved(
      periodKey: periodKey,
      periodLabel: periodLabel,
      item: item,
      resolution: resolution,
    );
    repository.appendAuditEvent(event);
    state = repository.loadResolutions();
    return event;
  }

  void removeResolution({
    required String periodKey,
    required String recipientId,
  }) {
    repository.removeResolution(periodKey: periodKey, recipientId: recipientId);
    state = repository.loadResolutions();
  }

  FinancialReportReleaseDistributionAuditEvent clearResolution({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseDistributionItem item,
    required String actor,
    DateTime? occurredAt,
  }) {
    repository.removeResolution(periodKey: periodKey, recipientId: item.id);
    final event = auditService.cleared(
      periodKey: periodKey,
      periodLabel: periodLabel,
      item: item,
      actor: actor,
      occurredAt: occurredAt,
    );
    repository.appendAuditEvent(event);
    state = repository.loadResolutions();
    return event;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
