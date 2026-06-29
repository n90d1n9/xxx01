import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/employee/models/employee_self_service_summary.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import 'ess_formatters.dart';

class EssSummaryGrid extends StatelessWidget {
  final EmployeeSelfServiceSummary summary;

  const EssSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Latest net pay',
          value: essCurrencyFormat.format(summary.latestNetPay),
          detail: '${summary.payStubCount} pay stubs',
          icon: Icons.receipt_long_outlined,
          color: const Color(0xFF059669),
        ),
        HrisSummaryMetric(
          title: 'YTD net pay',
          value: essCurrencyFormat.format(summary.totalNetPay),
          detail: 'available stubs',
          icon: Icons.payments_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Time off',
          value: '${summary.approvedTimeOffDays}',
          detail: 'approved days',
          icon: Icons.event_available_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Pending',
          value: '${summary.pendingTimeOffCount}',
          detail: 'time-off requests',
          icon: Icons.pending_actions_outlined,
          color: const Color(0xFFD97706),
        ),
      ],
    );
  }
}
