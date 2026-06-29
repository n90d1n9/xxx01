import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_assets_models.dart';

class EmployeeAssetAssignmentForm extends StatelessWidget {
  final EmployeeAssetAssignmentDraft draft;
  final TextEditingController labelController;
  final TextEditingController tagController;
  final TextEditingController ownerController;
  final ValueChanged<EmployeeAssetType> onTypeChanged;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<String> onTagChanged;
  final ValueChanged<String> onOwnerChanged;
  final VoidCallback onAdd;

  const EmployeeAssetAssignmentForm({
    super.key,
    required this.draft,
    required this.labelController,
    required this.tagController,
    required this.ownerController,
    required this.onTypeChanged,
    required this.onLabelChanged,
    required this.onTagChanged,
    required this.onOwnerChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeAssetType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Asset type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.devices_other_outlined),
            ),
            items:
                EmployeeAssetType.values
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
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Asset label',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            onChanged: onLabelChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tagController,
            decoration: const InputDecoration(
              labelText: 'Asset tag',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag_outlined),
            ),
            onChanged: onTagChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.support_agent_outlined),
            ),
            onChanged: onOwnerChanged,
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
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Assign asset'),
            ),
          ),
        ],
      ),
    );
  }
}
