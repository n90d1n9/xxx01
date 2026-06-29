import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_contract_lifecycle_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_contract_lifecycle_provider.dart';
import 'employee_contract_lifecycle_form.dart';
import 'employee_contract_lifecycle_tiles.dart';

class EmployeeContractLifecycleCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeContractLifecycleCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeContractLifecycleCenterPanel> createState() =>
      _EmployeeContractLifecycleCenterPanelState();
}

class _EmployeeContractLifecycleCenterPanelState
    extends ConsumerState<EmployeeContractLifecycleCenterPanel> {
  final _titleController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _requestedByController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeContractLifecycleProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeContractChangeDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_requestedByController, draft.requestedBy);
    _sync(_detailController, draft.detail);

    final changes = [...profile.changes]..sort((a, b) {
      final statusCompare = _changeRank(
        a.status,
      ).compareTo(_changeRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return b.effectiveDate.compareTo(a.effectiveDate);
    });

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Contract lifecycle',
      subtitle: profile.nextAction,
      children: [
        EmployeeContractLifecycleSummaryStrip(profile: profile),
        EmployeeContractTermsCard(
          contract: profile.contract,
          asOfDate: profile.asOfDate,
          onCompleteProbation: () {
            ref
                .read(
                  employeeContractLifecycleProfileProvider(employeeId).notifier,
                )
                .completeProbation();
            _showMessage('Probation completed for ${profile.employeeName}');
          },
          onMarkRenewed: () {
            ref
                .read(
                  employeeContractLifecycleProfileProvider(employeeId).notifier,
                )
                .markRenewed();
            _showMessage('Contract renewed for ${profile.employeeName}');
          },
        ),
        EmployeeContractChangeForm(
          draft: draft,
          titleController: _titleController,
          requestedByController: _requestedByController,
          detailController: _detailController,
          onTypeChanged:
              ref
                  .read(
                    employeeContractChangeDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeeContractChangeDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onRequestedByChanged:
              ref
                  .read(
                    employeeContractChangeDraftProvider(employeeId).notifier,
                  )
                  .setRequestedBy,
          onDetailChanged:
              ref
                  .read(
                    employeeContractChangeDraftProvider(employeeId).notifier,
                  )
                  .setDetail,
          onSelectEffectiveDate: () => _selectEffectiveDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (changes.isEmpty)
          const HrisListSurface(child: Text('No contract changes submitted.'))
        else
          ...changes.map(
            (change) => EmployeeContractChangeRequestTile(
              request: change,
              onApprove: () {
                ref
                    .read(
                      employeeContractLifecycleProfileProvider(
                        employeeId,
                      ).notifier,
                    )
                    .approveChange(change.id);
              },
              onSign: () {
                ref
                    .read(
                      employeeContractLifecycleProfileProvider(
                        employeeId,
                      ).notifier,
                    )
                    .signChange(change.id);
              },
              onActivate: () => _activateChange(change),
              onReject: () {
                ref
                    .read(
                      employeeContractLifecycleProfileProvider(
                        employeeId,
                      ).notifier,
                    )
                    .rejectChange(change.id);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(EmployeeContractChangeDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.effectiveDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeContractChangeDraftProvider(draft.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  void _submitDraft(EmployeeContractChangeDraft draft) {
    try {
      final request = ref
          .read(
            employeeContractLifecycleProfileProvider(draft.employeeId).notifier,
          )
          .submitDraft(draft);
      ref
          .read(employeeContractChangeDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.id} submitted for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _activateChange(EmployeeContractChangeRequest change) {
    ref
        .read(
          employeeContractLifecycleProfileProvider(change.employeeId).notifier,
        )
        .activateChange(change.id);
    _showMessage('${change.id} activated for ${change.employeeName}');
  }

  int _changeRank(EmployeeContractChangeStatus status) {
    return switch (status) {
      EmployeeContractChangeStatus.submitted => 0,
      EmployeeContractChangeStatus.approved => 1,
      EmployeeContractChangeStatus.signed => 2,
      EmployeeContractChangeStatus.activated => 3,
      EmployeeContractChangeStatus.rejected => 4,
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
