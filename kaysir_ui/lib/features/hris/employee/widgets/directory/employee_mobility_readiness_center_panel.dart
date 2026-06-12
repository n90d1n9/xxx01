import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_mobility_readiness_models.dart';
import '../../states/employee_mobility_readiness_provider.dart';
import 'employee_mobility_gate_form.dart';
import 'employee_mobility_readiness_tiles.dart';

class EmployeeMobilityReadinessCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeMobilityReadinessCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeMobilityReadinessCenterPanel> createState() =>
      _EmployeeMobilityReadinessCenterPanelState();
}

class _EmployeeMobilityReadinessCenterPanelState
    extends ConsumerState<EmployeeMobilityReadinessCenterPanel> {
  final _targetRoleController = TextEditingController();
  final _targetDepartmentController = TextEditingController();
  final _targetManagerController = TextEditingController();
  final _gateTitleController = TextEditingController();
  final _gateOwnerController = TextEditingController();
  final _gateDetailController = TextEditingController();

  @override
  void dispose() {
    _targetRoleController.dispose();
    _targetDepartmentController.dispose();
    _targetManagerController.dispose();
    _gateTitleController.dispose();
    _gateOwnerController.dispose();
    _gateDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeMobilityReadinessProvider(employeeId));
    final draft = ref.watch(employeeMobilityGateDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_targetRoleController, profile.targetRole);
    _sync(_targetDepartmentController, profile.targetDepartment);
    _sync(_targetManagerController, profile.targetManager);
    _sync(_gateTitleController, draft.title);
    _sync(_gateOwnerController, draft.owner);
    _sync(_gateDetailController, draft.detail);

    return HrisSectionPanel(
      icon: Icons.move_up_outlined,
      title: 'Mobility readiness',
      subtitle: profile.nextAction,
      children: [
        EmployeeMobilityReadinessSummaryStrip(profile: profile),
        EmployeeMobilityTargetCard(
          profile: profile,
          roleController: _targetRoleController,
          departmentController: _targetDepartmentController,
          managerController: _targetManagerController,
          onMoveTypeChanged:
              ref
                  .read(employeeMobilityReadinessProvider(employeeId).notifier)
                  .setMoveType,
          onRoleChanged:
              ref
                  .read(employeeMobilityReadinessProvider(employeeId).notifier)
                  .setTargetRole,
          onDepartmentChanged:
              ref
                  .read(employeeMobilityReadinessProvider(employeeId).notifier)
                  .setTargetDepartment,
          onManagerChanged:
              ref
                  .read(employeeMobilityReadinessProvider(employeeId).notifier)
                  .setTargetManager,
          onSelectEffectiveDate: () => _selectEffectiveDate(profile),
          onReset:
              ref
                  .read(employeeMobilityReadinessProvider(employeeId).notifier)
                  .resetToPreset,
        ),
        EmployeeMobilityGateForm(
          draft: draft,
          titleController: _gateTitleController,
          ownerController: _gateOwnerController,
          detailController: _gateDetailController,
          onTypeChanged:
              ref
                  .read(employeeMobilityGateDraftProvider(employeeId).notifier)
                  .setType,
          onTitleChanged:
              ref
                  .read(employeeMobilityGateDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeMobilityGateDraftProvider(employeeId).notifier)
                  .setOwner,
          onRiskChanged:
              ref
                  .read(employeeMobilityGateDraftProvider(employeeId).notifier)
                  .setRisk,
          onDetailChanged:
              ref
                  .read(employeeMobilityGateDraftProvider(employeeId).notifier)
                  .setDetail,
          onSelectDueDate: () => _selectDueDate(draft),
          onAdd: () => _addGate(draft),
        ),
        if (profile.gates.isEmpty)
          const HrisEmptyState(message: 'No mobility readiness gates yet')
        else
          ...profile.sortedGates.map(
            (gate) => EmployeeMobilityGateTile(
              gate: gate,
              asOfDate: profile.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(
                        employeeMobilityReadinessProvider(employeeId).notifier,
                      )
                      .updateGateStatus(gate.id, status),
              onWaive:
                  () => ref
                      .read(
                        employeeMobilityReadinessProvider(employeeId).notifier,
                      )
                      .waiveGate(gate.id),
              onReopen:
                  () => ref
                      .read(
                        employeeMobilityReadinessProvider(employeeId).notifier,
                      )
                      .reopenGate(gate.id),
              onRemove:
                  () => ref
                      .read(
                        employeeMobilityReadinessProvider(employeeId).notifier,
                      )
                      .removeGate(gate.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(
    EmployeeMobilityReadinessProfile profile,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          profile.effectiveDate.isBefore(profile.asOfDate)
              ? profile.asOfDate
              : profile.effectiveDate,
      firstDate: profile.asOfDate,
      lastDate: profile.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeMobilityReadinessProvider(profile.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  Future<void> _selectDueDate(EmployeeMobilityGateDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeMobilityGateDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _addGate(EmployeeMobilityGateDraft draft) {
    try {
      final gate = ref
          .read(employeeMobilityReadinessProvider(draft.employeeId).notifier)
          .addGate(draft);
      ref
          .read(employeeMobilityGateDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${gate.title} added to ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
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
