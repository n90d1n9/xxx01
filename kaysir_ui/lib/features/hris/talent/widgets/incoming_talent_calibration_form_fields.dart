import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_calibration_models.dart';

class IncomingTalentCalibrationTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentCalibrationTextInput({
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

class IncomingTalentCalibrationDecisionFields extends StatelessWidget {
  final IncomingTalentCalibrationReviewDraft draft;
  final ValueChanged<IncomingTalentCalibrationDecision> onDecisionChanged;
  final ValueChanged<IncomingTalentCalibrationPotential> onPotentialChanged;

  const IncomingTalentCalibrationDecisionFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onPotentialChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField =
        DropdownButtonFormField<IncomingTalentCalibrationDecision>(
          initialValue: draft.decision,
          decoration: const InputDecoration(
            labelText: 'Calibration decision',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fact_check_outlined),
          ),
          items:
              IncomingTalentCalibrationDecision.values
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
          validator: IncomingTalentCalibrationReviewDraft.validateDecision,
        );
    final potentialField =
        DropdownButtonFormField<IncomingTalentCalibrationPotential>(
          initialValue: draft.potential,
          decoration: const InputDecoration(
            labelText: 'Potential',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up_outlined),
          ),
          items:
              IncomingTalentCalibrationPotential.values
                  .map(
                    (potential) => DropdownMenuItem(
                      value: potential,
                      child: Text(potential.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onPotentialChanged(value);
          },
          validator: IncomingTalentCalibrationReviewDraft.validatePotential,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              decisionField,
              const SizedBox(height: 12),
              potentialField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: potentialField),
          ],
        );
      },
    );
  }
}

class IncomingTalentCalibrationDateFields extends StatelessWidget {
  final IncomingTalentCalibrationReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentCalibrationDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewField = _CalibrationDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error: IncomingTalentCalibrationReviewDraft.validateReviewDate(
        draft.reviewDate,
        draft.asOfDate,
      ),
      onTap: onSelectReviewDate,
    );
    final nextField = _CalibrationDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: IncomingTalentCalibrationReviewDraft.validateNextReviewDate(
        draft.reviewDate,
        draft.nextReviewDate,
      ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [reviewField, const SizedBox(height: 12), nextField],
          );
        }
        return Row(
          children: [
            Expanded(child: reviewField),
            const SizedBox(width: 12),
            Expanded(child: nextField),
          ],
        );
      },
    );
  }
}

class IncomingTalentCalibrationDraftReadiness extends StatelessWidget {
  final IncomingTalentCalibrationReviewDraft draft;

  const IncomingTalentCalibrationDraftReadiness({
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

class _CalibrationDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CalibrationDateField({
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
