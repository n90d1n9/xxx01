import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import '../models/incoming_talent_development_intervention_outcome_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionOutcomePicker
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeDraft draft;
  final List<IncomingTalentDevelopmentInterventionAction> interventions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentInterventionOutcomePicker({
    super.key,
    required this.draft,
    required this.interventions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        interventions.any((item) => item.id == draft.interventionId)
            ? draft.interventionId
            : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('development-intervention-outcome-${draft.interventionId}'),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Resolved intervention',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_outlined),
      ),
      items:
          interventions
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    '${item.candidateName} - ${item.actionType.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: interventions.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentDevelopmentInterventionOutcomeDraft.validateRequired(
                value,
                'a resolved intervention',
              ),
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentInterventionOutcomeTextInput({
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

class IncomingTalentDevelopmentInterventionOutcomeDateFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentDevelopmentInterventionOutcomeDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final reviewField = _DateInput(
      label: 'Review date',
      value: draft.reviewDate,
      errorText:
          IncomingTalentDevelopmentInterventionOutcomeDraft.validateReviewDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
      onTap: onSelectReviewDate,
    );
    final nextField = _DateInput(
      label: 'Next review',
      value: draft.nextReviewDate,
      errorText:
          IncomingTalentDevelopmentInterventionOutcomeDraft.validateNextReviewDate(
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

class IncomingTalentDevelopmentInterventionOutcomeSignalFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeDraft draft;
  final ValueChanged<IncomingTalentDevelopmentInterventionOutcomeDecision>
  onDecisionChanged;
  final ValueChanged<int> onConfidenceChanged;
  final ValueChanged<int> onReleaseRiskChanged;

  const IncomingTalentDevelopmentInterventionOutcomeSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onConfidenceChanged,
    required this.onReleaseRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = DropdownButtonFormField<
      IncomingTalentDevelopmentInterventionOutcomeDecision
    >(
      initialValue: draft.decision,
      decoration: const InputDecoration(
        labelText: 'Decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rule_folder_outlined),
      ),
      items:
          IncomingTalentDevelopmentInterventionOutcomeDecision.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onDecisionChanged(value);
      },
      validator:
          IncomingTalentDevelopmentInterventionOutcomeDraft.validateDecision,
    );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue: _validConfidence(draft.confidenceAfter),
      decoration: const InputDecoration(
        labelText: 'Confidence after',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.trending_up_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (item) => DropdownMenuItem(value: item, child: Text('$item/5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onConfidenceChanged(value);
      },
      validator:
          (value) =>
              IncomingTalentDevelopmentInterventionOutcomeDraft.validateConfidence(
                value ?? 0,
              ),
    );
    final riskField = DropdownButtonFormField<int>(
      initialValue: draft.remainingReleaseRiskCount.clamp(0, 5),
      decoration: const InputDecoration(
        labelText: 'Release risk left',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.report_problem_outlined),
      ),
      items:
          [0, 1, 2, 3, 4, 5]
              .map(
                (item) => DropdownMenuItem(value: item, child: Text('$item')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onReleaseRiskChanged(value);
      },
    );

    return Column(
      children: [
        decisionField,
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 620) {
              return Column(
                children: [
                  confidenceField,
                  const SizedBox(height: 12),
                  riskField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: confidenceField),
                const SizedBox(width: 12),
                Expanded(child: riskField),
              ],
            );
          },
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeReadiness
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeDraft draft;

  const IncomingTalentDevelopmentInterventionOutcomeReadiness({
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
          if (draft.interventionId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: draft.source?.label ?? 'Intervention',
                ),
                TalentMetaLabel(
                  icon: Icons.trending_up_outlined,
                  label:
                      '${_deltaLabel(draft.confidenceAfter - draft.confidenceBefore)} confidence',
                ),
                if (draft.releaseEvidenceCount > 0)
                  TalentMetaLabel(
                    icon: Icons.workspace_premium_outlined,
                    label: '${draft.releaseEvidenceCount} evidence signals',
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

class _DateInput extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  const _DateInput({
    required this.label,
    required this.value,
    required this.errorText,
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
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: errorText,
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

int? _validConfidence(int value) {
  return value >= 1 && value <= 5 ? value : null;
}

String _deltaLabel(int value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix$value';
}
