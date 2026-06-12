import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_coverage_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_approval_coverage_provider.dart';
import 'employee_approval_coverage_tiles.dart';
import 'employee_approval_delegation_form.dart';

class EmployeeApprovalCoverageCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeApprovalCoverageCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeApprovalCoverageCenterPanel> createState() =>
      _EmployeeApprovalCoverageCenterPanelState();
}

class _EmployeeApprovalCoverageCenterPanelState
    extends ConsumerState<EmployeeApprovalCoverageCenterPanel> {
  final _primaryController = TextEditingController();
  final _delegateController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _primaryController.dispose();
    _delegateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeApprovalCoverageProvider(employeeId));
    final draft = ref.watch(
      employeeApprovalDelegationDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_primaryController, draft.primaryApprover);
    _sync(_delegateController, draft.delegateApprover);
    _sync(_reasonController, draft.reason);

    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Approval coverage',
      subtitle: profile.nextAction,
      children: [
        EmployeeApprovalCoverageSummaryStrip(profile: profile),
        EmployeeApprovalCoverageStatusCard(profile: profile),
        EmployeeApprovalDelegationForm(
          draft: draft,
          primaryController: _primaryController,
          delegateController: _delegateController,
          reasonController: _reasonController,
          onAreaChanged:
              ref
                  .read(
                    employeeApprovalDelegationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setArea,
          onPrimaryChanged:
              ref
                  .read(
                    employeeApprovalDelegationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setPrimaryApprover,
          onDelegateChanged:
              ref
                  .read(
                    employeeApprovalDelegationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setDelegateApprover,
          onRiskChanged:
              ref
                  .read(
                    employeeApprovalDelegationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRisk,
          onReasonChanged:
              ref
                  .read(
                    employeeApprovalDelegationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setReason,
          onSelectStartDate: () => _selectStartDate(draft),
          onSelectEndDate: () => _selectEndDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (profile.delegations.isEmpty)
          const HrisEmptyState(message: 'No approval delegations configured')
        else
          ...profile.sortedDelegations.map(
            (delegation) => EmployeeApprovalDelegationTile(
              delegation: delegation,
              asOfDate: profile.asOfDate,
              onActivate:
                  () => ref
                      .read(
                        employeeApprovalCoverageProvider(employeeId).notifier,
                      )
                      .activate(delegation.id),
              onBlock:
                  () => ref
                      .read(
                        employeeApprovalCoverageProvider(employeeId).notifier,
                      )
                      .block(delegation.id),
              onExpire:
                  () => ref
                      .read(
                        employeeApprovalCoverageProvider(employeeId).notifier,
                      )
                      .expire(delegation.id),
              onRemove:
                  () => ref
                      .read(
                        employeeApprovalCoverageProvider(employeeId).notifier,
                      )
                      .remove(delegation.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectStartDate(EmployeeApprovalDelegationDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeApprovalDelegationDraftProvider(draft.employeeId).notifier,
        )
        .setStartDate(picked);
  }

  Future<void> _selectEndDate(EmployeeApprovalDelegationDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.endDate ??
          (draft.startDate ?? draft.asOfDate).add(const Duration(days: 30)),
      firstDate: draft.startDate ?? draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeApprovalDelegationDraftProvider(draft.employeeId).notifier,
        )
        .setEndDate(picked);
  }

  void _submitDraft(EmployeeApprovalDelegationDraft draft) {
    try {
      final delegation = ref
          .read(employeeApprovalCoverageProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref
          .read(
            employeeApprovalDelegationDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${delegation.area.label} delegation added');
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
