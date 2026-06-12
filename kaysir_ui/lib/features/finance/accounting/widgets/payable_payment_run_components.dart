import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../models/invoice.dart';
import '../models/payable_payment_run.dart';

class PaymentRunSummaryPanel extends StatelessWidget {
  final PayablePaymentRunPlan plan;
  final NumberFormat currency;

  const PaymentRunSummaryPanel({
    required this.plan,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.payments_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryMetric(
                label: 'Selected',
                value: plan.billCount.toString(),
              ),
            ),
            _SummaryMetric(
              label: 'Cash Required',
              value: currency.format(plan.totalAmount),
              alignEnd: true,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentRunControls extends StatelessWidget {
  final TextEditingController referenceController;
  final DateTime paymentDate;
  final String method;
  final bool isPosting;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onPickDate;

  const PaymentRunControls({
    required this.referenceController,
    required this.paymentDate,
    required this.method,
    required this.isPosting,
    required this.onMethodChanged,
    required this.onPickDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final referenceField = TextFormField(
          controller: referenceController,
          enabled: !isPosting,
          decoration: InputDecoration(
            labelText: 'Payment Reference',
            prefixIcon: const Icon(Icons.tag_outlined, size: 18),
            filled: true,
            fillColor: colorScheme.surface,
            border: const OutlineInputBorder(),
          ),
        );
        final methodField = AppSelectField<String>(
          label: 'Method',
          value: method,
          icon: Icons.account_balance_outlined,
          enabled: !isPosting,
          options: const [
            AppSelectOption(value: 'bank_transfer', label: 'Bank'),
            AppSelectOption(value: 'cash', label: 'Cash'),
            AppSelectOption(value: 'check', label: 'Check'),
            AppSelectOption(value: 'card', label: 'Card'),
            AppSelectOption(value: 'other', label: 'Other'),
          ],
          onChanged: onMethodChanged,
        );
        final dateField = InkWell(
          onTap: isPosting ? null : onPickDate,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Payment Date',
              prefixIcon: const Icon(Icons.event_outlined, size: 18),
              filled: true,
              fillColor: colorScheme.surface,
              border: const OutlineInputBorder(),
            ),
            child: Text(DateFormat('MM/dd/yyyy').format(paymentDate)),
          ),
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              referenceField,
              const SizedBox(height: 12),
              methodField,
              const SizedBox(height: 12),
              dateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: referenceField),
            const SizedBox(width: 12),
            Expanded(child: methodField),
            const SizedBox(width: 12),
            Expanded(child: dateField),
          ],
        );
      },
    );
  }
}

class PaymentRunQuickSelectBar extends StatelessWidget {
  const PaymentRunQuickSelectBar({
    required this.hasOpenBills,
    required this.hasSelection,
    required this.isPosting,
    required this.onDueNow,
    required this.onNextSevenDays,
    required this.onAllOpen,
    required this.onClear,
    super.key,
  });

  final bool hasOpenBills;
  final bool hasSelection;
  final bool isPosting;
  final VoidCallback onDueNow;
  final VoidCallback onNextSevenDays;
  final VoidCallback onAllOpen;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final canPick = hasOpenBills && !isPosting;
    final canClear = hasSelection && !isPosting;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppActionButton(
          label: 'Due Now',
          icon: Icons.priority_high_outlined,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          height: 36,
          onPressed: canPick ? onDueNow : null,
        ),
        AppActionButton(
          label: 'Next 7 Days',
          icon: Icons.calendar_view_week_outlined,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          height: 36,
          onPressed: canPick ? onNextSevenDays : null,
        ),
        AppActionButton(
          label: 'All Open',
          icon: Icons.done_all_outlined,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          height: 36,
          onPressed: canPick ? onAllOpen : null,
        ),
        AppActionButton(
          label: 'Clear',
          icon: Icons.clear_rounded,
          variant: AppActionButtonVariant.text,
          compact: true,
          height: 36,
          onPressed: canClear ? onClear : null,
        ),
      ],
    );
  }
}

class PaymentRunBillPickerPanel extends StatelessWidget {
  const PaymentRunBillPickerPanel({
    required this.bills,
    required this.selectedBillIds,
    required this.currency,
    required this.isPosting,
    required this.onBillSelectionChanged,
    super.key,
  });

  final List<Invoice> bills;
  final Set<String> selectedBillIds;
  final NumberFormat currency;
  final bool isPosting;
  final void Function(String billId, bool isSelected) onBillSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          bills.isEmpty
              ? const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No open payable bills',
                message: 'Fully paid bills stay out of the payment run.',
              )
              : ListView.separated(
                itemCount: bills.length,
                separatorBuilder:
                    (context, _) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return PaymentRunBillTile(
                    bill: bill,
                    currency: currency,
                    isSelected: selectedBillIds.contains(bill.id),
                    onChanged:
                        isPosting
                            ? null
                            : (isSelected) => onBillSelectionChanged(
                              bill.id,
                              isSelected ?? false,
                            ),
                  );
                },
              ),
    );
  }
}

class PaymentRunBillTile extends StatelessWidget {
  final Invoice bill;
  final NumberFormat currency;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const PaymentRunBillTile({
    required this.bill,
    required this.currency,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = bill.dueDate;
    final billReference = bill.invoiceNumber ?? bill.id;

    return AppCheckboxRow(
      title: billReference,
      subtitle: [
        bill.vendorName ?? 'Unknown Vendor',
        if (dueDate != null) DateFormat('MMM d, yyyy').format(dueDate),
      ].join(' - '),
      value: isSelected,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      trailing: Text(
        currency.format(bill.remainingAmount),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _SummaryMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
