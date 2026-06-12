import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_close_checklist.dart';
import '../../models/financial_period_close.dart';
import '../../repositories/financial_period_close_repository_provider.dart';
import '../../services/financial_period_close_service.dart';
import 'financial_provider.dart';

final financialPeriodCloseServiceProvider =
    Provider<FinancialPeriodCloseService>((ref) {
      return const FinancialPeriodCloseService();
    });

final financialPeriodCloseRecordsProvider = StateNotifierProvider<
  FinancialPeriodCloseNotifier,
  Map<String, FinancialPeriodCloseRecord>
>((ref) {
  return FinancialPeriodCloseNotifier(
    repository: ref.watch(financialPeriodCloseRepositoryProvider),
    service: ref.watch(financialPeriodCloseServiceProvider),
  );
});

final currentFinancialPeriodCloseRecordProvider =
    Provider<FinancialPeriodCloseRecord?>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      final service = ref.watch(financialPeriodCloseServiceProvider);
      final records = ref.watch(financialPeriodCloseRecordsProvider);
      final key = service.periodKey(
        periodLabel: period.label,
        periodStart: period.startDate,
        periodEnd: period.endDate,
      );

      return records[key];
    });

class FinancialPeriodCloseNotifier
    extends StateNotifier<Map<String, FinancialPeriodCloseRecord>> {
  final FinancialPeriodCloseRepository repository;
  final FinancialPeriodCloseService service;
  var _isDisposed = false;

  FinancialPeriodCloseNotifier({
    required this.repository,
    required this.service,
  }) : super(repository.loadRecords()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialPeriodCloseRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadRecords();
    }
  }

  FinancialPeriodCloseRecord closeCurrentPeriod({
    required FinancialCloseChecklist checklist,
    required FinancialStatementPeriod period,
    String closedBy = 'Current user',
    String? reportPackageHash,
    String? reportPackageHashAlgorithm,
    String? closingEntryPostingId,
    String? closingEntryReference,
    DateTime? closingEntryPostedAt,
  }) {
    final record = service.closePeriod(
      checklist: checklist,
      periodLabel: period.label,
      periodStart: period.startDate,
      periodEnd: period.endDate,
      closedBy: closedBy,
      reportPackageHash: reportPackageHash,
      reportPackageHashAlgorithm: reportPackageHashAlgorithm,
      closingEntryPostingId: closingEntryPostingId,
      closingEntryReference: closingEntryReference,
      closingEntryPostedAt: closingEntryPostedAt,
    );
    repository.upsertRecord(record);
    state = repository.loadRecords();
    return record;
  }

  FinancialPeriodCloseRecord reopenCurrentPeriod({
    required FinancialStatementPeriod period,
    required String reason,
    String reopenedBy = 'Current user',
  }) {
    final key = service.periodKey(
      periodLabel: period.label,
      periodStart: period.startDate,
      periodEnd: period.endDate,
    );
    final current = state[key];
    if (current == null) {
      throw StateError('No closed record exists for ${period.label}');
    }

    final record = service.reopenPeriod(
      record: current,
      reason: reason,
      reopenedBy: reopenedBy,
    );
    repository.upsertRecord(record);
    state = repository.loadRecords();
    return record;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
