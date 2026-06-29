import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_relations_models.dart';
import '../../states/employee_relations_provider.dart';
import 'employee_relations_event_form.dart';
import 'employee_relations_tiles.dart';

class EmployeeRelationsCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeRelationsCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeRelationsCenterPanel> createState() =>
      _EmployeeRelationsCenterPanelState();
}

class _EmployeeRelationsCenterPanelState
    extends ConsumerState<EmployeeRelationsCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeRelationsProfileProvider(employeeId));
    final draft = ref.watch(employeeRelationsEventDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_summaryController, draft.summary);

    final events = [...profile.events]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      final openCompare = _openRank(a).compareTo(_openRank(b));
      if (openCompare != 0) return openCompare;
      return b.occurredAt.compareTo(a.occurredAt);
    });

    return HrisSectionPanel(
      icon: Icons.handshake_outlined,
      title: 'Recognition and conduct',
      subtitle: profile.nextAction,
      children: [
        EmployeeRelationsSummaryStrip(profile: profile),
        EmployeeRelationsEventForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          summaryController: _summaryController,
          onTypeChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onTitleChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onSummaryChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setSummary,
          onSeverityChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setSeverity,
          onVisibilityChanged:
              ref
                  .read(
                    employeeRelationsEventDraftProvider(employeeId).notifier,
                  )
                  .setVisibility,
          onSelectOccurredAt: () => _selectOccurredAt(draft),
          onSelectFollowUpDate: () => _selectFollowUpDate(draft),
          onSubmit: () => _recordEvent(draft),
        ),
        if (events.isEmpty)
          const HrisListSurface(child: Text('No relations events recorded.'))
        else
          ...events.map(
            (event) => EmployeeRelationsEventTile(
              event: event,
              asOfDate: profile.asOfDate,
              onStartFollowUp: () {
                ref
                    .read(employeeRelationsProfileProvider(employeeId).notifier)
                    .startFollowUp(event.id);
              },
              onResolve: () => _resolveEvent(event),
              onArchive: () {
                ref
                    .read(employeeRelationsProfileProvider(employeeId).notifier)
                    .archiveEvent(event.id);
                _showMessage('${event.title} archived');
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectOccurredAt(EmployeeRelationsEventDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.occurredAt,
      firstDate: draft.asOfDate.subtract(const Duration(days: 365)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(employeeRelationsEventDraftProvider(draft.employeeId).notifier)
        .setOccurredAt(picked);
  }

  Future<void> _selectFollowUpDate(EmployeeRelationsEventDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.followUpDate,
      firstDate: draft.occurredAt,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeRelationsEventDraftProvider(draft.employeeId).notifier)
        .setFollowUpDate(picked);
  }

  void _recordEvent(EmployeeRelationsEventDraft draft) {
    try {
      final event = ref
          .read(employeeRelationsProfileProvider(draft.employeeId).notifier)
          .recordEvent(draft);
      ref
          .read(employeeRelationsEventDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${event.title} recorded for ${event.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _resolveEvent(EmployeeRelationsEvent event) {
    ref
        .read(employeeRelationsProfileProvider(event.employeeId).notifier)
        .resolveEvent(event.id);
    _showMessage('${event.title} resolved');
  }

  int _attentionRank(EmployeeRelationsEvent event, DateTime asOfDate) {
    return event.needsAttention(asOfDate) ? 0 : 1;
  }

  int _openRank(EmployeeRelationsEvent event) {
    if (event.isOpen) return 0;
    if (event.isPositive) return 1;
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
