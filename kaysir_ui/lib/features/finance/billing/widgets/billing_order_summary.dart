import 'package:flutter/material.dart';

import '../models/billing_tenant_preferences.dart';
import '../utils/billing_cart_summary.dart';
import '../utils/billing_formatters.dart';

class BillingOrderSummary extends StatelessWidget {
  final BillingCartSummary summary;
  final BillingTenantPreferences preferences;
  final String title;
  final bool compact;

  const BillingOrderSummary({
    super.key,
    required this.summary,
    this.preferences = const BillingTenantPreferences(),
    this.title = 'Order Summary',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _SummaryRowData(label: 'Subtotal', amount: summary.subtotal),
      if (summary.discount > 0)
        _SummaryRowData(label: 'Discount', amount: -summary.discount),
      if (summary.tax > 0) _SummaryRowData(label: 'Tax', amount: summary.tax),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SummaryRow(row: row, preferences: preferences),
          ),
        ),
        if (rows.isNotEmpty && !compact) const Divider(height: 18),
        _SummaryRow(
          row: _SummaryRowData(label: 'Total', amount: summary.total),
          preferences: preferences,
          emphasized: true,
        ),
      ],
    );
  }
}

class _SummaryRowData {
  final String label;
  final double amount;

  const _SummaryRowData({required this.label, required this.amount});
}

class _SummaryRow extends StatelessWidget {
  final _SummaryRowData row;
  final BillingTenantPreferences preferences;
  final bool emphasized;

  const _SummaryRow({
    required this.row,
    required this.preferences,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = row.amount < 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          row.label,
          style: TextStyle(
            color:
                emphasized ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontSize: emphasized ? 16 : 14,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${formatBillingCurrency(row.amount.abs(), preferences: preferences)}',
          style: TextStyle(
            color:
                isNegative
                    ? const Color(0xFF16A34A)
                    : emphasized
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF334155),
            fontSize: emphasized ? 18 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
