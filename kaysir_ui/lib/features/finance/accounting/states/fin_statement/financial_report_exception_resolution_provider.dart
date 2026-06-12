import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_exception_resolution.dart';
import '../../repositories/financial_report_exception_resolution_repository_provider.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';

final financialReportExceptionResolutionProvider = StateNotifierProvider<
  FinancialReportExceptionResolutionNotifier,
  Map<String, List<FinancialReportExceptionResolution>>
>((ref) {
  return FinancialReportExceptionResolutionNotifier(
    repository: ref.watch(financialReportExceptionResolutionRepositoryProvider),
  );
});

final currentFinancialReportExceptionResolutionPeriodKeyProvider =
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

final currentFinancialReportExceptionResolutionsProvider =
    Provider<List<FinancialReportExceptionResolution>>((ref) {
      final periodKey = ref.watch(
        currentFinancialReportExceptionResolutionPeriodKeyProvider,
      );
      final resolutions = ref.watch(financialReportExceptionResolutionProvider);
      return List.unmodifiable(resolutions[periodKey] ?? const []);
    });

class FinancialReportExceptionResolutionNotifier
    extends
        StateNotifier<Map<String, List<FinancialReportExceptionResolution>>> {
  final FinancialReportExceptionResolutionRepository repository;
  var _isDisposed = false;

  FinancialReportExceptionResolutionNotifier({required this.repository})
    : super(repository.loadResolutions()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialReportExceptionResolutionRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadResolutions();
    }
  }

  void upsertResolution({
    required String periodKey,
    required FinancialReportExceptionResolution resolution,
  }) {
    repository.upsertResolution(periodKey: periodKey, resolution: resolution);
    state = repository.loadResolutions();
  }

  void removeResolution({
    required String periodKey,
    required String exceptionId,
  }) {
    repository.removeResolution(periodKey: periodKey, exceptionId: exceptionId);
    state = repository.loadResolutions();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
