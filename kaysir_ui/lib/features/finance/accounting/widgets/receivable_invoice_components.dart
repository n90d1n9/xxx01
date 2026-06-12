import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/customer.dart';

class ReceivableInvoiceCustomerField extends StatelessWidget {
  const ReceivableInvoiceCustomerField({
    required this.customers,
    required this.selectedCustomerId,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<Customer> customers;
  final String selectedCustomerId;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<String>(
      label: 'Customer',
      value: selectedCustomerId,
      icon: Icons.person_search_outlined,
      enabled: enabled,
      menuMaxHeight: 280,
      options: [
        for (final customer in customers)
          AppSelectOption(value: customer.id, label: customer.name),
      ],
      onChanged: onChanged,
    );
  }
}

class ReceivableInvoiceDetailsFields extends StatelessWidget {
  const ReceivableInvoiceDetailsFields({
    required this.referenceController,
    required this.amountController,
    required this.enabled,
    super.key,
  });

  final TextEditingController referenceController;
  final TextEditingController amountController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final referenceField = TextFormField(
          controller: referenceController,
          enabled: enabled,
          decoration: _invoiceInputDecoration(
            context,
            label: 'Invoice Reference',
            icon: Icons.tag_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an invoice reference';
            }
            return null;
          },
        );
        final amountField = TextFormField(
          controller: amountController,
          enabled: enabled,
          decoration: _invoiceInputDecoration(
            context,
            label: 'Amount',
            icon: Icons.attach_money_rounded,
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null) {
              return 'Please enter a valid number';
            }
            if (amount <= 0) {
              return 'Amount must be greater than zero';
            }
            return null;
          },
        );

        if (constraints.maxWidth < 540) {
          return Column(
            children: [referenceField, const SizedBox(height: 12), amountField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: referenceField),
            const SizedBox(width: 12),
            Expanded(child: amountField),
          ],
        );
      },
    );
  }
}

class ReceivableInvoiceDateField extends StatelessWidget {
  const ReceivableInvoiceDateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.icon = Icons.event_outlined,
    super.key,
  });

  final String label;
  final DateTime date;
  final VoidCallback? onTap;
  final IconData icon;

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
                icon: icon,
                size: 36,
                iconSize: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextCluster(
                  eyebrow: label,
                  title: DateFormat('MM/dd/yyyy').format(date),
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

class ReceivableInvoiceDateFields extends StatelessWidget {
  const ReceivableInvoiceDateFields({
    required this.issueDate,
    required this.dueDate,
    required this.onPickIssueDate,
    required this.onPickDueDate,
    required this.enabled,
    super.key,
  });

  final DateTime issueDate;
  final DateTime dueDate;
  final VoidCallback onPickIssueDate;
  final VoidCallback onPickDueDate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final issueDateField = ReceivableInvoiceDateField(
          label: 'Issue Date',
          date: issueDate,
          icon: Icons.event_available_outlined,
          onTap: enabled ? onPickIssueDate : null,
        );
        final dueDateField = ReceivableInvoiceDateField(
          label: 'Due Date',
          date: dueDate,
          icon: Icons.event_repeat_outlined,
          onTap: enabled ? onPickDueDate : null,
        );

        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              issueDateField,
              const SizedBox(height: 12),
              dueDateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: issueDateField),
            const SizedBox(width: 12),
            Expanded(child: dueDateField),
          ],
        );
      },
    );
  }
}

class ReceivableInvoicePreviewPanel extends StatelessWidget {
  const ReceivableInvoicePreviewPanel({
    required this.customerName,
    required this.reference,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.currency,
    super.key,
  });

  final String customerName;
  final String reference;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final termDays = dueDate.difference(issueDate).inDays;
    final termLabel = termDays <= 0 ? 'Due on receipt' : 'Net $termDays days';

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
                  icon: Icons.request_quote_outlined,
                  size: 36,
                  iconSize: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextCluster(
                    eyebrow: reference.isEmpty ? 'Draft invoice' : reference,
                    title: 'Receivable Preview',
                    titleGap: 0,
                    titleStyle: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                    eyebrowStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
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
            AppInfoRow(
              title: customerName,
              subtitle: 'Customer',
              icon: Icons.account_circle_outlined,
              iconStyle: AppInfoRowIconStyle.badge,
              iconBoxSize: 34,
              iconSize: 17,
              contained: true,
            ),
            const SizedBox(height: 8),
            AppInfoRow(
              title: termLabel,
              subtitle: 'Payment Terms',
              icon: Icons.schedule_outlined,
              iconStyle: AppInfoRowIconStyle.badge,
              iconBoxSize: 34,
              iconSize: 17,
              contained: true,
              trailing: Text(
                DateFormat('MM/dd/yyyy').format(dueDate),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _invoiceInputDecoration(
  BuildContext context, {
  required String label,
  IconData? icon,
  String? prefixText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon, size: 18),
    prefixText: prefixText,
    filled: true,
    fillColor: colorScheme.surface,
    border: border,
    enabledBorder: border,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
