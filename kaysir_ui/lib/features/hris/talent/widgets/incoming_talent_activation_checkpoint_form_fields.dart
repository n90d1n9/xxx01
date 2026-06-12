import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentActivationCheckpointTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentActivationCheckpointTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class IncomingTalentActivationCheckpointDateField extends StatelessWidget {
  final IncomingTalentActivationCheckpointDraft draft;
  final VoidCallback onSelectReviewDate;

  const IncomingTalentActivationCheckpointDateField({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final error = IncomingTalentActivationCheckpointDraft.validateReviewDate(
      draft.reviewDate,
      draft.asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectReviewDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Review date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.reviewDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.reviewDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.reviewDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class IncomingTalentActivationCheckpointSignalFields extends StatelessWidget {
  final IncomingTalentActivationCheckpointDraft draft;
  final ValueChanged<IncomingTalentActivationCheckpointHealth> onHealthChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentActivationCheckpointSignalFields({
    super.key,
    required this.draft,
    required this.onHealthChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final healthField =
            DropdownButtonFormField<IncomingTalentActivationCheckpointHealth>(
              initialValue: draft.health,
              decoration: const InputDecoration(
                labelText: 'Checkpoint health',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_heart_outlined),
              ),
              items:
                  IncomingTalentActivationCheckpointHealth.values
                      .map(
                        (health) => DropdownMenuItem(
                          value: health,
                          child: Text(health.label),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onHealthChanged(value);
              },
              validator: IncomingTalentActivationCheckpointDraft.validateHealth,
            );
        final confidenceField = _ConfidenceField(
          value: draft.confidenceScore,
          onChanged: onConfidenceChanged,
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              healthField,
              const SizedBox(height: 12),
              confidenceField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: healthField),
            const SizedBox(width: 12),
            Expanded(child: confidenceField),
          ],
        );
      },
    );
  }
}

class IncomingTalentActivationCheckpointDraftReadiness extends StatelessWidget {
  final IncomingTalentActivationCheckpointDraft draft;

  const IncomingTalentActivationCheckpointDraftReadiness({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% complete',
          ),
          if (draft.acceptedProgramMilestoneCount > 0 ||
              draft.roleReadyProgramCompletionCount > 0 ||
              draft.programCompletionExtensionCount > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (draft.acceptedProgramMilestoneCount > 0)
                  TalentMetaLabel(
                    icon: Icons.task_alt_outlined,
                    label: '${draft.acceptedProgramMilestoneCount} milestones',
                  ),
                if (draft.roleReadyProgramCompletionCount > 0)
                  TalentMetaLabel(
                    icon: Icons.workspace_premium_outlined,
                    label:
                        '${draft.roleReadyProgramCompletionCount} role-ready',
                  ),
                if (draft.programCompletionExtensionCount > 0)
                  TalentMetaLabel(
                    icon: Icons.report_problem_outlined,
                    label:
                        '${draft.programCompletionExtensionCount} extensions',
                  ),
              ],
            ),
          ],
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ConfidenceField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(1, 5);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Confidence',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      child: Row(
        children: [
          Text(
            '$safeValue/5',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: safeValue.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$safeValue',
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}
