import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_benefits_models.dart';

class EmployeeDependentForm extends StatelessWidget {
  final EmployeeDependentDraft draft;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<EmployeeDependentRelationship> onRelationshipChanged;
  final ValueChanged<bool> onEligibleChanged;
  final VoidCallback onSelectBirthDate;
  final VoidCallback onAdd;

  const EmployeeDependentForm({
    super.key,
    required this.draft,
    required this.nameController,
    required this.onNameChanged,
    required this.onRelationshipChanged,
    required this.onEligibleChanged,
    required this.onSelectBirthDate,
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
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Dependent name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_add_alt_outlined),
            ),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeDependentRelationship>(
            initialValue: draft.relationship,
            decoration: const InputDecoration(
              labelText: 'Relationship',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom_outlined),
            ),
            items:
                EmployeeDependentRelationship.values
                    .map(
                      (relationship) => DropdownMenuItem(
                        value: relationship,
                        child: Text(relationship.label),
                      ),
                    )
                    .toList(),
            onChanged: (relationship) {
              if (relationship != null) onRelationshipChanged(relationship);
            },
          ),
          const SizedBox(height: 12),
          _BirthDateField(value: draft.birthDate, onTap: onSelectBirthDate),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Eligible for coverage'),
              value: draft.eligibleForCoverage,
              onChanged: onEligibleChanged,
            ),
          ),
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
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Add dependent'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _BirthDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Birth date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.cake_outlined),
        ),
        child: Text(
          value == null
              ? 'Select birth date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
