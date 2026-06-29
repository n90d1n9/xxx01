import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_request_models.dart';

class EmployeeDocumentRequestForm extends StatelessWidget {
  final EmployeeDocumentRequestDraft draft;
  final TextEditingController titleController;
  final TextEditingController requestedByController;
  final TextEditingController ownerController;
  final TextEditingController purposeController;
  final ValueChanged<EmployeeDocumentRequestType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onRequestedByChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onPurposeChanged;
  final ValueChanged<EmployeeDocumentDeliveryMethod> onDeliveryChanged;
  final ValueChanged<bool> onAcknowledgementChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onSubmit;

  const EmployeeDocumentRequestForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.requestedByController,
    required this.ownerController,
    required this.purposeController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onRequestedByChanged,
    required this.onOwnerChanged,
    required this.onPurposeChanged,
    required this.onDeliveryChanged,
    required this.onAcknowledgementChanged,
    required this.onSelectDueDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeDocumentRequestType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Document type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            items:
                EmployeeDocumentRequestType.values
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
          _DocumentTextField(
            controller: titleController,
            label: 'Title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DocumentTextField(
                  controller: requestedByController,
                  label: 'Requested by',
                  icon: Icons.person_outline,
                  onChanged: onRequestedByChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DueDateField(
                  dueDate: draft.dueDate,
                  onTap: onSelectDueDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.assignment_ind_outlined,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeDocumentDeliveryMethod>(
            initialValue: draft.deliveryMethod,
            decoration: const InputDecoration(
              labelText: 'Delivery method',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.send_outlined),
            ),
            items:
                EmployeeDocumentDeliveryMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(
                          method.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onDeliveryChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _DocumentTextField(
            controller: purposeController,
            label: 'Purpose',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onPurposeChanged,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requires acknowledgement',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.requiresAcknowledgement
                          ? 'Employee must acknowledge after issue.'
                          : 'Issuing the document closes the request.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: draft.requiresAcknowledgement,
                onChanged: onAcknowledgementChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              label: const Text('Add document request'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  final DateTime dueDate;
  final VoidCallback onTap;

  const _DueDateField({required this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(dueDate),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DocumentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _DocumentTextField({
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
