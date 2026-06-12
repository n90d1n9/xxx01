import 'package:flutter/material.dart';

import '../models/billing_dashboard_metric.dart';

class BillingDashboardStatCard extends StatelessWidget {
  final BillingDashboardMetric metric;
  final double? width;

  const BillingDashboardStatCard({super.key, required this.metric, this.width});

  @override
  Widget build(BuildContext context) {
    final color = billingDashboardMetricColor(metric.kind);
    final icon = billingDashboardMetricIcon(metric.kind);

    return Container(
      width: width ?? 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            metric.title,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

Color billingDashboardMetricColor(BillingDashboardMetricKind kind) {
  switch (kind) {
    case BillingDashboardMetricKind.totalBilled:
      return const Color(0xFF10B981);
    case BillingDashboardMetricKind.pending:
      return const Color(0xFFF59E0B);
    case BillingDashboardMetricKind.overdue:
      return const Color(0xFFEF4444);
    case BillingDashboardMetricKind.nextBilling:
      return const Color(0xFF6366F1);
  }
}

IconData billingDashboardMetricIcon(BillingDashboardMetricKind kind) {
  switch (kind) {
    case BillingDashboardMetricKind.totalBilled:
      return Icons.account_balance_wallet_outlined;
    case BillingDashboardMetricKind.pending:
      return Icons.pending_actions_outlined;
    case BillingDashboardMetricKind.overdue:
      return Icons.warning_amber_outlined;
    case BillingDashboardMetricKind.nextBilling:
      return Icons.event_outlined;
  }
}
