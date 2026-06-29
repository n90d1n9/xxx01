import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_manager_change_readiness_models.dart';
import '../../states/employee_manager_change_readiness_provider.dart';
import 'employee_manager_change_checklist_form.dart';
import 'employee_manager_change_readiness_tiles.dart';

class EmployeeManagerChangeReadinessCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeManagerChangeReadinessCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeManagerChangeReadinessCenterPanel> createState() =>
      _EmployeeManagerChangeReadinessCenterPanelState();
}

class _EmployeeManagerChangeReadinessCenterPanelState
    extends ConsumerState<EmployeeManagerChangeReadinessCenterPanel> {
  final _targetManagerController = TextEditingController();
  final _reasonController = TextEditingController();
  final _itemTitleController = TextEditingController();
  final _itemOwnerController = TextEditingController();
  final _itemDetailController = TextEditingController();

  @override
  void dispose() {
    _targetManagerController.dispose();
    _reasonController.dispose();
    _itemTitleController.dispose();
    _itemOwnerController.dispose();
    _itemDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeManagerChangeReadinessProvider(employeeId),
    );
    final draft = ref.watch(
      employeeManagerChangeChecklistDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_targetManagerController, profile.targetManager);
    _sync(_reasonController, profile.reason);
    _sync(_itemTitleController, draft.title);
    _sync(_itemOwnerController, draft.owner);
    _sync(_itemDetailController, draft.detail);

    return HrisSectionPanel(
      icon: Icons.manage_accounts_outlined,
      title: 'Manager change readiness',
      subtitle: profile.nextAction,
      children: [
        EmployeeManagerChangeSummaryStrip(profile: profile),
        EmployeeManagerChangeTargetCard(
          profile: profile,
          targetManagerController: _targetManagerController,
          reasonController: _reasonController,
          onChangeTypeChanged:
              ref
                  .read(
                    employeeManagerChangeReadinessProvider(employeeId).notifier,
                  )
                  .setChangeType,
          onTargetManagerChanged:
              ref
                  .read(
                    employeeManagerChangeReadinessProvider(employeeId).notifier,
                  )
                  .setTargetManager,
          onReasonChanged:
              ref
                  .read(
                    employeeManagerChangeReadinessProvider(employeeId).notifier,
                  )
                  .setReason,
          onSelectEffectiveDate: () => _selectEffectiveDate(profile),
          onReset:
              ref
                  .read(
                    employeeManagerChangeReadinessProvider(employeeId).notifier,
                  )
                  .resetToPreset,
        ),
        EmployeeManagerChangeChecklistForm(
          draft: draft,
          titleController: _itemTitleController,
          ownerController: _itemOwnerController,
          detailController: _itemDetailController,
          onTypeChanged:
              ref
                  .read(
                    employeeManagerChangeChecklistDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeeManagerChangeChecklistDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(
                    employeeManagerChangeChecklistDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onRiskChanged:
              ref
                  .read(
                    employeeManagerChangeChecklistDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRisk,
          onDetailChanged:
              ref
                  .read(
                    employeeManagerChangeChecklistDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setDetail,
          onSelectDueDate: () => _selectDueDate(draft),
          onAdd: () => _addChecklistItem(draft),
        ),
        if (profile.checklist.isEmpty)
          const HrisEmptyState(message: 'No manager change checklist items')
        else
          ...profile.sortedChecklist.map(
            (item) => EmployeeManagerChangeChecklistTile(
              item: item,
              asOfDate: profile.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(
                        employeeManagerChangeReadinessProvider(
                          employeeId,
                        ).notifier,
                      )
                      .updateChecklistStatus(item.id, status),
              onWaive:
                  () => ref
                      .read(
                        employeeManagerChangeReadinessProvider(
                          employeeId,
                        ).notifier,
                      )
                      .waiveChecklistItem(item.id),
              onReopen:
                  () => ref
                      .read(
                        employeeManagerChangeReadinessProvider(
                          employeeId,
                        ).notifier,
                      )
                      .reopenChecklistItem(item.id),
              onRemove:
                  () => ref
                      .read(
                        employeeManagerChangeReadinessProvider(
                          employeeId,
                        ).notifier,
                      )
                      .removeChecklistItem(item.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(
    EmployeeManagerChangeReadinessProfile profile,
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
        .read(
          employeeManagerChangeReadinessProvider(profile.employeeId).notifier,
        )
        .setEffectiveDate(picked);
  }

  Future<void> _selectDueDate(EmployeeManagerChangeChecklistDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeManagerChangeChecklistDraftProvider(
            draft.employeeId,
          ).notifier,
        )
        .setDueDate(picked);
  }

  void _addChecklistItem(EmployeeManagerChangeChecklistDraft draft) {
    try {
      final item = ref
          .read(
            employeeManagerChangeReadinessProvider(draft.employeeId).notifier,
          )
          .addChecklistItem(draft);
      ref
          .read(
            employeeManagerChangeChecklistDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${item.title} added to ${draft.employeeName}');
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
