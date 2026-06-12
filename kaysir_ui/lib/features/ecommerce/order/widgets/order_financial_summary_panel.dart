import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/utils/pos_formatters.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_financial_summary.dart';

class OrderFinancialSummaryPanel extends StatelessWidget {
  final pos_order.Order order;

  const OrderFinancialSummaryPanel({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = OrderFinancialSummary.fromOrder(order);

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              POSIconBadge(
                icon: Icons.account_balance_wallet_outlined,
                size: 30,
                iconSize: 17,
                backgroundColor: _statusColor(
                  theme,
                  summary,
                ).withValues(alpha: 0.14),
                foregroundColor: _statusColor(theme, summary),
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment summary',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.paymentCountLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(summary: summary),
            ],
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ...summary.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _FinancialLineRow(line: line),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ThemeData theme, OrderFinancialSummary summary) {
    if (summary.hasOverpayment) return theme.colorScheme.tertiary;
    if (summary.hasBalanceDue) return theme.colorScheme.error;
    return theme.colorScheme.primary;
  }
}

class _StatusPill extends StatelessWidget {
  final OrderFinancialSummary summary;

  const _StatusPill({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        summary.hasBalanceDue
            ? theme.colorScheme.error
            : summary.hasOverpayment
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        summary.statusLabel,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FinancialLineRow extends StatelessWidget {
  final OrderFinancialLine line;

  const _FinancialLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      fontWeight: line.isEmphasized ? FontWeight.w900 : FontWeight.w600,
      color:
          line.isEmphasized
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Expanded(child: Text(line.label, style: style)),
        Text(_formatAmount(line), style: style),
      ],
    );
  }

  String _formatAmount(OrderFinancialLine line) {
    final amount = formatPOSCurrency(line.amount);
    return line.isDeduction ? '-$amount' : amount;
  }
}
