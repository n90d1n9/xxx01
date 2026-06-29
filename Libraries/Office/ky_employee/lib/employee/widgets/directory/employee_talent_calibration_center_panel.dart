import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_talent_calibration_models.dart';
import '../../states/employee_talent_calibration_provider.dart';
import 'employee_talent_calibration_tiles.dart';
import 'employee_talent_follow_up_form.dart';

class EmployeeTalentCalibrationCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeTalentCalibrationCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeTalentCalibrationCenterPanel> createState() =>
      _EmployeeTalentCalibrationCenterPanelState();
}

class _EmployeeTalentCalibrationCenterPanelState
    extends ConsumerState<EmployeeTalentCalibrationCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeTalentCalibrationProvider(employeeId));
    final draft = ref.watch(employeeTalentFollowUpDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_notesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.grid_view_outlined,
      title: 'Talent calibration',
      subtitle: profile.nextAction,
      children: [
        EmployeeTalentCalibrationSummaryStrip(profile: profile),
        EmployeeTalentCalibrationCard(
          profile: profile,
          onPerformanceChanged:
              ref
                  .read(employeeTalentCalibrationProvider(employeeId).notifier)
                  .setPerformanceBand,
          onPotentialChanged:
              ref
                  .read(employeeTalentCalibrationProvider(employeeId).notifier)
                  .setPotentialBand,
          onRiskChanged:
              ref
                  .read(employeeTalentCalibrationProvider(employeeId).notifier)
                  .setRiskLevel,
          onDecisionChanged:
              ref
                  .read(employeeTalentCalibrationProvider(employeeId).notifier)
                  .setDecision,
          onMarkCalibrated: () {
            ref
                .read(employeeTalentCalibrationProvider(employeeId).notifier)
                .markCalibrated();
            _showMessage('Talent calibration marked current');
          },
          onMarkDisputed: () {
            ref
                .read(employeeTalentCalibrationProvider(employeeId).notifier)
                .markDisputed();
            _showMessage('Talent calibration marked disputed');
          },
        ),
        EmployeeTalentFollowUpForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          notesController: _notesController,
          onTypeChanged:
              ref
                  .read(
                    employeeTalentFollowUpDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeeTalentFollowUpDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(
                    employeeTalentFollowUpDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onNotesChanged:
              ref
                  .read(
                    employeeTalentFollowUpDraftProvider(employeeId).notifier,
                  )
                  .setNotes,
          onSelectDueDate: () => _selectDueDate(draft),
          onAdd: () => _addFollowUp(draft),
        ),
        if (profile.followUps.isEmpty)
          const HrisListSurface(child: Text('No calibration follow-ups yet.'))
        else
          ...profile.sortedFollowUps.map(
            (followUp) => EmployeeTalentFollowUpTile(
              followUp: followUp,
              asOfDate: profile.asOfDate,
              onStart: () {
                ref
                    .read(
                      employeeTalentCalibrationProvider(employeeId).notifier,
                    )
                    .startFollowUp(followUp.id);
              },
              onComplete: () {
                ref
                    .read(
                      employeeTalentCalibrationProvider(employeeId).notifier,
                    )
                    .completeFollowUp(followUp.id);
              },
              onWaive: () {
                ref
                    .read(
                      employeeTalentCalibrationProvider(employeeId).notifier,
                    )
                    .waiveFollowUp(followUp.id);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeTalentFollowUpDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.dueDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeTalentFollowUpDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _addFollowUp(EmployeeTalentFollowUpDraft draft) {
    try {
      final followUp = ref
          .read(employeeTalentCalibrationProvider(draft.employeeId).notifier)
          .addFollowUp(draft);
      ref
          .read(employeeTalentFollowUpDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${followUp.title} added');
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
