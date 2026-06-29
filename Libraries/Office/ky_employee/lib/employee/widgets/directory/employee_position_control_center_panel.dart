import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_position_control_models.dart';
import '../../states/employee_position_control_provider.dart';
import 'employee_position_control_tiles.dart';
import 'employee_position_requisition_form.dart';

class EmployeePositionControlCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePositionControlCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePositionControlCenterPanel> createState() =>
      _EmployeePositionControlCenterPanelState();
}

class _EmployeePositionControlCenterPanelState
    extends ConsumerState<EmployeePositionControlCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _businessCaseController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _businessCaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePositionControlProvider(employeeId));
    final draft = ref.watch(
      employeePositionRequisitionDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_businessCaseController, draft.businessCase);

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Position control',
      subtitle: profile.nextAction,
      children: [
        EmployeePositionControlSummaryStrip(profile: profile),
        EmployeePositionControlCard(
          position: profile.position,
          asOfDate: profile.asOfDate,
          onFreeze: () {
            ref
                .read(employeePositionControlProvider(employeeId).notifier)
                .freezePosition();
            _showMessage('Position frozen');
          },
          onUnfreeze: () {
            ref
                .read(employeePositionControlProvider(employeeId).notifier)
                .unfreezePosition();
            _showMessage('Position unfrozen');
          },
          onClearBudget: () {
            ref
                .read(employeePositionControlProvider(employeeId).notifier)
                .clearBudgetVariance();
            _showMessage('Position budget variance cleared');
          },
        ),
        EmployeePositionRequisitionForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          businessCaseController: _businessCaseController,
          onTypeChanged:
              ref
                  .read(
                    employeePositionRequisitionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeePositionRequisitionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(
                    employeePositionRequisitionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onRequestedFteChanged:
              ref
                  .read(
                    employeePositionRequisitionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRequestedFte,
          onBusinessCaseChanged:
              ref
                  .read(
                    employeePositionRequisitionDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setBusinessCase,
          onSelectTargetStartDate: () => _selectTargetStartDate(draft),
          onAdd: () => _addRequisition(draft),
        ),
        if (profile.requisitions.isEmpty)
          const HrisListSurface(child: Text('No position requisitions.'))
        else
          ...profile.sortedRequisitions.map(
            (requisition) => EmployeePositionRequisitionTile(
              requisition: requisition,
              asOfDate: profile.asOfDate,
              onApprove: () => _approve(requisition),
              onOpen: () => _open(requisition),
              onFill: () => _fill(requisition),
              onCancel: () => _cancel(requisition),
            ),
          ),
      ],
    );
  }

  Future<void> _selectTargetStartDate(
    EmployeePositionRequisitionDraft draft,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.targetStartDate ?? draft.asOfDate.add(const Duration(days: 30)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeePositionRequisitionDraftProvider(draft.employeeId).notifier,
        )
        .setTargetStartDate(picked);
  }

  void _addRequisition(EmployeePositionRequisitionDraft draft) {
    try {
      final requisition = ref
          .read(employeePositionControlProvider(draft.employeeId).notifier)
          .addRequisition(draft);
      ref
          .read(
            employeePositionRequisitionDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${requisition.title} submitted');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _approve(EmployeePositionRequisition requisition) {
    ref
        .read(employeePositionControlProvider(requisition.employeeId).notifier)
        .approveRequisition(requisition.id);
    _showMessage('${requisition.title} approved');
  }

  void _open(EmployeePositionRequisition requisition) {
    ref
        .read(employeePositionControlProvider(requisition.employeeId).notifier)
        .openRequisition(requisition.id);
    _showMessage('${requisition.title} opened');
  }

  void _fill(EmployeePositionRequisition requisition) {
    ref
        .read(employeePositionControlProvider(requisition.employeeId).notifier)
        .fillRequisition(requisition.id);
    _showMessage('${requisition.title} filled');
  }

  void _cancel(EmployeePositionRequisition requisition) {
    ref
        .read(employeePositionControlProvider(requisition.employeeId).notifier)
        .cancelRequisition(requisition.id);
    _showMessage('${requisition.title} cancelled');
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
