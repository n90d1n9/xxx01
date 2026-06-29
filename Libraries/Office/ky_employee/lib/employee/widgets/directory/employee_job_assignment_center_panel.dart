import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_assignment_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_job_assignment_provider.dart';
import 'employee_job_assignment_form.dart';
import 'employee_job_assignment_tiles.dart';

class EmployeeJobAssignmentCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeJobAssignmentCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeJobAssignmentCenterPanel> createState() =>
      _EmployeeJobAssignmentCenterPanelState();
}

class _EmployeeJobAssignmentCenterPanelState
    extends ConsumerState<EmployeeJobAssignmentCenterPanel> {
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _managerController = TextEditingController();
  final _locationController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _gradeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    _departmentController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _costCenterController.dispose();
    _gradeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeJobAssignmentProfileProvider(employeeId));
    final draft = ref.watch(employeeJobAssignmentDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_positionController, draft.position);
    _sync(_departmentController, draft.department);
    _sync(_managerController, draft.manager);
    _sync(_locationController, draft.location);
    _sync(_costCenterController, draft.costCenter);
    _sync(_gradeController, draft.grade);
    _sync(_notesController, draft.notes);

    final currentAssignment = profile.currentAssignment;
    final timeline =
        profile.assignments
            .where((assignment) => assignment.id != currentAssignment?.id)
            .toList()
          ..sort((a, b) {
            final attentionCompare = _attentionRank(
              a,
            ).compareTo(_attentionRank(b));
            if (attentionCompare != 0) return attentionCompare;
            return b.startDate.compareTo(a.startDate);
          });

    return HrisSectionPanel(
      icon: Icons.badge_outlined,
      title: 'Job assignment center',
      subtitle: profile.nextAction,
      children: [
        EmployeeJobAssignmentSummaryStrip(profile: profile),
        if (currentAssignment == null)
          const HrisListSurface(child: Text('No active assignment found.'))
        else
          EmployeeJobAssignmentCurrentCard(
            assignment: currentAssignment,
            asOfDate: profile.asOfDate,
          ),
        EmployeeJobAssignmentForm(
          draft: draft,
          positionController: _positionController,
          departmentController: _departmentController,
          managerController: _managerController,
          locationController: _locationController,
          costCenterController: _costCenterController,
          gradeController: _gradeController,
          notesController: _notesController,
          onPositionChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setPosition,
          onDepartmentChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setDepartment,
          onManagerChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setManager,
          onLocationChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setLocation,
          onCostCenterChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setCostCenter,
          onGradeChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setGrade,
          onContractTypeChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setContractType,
          onArrangementChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setArrangement,
          onAssignmentTypeChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setAssignmentType,
          onNotesChanged:
              ref
                  .read(employeeJobAssignmentDraftProvider(employeeId).notifier)
                  .setNotes,
          onSelectStartDate: () => _selectStartDate(draft),
          onAdd: () => _addAssignment(draft),
        ),
        if (timeline.isEmpty)
          const HrisListSurface(
            child: Text('No scheduled or historical assignment changes.'),
          )
        else
          ...timeline.map(
            (assignment) => EmployeeJobAssignmentRecordTile(
              assignment: assignment,
              asOfDate: profile.asOfDate,
              onApprove: () => _approve(assignment),
              onActivate: () => _activate(assignment),
            ),
          ),
      ],
    );
  }

  Future<void> _selectStartDate(EmployeeJobAssignmentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.startDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 1825)),
    );
    if (picked == null) return;
    ref
        .read(employeeJobAssignmentDraftProvider(draft.employeeId).notifier)
        .setStartDate(picked);
  }

  void _addAssignment(EmployeeJobAssignmentDraft draft) {
    try {
      final assignment = ref
          .read(employeeJobAssignmentProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeJobAssignmentDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${assignment.id} scheduled for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _approve(EmployeeJobAssignmentRecord assignment) {
    ref
        .read(
          employeeJobAssignmentProfileProvider(assignment.employeeId).notifier,
        )
        .approve(assignment.id);
    _showMessage('${assignment.id} approved');
  }

  void _activate(EmployeeJobAssignmentRecord assignment) {
    ref
        .read(
          employeeJobAssignmentProfileProvider(assignment.employeeId).notifier,
        )
        .activate(assignment.id);
    _showMessage('${assignment.id} activated');
  }

  int _attentionRank(EmployeeJobAssignmentRecord assignment) {
    if (assignment.needsAttention(widget.snapshot.asOfDate)) return 0;
    if (assignment.status == EmployeeJobAssignmentStatus.scheduled) return 1;
    if (assignment.status == EmployeeJobAssignmentStatus.completed) return 3;
    return 2;
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
