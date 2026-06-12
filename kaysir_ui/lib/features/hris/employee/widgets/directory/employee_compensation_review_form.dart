import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compensation_models.dart';
import 'employee_compensation_tiles.dart';

class EmployeeCompensationDraftForm extends StatelessWidget {
  final EmployeeCompensationReviewDraft draft;
  final TextEditingController salaryController;
  final TextEditingController justificationController;
  final ValueChanged<EmployeeCompensationReviewType> onTypeChanged;
  final ValueChanged<String> onSalaryChanged;
  final ValueChanged<String> onJustificationChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSubmit;

  const EmployeeCompensationDraftForm({
    super.key,
    required this.draft,
    required this.salaryController,
    required this.justificationController,
    required this.onTypeChanged,
    required this.onSalaryChanged,
    required this.onJustificationChanged,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeCompensationReviewType>(
              segments:
                  EmployeeCompensationReviewType.values
                      .map(
                        (type) =>
                            ButtonSegment(value: type, label: Text(type.label)),
                      )
                      .toList(),
              selected: {draft.reviewType},
              onSelectionChanged:
                  (selection) => onTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: salaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Proposed base salary',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.price_change_outlined),
              prefixText: '${draft.package.currencyCode} ',
            ),
            onChanged: onSalaryChanged,
          ),
          const SizedBox(height: 12),
          _EffectiveDateField(draft: draft, onTap: onSelectDate),
          const SizedBox(height: 12),
          TextField(
            controller: justificationController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Justification',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onJustificationChanged,
          ),
          const SizedBox(height: 12),
          EmployeeCompensationImpactPreview(
            impact: draft.impact,
            currencyCode: draft.package.currencyCode,
          ),
          const SizedBox(height: 12),
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
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectiveDateField extends StatelessWidget {
  final EmployeeCompensationReviewDraft draft;
  final VoidCallback onTap;

  const _EffectiveDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          draft.effectiveDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.effectiveDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                draft.effectiveDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
