import 'package:flutter/material.dart';

import '../models/financial_report_evidence_close_task.dart';
import 'financial_report_evidence_task_resolution_components.dart';
import 'financial_report_resolution_form_components.dart';

Future<FinancialReportEvidenceCloseTaskResolution?>
showFinancialReportEvidenceTaskResolutionDialog(
  BuildContext context, {
  required FinancialReportEvidenceCloseTask task,
  required FinancialReportEvidenceCloseTaskResolutionStatus initialStatus,
  FinancialReportEvidenceCloseTaskResolution? existingResolution,
}) {
  return showDialog<FinancialReportEvidenceCloseTaskResolution>(
    context: context,
    builder:
        (context) => _FinancialReportEvidenceTaskResolutionDialog(
          task: task,
          initialStatus: initialStatus,
          existingResolution: existingResolution,
        ),
  );
}

class _FinancialReportEvidenceTaskResolutionDialog extends StatefulWidget {
  final FinancialReportEvidenceCloseTask task;
  final FinancialReportEvidenceCloseTaskResolutionStatus initialStatus;
  final FinancialReportEvidenceCloseTaskResolution? existingResolution;

  const _FinancialReportEvidenceTaskResolutionDialog({
    required this.task,
    required this.initialStatus,
    this.existingResolution,
  });

  @override
  State<_FinancialReportEvidenceTaskResolutionDialog> createState() =>
      _FinancialReportEvidenceTaskResolutionDialogState();
}

class _FinancialReportEvidenceTaskResolutionDialogState
    extends State<_FinancialReportEvidenceTaskResolutionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _referenceController;
  late final TextEditingController _noteController;
  late FinancialReportEvidenceCloseTaskResolutionStatus _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingResolution;
    _status = existing?.status ?? widget.initialStatus;
    _reviewerController = TextEditingController(
      text: existing?.reviewer ?? widget.task.reviewer,
    );
    _referenceController = TextEditingController(
      text: existing?.evidenceReference ?? '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialReportResolutionDialogFrame(
      header: const FinancialReportEvidenceTaskResolutionHeader(),
      formKey: _formKey,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submit,
      children: [
        FinancialReportEvidenceTaskSummaryCard(task: widget.task),
        const SizedBox(height: 14),
        FinancialReportEvidenceTaskStatusField(
          status: _status,
          onChanged: (value) {
            setState(() => _status = value);
          },
        ),
        const SizedBox(height: 12),
        FinancialReportResolutionTextField(
          controller: _reviewerController,
          label: 'Reviewer',
          icon: Icons.verified_user_rounded,
          validator: financialReportResolutionRequiredValidator,
        ),
        const SizedBox(height: 12),
        FinancialReportResolutionTextField(
          controller: _referenceController,
          label: 'Evidence reference',
          hintText: 'Example: WP-BANK-001',
          icon: Icons.tag_rounded,
        ),
        const SizedBox(height: 12),
        FinancialReportResolutionTextField(
          controller: _noteController,
          label: 'Resolution note',
          hintText: 'Describe the review, approval, or follow-up.',
          icon: Icons.notes_rounded,
          alignLabelWithHint: true,
          maxLines: 3,
          validator: financialReportResolutionRequiredValidator,
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final reference = _referenceController.text.trim();
    Navigator.of(context).pop(
      FinancialReportEvidenceCloseTaskResolution(
        taskId: widget.task.id,
        status: _status,
        reviewer: _reviewerController.text.trim(),
        resolvedAt: DateTime.now(),
        note: _noteController.text.trim(),
        evidenceReference: reference.isEmpty ? null : reference,
      ),
    );
  }
}
