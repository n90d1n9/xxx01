import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_accommodation_models.dart';

class EmployeeAccommodationForm extends StatelessWidget {
  final EmployeeAccommodationDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController summaryController;
  final ValueChanged<EmployeeAccommodationType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onSummaryChanged;
  final ValueChanged<EmployeeAccommodationSensitivity> onSensitivityChanged;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSubmit;

  const EmployeeAccommodationForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.summaryController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onSummaryChanged,
    required this.onSensitivityChanged,
    required this.onSelectStartDate,
    required this.onSelectReviewDate,
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
                child: DropdownButtonFormField<EmployeeAccommodationType>(
                  initialValue: draft.type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Support type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items:
                      EmployeeAccommodationType.values
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
                child:
                    DropdownButtonFormField<EmployeeAccommodationSensitivity>(
                      initialValue: draft.sensitivity,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Sensitivity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      items:
                          EmployeeAccommodationSensitivity.values
                              .map(
                                (sensitivity) => DropdownMenuItem(
                                  value: sensitivity,
                                  child: Text(
                                    sensitivity.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) onSensitivityChanged(value);
                      },
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AccommodationDateField(
                  label: 'Start',
                  date: draft.startDate,
                  onTap: onSelectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccommodationDateField(
                  label: 'Review',
                  date: draft.reviewDate,
                  onTap: onSelectReviewDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AccommodationTextField(
            controller: titleController,
            label: 'Support title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _AccommodationTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.person_outline,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _AccommodationTextField(
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
              label: const Text('Submit request'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccommodationDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _AccommodationDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AccommodationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _AccommodationTextField({
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
