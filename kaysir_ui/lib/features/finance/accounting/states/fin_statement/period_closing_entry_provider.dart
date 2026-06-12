import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../accounting_core/models/ledger_posting.dart';
import '../../models/period_closing_entry.dart';
import '../../services/period_closing_entry_posting_service.dart';
import '../../services/period_closing_entry_service.dart';
import '../accounting_core_provider.dart';
import '../financial_period_posting_guard_provider.dart';
import '../gl/ledger_provider.dart';
import 'financial_provider.dart';

final periodClosingEntryServiceProvider = Provider<PeriodClosingEntryService>((
  ref,
) {
  return const PeriodClosingEntryService();
});

final periodClosingEntryPostingServiceProvider =
    Provider<PeriodClosingEntryPostingService>((ref) {
      return PeriodClosingEntryPostingService(
        postingService: ref.watch(ledgerPostingServiceProvider),
        postingGuardService: ref.watch(
          financialPeriodPostingGuardServiceProvider,
        ),
      );
    });

final currentPeriodClosingEntryPreviewProvider =
    Provider<PeriodClosingEntryPreview>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      final ledger = ref.watch(combinedLedgerProvider);
      final service = ref.watch(periodClosingEntryServiceProvider);
      final latestLedgerDate =
          ledger.isEmpty
              ? DateTime.now()
              : ledger
                  .map((transaction) => transaction.date)
                  .reduce((a, b) => a.isAfter(b) ? a : b);

      return service.preview(
        periodLabel: period.label,
        closingDate: period.endDate ?? latestLedgerDate,
        transactions: ledger,
        chartOfAccounts: ref.watch(accountingChartProvider),
        periodStart: period.startDate,
        periodEnd: period.endDate,
      );
    });

final currentPeriodClosingEntryPostingProvider = Provider<LedgerPosting?>((
  ref,
) {
  final preview = ref.watch(currentPeriodClosingEntryPreviewProvider);
  final draft = preview.draft;
  if (draft == null) {
    return null;
  }

  final service = ref.watch(periodClosingEntryPostingServiceProvider);
  return service.postedClosingEntryFor(
    draft: draft,
    postings: ref.watch(postedLedgerProvider),
  );
});

final currentPeriodClosingEntryPostedProvider = Provider<bool>((ref) {
  return ref.watch(currentPeriodClosingEntryPostingProvider) != null;
});
