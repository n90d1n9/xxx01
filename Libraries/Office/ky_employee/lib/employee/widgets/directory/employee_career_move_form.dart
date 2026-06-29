import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_career_path_models.dart';

class EmployeeCareerMoveForm extends StatelessWidget {
  final EmployeeCareerMoveDraft draft;
  final TextEditingController titleController;
  final TextEditingController sponsorController;
  final TextEditingController targetRoleController;
  final TextEditingController summaryController;
  final ValueChanged<EmployeeCareerMoveType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onSponsorChanged;
  final ValueChanged<String> onTargetRoleChanged;
  final ValueChanged<String> onSummaryChanged;
  final VoidCallback onSelectTargetDate;
  final VoidCallback onSubmit;

  const EmployeeCareerMoveForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.sponsorController,
    required this.targetRoleController,
    required this.summaryController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onSponsorChanged,
    required this.onTargetRoleChanged,
    required this.onSummaryChanged,
    required this.onSelectTargetDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<EmployeeCareerMoveType>(
                  initialValue: draft.type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Move type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.route_outlined),
                  ),
                  items:
                      EmployeeCareerMoveType.values
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CareerDateField(
                  date: draft.targetDate,
                  onTap: onSelectTargetDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CareerTextField(
            controller: titleController,
            label: 'Move title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _CareerTextField(
            controller: sponsorController,
            label: 'Sponsor',
            icon: Icons.person_outline,
            onChanged: onSponsorChanged,
          ),
          const SizedBox(height: 12),
          _CareerTextField(
            controller: targetRoleController,
            label: 'Target role',
            icon: Icons.badge_outlined,
            onChanged: onTargetRoleChanged,
          ),
          const SizedBox(height: 12),
          _CareerTextField(
            controller: summaryController,
            label: 'Summary',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onSummaryChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
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
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Propose move'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _CareerDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Target date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CareerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _CareerTextField({
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
