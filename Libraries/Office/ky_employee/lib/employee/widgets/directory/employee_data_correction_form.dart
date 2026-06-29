import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_models.dart';
import '../../models/employee_data_quality_models.dart';
import 'employee_data_quality_styles.dart';

class EmployeeDataCorrectionForm extends StatelessWidget {
  final EmployeeDataCorrectionDraft draft;
  final List<EmployeeDataQualityIssue> issues;
  final TextEditingController currentValueController;
  final TextEditingController proposedValueController;
  final TextEditingController rationaleController;
  final TextEditingController requesterController;
  final TextEditingController reviewerController;
  final ValueChanged<EmployeeDataQualityIssue> onIssueChanged;
  final ValueChanged<String> onCurrentValueChanged;
  final ValueChanged<String> onProposedValueChanged;
  final ValueChanged<String> onRationaleChanged;
  final ValueChanged<String> onRequesterChanged;
  final ValueChanged<String> onReviewerChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onSubmit;

  const EmployeeDataCorrectionForm({
    super.key,
    required this.draft,
    required this.issues,
    required this.currentValueController,
    required this.proposedValueController,
    required this.rationaleController,
    required this.requesterController,
    required this.reviewerController,
    required this.onIssueChanged,
    required this.onCurrentValueChanged,
    required this.onProposedValueChanged,
    required this.onRationaleChanged,
    required this.onRequesterChanged,
    required this.onReviewerChanged,
    required this.onPickDueDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IssuePicker(draft: draft, issues: issues, onChanged: onIssueChanged),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _currentValueField(),
                    const SizedBox(height: 12),
                    _proposedValueField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _currentValueField()),
                  const SizedBox(width: 12),
                  Expanded(child: _proposedValueField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: rationaleController,
            minLines: 2,
            maxLines: 4,
            onChanged: onRationaleChanged,
            decoration: const InputDecoration(
              labelText: 'Correction rationale',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _requesterField(),
                    const SizedBox(height: 12),
                    _reviewerField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _requesterField()),
                  const SizedBox(width: 12),
                  Expanded(child: _reviewerField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onPickDueDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(_dueDateLabel(draft.dueDate)),
              ),
              FilledButton.icon(
                onPressed: draft.isReadyToSubmit ? onSubmit : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit correction'),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _currentValueField() {
    return TextField(
      controller: currentValueController,
      onChanged: onCurrentValueChanged,
      decoration: const InputDecoration(
        labelText: 'Current value',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.history_outlined),
      ),
    );
  }

  Widget _proposedValueField() {
    return TextField(
      controller: proposedValueController,
      onChanged: onProposedValueChanged,
      decoration: const InputDecoration(
        labelText: 'Proposed value',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.edit_outlined),
      ),
    );
  }

  Widget _requesterField() {
    return TextField(
      controller: requesterController,
      onChanged: onRequesterChanged,
      decoration: const InputDecoration(
        labelText: 'Requester',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_add_alt_outlined),
      ),
    );
  }

  Widget _reviewerField() {
    return TextField(
      controller: reviewerController,
      onChanged: onReviewerChanged,
      decoration: const InputDecoration(
        labelText: 'Reviewer',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_user_outlined),
      ),
    );
  }

  String _dueDateLabel(DateTime? date) {
    if (date == null) return 'Select due date';
    return 'Due ${DateFormat('MMM d, yyyy').format(date)}';
  }
}

class _IssuePicker extends StatelessWidget {
  final EmployeeDataCorrectionDraft draft;
  final List<EmployeeDataQualityIssue> issues;
  final ValueChanged<EmployeeDataQualityIssue> onChanged;

  const _IssuePicker({
    required this.draft,
    required this.issues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIssueId =
        issues.any((issue) => issue.id == draft.issueId) ? draft.issueId : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedIssueId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Data quality issue',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rule_folder_outlined),
      ),
      items:
          issues
              .map(
                (issue) => DropdownMenuItem(
                  value: issue.id,
                  child: Row(
                    children: [
                      Icon(
                        employeeDataQualityTypeIcon(issue.type),
                        size: 16,
                        color: employeeDataQualitySeverityColor(issue.severity),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          issue.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (issueId) {
        if (issueId == null) return;
        for (final issue in issues) {
          if (issue.id == issueId) {
            onChanged(issue);
            break;
          }
        }
      },
    );
  }
}
