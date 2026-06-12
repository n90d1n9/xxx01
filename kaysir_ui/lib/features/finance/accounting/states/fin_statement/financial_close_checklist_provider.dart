import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_close_checklist.dart';
import '../../services/financial_close_checklist_service.dart';
import '../accounting_core_provider.dart';
import '../bank_reconciliation_provider.dart';
import '../gl/ledger_provider.dart';
import '../payable_reconciliation_provider.dart';
import '../receivable_reconciliation_provider.dart';
import 'financial_provider.dart';
import 'period_closing_entry_provider.dart';
import 'financial_report_disclosure_review_provider.dart';
import 'financial_report_evidence_task_resolution_provider.dart';
import 'financial_report_exception_resolution_provider.dart';
import 'financial_report_pack_provider.dart';

final financialCloseChecklistServiceProvider =
    Provider<FinancialCloseChecklistService>((ref) {
      return const FinancialCloseChecklistService();
    });

final financialCloseChecklistProvider = Provider<FinancialCloseChecklist>((
  ref,
) {
  final period = ref.watch(selectedFinancialPeriodProvider);
  final pack = ref.watch(financialReportPackProvider);
  final ledgerTransactions = ref.watch(combinedLedgerProvider);
  final closingEntryPosted = ref.watch(currentPeriodClosingEntryPostedProvider);
  final exceptionResolutions = ref.watch(
    currentFinancialReportExceptionResolutionsProvider,
  );
  final evidenceTaskResolutions = ref.watch(
    currentFinancialReportEvidenceTaskResolutionsProvider,
  );
  final disclosureReviewItems = ref.watch(
    currentFinancialReportDisclosureReviewItemsProvider,
  );
  final service = ref.watch(financialCloseChecklistServiceProvider);

  return service.build(
    pack: pack,
    ledgerTransactions: ledgerTransactions,
    closingEntryPosted: closingEntryPosted,
    exceptionResolutions: exceptionResolutions,
    evidenceTaskResolutions: evidenceTaskResolutions,
    disclosureReviewItems: disclosureReviewItems,
    postedAdjustmentJournals: ref.watch(postedLedgerProvider),
    bankReconciliation: ref.watch(bankReconciliationProvider),
    bankReconciliationControlSummary: ref.watch(
      bankReconciliationControlSummaryProvider,
    ),
    bankTimingRegister: ref.watch(bankReconciliationTimingRegisterProvider),
    bankTimingReviews: ref.watch(bankReconciliationTimingReviewsProvider),
    receivableReconciliation: ref.watch(receivableReconciliationProvider),
    payableReconciliation: ref.watch(payableReconciliationProvider),
    periodStart: period.startDate,
    periodEnd: period.endDate,
  );
});
