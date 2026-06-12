import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_history_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_job_history_provider.dart';
import 'employee_job_history_event_form.dart';
import 'employee_job_history_tiles.dart';

class EmployeeJobHistoryCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeJobHistoryCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeJobHistoryCenterPanel> createState() =>
      _EmployeeJobHistoryCenterPanelState();
}

class _EmployeeJobHistoryCenterPanelState
    extends ConsumerState<EmployeeJobHistoryCenterPanel> {
  final _titleController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();
  final _evidenceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _ownerController.dispose();
    _noteController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeJobHistoryProfileProvider(employeeId));
    final draft = ref.watch(employeeJobHistoryDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_fromController, draft.fromValue);
    _sync(_toController, draft.toValue);
    _sync(_ownerController, draft.owner);
    _sync(_noteController, draft.note);
    _sync(_evidenceController, draft.evidence);

    return HrisSectionPanel(
      icon: Icons.history_edu_outlined,
      title: 'Job history ledger',
      subtitle: profile.nextAction,
      children: [
        EmployeeJobHistorySummaryStrip(profile: profile),
        EmployeeJobHistoryCurrentCard(profile: profile),
        EmployeeJobHistoryEventForm(
          draft: draft,
          titleController: _titleController,
          fromController: _fromController,
          toController: _toController,
          ownerController: _ownerController,
          noteController: _noteController,
          evidenceController: _evidenceController,
          onTypeChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setType,
          onTitleChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setTitle,
          onFromChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setFromValue,
          onToChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setToValue,
          onSourceChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setSource,
          onOwnerChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setOwner,
          onNoteChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setNote,
          onEvidenceChanged:
              ref
                  .read(employeeJobHistoryDraftProvider(employeeId).notifier)
                  .setEvidence,
          onSelectEffectiveDate: () => _selectEffectiveDate(draft),
          onAdd: () => _addEvent(draft),
        ),
        if (profile.history.isEmpty)
          const HrisEmptyState(message: 'No job history events recorded')
        else
          ...profile.sortedHistory.map(
            (event) => EmployeeJobHistoryEventTile(
              event: event,
              asOfDate: profile.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(
                        employeeJobHistoryProfileProvider(employeeId).notifier,
                      )
                      .updateStatus(event.id, status),
              onAttachEvidence: () => _attachEvidence(event),
              onMarkEffective: () => _markEffective(event),
              onRequestEvidence: () => _requestEvidence(event),
              onReverse: () => _reverseEvent(event),
              onRemove:
                  () => ref
                      .read(
                        employeeJobHistoryProfileProvider(employeeId).notifier,
                      )
                      .removeEvent(event.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(EmployeeJobHistoryEventDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.effectiveDate ?? draft.asOfDate,
      firstDate: draft.earliestDate,
      lastDate: draft.asOfDate.add(const Duration(days: 1825)),
    );
    if (picked == null) return;
    ref
        .read(employeeJobHistoryDraftProvider(draft.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  void _addEvent(EmployeeJobHistoryEventDraft draft) {
    try {
      final event = ref
          .read(employeeJobHistoryProfileProvider(draft.employeeId).notifier)
          .addEvent(draft);
      ref
          .read(employeeJobHistoryDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${event.title} added to ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _attachEvidence(EmployeeJobHistoryEvent event) {
    ref
        .read(employeeJobHistoryProfileProvider(event.employeeId).notifier)
        .attachEvidence(event.id);
    _showMessage('Evidence attached for ${event.title}');
  }

  void _markEffective(EmployeeJobHistoryEvent event) {
    ref
        .read(employeeJobHistoryProfileProvider(event.employeeId).notifier)
        .markEffective(event.id);
    _showMessage('${event.title} marked effective');
  }

  void _requestEvidence(EmployeeJobHistoryEvent event) {
    ref
        .read(employeeJobHistoryProfileProvider(event.employeeId).notifier)
        .requestEvidence(event.id);
    _showMessage('Evidence requested for ${event.title}');
  }

  void _reverseEvent(EmployeeJobHistoryEvent event) {
    ref
        .read(employeeJobHistoryProfileProvider(event.employeeId).notifier)
        .reverseEvent(event.id);
    _showMessage('${event.title} reversed');
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
