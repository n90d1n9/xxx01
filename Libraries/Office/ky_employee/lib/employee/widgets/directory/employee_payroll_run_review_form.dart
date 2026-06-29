import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_models.dart';

class EmployeePayrollRunReviewForm extends StatelessWidget {
  final EmployeePayrollRunProfile profile;
  final EmployeePayrollRunReviewDraft draft;
  final TextEditingController reviewerController;
  final TextEditingController noteController;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<bool> onPayslipVisibleChanged;
  final VoidCallback onReview;
  final VoidCallback onExport;
  final VoidCallback onReopen;

  const EmployeePayrollRunReviewForm({
    super.key,
    required this.profile,
    required this.draft,
    required this.reviewerController,
    required this.noteController,
    required this.onReviewerChanged,
    required this.onNoteChanged,
    required this.onPayslipVisibleChanged,
    required this.onReview,
    required this.onExport,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final errors = [
      if (profile.blockerCount > 0)
        'Clear ${profile.blockerCount} blocker${profile.blockerCount == 1 ? '' : 's'} before review',
      ...draft.validationErrors,
    ];
    final readyToReview = profile.canReview && draft.isReadyToReview;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run review',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewerController,
            enabled: profile.status != EmployeePayrollRunStatus.exported,
            decoration: const InputDecoration(
              labelText: 'Reviewer',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onReviewerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            enabled: profile.status != EmployeePayrollRunStatus.exported,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Review note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                profile.status == EmployeePayrollRunStatus.exported
                    ? null
                    : () => onPayslipVisibleChanged(!draft.payslipVisible),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: draft.payslipVisible,
                    onChanged:
                        profile.status == EmployeePayrollRunStatus.exported
                            ? null
                            : (value) =>
                                onPayslipVisibleChanged(value ?? false),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Make payslip visible after export',
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
            color: readyToReview ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty &&
              profile.status != EmployeePayrollRunStatus.ready &&
              profile.status != EmployeePayrollRunStatus.exported) ...[
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
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.status == EmployeePayrollRunStatus.ready)
                OutlinedButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reopen'),
                ),
              FilledButton.tonalIcon(
                onPressed: readyToReview ? onReview : null,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Mark reviewed'),
              ),
              FilledButton.icon(
                onPressed: profile.canExport ? onExport : null,
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Export payroll'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
