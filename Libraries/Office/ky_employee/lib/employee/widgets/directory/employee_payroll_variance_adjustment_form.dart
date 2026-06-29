import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_variance_models.dart';

class EmployeePayrollVarianceAdjustmentForm extends StatelessWidget {
  final EmployeePayrollVarianceAdjustmentDraft draft;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController ownerController;
  final TextEditingController reasonController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<bool> onTaxableImpactChanged;
  final VoidCallback onAdd;

  const EmployeePayrollVarianceAdjustmentForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.amountController,
    required this.ownerController,
    required this.reasonController,
    required this.onTitleChanged,
    required this.onAmountChanged,
    required this.onOwnerChanged,
    required this.onReasonChanged,
    required this.onTaxableImpactChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual variance adjustment',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Adjustment title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tune_outlined),
                  ),
                  onChanged: onTitleChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money_outlined),
                    suffixText: draft.currencyCode,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(
                      value.replaceAll(',', '').trim(),
                    );
                    if (parsed == null) return;
                    onAmountChanged(parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Adjustment reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onReasonChanged,
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onTaxableImpactChanged(!draft.taxableImpact),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: draft.taxableImpact,
                    onChanged:
                        (value) => onTaxableImpactChanged(value ?? false),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Taxable payroll impact',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
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
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('Add adjustment'),
            ),
          ),
        ],
      ),
    );
  }
}
