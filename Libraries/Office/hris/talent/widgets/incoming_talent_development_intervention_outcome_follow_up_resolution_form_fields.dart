import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPicker
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
  draft;
  final List<IncomingTalentDevelopmentInterventionOutcomeFollowUp> followUps;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPicker({
    super.key,
    required this.draft,
    required this.followUps,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        followUps.any((item) => item.id == draft.followUpId)
            ? draft.followUpId
            : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('intervention-follow-up-resolution-${draft.followUpId}'),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Closed follow-up',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          followUps
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    '${item.candidateName} - ${item.status.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: followUps.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateRequired(
                value,
                'a closed follow-up',
              ),
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionTextInput({
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

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDateFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
  draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewDateField = _ResolutionDateField(
      label: 'Review date',
      icon: Icons.event_available_outlined,
      value: draft.reviewDate,
      error:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateReviewDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
      onTap: onSelectReviewDate,
    );
    final nextReviewField = _ResolutionDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateNextReviewDate(
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
              reviewDateField,
              const SizedBox(height: 12),
              nextReviewField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: reviewDateField),
            const SizedBox(width: 12),
            Expanded(child: nextReviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSignalFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
  draft;
  final ValueChanged<
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  >
  onDecisionChanged;
  final ValueChanged<int> onConfidenceChanged;
  final ValueChanged<int> onRiskChanged;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onConfidenceChanged,
    required this.onRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = DropdownButtonFormField<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
    >(
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Resolution decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rule_outlined),
      ),
      items:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
              .values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onDecisionChanged(value);
      },
      validator:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
              .validateDecision,
    );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.confidenceAfter >= 1 && draft.confidenceAfter <= 5
              ? draft.confidenceAfter
              : null,
      decoration: const InputDecoration(
        labelText: 'Final confidence',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onConfidenceChanged(value);
      },
      validator:
          (value) =>
              IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateConfidenceAfter(
                value ?? 0,
              ),
    );
    final riskValues = _riskValues(draft.remainingReleaseRiskCount);
    final riskField = DropdownButtonFormField<int>(
      initialValue:
          riskValues.contains(draft.remainingReleaseRiskCount)
              ? draft.remainingReleaseRiskCount
              : null,
      decoration: const InputDecoration(
        labelText: 'Release risks left',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.report_problem_outlined),
      ),
      items:
          riskValues
              .map(
                (count) => DropdownMenuItem(
                  value: count,
                  child: Text(count == 0 ? 'None' : '$count risks'),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onRiskChanged(value);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              decisionField,
              const SizedBox(height: 12),
              confidenceField,
              const SizedBox(height: 12),
              riskField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: confidenceField),
            const SizedBox(width: 12),
            Expanded(child: riskField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionReadiness
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
  draft;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionReadiness({
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
          if (draft.followUpId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.rule_folder_outlined,
                  label: draft.sourceDecision?.label ?? 'Outcome',
                ),
                TalentMetaLabel(
                  icon: Icons.flag_outlined,
                  label: draft.sourceStatus?.label ?? 'Follow-up',
                ),
                TalentMetaLabel(
                  icon: Icons.trending_up_outlined,
                  label:
                      '${draft.confidenceBefore}/5 to ${draft.confidenceAfter}/5 confidence',
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

class _ResolutionDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ResolutionDateField({
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

List<int> _riskValues(int selectedValue) {
  final values = List<int>.generate(6, (index) => index);
  if (selectedValue > 5) values.add(selectedValue);
  return values;
}
