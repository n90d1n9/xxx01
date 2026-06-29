import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_org_models.dart';

class EmployeeOrgRelationshipForm extends StatelessWidget {
  final EmployeeOrgRelationshipDraft draft;
  final TextEditingController relatedController;
  final TextEditingController ownerController;
  final TextEditingController reasonController;
  final ValueChanged<EmployeeOrgRelationshipType> onTypeChanged;
  final ValueChanged<String> onRelatedChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onAdd;

  const EmployeeOrgRelationshipForm({
    super.key,
    required this.draft,
    required this.relatedController,
    required this.ownerController,
    required this.reasonController,
    required this.onTypeChanged,
    required this.onRelatedChanged,
    required this.onOwnerChanged,
    required this.onReasonChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeOrgRelationshipType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Relationship type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
            items:
                EmployeeOrgRelationshipType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _OrgTextField(
            controller: relatedController,
            label: 'Related employee',
            icon: Icons.person_outline,
            onChanged: onRelatedChanged,
          ),
          const SizedBox(height: 12),
          _OrgTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.supervisor_account_outlined,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _OrgTextField(
            controller: reasonController,
            label: 'Reason',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onReasonChanged,
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
              onPressed: draft.isReadyToSubmit ? onAdd : null,
              icon: const Icon(Icons.add_link_outlined),
              label: const Text('Add relationship'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _OrgTextField({
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
