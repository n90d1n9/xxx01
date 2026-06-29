import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageActionOutcomeDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageActionOutcomeDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentSuccessionCoverageActionOutcomeDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewField = _CoverageOutcomeDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error: validateCoverageActionOutcomeReviewDate(
        draft.reviewDate,
        draft.asOfDate,
      ),
      onTap: onSelectReviewDate,
    );
    final nextReviewField = _CoverageOutcomeDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: validateCoverageActionOutcomeNextReviewDate(
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

class _CoverageOutcomeDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CoverageOutcomeDateField({
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
