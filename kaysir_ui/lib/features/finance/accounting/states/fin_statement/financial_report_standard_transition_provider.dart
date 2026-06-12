import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_standard_transition.dart';
import '../../services/financial_report_standard_transition_service.dart';
import '../accounting_policy_provider.dart';
import 'financial_report_pack_provider.dart';

final financialReportStandardTransitionServiceProvider =
    Provider<FinancialReportStandardTransitionService>((ref) {
      return const FinancialReportStandardTransitionService();
    });

final currentFinancialReportStandardTransitionProvider =
    Provider<FinancialReportStandardTransitionSummary>((ref) {
      return ref
          .watch(financialReportStandardTransitionServiceProvider)
          .summarize(
            pack: ref.watch(financialReportPackProvider),
            policy: ref.watch(accountingPolicyProvider),
            asOf: DateTime.now(),
          );
    });
