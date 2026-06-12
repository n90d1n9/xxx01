import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

class ReceivablePaymentBalancePanel extends StatelessWidget {
  const ReceivablePaymentBalancePanel({
    required this.invoiceReference,
    required this.customerLabel,
    required this.outstandingAmount,
    required this.currency,
    super.key,
  });

  final String invoiceReference;
  final String customerLabel;
  final double outstandingAmount;
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(
              icon: Icons.account_balance_wallet_outlined,
              size: 42,
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextCluster(
                eyebrow: invoiceReference,
                title: currency.format(outstandingAmount),
                subtitle: customerLabel,
                titleStyle: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Receivable',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceivablePaymentMethodField extends StatelessWidget {
  const ReceivablePaymentMethodField({
    required this.method,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String method;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      label: 'Payment Method',
      value: method,
      icon: Icons.payments_outlined,
      enabled: enabled,
      options: const [
        AppSelectOption(value: 'bank_transfer', label: 'Bank Transfer'),
        AppSelectOption(value: 'credit_card', label: 'Credit Card'),
        AppSelectOption(value: 'cash', label: 'Cash'),
        AppSelectOption(value: 'check', label: 'Check'),
        AppSelectOption(value: 'other', label: 'Other'),
      ],
      onChanged: onChanged,
    );
  }
}

class ReceivablePaymentDateField extends StatelessWidget {
  const ReceivablePaymentDateField({
    required this.paymentDate,
    required this.onTap,
    super.key,
  });

  final DateTime paymentDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: DateFormat('MM/dd/yyyy').format(paymentDate),
      subtitle: 'Payment Date',
      icon: Icons.event_available_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      onTap: onTap,
      trailing: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
