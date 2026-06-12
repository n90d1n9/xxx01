import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_workflow_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_action_workflow_provider.dart';
import 'employee_action_workflow_form.dart';
import 'employee_action_workflow_tiles.dart';

class EmployeeActionWorkflowPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeActionWorkflowPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeActionWorkflowPanel> createState() =>
      _EmployeeActionWorkflowPanelState();
}

class _EmployeeActionWorkflowPanelState
    extends ConsumerState<EmployeeActionWorkflowPanel> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeActionWorkflowProvider(employeeId));
    final draft = ref.watch(employeeActionTaskDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_descriptionController, draft.description);
    _sync(_ownerController, draft.owner);

    final tasks = profile.sortedTasks;

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Action workflow',
      subtitle: profile.nextAction,
      children: [
        EmployeeActionWorkflowSummaryStrip(profile: profile),
        EmployeeActionWorkflowForm(
          draft: draft,
          titleController: _titleController,
          descriptionController: _descriptionController,
          ownerController: _ownerController,
          onTitleChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setTitle,
          onDescriptionChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setDescription,
          onOwnerChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setOwner,
          onAreaChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setArea,
          onPriorityChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setPriority,
          onDueDateChanged:
              ref
                  .read(employeeActionTaskDraftProvider(employeeId).notifier)
                  .setDueDate,
          onSubmit: () => _addTask(draft),
        ),
        if (tasks.isEmpty)
          const HrisEmptyState(message: 'No employee workflow tasks')
        else
          ...tasks.map(
            (task) => EmployeeActionWorkflowTaskTile(
              task: task,
              asOfDate: profile.asOfDate,
              onStart: () => _startTask(task),
              onWait: () => _markWaiting(task),
              onComplete: () => _completeTask(task),
              onReopen: () => _reopenTask(task),
              onCancel: () => _cancelTask(task),
            ),
          ),
      ],
    );
  }

  void _addTask(EmployeeActionTaskDraft draft) {
    try {
      final task = ref
          .read(employeeActionWorkflowProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeActionTaskDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${task.title} added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _startTask(EmployeeActionTask task) {
    ref
        .read(employeeActionWorkflowProvider(task.employeeId).notifier)
        .startTask(task.id);
    _showMessage('${task.title} started');
  }

  void _markWaiting(EmployeeActionTask task) {
    ref
        .read(employeeActionWorkflowProvider(task.employeeId).notifier)
        .markWaiting(task.id);
    _showMessage('${task.title} waiting');
  }

  void _completeTask(EmployeeActionTask task) {
    ref
        .read(employeeActionWorkflowProvider(task.employeeId).notifier)
        .completeTask(task.id);
    _showMessage('${task.title} completed');
  }

  void _reopenTask(EmployeeActionTask task) {
    ref
        .read(employeeActionWorkflowProvider(task.employeeId).notifier)
        .reopenTask(task.id);
    _showMessage('${task.title} reopened');
  }

  void _cancelTask(EmployeeActionTask task) {
    ref
        .read(employeeActionWorkflowProvider(task.employeeId).notifier)
        .cancelTask(task.id);
    _showMessage('${task.title} cancelled');
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
