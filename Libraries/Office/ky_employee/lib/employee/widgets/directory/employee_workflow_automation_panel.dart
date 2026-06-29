import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_workflow_automation_models.dart';
import '../../states/employee_workflow_automation_provider.dart';
import 'employee_workflow_automation_form.dart';
import 'employee_workflow_automation_tiles.dart';

class EmployeeWorkflowAutomationPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeWorkflowAutomationPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeWorkflowAutomationPanel> createState() =>
      _EmployeeWorkflowAutomationPanelState();
}

class _EmployeeWorkflowAutomationPanelState
    extends ConsumerState<EmployeeWorkflowAutomationPanel> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _sourceController = TextEditingController();
  final _taskTitleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _sourceController.dispose();
    _taskTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeWorkflowAutomationProfileProvider(employeeId),
    );
    final draft = ref.watch(
      employeeWorkflowAutomationDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_nameController, draft.name);
    _sync(_ownerController, draft.owner);
    _sync(_sourceController, draft.sourceLabel);
    _sync(_taskTitleController, draft.generatedTaskTitle);
    _sync(_notesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.auto_awesome_motion_outlined,
      title: 'Workflow automation hooks',
      subtitle: profile.nextAction,
      children: [
        EmployeeWorkflowAutomationSummaryStrip(profile: profile),
        EmployeeWorkflowAutomationStatusCard(profile: profile),
        EmployeeWorkflowAutomationForm(
          draft: draft,
          nameController: _nameController,
          ownerController: _ownerController,
          sourceController: _sourceController,
          taskTitleController: _taskTitleController,
          notesController: _notesController,
          onNameChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setName,
          onTriggerChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTrigger,
          onDeliveryChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setDelivery,
          onOwnerChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onSourceChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSourceLabel,
          onTaskTitleChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setGeneratedTaskTitle,
          onSlaHoursChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSlaHours,
          onRiskChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRisk,
          onNotesChanged:
              ref
                  .read(
                    employeeWorkflowAutomationDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNotes,
          onSelectNextRun: () => _selectNextRun(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (profile.hooks.isEmpty)
          const HrisEmptyState(message: 'No workflow automation hooks')
        else
          ...profile.sortedHooks.map(
            (hook) => EmployeeWorkflowAutomationHookTile(
              hook: hook,
              asOfDate: profile.asOfDate,
              onRun: () => _runHook(hook),
              onActivate: () => _activateHook(hook),
              onPause: () => _pauseHook(hook),
              onFail: () => _failHook(hook),
              onRemove:
                  () => ref
                      .read(
                        employeeWorkflowAutomationProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .remove(hook.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectNextRun(EmployeeWorkflowAutomationHookDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.nextRunAt ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeWorkflowAutomationDraftProvider(draft.employeeId).notifier,
        )
        .setNextRunAt(picked);
  }

  void _submitDraft(EmployeeWorkflowAutomationHookDraft draft) {
    try {
      final hook = ref
          .read(
            employeeWorkflowAutomationProfileProvider(
              draft.employeeId,
            ).notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            employeeWorkflowAutomationDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${hook.name} added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _runHook(EmployeeWorkflowAutomationHook hook) {
    ref
        .read(
          employeeWorkflowAutomationProfileProvider(hook.employeeId).notifier,
        )
        .runNow(hook.id);
    _showMessage('${hook.name} generated a task');
  }

  void _activateHook(EmployeeWorkflowAutomationHook hook) {
    ref
        .read(
          employeeWorkflowAutomationProfileProvider(hook.employeeId).notifier,
        )
        .activate(hook.id);
    _showMessage('${hook.name} activated');
  }

  void _pauseHook(EmployeeWorkflowAutomationHook hook) {
    ref
        .read(
          employeeWorkflowAutomationProfileProvider(hook.employeeId).notifier,
        )
        .pause(hook.id);
    _showMessage('${hook.name} paused');
  }

  void _failHook(EmployeeWorkflowAutomationHook hook) {
    ref
        .read(
          employeeWorkflowAutomationProfileProvider(hook.employeeId).notifier,
        )
        .markFailed(hook.id);
    _showMessage('${hook.name} marked failed');
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
