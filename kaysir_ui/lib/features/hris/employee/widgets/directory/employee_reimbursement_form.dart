import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_reimbursement_models.dart';

class EmployeeExpenseClaimForm extends StatelessWidget {
  final EmployeeExpenseDraft draft;
  final TextEditingController merchantController;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final ValueChanged<EmployeeExpenseCategory> onCategoryChanged;
  final ValueChanged<String> onMerchantChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<bool> onReceiptChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSubmit;

  const EmployeeExpenseClaimForm({
    super.key,
    required this.draft,
    required this.merchantController,
    required this.amountController,
    required this.descriptionController,
    required this.onCategoryChanged,
    required this.onMerchantChanged,
    required this.onAmountChanged,
    required this.onDescriptionChanged,
    required this.onReceiptChanged,
    required this.onSelectDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeExpenseCategory>(
            initialValue: draft.category,
            decoration: const InputDecoration(
              labelText: 'Expense category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items:
                EmployeeExpenseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ExpenseTextField(
                  controller: amountController,
                  label: 'Amount',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExpenseDateField(
                  date: draft.incurredOn,
                  onTap: onSelectDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ExpenseTextField(
            controller: merchantController,
            label: 'Merchant',
            icon: Icons.storefront_outlined,
            onChanged: onMerchantChanged,
          ),
          const SizedBox(height: 12),
          _ExpenseTextField(
            controller: descriptionController,
            label: 'Description',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt attached',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.receiptAttached
                          ? 'Claim can move straight to approval.'
                          : 'Claim will need receipt follow-up.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: draft.receiptAttached,
                onChanged: onReceiptChanged,
              ),
            ],
          ),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add claim'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _ExpenseDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Incurred',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ExpenseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int minLines;

  const _ExpenseTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
