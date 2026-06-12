import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_leave_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_leave_provider.dart';
import 'employee_leave_request_form.dart';
import 'employee_leave_tiles.dart';

class EmployeeLeaveCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeLeaveCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeLeaveCenterPanel> createState() =>
      _EmployeeLeaveCenterPanelState();
}

class _EmployeeLeaveCenterPanelState
    extends ConsumerState<EmployeeLeaveCenterPanel> {
  final _reasonController = TextEditingController();
  final _coverageOwnerController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _coverageOwnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeLeaveProfileProvider(employeeId));
    final draft = ref.watch(employeeLeaveRequestDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_reasonController, draft.reason);
    _sync(_coverageOwnerController, draft.coverageOwner);

    final requests = [...profile.requests]..sort((a, b) {
      final statusCompare = _requestRank(
        a.status,
      ).compareTo(_requestRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return b.startDate.compareTo(a.startDate);
    });

    return HrisSectionPanel(
      icon: Icons.beach_access_outlined,
      title: 'Leave and absence',
      subtitle: profile.nextAction,
      children: [
        EmployeeLeaveSummaryStrip(profile: profile),
        EmployeeLeaveBalancesCard(balances: profile.balances),
        EmployeeLeaveRequestForm(
          draft: draft,
          reasonController: _reasonController,
          coverageOwnerController: _coverageOwnerController,
          onTypeChanged:
              ref
                  .read(employeeLeaveRequestDraftProvider(employeeId).notifier)
                  .setType,
          onReasonChanged:
              ref
                  .read(employeeLeaveRequestDraftProvider(employeeId).notifier)
                  .setReason,
          onCoverageOwnerChanged:
              ref
                  .read(employeeLeaveRequestDraftProvider(employeeId).notifier)
                  .setCoverageOwner,
          onSelectStartDate: () => _selectStartDate(draft),
          onSelectEndDate: () => _selectEndDate(draft),
          onAdd: () => _addRequest(draft),
        ),
        ...profile.risks.map((risk) => EmployeeLeaveRiskTile(risk: risk)),
        ...profile.blackouts
            .take(2)
            .map((blackout) => EmployeeLeaveBlackoutTile(blackout: blackout)),
        if (requests.isEmpty)
          const HrisListSurface(child: Text('No leave requests recorded.'))
        else
          ...requests.map(
            (request) => EmployeeLeaveRequestTile(
              request: request,
              onApprove:
                  () => ref
                      .read(employeeLeaveProfileProvider(employeeId).notifier)
                      .approveRequest(request.id),
              onReject:
                  () => ref
                      .read(employeeLeaveProfileProvider(employeeId).notifier)
                      .rejectRequest(request.id),
              onCancel:
                  () => ref
                      .read(employeeLeaveProfileProvider(employeeId).notifier)
                      .cancelRequest(request.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectStartDate(EmployeeLeaveRequestDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeLeaveRequestDraftProvider(draft.employeeId).notifier)
        .setStartDate(picked);
  }

  Future<void> _selectEndDate(EmployeeLeaveRequestDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.endDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeLeaveRequestDraftProvider(draft.employeeId).notifier)
        .setEndDate(picked);
  }

  void _addRequest(EmployeeLeaveRequestDraft draft) {
    try {
      final request = ref
          .read(employeeLeaveProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeLeaveRequestDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.id} added for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  int _requestRank(EmployeeLeaveRequestStatus status) {
    return switch (status) {
      EmployeeLeaveRequestStatus.pending => 0,
      EmployeeLeaveRequestStatus.approved => 1,
      EmployeeLeaveRequestStatus.rejected => 2,
      EmployeeLeaveRequestStatus.cancelled => 3,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
