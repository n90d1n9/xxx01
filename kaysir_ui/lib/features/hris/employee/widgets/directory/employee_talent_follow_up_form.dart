import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_talent_calibration_models.dart';

class EmployeeTalentFollowUpForm extends StatelessWidget {
  final EmployeeTalentFollowUpDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController notesController;
  final ValueChanged<EmployeeTalentFollowUpType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onAdd;

  const EmployeeTalentFollowUpForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.notesController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onNotesChanged,
    required this.onSelectDueDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeTalentFollowUpType>(
            initialValue: draft.type,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Follow-up type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.route_outlined),
            ),
            items:
                EmployeeTalentFollowUpType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _TalentTextField(
            controller: titleController,
            label: 'Follow-up title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _TalentTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.person_outline,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _TalentDateField(value: draft.dueDate, onTap: onSelectDueDate),
          const SizedBox(height: 12),
          _TalentTextField(
            controller: notesController,
            label: 'Calibration notes',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onNotesChanged,
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
              label: const Text('Add follow-up'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _TalentDateField({required this.value, required this.onTap});

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
          value == null
              ? 'Select date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _TalentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _TalentTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
