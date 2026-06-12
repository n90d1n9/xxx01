import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/ess_history_models.dart';
import '../ess/ess_formatters.dart';

class PayHistorySummaryGrid extends StatelessWidget {
  final PayHistorySummary summary;

  const PayHistorySummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Pay stubs',
          value: '${summary.stubCount}',
          detail:
              summary.latestPayDate == null
                  ? 'No pay date yet'
                  : 'Latest ${DateFormat('MMM d').format(summary.latestPayDate!)}',
          icon: Icons.receipt_long_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'Gross pay',
          value: essCurrencyFormat.format(summary.totalGrossPay),
          detail: 'Before deductions',
          icon: Icons.trending_up_outlined,
          color: const Color(0xFF15803D),
        ),
        HrisSummaryMetric(
          title: 'Net pay',
          value: essCurrencyFormat.format(summary.totalNetPay),
          detail: '${essCurrencyFormat.format(summary.averageNetPay)} average',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Deductions',
          value: essCurrencyFormat.format(summary.totalDeductions),
          detail: 'Taxes, benefits, retirement',
          icon: Icons.remove_circle_outline,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
