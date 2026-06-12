import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_release_signoff.dart';
import '../../repositories/financial_report_release_signoff_repository_provider.dart';
import '../../services/financial_report_release_signoff_audit_service.dart';
import '../../services/financial_report_release_signoff_service.dart';
import '../accounting_policy_provider.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';
import 'financial_report_pack_provider.dart';

final financialReportReleaseSignOffServiceProvider =
    Provider<FinancialReportReleaseSignOffService>((ref) {
      return const FinancialReportReleaseSignOffService();
    });

final financialReportReleaseSignOffAuditServiceProvider =
    Provider<FinancialReportReleaseSignOffAuditService>((ref) {
      return FinancialReportReleaseSignOffAuditService();
    });

final financialReportReleaseSignOffProvider = StateNotifierProvider<
  FinancialReportReleaseSignOffNotifier,
  Map<String, List<FinancialReportReleaseSignOffResolution>>
>((ref) {
  return FinancialReportReleaseSignOffNotifier(
    repository: ref.watch(financialReportReleaseSignOffRepositoryProvider),
    auditService: ref.watch(financialReportReleaseSignOffAuditServiceProvider),
  );
});

final currentFinancialReportReleaseSignOffPeriodKeyProvider = Provider<String>((
  ref,
) {
  final period = ref.watch(selectedFinancialPeriodProvider);
  return ref
      .watch(financialPeriodCloseServiceProvider)
      .periodKey(
        periodLabel: period.label,
        periodStart: period.startDate,
        periodEnd: period.endDate,
      );
});

final currentFinancialReportReleaseSignOffRequirementsProvider =
    Provider<List<FinancialReportReleaseSignOffRequirement>>((ref) {
      return ref
          .watch(financialReportReleaseSignOffServiceProvider)
          .buildRequirements(
            pack: ref.watch(financialReportPackProvider),
            policy: ref.watch(accountingPolicyProvider),
          );
    });

final currentFinancialReportReleaseSignOffResolutionsProvider =
    Provider<List<FinancialReportReleaseSignOffResolution>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportReleaseSignOffPeriodKeyProvider,
      );
      final resolutions = ref.watch(financialReportReleaseSignOffProvider);
      return List.unmodifiable(resolutions[periodKey] ?? const []);
    });

final currentFinancialReportReleaseSignOffItemsProvider =
    Provider<List<FinancialReportReleaseSignOffItem>>((ref) {
      return ref
          .watch(financialReportReleaseSignOffServiceProvider)
          .buildReviewItems(
            requirements: ref.watch(
              currentFinancialReportReleaseSignOffRequirementsProvider,
            ),
            resolutions: ref.watch(
              currentFinancialReportReleaseSignOffResolutionsProvider,
            ),
          );
    });

final currentFinancialReportReleaseSignOffAuditProvider = Provider<
  List<FinancialReportReleaseSignOffAuditEvent>
>((ref) {
  final periodKey = ref.watch(
    currentFinancialReportReleaseSignOffPeriodKeyProvider,
  );
  final repository = ref.watch(financialReportReleaseSignOffRepositoryProvider);
  final auditService = ref.watch(
    financialReportReleaseSignOffAuditServiceProvider,
  );
  ref.watch(financialReportReleaseSignOffProvider);
  return auditService.newestFirst(
    repository.loadAuditEvents().where((event) => event.periodKey == periodKey),
  );
});

class FinancialReportReleaseSignOffNotifier
    extends
        StateNotifier<
          Map<String, List<FinancialReportReleaseSignOffResolution>>
        > {
  final FinancialReportReleaseSignOffRepository repository;
  final FinancialReportReleaseSignOffAuditService auditService;
  var _isDisposed = false;

  FinancialReportReleaseSignOffNotifier({
    required this.repository,
    required this.auditService,
  }) : super(repository.loadResolutions()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportReleaseSignOffRepository) {
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
    required FinancialReportReleaseSignOffResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    state = repository.loadResolutions();
  }

  FinancialReportReleaseSignOffAuditEvent recordResolution({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseSignOffItem item,
    required FinancialReportReleaseSignOffResolution resolution,
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
    required String requirementId,
  }) {
    repository.removeResolution(
      periodKey: periodKey,
      requirementId: requirementId,
    );
    state = repository.loadResolutions();
  }

  FinancialReportReleaseSignOffAuditEvent clearResolution({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseSignOffItem item,
    required String actor,
    DateTime? occurredAt,
  }) {
    repository.removeResolution(periodKey: periodKey, requirementId: item.id);
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
