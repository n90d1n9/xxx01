import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

class PayableBillDateField extends StatelessWidget {
  const PayableBillDateField({
    required this.label,
    required this.date,
    required this.onTap,
    super.key,
  });

  final String label;
  final DateTime date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: colorScheme.outlineVariant),
    );

    return Material(
      color: colorScheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              AppIconBadge(
                icon: Icons.event_outlined,
                size: 36,
                iconSize: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextCluster(
                  title: DateFormat('MM/dd/yyyy').format(date),
                  eyebrow: label,
                  titleGap: 0,
                  titleStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                  eyebrowStyle: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PayableBillJournalPreview extends StatelessWidget {
  const PayableBillJournalPreview({
    required this.debitAccountName,
    required this.creditAccountName,
    required this.amount,
    required this.currency,
    super.key,
  });

  final String debitAccountName;
  final String creditAccountName;
  final double amount;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppIconBadge(
                  icon: Icons.account_tree_outlined,
                  size: 36,
                  iconSize: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Journal Preview',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  currency.format(amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _JournalPreviewEntry(
              label: 'Debit',
              accountName: debitAccountName,
              amount: currency.format(amount),
              icon: Icons.trending_up_rounded,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _JournalPreviewEntry(
              label: 'Credit',
              accountName: creditAccountName,
              amount: currency.format(amount),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalPreviewEntry extends StatelessWidget {
  const _JournalPreviewEntry({
    required this.label,
    required this.accountName,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final String accountName;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: accountName,
      subtitle: label,
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBoxSize: 34,
      iconSize: 17,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      trailing: Text(
        amount,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
