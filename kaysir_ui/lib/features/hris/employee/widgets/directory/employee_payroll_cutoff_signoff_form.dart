import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_cutoff_models.dart';

class EmployeePayrollCutoffSignoffForm extends StatelessWidget {
  final EmployeePayrollCutoffSignoffDraft draft;
  final TextEditingController reviewerController;
  final TextEditingController noteController;
  final int blockerCount;
  final int warningCount;
  final bool canSignOff;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<bool> onAcceptWarningsChanged;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSubmit;

  const EmployeePayrollCutoffSignoffForm({
    super.key,
    required this.draft,
    required this.reviewerController,
    required this.noteController,
    required this.blockerCount,
    required this.warningCount,
    required this.canSignOff,
    required this.onReviewerChanged,
    required this.onNoteChanged,
    required this.onAcceptWarningsChanged,
    required this.onSelectReviewDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = [
      if (blockerCount > 0)
        'Resolve $blockerCount blocker${blockerCount == 1 ? '' : 's'} before sign-off',
      if (warningCount > 0 && !draft.acceptOpenWarnings)
        'Accept open warnings or resolve them',
      ...draft.validationErrors,
    ];
    final ready =
        canSignOff &&
        draft.isReadyToSubmit &&
        (warningCount == 0 || draft.acceptOpenWarnings);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payroll sign-off',
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
                  controller: reviewerController,
                  decoration: const InputDecoration(
                    labelText: 'Reviewer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  onChanged: onReviewerChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReviewDateField(
                  value: draft.reviewDate,
                  onTap: onSelectReviewDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Sign-off note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          if (warningCount > 0) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onAcceptWarningsChanged(!draft.acceptOpenWarnings),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: draft.acceptOpenWarnings,
                      onChanged:
                          (value) => onAcceptWarningsChanged(value ?? false),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Accept $warningCount open warning${warningCount == 1 ? '' : 's'} for this cutoff',
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
          ],
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
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
              onPressed: ready ? onSubmit : null,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Sign off cutoff'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDateField extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;

  const _ReviewDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Review date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(value),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
        ),
      ),
    );
  }
}
