import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_pack.dart';
import '../../models/financial_report_tax_profile.dart';
import '../../services/financial_report_pack_service.dart';
import '../accounting_policy_provider.dart';
import '../bank_reconciliation_provider.dart';
import 'financial_provider.dart';
import 'financial_report_management_measure_provider.dart';

final selectedFinancialReportTaxProfileProvider =
    StateProvider<FinancialReportTaxProfile>(
      (ref) => FinancialReportTaxProfiles.standardCorporate,
    );

final financialReportPackServiceProvider = Provider<FinancialReportPackService>(
  (ref) {
    return FinancialReportPackService(
      taxProfile: ref.watch(selectedFinancialReportTaxProfileProvider),
      accountingPolicy: ref.watch(accountingPolicyProvider),
    );
  },
);

final financialReportPackProvider = Provider<FinancialReportPack>((ref) {
  final controller = ref.watch(financialStatementsControllerProvider);
  final service = ref.watch(financialReportPackServiceProvider);

  return service.build(
    entries: controller.allEntries,
    periodStart: controller.period.startDate,
    periodEnd: controller.period.endDate,
    periodLabel: controller.periodLabel,
    asOfLabel: controller.period.asOfLabel,
    bankReconciliation: ref.watch(bankReconciliationProvider),
    bankReconciliationControlSummary: ref.watch(
      bankReconciliationControlSummaryProvider,
    ),
    bankTimingRegister: ref.watch(bankReconciliationTimingRegisterProvider),
    bankTimingReviews: ref.watch(bankReconciliationTimingReviewsProvider),
    managementMeasures: ref.watch(financialReportManagementMeasuresProvider),
  );
});
