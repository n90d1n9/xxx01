import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_development_models.dart';

class EmployeeLearningAssignmentForm extends StatelessWidget {
  final EmployeeLearningAssignmentDraft draft;
  final TextEditingController titleController;
  final TextEditingController providerController;
  final TextEditingController skillFocusController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<String> onSkillFocusChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onAdd;

  const EmployeeLearningAssignmentForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.providerController,
    required this.skillFocusController,
    required this.onTitleChanged,
    required this.onProviderChanged,
    required this.onSkillFocusChanged,
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
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Learning title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.menu_book_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: providerController,
            decoration: const InputDecoration(
              labelText: 'Provider',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school_outlined),
            ),
            onChanged: onProviderChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: skillFocusController,
            decoration: const InputDecoration(
              labelText: 'Skill focus',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.psychology_outlined),
            ),
            onChanged: onSkillFocusChanged,
          ),
          const SizedBox(height: 12),
          _LearningDateField(value: draft.dueDate, onTap: onSelectDueDate),
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
              icon: const Icon(Icons.playlist_add_check_outlined),
              label: const Text('Add learning'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _LearningDateField({required this.value, required this.onTap});

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
