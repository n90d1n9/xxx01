import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageReviewTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionCoverageReviewTextInput({
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

class IncomingTalentSuccessionCoverageReviewDecisionField
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageReviewDraft draft;
  final ValueChanged<IncomingTalentSuccessionCoverageReviewDecision> onChanged;

  const IncomingTalentSuccessionCoverageReviewDecisionField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<
      IncomingTalentSuccessionCoverageReviewDecision
    >(
      key: ValueKey('succession-coverage-decision-${draft.decision}'),
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Coverage decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_user_outlined),
      ),
      items:
          IncomingTalentSuccessionCoverageReviewDecision.values
              .map(
                (decision) => DropdownMenuItem(
                  value: decision,
                  child: Text(decision.label),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: IncomingTalentSuccessionCoverageReviewDraft.validateDecision,
    );
  }
}

class IncomingTalentSuccessionCoverageReviewDateFields extends StatelessWidget {
  final IncomingTalentSuccessionCoverageReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentSuccessionCoverageReviewDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewField = _CoverageDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error: IncomingTalentSuccessionCoverageReviewDraft.validateReviewDate(
        draft.reviewDate,
        draft.asOfDate,
      ),
      onTap: onSelectReviewDate,
    );
    final nextReviewField = _CoverageDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: IncomingTalentSuccessionCoverageReviewDraft.validateNextReviewDate(
        draft.reviewDate,
        draft.nextReviewDate,
      ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              reviewField,
              const SizedBox(height: 12),
              nextReviewField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: reviewField),
            const SizedBox(width: 12),
            Expanded(child: nextReviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionCoverageReviewDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageReviewDraft draft;

  const IncomingTalentSuccessionCoverageReviewDraftReadiness({
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
                    Expanded(
                      child: Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CoverageDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CoverageDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          errorText: hasError ? error : null,
        ),
        child: Text(
          value == null ? 'Select date' : DateFormat('MMM d, y').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
