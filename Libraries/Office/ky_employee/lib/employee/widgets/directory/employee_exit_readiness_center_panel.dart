import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_exit_readiness_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_exit_readiness_provider.dart';
import 'employee_exit_clearance_form.dart';
import 'employee_exit_readiness_tiles.dart';

class EmployeeExitReadinessCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeExitReadinessCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeExitReadinessCenterPanel> createState() =>
      _EmployeeExitReadinessCenterPanelState();
}

class _EmployeeExitReadinessCenterPanelState
    extends ConsumerState<EmployeeExitReadinessCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeExitReadinessProvider(employeeId));
    final draft = ref.watch(employeeExitClearanceDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_noteController, draft.note);

    return HrisSectionPanel(
      icon: Icons.logout_outlined,
      title: 'Exit readiness',
      subtitle: profile.nextAction,
      children: [
        EmployeeExitReadinessSummaryStrip(profile: profile),
        EmployeeExitPlanCard(
          profile: profile,
          onTypeChanged:
              ref
                  .read(employeeExitReadinessProvider(employeeId).notifier)
                  .setExitType,
          onSelectFinalWorkday: () => _selectFinalWorkday(profile),
          onReset:
              ref
                  .read(employeeExitReadinessProvider(employeeId).notifier)
                  .resetToPreset,
        ),
        EmployeeExitClearanceForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          noteController: _noteController,
          onTitleChanged:
              ref
                  .read(employeeExitClearanceDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeExitClearanceDraftProvider(employeeId).notifier)
                  .setOwner,
          onCategoryChanged:
              ref
                  .read(employeeExitClearanceDraftProvider(employeeId).notifier)
                  .setCategory,
          onRiskChanged:
              ref
                  .read(employeeExitClearanceDraftProvider(employeeId).notifier)
                  .setRisk,
          onNoteChanged:
              ref
                  .read(employeeExitClearanceDraftProvider(employeeId).notifier)
                  .setNote,
          onSelectDate: () => _selectDueDate(draft),
          onAdd: () => _addItem(draft),
        ),
        if (profile.items.isEmpty)
          const HrisEmptyState(message: 'No exit clearance items yet')
        else
          ...profile.sortedItems.map(
            (item) => EmployeeExitClearanceTile(
              item: item,
              asOfDate: profile.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(employeeExitReadinessProvider(employeeId).notifier)
                      .updateItemStatus(item.id, status),
              onWaive:
                  () => ref
                      .read(employeeExitReadinessProvider(employeeId).notifier)
                      .waiveItem(item.id),
              onReopen:
                  () => ref
                      .read(employeeExitReadinessProvider(employeeId).notifier)
                      .reopenItem(item.id),
              onRemove:
                  () => ref
                      .read(employeeExitReadinessProvider(employeeId).notifier)
                      .removeItem(item.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectFinalWorkday(EmployeeExitReadinessProfile profile) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          profile.finalWorkday.isBefore(profile.asOfDate)
              ? profile.asOfDate
              : profile.finalWorkday,
      firstDate: profile.asOfDate,
      lastDate: profile.asOfDate.add(const Duration(days: 1095)),
    );
    if (picked == null) return;
    ref
        .read(employeeExitReadinessProvider(profile.employeeId).notifier)
        .setFinalWorkday(picked);
  }

  Future<void> _selectDueDate(EmployeeExitClearanceDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 1095)),
    );
    if (picked == null) return;
    ref
        .read(employeeExitClearanceDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _addItem(EmployeeExitClearanceDraft draft) {
    try {
      final item = ref
          .read(employeeExitReadinessProvider(draft.employeeId).notifier)
          .addItem(draft);
      ref
          .read(employeeExitClearanceDraftProvider(draft.employeeId).notifier)
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
