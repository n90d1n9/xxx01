import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

class PayablePaymentBalancePanel extends StatelessWidget {
  const PayablePaymentBalancePanel({
    required this.billReference,
    required this.vendorName,
    required this.outstandingAmount,
    required this.currency,
    super.key,
  });

  final String billReference;
  final String vendorName;
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
              icon: Icons.receipt_long_outlined,
              size: 42,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextCluster(
                eyebrow: billReference,
                title: currency.format(outstandingAmount),
                subtitle: vendorName,
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
              'Outstanding',
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

class PayablePaymentMethodField extends StatelessWidget {
  const PayablePaymentMethodField({
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
      icon: Icons.account_balance_outlined,
      enabled: enabled,
      options: const [
        AppSelectOption(value: 'bank_transfer', label: 'Bank Transfer'),
        AppSelectOption(value: 'cash', label: 'Cash'),
        AppSelectOption(value: 'check', label: 'Check'),
        AppSelectOption(value: 'card', label: 'Card'),
        AppSelectOption(value: 'other', label: 'Other'),
      ],
      onChanged: onChanged,
    );
  }
}

class PayablePaymentDateField extends StatelessWidget {
  const PayablePaymentDateField({
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
