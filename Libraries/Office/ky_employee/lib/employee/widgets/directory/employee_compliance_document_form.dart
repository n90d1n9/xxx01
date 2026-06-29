import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compliance_models.dart';

class EmployeeComplianceDocumentForm extends StatelessWidget {
  final EmployeeComplianceDocumentDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController notesController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<EmployeeComplianceDocumentType> onTypeChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onSelectExpiryDate;
  final VoidCallback onClearExpiryDate;
  final VoidCallback onAdd;

  const EmployeeComplianceDocumentForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.notesController,
    required this.onTitleChanged,
    required this.onTypeChanged,
    required this.onOwnerChanged,
    required this.onNotesChanged,
    required this.onSelectDueDate,
    required this.onSelectExpiryDate,
    required this.onClearExpiryDate,
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
              labelText: 'Document title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeComplianceDocumentType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Document type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder_copy_outlined),
            ),
            items:
                EmployeeComplianceDocumentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (type) {
              if (type != null) onTypeChanged(type);
            },
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
          _DocumentDateField(
            label: 'Due date',
            value: draft.dueDate,
            onTap: onSelectDueDate,
          ),
          const SizedBox(height: 12),
          _DocumentDateField(
            label: 'Expiry date',
            value: draft.expiresAt,
            emptyLabel: 'Optional',
            onTap: onSelectExpiryDate,
            onClear: draft.expiresAt == null ? null : onClearExpiryDate,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
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
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Add document'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentDateField extends StatelessWidget {
  final String label;
  final String emptyLabel;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DocumentDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.emptyLabel = 'Select date',
    this.onClear,
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
          prefixIcon: const Icon(Icons.event_available_outlined),
          suffixIcon:
              onClear == null
                  ? null
                  : IconButton(
                    tooltip: 'Clear date',
                    icon: const Icon(Icons.close_outlined),
                    onPressed: onClear,
                  ),
        ),
        child: Text(
          value == null ? emptyLabel : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
