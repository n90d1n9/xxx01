import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_activity_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_action_activity_provider.dart';
import 'employee_action_activity_form.dart';
import 'employee_action_activity_tiles.dart';

class EmployeeActionActivityPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeActionActivityPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeActionActivityPanel> createState() =>
      _EmployeeActionActivityPanelState();
}

class _EmployeeActionActivityPanelState
    extends ConsumerState<EmployeeActionActivityPanel> {
  final _authorController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeActionActivityProvider(employeeId));
    final draft = ref.watch(employeeActionActivityDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_authorController, draft.author);
    _sync(_bodyController, draft.body);

    final tasks =
        profile.activeTasks.isEmpty ? profile.tasks : profile.activeTasks;

    return HrisSectionPanel(
      icon: Icons.forum_outlined,
      title: 'Action activity log',
      subtitle: profile.nextAction,
      children: [
        EmployeeActionActivitySummaryStrip(profile: profile),
        EmployeeActionActivityForm(
          draft: draft,
          tasks: tasks,
          authorController: _authorController,
          bodyController: _bodyController,
          onTaskChanged:
              ref
                  .read(
                    employeeActionActivityDraftProvider(employeeId).notifier,
                  )
                  .setTaskId,
          onAuthorChanged:
              ref
                  .read(
                    employeeActionActivityDraftProvider(employeeId).notifier,
                  )
                  .setAuthor,
          onBodyChanged:
              ref
                  .read(
                    employeeActionActivityDraftProvider(employeeId).notifier,
                  )
                  .setBody,
          onTypeChanged:
              ref
                  .read(
                    employeeActionActivityDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onVisibilityChanged:
              ref
                  .read(
                    employeeActionActivityDraftProvider(employeeId).notifier,
                  )
                  .setVisibility,
          onSubmit: () => _addEntry(draft),
        ),
        if (profile.latestEntries.isEmpty)
          const HrisEmptyState(message: 'No employee action activity')
        else
          ...profile.latestEntries.map(
            (entry) => EmployeeActionActivityEntryTile(
              entry: entry,
              onAcknowledge: () => _acknowledge(entry),
            ),
          ),
      ],
    );
  }

  void _addEntry(EmployeeActionActivityDraft draft) {
    try {
      final entry = ref
          .read(employeeActionActivityProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeActionActivityDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${entry.type.label} added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _acknowledge(EmployeeActionActivityEntry entry) {
    ref
        .read(employeeActionActivityProvider(entry.employeeId).notifier)
        .acknowledge(entry.id);
    _showMessage('${entry.type.label} acknowledged');
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
