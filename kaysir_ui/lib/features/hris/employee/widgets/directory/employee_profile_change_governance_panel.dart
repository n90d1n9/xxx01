import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../data/employee_management_seed_data.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_profile_change_governance_models.dart';
import '../../states/employee_profile_change_governance_provider.dart';
import 'employee_profile_change_governance_form.dart';
import 'employee_profile_change_governance_tiles.dart';

/// Center panel for governed effective-dated employee profile changes.
class EmployeeProfileChangeGovernancePanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeProfileChangeGovernancePanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeProfileChangeGovernancePanel> createState() =>
      _EmployeeProfileChangeGovernancePanelState();
}

/// Coordinates draft input and request lifecycle actions for profile changes.
class _EmployeeProfileChangeGovernancePanelState
    extends ConsumerState<EmployeeProfileChangeGovernancePanel> {
  final _currentValueController = TextEditingController();
  final _proposedValueController = TextEditingController();
  final _reasonController = TextEditingController();
  final _requesterController = TextEditingController();
  final _reviewerController = TextEditingController();
  final _approverController = TextEditingController();

  @override
  void dispose() {
    _currentValueController.dispose();
    _proposedValueController.dispose();
    _reasonController.dispose();
    _requesterController.dispose();
    _reviewerController.dispose();
    _approverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeProfileChangeGovernanceProvider(employeeId),
    );
    final draft = ref.watch(employeeProfileChangeDraftProvider(employeeId));

    if (profile == null || draft == null) return const SizedBox.shrink();

    _sync(_currentValueController, draft.currentValue);
    _sync(_proposedValueController, draft.proposedValue);
    _sync(_reasonController, draft.reason);
    _sync(_requesterController, draft.requester);
    _sync(_reviewerController, draft.reviewer);
    _sync(_approverController, draft.approver);

    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'Profile change governance',
      subtitle: profile.nextAction,
      children: [
        EmployeeProfileChangeGovernanceSummaryStrip(profile: profile),
        EmployeeProfileChangeGovernanceForm(
          draft: draft,
          currentValueController: _currentValueController,
          proposedValueController: _proposedValueController,
          reasonController: _reasonController,
          requesterController: _requesterController,
          reviewerController: _reviewerController,
          approverController: _approverController,
          onFieldChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setField,
          onCurrentValueChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setCurrentValue,
          onProposedValueChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setProposedValue,
          onReasonChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setReason,
          onRequesterChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setRequester,
          onReviewerChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setReviewer,
          onApproverChanged:
              ref
                  .read(employeeProfileChangeDraftProvider(employeeId).notifier)
                  .setApprover,
          onSelectEffectiveDate: () => _selectEffectiveDate(draft),
          onSubmit: () => _submit(draft),
        ),
        if (profile.sortedRequests.isEmpty)
          const HrisEmptyState(message: 'No governed profile changes pending')
        else
          ...profile.sortedRequests.map(
            (request) => EmployeeProfileChangeRequestTile(
              request: request,
              asOfDate: profile.asOfDate,
              onStartReview: () => _startReview(request),
              onApprove: () => _approve(request),
              onSchedule: () => _schedule(request),
              onApply: () => _apply(request),
              onReject: () => _reject(request),
              onCancel: () => _cancel(request),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(EmployeeProfileChangeDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeProfileChangeDraftProvider(draft.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  void _submit(EmployeeProfileChangeDraft draft) {
    try {
      final request = ref
          .read(
            employeeProfileChangeGovernanceProvider(draft.employeeId).notifier,
          )
          .addDraft(draft);
      ref
          .read(employeeProfileChangeDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.field.label} change submitted');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _startReview(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .startReview(request.id);
    _showMessage('${request.field.label} change in review');
  }

  void _approve(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .approve(request.id);
    _showMessage('${request.field.label} change approved');
  }

  void _schedule(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .schedule(request.id);
    _showMessage('${request.field.label} change scheduled');
  }

  void _apply(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .apply(request.id);
    _showMessage('${request.field.label} change applied');
  }

  void _reject(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .reject(request.id);
    _showMessage('${request.field.label} change rejected');
  }

  void _cancel(EmployeeProfileChangeRequest request) {
    ref
        .read(
          employeeProfileChangeGovernanceProvider(request.employeeId).notifier,
        )
        .cancel(request.id);
    _showMessage('${request.field.label} change cancelled');
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

@Preview(name: 'Employee profile change governance panel')
Widget employeeProfileChangeGovernancePanelPreview() {
  final snapshot = buildEmployeeManagementSnapshot(
    member: EmployeeDirectoryMember(
      id: '4',
      name: 'David Kim',
      position: 'Product Manager',
      department: 'Product',
      avatarUrl: '',
      email: 'david.kim@company.com',
      phone: '+1 (555) 789-0123',
      joiningDate: DateTime(2023, 2, 14),
      performance: 4.3,
      location: 'Jakarta',
      manager: 'Olivia Wilson',
      status: EmployeeDirectoryStatus.watchlist,
    ),
    asOfDate: DateTime(2026, 6, 1),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmployeeProfileChangeGovernancePanel(snapshot: snapshot),
        ),
      ),
    ),
  );
}
