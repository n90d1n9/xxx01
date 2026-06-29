import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_automation_models.dart';

class EmployeeWorkflowAutomationForm extends StatelessWidget {
  final EmployeeWorkflowAutomationHookDraft draft;
  final TextEditingController nameController;
  final TextEditingController ownerController;
  final TextEditingController sourceController;
  final TextEditingController taskTitleController;
  final TextEditingController notesController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<EmployeeWorkflowAutomationTrigger> onTriggerChanged;
  final ValueChanged<EmployeeWorkflowAutomationDelivery> onDeliveryChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTaskTitleChanged;
  final ValueChanged<int> onSlaHoursChanged;
  final ValueChanged<EmployeeWorkflowAutomationRisk> onRiskChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectNextRun;
  final VoidCallback onSubmit;

  const EmployeeWorkflowAutomationForm({
    super.key,
    required this.draft,
    required this.nameController,
    required this.ownerController,
    required this.sourceController,
    required this.taskTitleController,
    required this.notesController,
    required this.onNameChanged,
    required this.onTriggerChanged,
    required this.onDeliveryChanged,
    required this.onOwnerChanged,
    required this.onSourceChanged,
    required this.onTaskTitleChanged,
    required this.onSlaHoursChanged,
    required this.onRiskChanged,
    required this.onNotesChanged,
    required this.onSelectNextRun,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeWorkflowAutomationTrigger>(
            initialValue: draft.trigger,
            decoration: const InputDecoration(
              labelText: 'Trigger',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.auto_awesome_motion_outlined),
            ),
            items:
                EmployeeWorkflowAutomationTrigger.values
                    .map(
                      (trigger) => DropdownMenuItem(
                        value: trigger,
                        child: Text(trigger.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTriggerChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeWorkflowAutomationDelivery>(
            initialValue: draft.delivery,
            decoration: const InputDecoration(
              labelText: 'Delivery',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            items:
                EmployeeWorkflowAutomationDelivery.values
                    .map(
                      (delivery) => DropdownMenuItem(
                        value: delivery,
                        child: Text(delivery.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onDeliveryChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Automation name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title_outlined),
            ),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: taskTitleController,
            decoration: const InputDecoration(
              labelText: 'Generated task title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt_outlined),
            ),
            onChanged: onTaskTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: sourceController,
            decoration: const InputDecoration(
              labelText: 'Source label',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            onChanged: onSourceChanged,
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
          DropdownButtonFormField<int>(
            initialValue: draft.slaHours,
            decoration: const InputDecoration(
              labelText: 'SLA window',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule_outlined),
            ),
            items:
                const [4, 8, 12, 24, 48, 72, 120]
                    .map(
                      (hours) => DropdownMenuItem(
                        value: hours,
                        child: Text('$hours hours'),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onSlaHoursChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeWorkflowAutomationRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeWorkflowAutomationRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(risk.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _NextRunField(draft: draft, onTap: onSelectNextRun),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Automation notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNotesChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HrisProgressBar(
                  value: draft.completionRatio,
                  color:
                      draft.isReadyToSubmit
                          ? const Color(0xFF15803D)
                          : HrisColors.primary,
                  label: '${(draft.completionRatio * 100).round()}% ready',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: draft.isReadyToSubmit ? onSubmit : null,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add hook'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextRunField extends StatelessWidget {
  final EmployeeWorkflowAutomationHookDraft draft;
  final VoidCallback onTap;

  const _NextRunField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nextRun = draft.nextRunAt;
    final label =
        nextRun == null
            ? 'Select next run'
            : DateFormat('MMM d, yyyy').format(nextRun);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Next run',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
