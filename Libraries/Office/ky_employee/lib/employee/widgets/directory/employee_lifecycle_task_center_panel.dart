import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_lifecycle_task_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_lifecycle_task_provider.dart';
import 'employee_lifecycle_task_tiles.dart';

class EmployeeLifecycleTaskCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeLifecycleTaskCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeLifecycleTaskCenterPanel> createState() =>
      _EmployeeLifecycleTaskCenterPanelState();
}

class _EmployeeLifecycleTaskCenterPanelState
    extends ConsumerState<EmployeeLifecycleTaskCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final plan = ref.watch(employeeLifecyclePlanProvider(employeeId));
    final draft = ref.watch(employeeLifecycleTaskDraftProvider(employeeId));

    if (plan == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);

    final tasks = [...plan.tasks]..sort((a, b) {
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Lifecycle task center',
      subtitle: plan.nextAction,
      children: [
        EmployeeLifecyclePlanSummaryStrip(plan: plan),
        _PlanControlCard(
          plan: plan,
          onTypeChanged:
              ref
                  .read(employeeLifecyclePlanProvider(employeeId).notifier)
                  .setPlanType,
          onReset:
              ref
                  .read(employeeLifecyclePlanProvider(employeeId).notifier)
                  .resetToPreset,
        ),
        _TaskDraftForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          onTitleChanged:
              ref
                  .read(employeeLifecycleTaskDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeLifecycleTaskDraftProvider(employeeId).notifier)
                  .setOwner,
          onPriorityChanged:
              ref
                  .read(employeeLifecycleTaskDraftProvider(employeeId).notifier)
                  .setPriority,
          onSelectDate: () => _selectDueDate(draft),
          onAdd: () => _addTask(draft),
        ),
        if (tasks.isEmpty)
          const HrisListSurface(
            child: Text('No lifecycle tasks are assigned yet.'),
          )
        else
          ...tasks.map(
            (task) => EmployeeLifecycleTaskTile(
              task: task,
              asOfDate: plan.asOfDate,
              onStatusChanged:
                  (status) => ref
                      .read(employeeLifecyclePlanProvider(employeeId).notifier)
                      .updateTaskStatus(task.id, status),
              onRemove:
                  () => ref
                      .read(employeeLifecyclePlanProvider(employeeId).notifier)
                      .removeTask(task.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeLifecycleTaskDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeLifecycleTaskDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _addTask(EmployeeLifecycleTaskDraft draft) {
    try {
      final task = ref
          .read(employeeLifecyclePlanProvider(draft.employeeId).notifier)
          .addTask(draft);
      ref
          .read(employeeLifecycleTaskDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${task.title} added to ${draft.employeeName}');
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

class _PlanControlCard extends StatelessWidget {
  final EmployeeLifecyclePlan plan;
  final ValueChanged<EmployeeLifecyclePlanType> onTypeChanged;
  final VoidCallback onReset;

  const _PlanControlCard({
    required this.plan,
    required this.onTypeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeLifecyclePlanType>(
              segments:
                  EmployeeLifecyclePlanType.values
                      .map(
                        (type) =>
                            ButtonSegment(value: type, label: Text(type.label)),
                      )
                      .toList(),
              selected: {plan.type},
              onSelectionChanged:
                  (selection) => onTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.completionRatio,
            color:
                plan.blockedCount > 0
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF15803D),
            label: '${(plan.completionRatio * 100).round()}% complete',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reset preset'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDraftForm extends StatelessWidget {
  final EmployeeLifecycleTaskDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<EmployeeLifecycleTaskPriority> onPriorityChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onAdd;

  const _TaskDraftForm({
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onPriorityChanged,
    required this.onSelectDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.playlist_add_check_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _DueDateField(draft: draft, onTap: onSelectDate),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeLifecycleTaskPriority>(
            initialValue: draft.priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeLifecycleTaskPriority.values
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.label),
                      ),
                    )
                    .toList(),
            onChanged: (priority) {
              if (priority != null) onPriorityChanged(priority);
            },
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add task'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  final EmployeeLifecycleTaskDraft draft;
  final VoidCallback onTap;

  const _DueDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          draft.dueDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.dueDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.dueDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
