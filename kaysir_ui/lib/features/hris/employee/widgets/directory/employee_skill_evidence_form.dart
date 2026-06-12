import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_skill_inventory_models.dart';

class EmployeeSkillEvidenceForm extends StatelessWidget {
  final EmployeeSkillEvidenceDraft draft;
  final TextEditingController skillController;
  final TextEditingController verifierController;
  final TextEditingController evidenceController;
  final ValueChanged<String> onSkillChanged;
  final ValueChanged<EmployeeSkillInventoryCategory> onCategoryChanged;
  final ValueChanged<EmployeeSkillEvidenceType> onEvidenceTypeChanged;
  final ValueChanged<String> onVerifierChanged;
  final ValueChanged<String> onEvidenceChanged;
  final ValueChanged<int> onObservedLevelChanged;
  final ValueChanged<int> onRequiredLevelChanged;
  final ValueChanged<EmployeeSkillCriticality> onCriticalityChanged;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onAddEvidence;

  const EmployeeSkillEvidenceForm({
    super.key,
    required this.draft,
    required this.skillController,
    required this.verifierController,
    required this.evidenceController,
    required this.onSkillChanged,
    required this.onCategoryChanged,
    required this.onEvidenceTypeChanged,
    required this.onVerifierChanged,
    required this.onEvidenceChanged,
    required this.onObservedLevelChanged,
    required this.onRequiredLevelChanged,
    required this.onCriticalityChanged,
    required this.onSelectReviewDate,
    required this.onAddEvidence,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: skillController,
            decoration: const InputDecoration(
              labelText: 'Skill name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.psychology_alt_outlined),
            ),
            onChanged: onSkillChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EnumDropdown<EmployeeSkillInventoryCategory>(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  value: draft.category,
                  values: EmployeeSkillInventoryCategory.values,
                  labelFor: (value) => value.label,
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnumDropdown<EmployeeSkillCriticality>(
                  label: 'Criticality',
                  icon: Icons.priority_high_outlined,
                  value: draft.criticality,
                  values: EmployeeSkillCriticality.values,
                  labelFor: (value) => value.label,
                  onChanged: onCriticalityChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _EnumDropdown<EmployeeSkillEvidenceType>(
            label: 'Evidence type',
            icon: Icons.fact_check_outlined,
            value: draft.evidenceType,
            values: EmployeeSkillEvidenceType.values,
            labelFor: (value) => value.label,
            onChanged: onEvidenceTypeChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: verifierController,
            decoration: const InputDecoration(
              labelText: 'Verifier',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_search_outlined),
            ),
            onChanged: onVerifierChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: evidenceController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Evidence summary',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onEvidenceChanged,
          ),
          const SizedBox(height: 12),
          _LevelSelector(
            label: 'Observed level',
            value: draft.observedLevel,
            onChanged: onObservedLevelChanged,
          ),
          const SizedBox(height: 10),
          _LevelSelector(
            label: 'Required level',
            value: draft.requiredLevel,
            onChanged: onRequiredLevelChanged,
          ),
          const SizedBox(height: 12),
          _ReviewDateField(
            value: draft.nextReviewDate,
            onTap: onSelectReviewDate,
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
              onPressed: draft.isReadyToAdd ? onAddEvidence : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add evidence'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items:
          values
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry,
                  child: Text(labelFor(entry), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _LevelSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$value',
          onChanged: (next) => onChanged(next.round()),
        ),
      ],
    );
  }
}

class _ReviewDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _ReviewDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Next review date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
