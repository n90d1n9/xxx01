import 'package:flutter/material.dart';

import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_review_exception.dart';
import 'financial_report_exception_resolution_components.dart';
import 'financial_report_resolution_form_components.dart';

Future<FinancialReportExceptionResolution?>
showFinancialReportExceptionResolutionDialog(
  BuildContext context, {
  required FinancialReportReviewException exception,
  required FinancialReportExceptionResolutionStatus initialStatus,
  FinancialReportExceptionResolution? existingResolution,
  List<LedgerPosting> adjustmentPostings = const [],
}) {
  return showDialog<FinancialReportExceptionResolution>(
    context: context,
    builder:
        (context) => _FinancialReportExceptionResolutionDialog(
          exception: exception,
          initialStatus: initialStatus,
          existingResolution: existingResolution,
          adjustmentPostings: adjustmentPostings,
        ),
  );
}

class _FinancialReportExceptionResolutionDialog extends StatefulWidget {
  final FinancialReportReviewException exception;
  final FinancialReportExceptionResolutionStatus initialStatus;
  final FinancialReportExceptionResolution? existingResolution;
  final List<LedgerPosting> adjustmentPostings;

  const _FinancialReportExceptionResolutionDialog({
    required this.exception,
    required this.initialStatus,
    this.existingResolution,
    this.adjustmentPostings = const [],
  });

  @override
  State<_FinancialReportExceptionResolutionDialog> createState() =>
      _FinancialReportExceptionResolutionDialogState();
}

class _FinancialReportExceptionResolutionDialogState
    extends State<_FinancialReportExceptionResolutionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reviewerController;
  late final TextEditingController _noteController;
  late final TextEditingController _referenceController;
  late FinancialReportExceptionResolutionStatus _status;
  String? _selectedAdjustmentPostingId;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingResolution;
    _status = existing?.status ?? widget.initialStatus;
    _reviewerController = TextEditingController(
      text: existing?.reviewer ?? 'Controller',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _referenceController = TextEditingController(
      text: existing?.adjustmentReference ?? '',
    );
    _selectedAdjustmentPostingId = existing?.adjustmentPostingId;
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _noteController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FinancialReportResolutionDialogFrame(
      header: const FinancialReportExceptionResolutionHeader(),
      formKey: _formKey,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submit,
      children: [
        FinancialReportExceptionSummaryCard(exception: widget.exception),
        const SizedBox(height: 14),
        FinancialReportExceptionStatusField(
          status: _status,
          onChanged: (value) {
            setState(() => _status = value);
          },
        ),
        const SizedBox(height: 12),
        FinancialReportResolutionTextField(
          controller: _reviewerController,
          label: 'Reviewer',
          icon: Icons.person_rounded,
          validator: financialReportResolutionRequiredValidator,
        ),
        const SizedBox(height: 12),
        FinancialReportExceptionEvidenceField(
          status: _status,
          referenceController: _referenceController,
          adjustmentPostings: widget.adjustmentPostings,
          selectedAdjustmentPostingId: _selectedAdjustmentPostingId,
          onAdjustmentPostingChanged: (value) {
            setState(() => _selectedAdjustmentPostingId = value);
          },
          postedAdjustmentValidator: _postedAdjustmentValidator,
        ),
        const SizedBox(height: 12),
        FinancialReportResolutionTextField(
          controller: _noteController,
          label: 'Resolution note',
          hintText: 'Describe the schedule, approval, or adjustment.',
          icon: Icons.notes_rounded,
          alignLabelWithHint: true,
          maxLines: 3,
          validator: financialReportResolutionRequiredValidator,
        ),
      ],
    );
  }

  String? _postedAdjustmentValidator(String? value) {
    if (_status == FinancialReportExceptionResolutionStatus.adjusted &&
        (value == null || value.trim().isEmpty)) {
      return 'Posted adjustment journal is required';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedPosting = _selectedAdjustmentPosting();
    final reference =
        _status == FinancialReportExceptionResolutionStatus.adjusted
            ? selectedPosting?.reference.trim() ?? ''
            : _referenceController.text.trim();
    Navigator.of(context).pop(
      FinancialReportExceptionResolution(
        exceptionId: widget.exception.id,
        status: _status,
        reviewer: _reviewerController.text.trim(),
        resolvedAt: DateTime.now(),
        note: _noteController.text.trim(),
        adjustmentReference: reference.isEmpty ? null : reference,
        adjustmentPostingId: selectedPosting?.id,
      ),
    );
  }

  LedgerPosting? _selectedAdjustmentPosting() {
    final selectedId = _selectedAdjustmentPostingId;
    if (selectedId == null) {
      return null;
    }
    for (final posting in widget.adjustmentPostings) {
      if (posting.id == selectedId) {
        return posting;
      }
    }
    return null;
  }
}
