import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'project_form_layout.dart';

class ProjectFormDateRangeEditor extends StatelessWidget {
  const ProjectFormDateRangeEditor({
    required this.startDate,
    required this.endDate,
    required this.onStartChanged,
    required this.onEndChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final durationDays = endDate.difference(startDate).inDays + 1;

    return ProjectResponsiveFormGrid(
      children: [
        _DatePickerButton(
          label: 'Start date',
          value: dateFormat.format(startDate),
          onPressed:
              () => _pickDate(
                context: context,
                initialDate: startDate,
                onChanged: onStartChanged,
              ),
        ),
        _DatePickerButton(
          label: 'End date',
          value:
              durationDays > 0
                  ? '${dateFormat.format(endDate)} - $durationDays days'
                  : dateFormat.format(endDate),
          onPressed:
              () => _pickDate(
                context: context,
                initialDate: endDate,
                onChanged: onEndChanged,
              ),
        ),
      ],
    );
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onChanged,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2035),
    );
    if (selected != null) onChanged(selected);
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size.fromHeight(56),
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.event_outlined),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
