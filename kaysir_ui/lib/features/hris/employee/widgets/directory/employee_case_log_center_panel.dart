import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_case_log_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_case_log_provider.dart';
import 'employee_case_intake_form.dart';
import 'employee_case_log_tiles.dart';
import 'employee_case_note_form.dart';

class EmployeeHrCaseLogCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeHrCaseLogCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeHrCaseLogCenterPanel> createState() =>
      _EmployeeHrCaseLogCenterPanelState();
}

class _EmployeeHrCaseLogCenterPanelState
    extends ConsumerState<EmployeeHrCaseLogCenterPanel> {
  final _caseTitleController = TextEditingController();
  final _caseOwnerController = TextEditingController();
  final _caseSummaryController = TextEditingController();
  final _authorController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _caseTitleController.dispose();
    _caseOwnerController.dispose();
    _caseSummaryController.dispose();
    _authorController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final log = ref.watch(employeeHrCaseLogProvider(employeeId));
    final intakeDraft = ref.watch(
      employeeHrCaseIntakeDraftProvider(employeeId),
    );
    final draft = ref.watch(employeeHrCaseNoteDraftProvider(employeeId));

    if (log == null || intakeDraft == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_caseTitleController, intakeDraft.title);
    _sync(_caseOwnerController, intakeDraft.owner);
    _sync(_caseSummaryController, intakeDraft.summary);
    _sync(_authorController, draft.author);
    _sync(_bodyController, draft.body);

    final cases = log.sortedCases;

    return HrisSectionPanel(
      icon: Icons.folder_shared_outlined,
      title: 'HR case log',
      subtitle: log.nextAction,
      children: [
        EmployeeHrCaseLogSummaryStrip(log: log),
        EmployeeHrCaseIntakeForm(
          draft: intakeDraft,
          titleController: _caseTitleController,
          ownerController: _caseOwnerController,
          summaryController: _caseSummaryController,
          onTitleChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setOwner,
          onSummaryChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setSummary,
          onTypeChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setType,
          onPriorityChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setPriority,
          onConfidentialityChanged:
              ref
                  .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
                  .setConfidentiality,
          onPickFollowUp: () => _pickIntakeFollowUp(employeeId),
          onCreate: () => _createCase(intakeDraft),
        ),
        EmployeeHrCaseNoteForm(
          draft: draft,
          cases: cases,
          authorController: _authorController,
          bodyController: _bodyController,
          onCaseChanged:
              ref
                  .read(employeeHrCaseNoteDraftProvider(employeeId).notifier)
                  .setCaseId,
          onAuthorChanged:
              ref
                  .read(employeeHrCaseNoteDraftProvider(employeeId).notifier)
                  .setAuthor,
          onBodyChanged:
              ref
                  .read(employeeHrCaseNoteDraftProvider(employeeId).notifier)
                  .setBody,
          onConfidentialChanged:
              ref
                  .read(employeeHrCaseNoteDraftProvider(employeeId).notifier)
                  .setConfidential,
          onAdd: () => _addNote(draft),
        ),
        if (cases.isEmpty)
          const HrisListSurface(child: Text('No HR cases recorded yet.'))
        else
          ...cases.map(
            (record) => EmployeeHrCaseRecordTile(
              record: record,
              asOfDate: log.asOfDate,
              onStart:
                  () => ref
                      .read(employeeHrCaseLogProvider(employeeId).notifier)
                      .updateCaseStatus(
                        record.id,
                        EmployeeHrCaseStatus.inProgress,
                      ),
              onResolve:
                  () => ref
                      .read(employeeHrCaseLogProvider(employeeId).notifier)
                      .resolveCase(record.id),
              onScheduleFollowUp: () => _scheduleFollowUp(record),
            ),
          ),
        ...log.latestNotes.map(
          (note) => EmployeeHrCaseNoteTile(
            note: note,
            caseRecord: _caseFor(log.cases, note.caseId),
          ),
        ),
      ],
    );
  }

  Future<void> _pickIntakeFollowUp(String employeeId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.snapshot.asOfDate.add(const Duration(days: 7)),
      firstDate: widget.snapshot.asOfDate,
      lastDate: widget.snapshot.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeHrCaseIntakeDraftProvider(employeeId).notifier)
        .setFollowUpDate(picked);
  }

  Future<void> _scheduleFollowUp(EmployeeHrCaseRecord record) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.snapshot.asOfDate.add(const Duration(days: 7)),
      firstDate: widget.snapshot.asOfDate.subtract(const Duration(days: 30)),
      lastDate: widget.snapshot.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeHrCaseLogProvider(record.employeeId).notifier)
        .scheduleFollowUp(record.id, picked);
  }

  void _createCase(EmployeeHrCaseIntakeDraft draft) {
    try {
      final record = ref
          .read(employeeHrCaseLogProvider(draft.employeeId).notifier)
          .createCase(draft);
      ref
          .read(employeeHrCaseIntakeDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${record.title} created');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _addNote(EmployeeHrCaseNoteDraft draft) {
    try {
      final note = ref
          .read(employeeHrCaseLogProvider(draft.employeeId).notifier)
          .addNote(draft);
      ref
          .read(employeeHrCaseNoteDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${note.id} added for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  EmployeeHrCaseRecord? _caseFor(
    List<EmployeeHrCaseRecord> cases,
    String caseId,
  ) {
    for (final record in cases) {
      if (record.id == caseId) return record;
    }
    return null;
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
