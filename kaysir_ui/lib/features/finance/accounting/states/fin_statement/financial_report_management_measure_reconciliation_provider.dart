import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_management_measure.dart';
import '../../models/financial_report_pack.dart';
import 'financial_report_management_measure_provider.dart';
import 'financial_report_pack_provider.dart';

final currentFinancialReportManagementMeasureReconciliationsProvider =
    Provider<List<FinancialReportManagementMeasureReconciliation>>((ref) {
      final pack = ref.watch(financialReportPackProvider);

      return ref
          .watch(financialReportManagementMeasureServiceProvider)
          .reconcileAll(
            profitOrLoss: pack.statementFor(
              FinancialReportStatementKind.profitOrLossAndOci,
            ),
            measures: ref.watch(financialReportManagementMeasuresProvider),
          );
    });
