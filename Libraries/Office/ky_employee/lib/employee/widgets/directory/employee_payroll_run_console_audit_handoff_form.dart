import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Responsive form fields for submitting payroll audit package handoffs.
class EmployeePayrollRunConsoleAuditHandoffForm extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditHandoffReview review;
  final TextEditingController reviewerController;
  final TextEditingController approverController;
  final TextEditingController noteController;
  final String? visibleError;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onApproverChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback? onSubmit;
  final VoidCallback? onClear;

  const EmployeePayrollRunConsoleAuditHandoffForm({
    super.key,
    required this.review,
    required this.reviewerController,
    required this.approverController,
    required this.noteController,
    required this.visibleError,
    required this.onReviewerChanged,
    required this.onApproverChanged,
    required this.onNoteChanged,
    required this.onSelectDueDate,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720) {
              return Column(
                children: [
                  _reviewerField(),
                  const SizedBox(height: 12),
                  _approverField(),
                  const SizedBox(height: 12),
                  _DueDateField(
                    value: review.draft.dueDate,
                    onTap: onSelectDueDate,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _reviewerField()),
                const SizedBox(width: 12),
                Expanded(child: _approverField()),
                const SizedBox(width: 12),
                Expanded(
                  child: _DueDateField(
                    value: review.draft.dueDate,
                    onTap: onSelectDueDate,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('employee-payroll-audit-handoff-note-field'),
          controller: noteController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Handoff note',
            prefixIcon: Icon(Icons.notes_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: onNoteChanged,
        ),
        const SizedBox(height: 12),
        HrisProgressBar(
          value: review.completionRatio,
          color:
              review.canSubmit ? const Color(0xFF15803D) : HrisColors.primary,
          label: '${(review.completionRatio * 100).round()}% ready',
        ),
        if (visibleError != null) ...[
          const SizedBox(height: 8),
          Text(
            visibleError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB91C1C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey(
                'employee-payroll-audit-handoff-submit-button',
              ),
              onPressed: onSubmit,
              icon: const Icon(Icons.outbox_outlined),
              label: const Text('Submit handoff'),
            ),
            OutlinedButton.icon(
              key: const ValueKey(
                'employee-payroll-audit-handoff-clear-button',
              ),
              onPressed: onClear,
              icon: const Icon(Icons.clear_all_outlined),
              label: const Text('Clear handoff'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewerField() {
    return TextField(
      key: const ValueKey('employee-payroll-audit-handoff-reviewer-field'),
      controller: reviewerController,
      decoration: const InputDecoration(
        labelText: 'Reviewer',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: onReviewerChanged,
    );
  }

  Widget _approverField() {
    return TextField(
      key: const ValueKey('employee-payroll-audit-handoff-approver-field'),
      controller: approverController,
      decoration: const InputDecoration(
        labelText: 'Approver',
        prefixIcon: Icon(Icons.verified_user_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: onApproverChanged,
    );
  }
}

/// Tappable due-date field used by the payroll audit handoff form.
class _DueDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _DueDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('employee-payroll-audit-handoff-due-date-field'),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          prefixIcon: Icon(Icons.event_available_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(
          value == null
              ? 'Select due date'
              : DateFormat('MMM d, yyyy').format(value!),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
        ),
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit handoff form')
Widget employeePayrollRunConsoleAuditHandoffFormPreview() {
  final reviewerController = TextEditingController(text: 'Alya Rahman');
  final approverController = TextEditingController(text: 'Rafi Pratama');
  final noteController = TextEditingController(
    text: 'Reviewed payroll evidence before handoff.',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditHandoffForm(
          review: _previewReview(),
          reviewerController: reviewerController,
          approverController: approverController,
          noteController: noteController,
          visibleError: null,
          onReviewerChanged: (_) {},
          onApproverChanged: (_) {},
          onNoteChanged: (_) {},
          onSelectDueDate: () {},
          onSubmit: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditHandoffReview _previewReview() {
  final package = EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _previewEvent(
            id: 'payroll-console-audit-1',
            type: EmployeePayrollRunConsoleCommandType.prepareExport,
          ),
          _previewEvent(
            id: 'payroll-console-audit-2',
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
          ),
          _previewEvent(
            id: 'payroll-console-audit-3',
            type: EmployeePayrollRunConsoleCommandType.publishPayslip,
          ),
          _previewEvent(
            id: 'payroll-console-audit-4',
            type: EmployeePayrollRunConsoleCommandType.closePeriod,
          ),
        ],
      ),
    ),
  );

  return EmployeePayrollRunConsoleAuditHandoffReview.fromState(
    package: package,
    draft: EmployeePayrollRunConsoleAuditHandoffDraft(
      reviewer: 'Alya Rahman',
      approver: 'Rafi Pratama',
      dueDate: DateTime(2026, 6, 1),
      note: 'Reviewed payroll evidence before handoff.',
    ),
    handoffs: const [],
  );
}

EmployeePayrollRunConsoleAuditEvent _previewEvent({
  required String id,
  required EmployeePayrollRunConsoleCommandType type,
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: type,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: 3,
    completedCount: 3,
    skippedCount: 0,
    errors: const [],
    message: '${type.label} audit evidence captured.',
  );
}
