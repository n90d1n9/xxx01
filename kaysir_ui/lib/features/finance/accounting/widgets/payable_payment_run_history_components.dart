import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/payable_payment_run.dart';

class PaymentRunHistoryRecordCard extends StatelessWidget {
  const PaymentRunHistoryRecordCard({
    super.key,
    required this.record,
    required this.currency,
  });

  final PayablePaymentRunRecord record;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final methodStyle = _methodStyle(context, record.method);

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: _PaymentRunLeadingIcon(color: methodStyle.color),
          title: Text(
            record.reference,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Paid ${dateFormat.format(record.paymentDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppStatusPill(
                  label: methodStyle.label,
                  color: methodStyle.color,
                  icon: methodStyle.icon,
                  maxWidth: 150,
                ),
              ],
            ),
          ),
          trailing: _PaymentRunAmountSummary(
            amount: currency.format(record.totalAmount),
            billCount: _billCountLabel(record.billCount),
          ),
          children: [
            const SizedBox(height: 4),
            PaymentRunHistoryItemList(record: record, currency: currency),
          ],
        ),
      ),
    );
  }
}

class PaymentRunHistoryItemList extends StatelessWidget {
  const PaymentRunHistoryItemList({
    super.key,
    required this.record,
    required this.currency,
  });

  final PayablePaymentRunRecord record;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    if (record.items.isEmpty) {
      return const AppInfoRow(
        contained: true,
        icon: Icons.receipt_long_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        title: 'No bill items captured',
        subtitle: 'This payment run was posted without itemized bill lines.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < record.items.length; index++) ...[
          _PaymentRunHistoryItemRow(
            item: record.items[index],
            currency: currency,
          ),
          if (index != record.items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _PaymentRunHistoryItemRow extends StatelessWidget {
  const _PaymentRunHistoryItemRow({required this.item, required this.currency});

  final PayablePaymentRunRecordItem item;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppInfoRow(
      contained: true,
      icon: Icons.receipt_long_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: colorScheme.secondaryContainer,
      iconForegroundColor: colorScheme.onSecondaryContainer,
      title: item.billReference,
      subtitle: _itemSubtitle(item),
      subtitleMaxLines: 2,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 124),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            currency.format(item.amount),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  String _itemSubtitle(PayablePaymentRunRecordItem item) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final details = <String>[
      item.vendorName,
      if (item.dueDate != null) 'Due ${dateFormat.format(item.dueDate!)}',
      if (item.paymentId.isNotEmpty) 'Payment ${item.paymentId}',
    ];

    return details.join(' - ');
  }
}

class _PaymentRunAmountSummary extends StatelessWidget {
  const _PaymentRunAmountSummary({
    required this.amount,
    required this.billCount,
  });

  final String amount;
  final String billCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              amount,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            billCount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRunLeadingIcon extends StatelessWidget {
  const _PaymentRunLeadingIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(Icons.payments_outlined, color: color, size: 20),
      ),
    );
  }
}

class _PaymentRunMethodStyle {
  const _PaymentRunMethodStyle({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_PaymentRunMethodStyle _methodStyle(BuildContext context, String method) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (method) {
    case 'bank_transfer':
      return _PaymentRunMethodStyle(
        label: 'Bank transfer',
        icon: Icons.account_balance_outlined,
        color: colorScheme.primary,
      );
    case 'cash':
      return _PaymentRunMethodStyle(
        label: 'Cash',
        icon: Icons.payments_outlined,
        color: Colors.green.shade700,
      );
    case 'check':
      return _PaymentRunMethodStyle(
        label: 'Check',
        icon: Icons.fact_check_outlined,
        color: Colors.orange.shade700,
      );
    case 'card':
      return _PaymentRunMethodStyle(
        label: 'Card',
        icon: Icons.credit_card_outlined,
        color: Colors.indigo.shade600,
      );
    default:
      return _PaymentRunMethodStyle(
        label: 'Other',
        icon: Icons.more_horiz_rounded,
        color: colorScheme.onSurfaceVariant,
      );
  }
}

String _billCountLabel(int count) {
  return count == 1 ? '1 bill' : '$count bills';
}
