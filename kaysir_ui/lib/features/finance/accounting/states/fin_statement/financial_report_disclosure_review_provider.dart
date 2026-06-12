import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_disclosure_review.dart';
import '../../repositories/financial_report_disclosure_review_repository_provider.dart';
import '../../services/financial_report_disclosure_review_service.dart';
import '../accounting_policy_provider.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';
import 'financial_report_pack_provider.dart';

final financialReportDisclosureReviewServiceProvider =
    Provider<FinancialReportDisclosureReviewService>((ref) {
      return const FinancialReportDisclosureReviewService();
    });

final financialReportDisclosureReviewProvider = StateNotifierProvider<
  FinancialReportDisclosureReviewNotifier,
  Map<String, List<FinancialReportDisclosureResolution>>
>((ref) {
  return FinancialReportDisclosureReviewNotifier(
    repository: ref.watch(financialReportDisclosureReviewRepositoryProvider),
  );
});

final currentFinancialReportDisclosureReviewPeriodKeyProvider =
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

final currentFinancialReportDisclosureRequirementsProvider =
    Provider<List<FinancialReportDisclosureRequirement>>((ref) {
      return ref
          .watch(financialReportDisclosureReviewServiceProvider)
          .buildRequirements(
            pack: ref.watch(financialReportPackProvider),
            policy: ref.watch(accountingPolicyProvider),
          );
    });

final currentFinancialReportDisclosureResolutionsProvider =
    Provider<List<FinancialReportDisclosureResolution>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportDisclosureReviewPeriodKeyProvider,
      );
      final resolutions = ref.watch(financialReportDisclosureReviewProvider);
      return List.unmodifiable(resolutions[periodKey] ?? const []);
    });

final currentFinancialReportDisclosureReviewItemsProvider =
    Provider<List<FinancialReportDisclosureReviewItem>>((ref) {
      return ref
          .watch(financialReportDisclosureReviewServiceProvider)
          .buildReviewItems(
            requirements: ref.watch(
              currentFinancialReportDisclosureRequirementsProvider,
            ),
            resolutions: ref.watch(
              currentFinancialReportDisclosureResolutionsProvider,
            ),
          );
    });

class FinancialReportDisclosureReviewNotifier
    extends
        StateNotifier<Map<String, List<FinancialReportDisclosureResolution>>> {
  final FinancialReportDisclosureReviewRepository repository;
  var _isDisposed = false;

  FinancialReportDisclosureReviewNotifier({required this.repository})
    : super(repository.loadResolutions()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportDisclosureReviewRepository) {
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
    required FinancialReportDisclosureResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    state = repository.loadResolutions();
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
