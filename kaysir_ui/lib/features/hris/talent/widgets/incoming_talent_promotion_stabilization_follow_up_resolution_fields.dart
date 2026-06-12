import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'talent_meta_label.dart';

/// Picker for promotion follow-up actions ready for resolution review.
class IncomingTalentPromotionStabilizationFollowUpResolutionActionPicker
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpResolutionDraft draft;
  final List<IncomingTalentPromotionStabilizationFollowUpAction> actions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentPromotionStabilizationFollowUpResolutionActionPicker({
    super.key,
    required this.draft,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        actions.any((action) => action.id == draft.actionId)
            ? draft.actionId
            : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('promotion-follow-up-resolution-${draft.actionId}'),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Resolved follow-up',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.playlist_add_check_outlined),
      ),
      items:
          actions
              .map(
                (action) => DropdownMenuItem(
                  value: action.id,
                  child: Text(
                    '${action.candidateName} - ${action.status.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: actions.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentPromotionFollowUpResolutionRequired(
            value,
            'a resolved or escalated follow-up',
          ),
    );
  }
}

/// Date controls for promotion follow-up resolution reviews.
class IncomingTalentPromotionStabilizationFollowUpResolutionDateFields
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpResolutionDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentPromotionStabilizationFollowUpResolutionDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Review',
          date: draft.reviewDate,
          onTap: onSelectReviewDate,
          error: validateIncomingTalentPromotionFollowUpResolutionDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Next review',
          date: draft.nextReviewDate,
          onTap: onSelectNextReviewDate,
          error:
              validateIncomingTalentPromotionFollowUpResolutionNextReviewDate(
                draft.reviewDate,
                draft.nextReviewDate,
              ),
        ),
      ],
    );
  }
}

/// Outcome, confidence, and residual-risk controls for resolution reviews.
class IncomingTalentPromotionStabilizationFollowUpResolutionSignalFields
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpResolutionDraft draft;
  final ValueChanged<
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
  >
  onOutcomeChanged;
  final ValueChanged<int> onConfidenceChanged;
  final ValueChanged<int> onResidualRiskChanged;

  const IncomingTalentPromotionStabilizationFollowUpResolutionSignalFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onConfidenceChanged,
    required this.onResidualRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<
          IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
        >(
          initialValue: draft.outcome,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.rule_outlined),
          ),
          items:
              IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
                  .values
                  .map(
                    (outcome) => DropdownMenuItem(
                      value: outcome,
                      child: Text(outcome.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onOutcomeChanged(value);
          },
          validator: validateIncomingTalentPromotionFollowUpResolutionOutcome,
        ),
        DropdownButtonFormField<int>(
          initialValue:
              draft.confidenceAfter >= 1 && draft.confidenceAfter <= 5
                  ? draft.confidenceAfter
                  : null,
          decoration: const InputDecoration(
            labelText: 'Confidence',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.speed_outlined),
          ),
          items:
              [1, 2, 3, 4, 5]
                  .map(
                    (score) => DropdownMenuItem(
                      value: score,
                      child: Text('$score / 5'),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onConfidenceChanged(value);
          },
          validator:
              (value) =>
                  validateIncomingTalentPromotionFollowUpResolutionConfidence(
                    value ?? 0,
                  ),
        ),
        DropdownButtonFormField<int>(
          initialValue:
              draft.residualRiskCount >= 0 && draft.residualRiskCount <= 5
                  ? draft.residualRiskCount
                  : null,
          decoration: const InputDecoration(
            labelText: 'Residual risk',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.report_problem_outlined),
          ),
          items:
              [0, 1, 2, 3, 4, 5]
                  .map(
                    (count) => DropdownMenuItem(
                      value: count,
                      child: Text(count == 0 ? 'None' : '$count risks'),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onResidualRiskChanged(value);
          },
          validator:
              (value) =>
                  validateIncomingTalentPromotionFollowUpResolutionResidualRisk(
                    value ?? 0,
                  ),
        ),
      ],
    );
  }
}

/// Readiness panel for promotion follow-up resolution draft completeness.
class IncomingTalentPromotionStabilizationFollowUpResolutionReadiness
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpResolutionDraft draft;

  const IncomingTalentPromotionStabilizationFollowUpResolutionReadiness({
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
            label: ready ? 'Resolution ready' : 'Resolution draft',
          ),
          if (draft.actionId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.flag_outlined,
                  label: draft.actionStatus?.label ?? 'Follow-up',
                ),
                TalentMetaLabel(
                  icon: Icons.priority_high_outlined,
                  label: draft.actionPriority?.label ?? 'Priority',
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

/// Submit controls for promotion follow-up resolution reviews.
class IncomingTalentPromotionStabilizationFollowUpResolutionFormActions
    extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionStabilizationFollowUpResolutionFormActions({
    super.key,
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onClear, child: const Text('Clear')),
        const SizedBox(width: 10),
        FilledButton.icon(
          key: const Key(
            'incoming-talent-promotion-follow-up-resolution-submit',
          ),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Submit review'),
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion follow-up resolution picker')
Widget incomingTalentPromotionFollowUpResolutionPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            IncomingTalentPromotionStabilizationFollowUpResolutionActionPicker(
              draft: _previewDraft,
              actions: [_previewAction],
              onChanged: (_) {},
            ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion follow-up resolution signals')
Widget incomingTalentPromotionFollowUpResolutionSignalsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            IncomingTalentPromotionStabilizationFollowUpResolutionSignalFields(
              draft: _previewDraft,
              onOutcomeChanged: (_) {},
              onConfidenceChanged: (_) {},
              onResidualRiskChanged: (_) {},
            ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion follow-up resolution readiness')
Widget incomingTalentPromotionFollowUpResolutionReadinessPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpResolutionReadiness(
          draft: _previewDraft,
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentPromotionStabilizationFollowUpAction(
  id: 'promotion-follow-up-preview',
  reviewId: 'promotion-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  actionType:
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
  priority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
  status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
  dueDate: DateTime(2026, 7, 21),
  actionPlan:
      'Run manager coaching checkpoint and clarify promotion success measures.',
  successCriteria:
      'Manager and employee confirm clear expectations and support cadence.',
  escalationNote: 'Escalate if progress is not confirmed by the due date.',
  resolutionNote:
      'Manager and employee confirmed the promotion support cadence.',
  sourceOutcome:
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  sourceReviewStatus:
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
  sourceConfidenceScore: 3,
  createdAt: DateTime(2026, 7, 9),
);

final _previewDraft =
    IncomingTalentPromotionStabilizationFollowUpResolutionDraft.fromAction(
      action: _previewAction,
      asOfDate: DateTime(2026, 7, 28),
    );
