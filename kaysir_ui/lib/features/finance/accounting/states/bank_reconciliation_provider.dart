import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_journal_draft.dart';
import '../models/bank_reconciliation_resolution.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';
import '../repositories/bank_reconciliation_timing_review_repository_provider.dart';
import '../services/bank_reconciliation_control_summary_service.dart';
import '../repositories/bank_statement_repository_provider.dart';
import '../services/bank_reconciliation_journal_draft_service.dart';
import '../services/bank_reconciliation_timing_register_service.dart';
import '../services/bank_statement_import_service.dart';
import '../services/bank_reconciliation_service.dart';
import '../services/bank_reconciliation_resolution_service.dart';
import 'accounting_core_provider.dart';
import 'fin_statement/financial_period_close_provider.dart';
import 'fin_statement/financial_provider.dart';
import 'gl/ledger_provider.dart';

final bankStatementLinesProvider =
    StateNotifierProvider<BankStatementLineNotifier, List<BankStatementLine>>((
      ref,
    ) {
      return BankStatementLineNotifier(
        repository: ref.watch(bankStatementRepositoryProvider),
      );
    });

final bankReconciliationServiceProvider = Provider<BankReconciliationService>((
  ref,
) {
  return const BankReconciliationService();
});

final bankStatementImportServiceProvider = Provider<BankStatementImportService>(
  (ref) {
    return const BankStatementImportService();
  },
);

final bankReconciliationResolutionServiceProvider =
    Provider<BankReconciliationResolutionService>((ref) {
      return const BankReconciliationResolutionService();
    });

final bankReconciliationControlSummaryServiceProvider =
    Provider<BankReconciliationControlSummaryService>((ref) {
      return const BankReconciliationControlSummaryService();
    });

final bankReconciliationJournalDraftServiceProvider =
    Provider<BankReconciliationJournalDraftService>((ref) {
      return const BankReconciliationJournalDraftService();
    });

final bankReconciliationTimingRegisterServiceProvider =
    Provider<BankReconciliationTimingRegisterService>((ref) {
      return const BankReconciliationTimingRegisterService();
    });

final bankReconciliationProvider = Provider<BankReconciliation>((ref) {
  final period = ref.watch(selectedFinancialPeriodProvider);
  final service = ref.watch(bankReconciliationServiceProvider);

  return service.reconcile(
    statementLines: ref.watch(bankStatementLinesProvider),
    ledgerTransactions: ref.watch(combinedLedgerProvider),
    periodStart: period.startDate,
    periodEnd: period.endDate,
  );
});

final bankReconciliationResolutionProvider =
    Provider<BankReconciliationResolutionPlan>((ref) {
      final service = ref.watch(bankReconciliationResolutionServiceProvider);
      return service.build(ref.watch(bankReconciliationProvider));
    });

final bankReconciliationControlSummaryProvider =
    Provider<BankReconciliationControlSummary>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      final service = ref.watch(
        bankReconciliationControlSummaryServiceProvider,
      );
      return service.summarize(
        reconciliation: ref.watch(bankReconciliationProvider),
        resolutionPlan: ref.watch(bankReconciliationResolutionProvider),
        asOfDate: period.endDate ?? DateTime.now(),
      );
    });

final bankReconciliationTimingRegisterProvider =
    Provider<List<BankReconciliationTimingRegisterItem>>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      final service = ref.watch(
        bankReconciliationTimingRegisterServiceProvider,
      );
      return service.build(
        resolutionPlan: ref.watch(bankReconciliationResolutionProvider),
        asOfDate: period.endDate ?? DateTime.now(),
      );
    });

final bankReconciliationTimingReviewsProvider = StateNotifierProvider<
  BankReconciliationTimingReviewsNotifier,
  Map<String, BankReconciliationTimingReview>
>((ref) {
  return BankReconciliationTimingReviewsNotifier(
    repository: ref.watch(bankReconciliationTimingReviewRepositoryProvider),
    periodKey: ref.watch(bankReconciliationTimingReviewPeriodKeyProvider),
  );
});

final bankReconciliationTimingReviewPeriodKeyProvider = Provider<String>((ref) {
  final period = ref.watch(selectedFinancialPeriodProvider);
  return ref
      .watch(financialPeriodCloseServiceProvider)
      .periodKey(
        periodLabel: period.label,
        periodStart: period.startDate,
        periodEnd: period.endDate,
      );
});

final bankReconciliationJournalDraftSuggestionsProvider =
    Provider<List<BankReconciliationJournalDraftSuggestion>>((ref) {
      final service = ref.watch(bankReconciliationJournalDraftServiceProvider);
      return service.buildSuggestions(
        resolutionPlan: ref.watch(bankReconciliationResolutionProvider),
        chartOfAccounts: ref.watch(accountingChartProvider),
        existingPostings: ref.watch(postedLedgerProvider),
      );
    });

class BankStatementLineNotifier extends StateNotifier<List<BankStatementLine>> {
  final BankStatementRepository repository;
  var _isDisposed = false;

  BankStatementLineNotifier({required this.repository})
    : super(repository.loadLines()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableBankStatementRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadLines();
    }
  }

  void addLine(BankStatementLine line) {
    repository.appendLine(line);
    state = repository.loadLines();
  }

  void addLines(Iterable<BankStatementLine> lines) {
    repository.appendLines(lines);
    state = repository.loadLines();
  }

  void removeLine(String id) {
    repository.removeLine(id);
    state = repository.loadLines();
  }

  void clear() {
    repository.clear();
    state = repository.loadLines();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class BankReconciliationTimingReviewsNotifier
    extends StateNotifier<Map<String, BankReconciliationTimingReview>> {
  final BankReconciliationTimingReviewRepository repository;
  final String periodKey;
  var _isDisposed = false;

  BankReconciliationTimingReviewsNotifier({
    required this.repository,
    required this.periodKey,
  }) : super(repository.loadReviews(periodKey)) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableBankReconciliationTimingReviewRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadReviews(periodKey);
    }
  }

  void saveReview(BankReconciliationTimingReview review) {
    repository.saveReview(periodKey: periodKey, review: review);
    state = repository.loadReviews(periodKey);
  }

  void clearReview(String reference) {
    repository.removeReview(periodKey: periodKey, reference: reference);
    state = repository.loadReviews(periodKey);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
