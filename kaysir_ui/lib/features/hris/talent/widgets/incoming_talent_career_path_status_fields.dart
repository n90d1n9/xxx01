import 'package:flutter/material.dart';

import '../models/incoming_talent_career_path_models.dart';

class IncomingTalentCareerPathStatusFields extends StatelessWidget {
  final IncomingTalentCareerPathDraft draft;
  final ValueChanged<IncomingTalentCareerPathStatus> onStatusChanged;
  final ValueChanged<IncomingTalentCareerPathPriority> onPriorityChanged;
  final ValueChanged<int> onCurrentLevelChanged;
  final ValueChanged<int> onTargetLevelChanged;

  const IncomingTalentCareerPathStatusFields({
    super.key,
    required this.draft,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCurrentLevelChanged,
    required this.onTargetLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<IncomingTalentCareerPathStatus>(
        initialValue: draft.status,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.flag_outlined),
        ),
        items:
            IncomingTalentCareerPathStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) onStatusChanged(value);
        },
        validator: validateIncomingTalentCareerPathStatus,
      ),
      DropdownButtonFormField<IncomingTalentCareerPathPriority>(
        initialValue: draft.priority,
        decoration: const InputDecoration(
          labelText: 'Priority',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.priority_high_outlined),
        ),
        items:
            IncomingTalentCareerPathPriority.values
                .map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.label),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) onPriorityChanged(value);
        },
        validator: validateIncomingTalentCareerPathPriority,
      ),
      _LevelField(
        label: 'Current level',
        value: draft.currentLevel,
        validator:
            (value) => validateIncomingTalentCareerPathLevel(
              value ?? 0,
              'Current level',
            ),
        onChanged: onCurrentLevelChanged,
      ),
      _LevelField(
        label: 'Target level',
        value: draft.targetLevel,
        validator:
            (value) => validateIncomingTalentCareerPathTargetLevel(
              currentLevel: draft.currentLevel,
              targetLevel: value ?? 0,
            ),
        onChanged: onTargetLevelChanged,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                fields[index],
                if (index < fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              Expanded(child: fields[index]),
              if (index < fields.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _LevelField extends StatelessWidget {
  final String label;
  final int value;
  final String? Function(int?) validator;
  final ValueChanged<int> onChanged;

  const _LevelField({
    required this.label,
    required this.value,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.stacked_line_chart_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (level) =>
                    DropdownMenuItem(value: level, child: Text('Level $level')),
              )
              .toList(),
      onChanged: (level) {
        if (level != null) onChanged(level);
      },
      validator: validator,
    );
  }
}
