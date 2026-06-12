import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_timeline_models.dart';
import '../../states/employee_timeline_provider.dart';
import 'employee_timeline_form.dart';
import 'employee_timeline_tiles.dart';

class EmployeeTimelineCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeTimelineCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeTimelineCenterPanel> createState() =>
      _EmployeeTimelineCenterPanelState();
}

class _EmployeeTimelineCenterPanelState
    extends ConsumerState<EmployeeTimelineCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeTimelineProfileProvider(employeeId));
    final draft = ref.watch(employeeTimelineDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_detailController, draft.detail);

    final entries = [...profile.entries]..sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      return b.occurredAt.compareTo(a.occurredAt);
    });

    return HrisSectionPanel(
      icon: Icons.timeline_outlined,
      title: 'Employee 360 timeline',
      subtitle: profile.nextAction,
      children: [
        EmployeeTimelineSummaryStrip(profile: profile),
        EmployeeTimelineEntryForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          detailController: _detailController,
          onTypeChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setType,
          onPriorityChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setPriority,
          onTitleChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setOwner,
          onDetailChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setDetail,
          onPinnedChanged:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .setPinned,
          onSelectOccurredAt: () => _selectOccurredAt(draft),
          onSelectDueAt: () => _selectDueAt(draft),
          onClearDueAt:
              ref
                  .read(employeeTimelineDraftProvider(employeeId).notifier)
                  .clearDueAt,
          onSubmit: () => _addEntry(draft),
        ),
        ...entries.map(
          (entry) => EmployeeTimelineEntryTile(
            entry: entry,
            asOfDate: profile.asOfDate,
            onResolve:
                () => ref
                    .read(employeeTimelineProfileProvider(employeeId).notifier)
                    .resolveEntry(entry.id),
            onReopen:
                () => ref
                    .read(employeeTimelineProfileProvider(employeeId).notifier)
                    .reopenEntry(entry.id),
            onTogglePinned:
                () => ref
                    .read(employeeTimelineProfileProvider(employeeId).notifier)
                    .togglePinned(entry.id),
          ),
        ),
      ],
    );
  }

  Future<void> _selectOccurredAt(EmployeeTimelineDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.occurredAt,
      firstDate: draft.asOfDate.subtract(const Duration(days: 3650)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(employeeTimelineDraftProvider(draft.employeeId).notifier)
        .setOccurredAt(picked);
  }

  Future<void> _selectDueAt(EmployeeTimelineDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueAt ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.occurredAt,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeTimelineDraftProvider(draft.employeeId).notifier)
        .setDueAt(picked);
  }

  void _addEntry(EmployeeTimelineDraft draft) {
    try {
      final entry = ref
          .read(employeeTimelineProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeTimelineDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${entry.id} added to ${entry.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  int _attentionRank(EmployeeTimelineEntry entry, DateTime asOfDate) {
    return entry.needsAttention(asOfDate) ? 0 : 1;
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
