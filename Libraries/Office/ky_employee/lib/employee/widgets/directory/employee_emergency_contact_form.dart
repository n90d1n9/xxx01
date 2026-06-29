import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_personal_records_models.dart';

class EmployeeEmergencyContactForm extends StatelessWidget {
  final EmployeeEmergencyContactDraft draft;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<EmployeeEmergencyContactRelationship>
  onRelationshipChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<bool> onPrimaryChanged;
  final VoidCallback onAdd;

  const EmployeeEmergencyContactForm({
    super.key,
    required this.draft,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.onNameChanged,
    required this.onRelationshipChanged,
    required this.onPhoneChanged,
    required this.onEmailChanged,
    required this.onPrimaryChanged,
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
              labelText: 'Contact name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.contact_emergency_outlined),
            ),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeEmergencyContactRelationship>(
            initialValue: draft.relationship,
            decoration: const InputDecoration(
              labelText: 'Relationship',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom_outlined),
            ),
            items:
                EmployeeEmergencyContactRelationship.values
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
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            onChanged: onPhoneChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            onChanged: onEmailChanged,
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Make primary contact'),
              value: draft.primary,
              onChanged: onPrimaryChanged,
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
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add contact'),
            ),
          ),
        ],
      ),
    );
  }
}
