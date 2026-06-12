import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_review_models.dart';

class IncomingTalentCareerPathReviewTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentCareerPathReviewTextInput({
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

class IncomingTalentCareerPathReviewDecisionFields extends StatelessWidget {
  final IncomingTalentCareerPathReviewDraft draft;
  final ValueChanged<IncomingTalentCareerPathReviewDecision> onDecisionChanged;
  final ValueChanged<int> onReviewedLevelChanged;

  const IncomingTalentCareerPathReviewDecisionFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onReviewedLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField =
        DropdownButtonFormField<IncomingTalentCareerPathReviewDecision>(
          initialValue: draft.decision,
          decoration: const InputDecoration(
            labelText: 'Review decision',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fact_check_outlined),
          ),
          items:
              IncomingTalentCareerPathReviewDecision.values
                  .map(
                    (decision) => DropdownMenuItem(
                      value: decision,
                      child: Text(decision.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onDecisionChanged(value);
          },
          validator: validateIncomingTalentCareerPathReviewDecision,
        );
    final reviewedLevelField = DropdownButtonFormField<int>(
      initialValue: draft.reviewedLevel,
      decoration: const InputDecoration(
        labelText: 'Reviewed level',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.stacked_line_chart_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (level) =>
                    DropdownMenuItem(value: level, child: Text('Level $level')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onReviewedLevelChanged(value);
      },
      validator:
          (value) => validateIncomingTalentCareerPathReviewReviewedLevel(
            reviewedLevel: value ?? 0,
            targetLevel: draft.targetLevel,
          ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              decisionField,
              const SizedBox(height: 12),
              reviewedLevelField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: reviewedLevelField),
          ],
        );
      },
    );
  }
}

class IncomingTalentCareerPathReviewDateFields extends StatelessWidget {
  final IncomingTalentCareerPathReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentCareerPathReviewDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewDateField = _ReviewDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error: validateIncomingTalentCareerPathReviewDate(
        draft.reviewDate,
        draft.asOfDate,
        'review date',
      ),
      onTap: onSelectReviewDate,
    );
    final nextReviewDateField = _ReviewDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: validateIncomingTalentCareerPathReviewDate(
        draft.nextReviewDate,
        draft.asOfDate,
        'next review date',
      ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              reviewDateField,
              const SizedBox(height: 12),
              nextReviewDateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: reviewDateField),
            const SizedBox(width: 12),
            Expanded(child: nextReviewDateField),
          ],
        );
      },
    );
  }
}

class _ReviewDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ReviewDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.error,
    required this.onTap,
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
          prefixIcon: Icon(icon),
          errorText: error,
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
