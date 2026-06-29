import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_models.dart';
import '../../models/employee_data_quality_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_data_correction_provider.dart';
import 'employee_data_correction_form.dart';
import 'employee_data_correction_tiles.dart';

class EmployeeDataCorrectionPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDataCorrectionPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeDataCorrectionPanel> createState() =>
      _EmployeeDataCorrectionPanelState();
}

class _EmployeeDataCorrectionPanelState
    extends ConsumerState<EmployeeDataCorrectionPanel> {
  final _currentValueController = TextEditingController();
  final _proposedValueController = TextEditingController();
  final _rationaleController = TextEditingController();
  final _requesterController = TextEditingController();
  final _reviewerController = TextEditingController();

  @override
  void dispose() {
    _currentValueController.dispose();
    _proposedValueController.dispose();
    _rationaleController.dispose();
    _requesterController.dispose();
    _reviewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeDataCorrectionProvider(employeeId));
    final draft = ref.watch(employeeDataCorrectionDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_currentValueController, draft.currentValue);
    _sync(_proposedValueController, draft.proposedValue);
    _sync(_rationaleController, draft.rationale);
    _sync(_requesterController, draft.requester);
    _sync(_reviewerController, draft.reviewer);

    final issues =
        profile.openIssues.isEmpty ? profile.issues : profile.openIssues;

    return HrisSectionPanel(
      icon: Icons.edit_note_outlined,
      title: 'Data correction workflow',
      subtitle: profile.nextAction,
      children: [
        EmployeeDataCorrectionSummaryStrip(profile: profile),
        if (issues.isEmpty)
          const HrisEmptyState(message: 'No data quality issues to correct')
        else
          EmployeeDataCorrectionForm(
            draft: draft,
            issues: issues,
            currentValueController: _currentValueController,
            proposedValueController: _proposedValueController,
            rationaleController: _rationaleController,
            requesterController: _requesterController,
            reviewerController: _reviewerController,
            onIssueChanged: _setIssue,
            onCurrentValueChanged:
                ref
                    .read(
                      employeeDataCorrectionDraftProvider(employeeId).notifier,
                    )
                    .setCurrentValue,
            onProposedValueChanged:
                ref
                    .read(
                      employeeDataCorrectionDraftProvider(employeeId).notifier,
                    )
                    .setProposedValue,
            onRationaleChanged:
                ref
                    .read(
                      employeeDataCorrectionDraftProvider(employeeId).notifier,
                    )
                    .setRationale,
            onRequesterChanged:
                ref
                    .read(
                      employeeDataCorrectionDraftProvider(employeeId).notifier,
                    )
                    .setRequester,
            onReviewerChanged:
                ref
                    .read(
                      employeeDataCorrectionDraftProvider(employeeId).notifier,
                    )
                    .setReviewer,
            onPickDueDate: () => _pickDueDate(employeeId),
            onSubmit: () => _submit(draft),
          ),
        if (profile.sortedRequests.isEmpty)
          const HrisEmptyState(message: 'No data correction requests')
        else
          ...profile.sortedRequests.map(
            (request) => EmployeeDataCorrectionRequestTile(
              request: request,
              asOfDate: profile.asOfDate,
              onStartReview: () => _startReview(request),
              onApprove: () => _approve(request),
              onApply: () => _apply(request),
              onReject: () => _reject(request),
              onCancel: () => _cancel(request),
              onReopen: () => _reopen(request),
            ),
          ),
      ],
    );
  }

  void _setIssue(EmployeeDataQualityIssue issue) {
    final currentValue = currentValueForDataCorrectionIssue(
      widget.snapshot.member,
      issue,
    );
    ref
        .read(employeeDataCorrectionDraftProvider(issue.employeeId).notifier)
        .setIssue(issue: issue, currentValue: currentValue);
  }

  Future<void> _pickDueDate(String employeeId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.snapshot.asOfDate.add(const Duration(days: 3)),
      firstDate: widget.snapshot.asOfDate,
      lastDate: widget.snapshot.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeDataCorrectionDraftProvider(employeeId).notifier)
        .setDueDate(picked);
  }

  void _submit(EmployeeDataCorrectionDraft draft) {
    try {
      final request = ref
          .read(employeeDataCorrectionProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeDataCorrectionDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.field} correction submitted');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _startReview(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .startReview(request.id);
    _showMessage('${request.field} correction in review');
  }

  void _approve(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .approve(request.id);
    _showMessage('${request.field} correction approved');
  }

  void _apply(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .apply(request.id);
    _showMessage('${request.field} correction applied');
  }

  void _reject(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .reject(request.id);
    _showMessage('${request.field} correction rejected');
  }

  void _cancel(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .cancel(request.id);
    _showMessage('${request.field} correction cancelled');
  }

  void _reopen(EmployeeDataCorrectionRequest request) {
    ref
        .read(employeeDataCorrectionProvider(request.employeeId).notifier)
        .reopen(request.id);
    _showMessage('${request.field} correction reopened');
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
