import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Picker for risky stabilization reviews ready for follow-up action.
class IncomingTalentPromotionStabilizationFollowUpReviewPicker
    extends StatelessWidget {
  final List<IncomingTalentPromotionStabilizationReview> reviews;
  final String? selectedReviewId;
  final ValueChanged<String?> onReviewChanged;

  const IncomingTalentPromotionStabilizationFollowUpReviewPicker({
    super.key,
    required this.reviews,
    required this.selectedReviewId,
    required this.onReviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedReviewId,
      decoration: const InputDecoration(
        labelText: 'Stabilization review',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rate_review_outlined),
      ),
      items:
          reviews
              .map(
                (review) => DropdownMenuItem(
                  value: review.id,
                  child: Text(
                    '${review.candidateName} - ${review.outcome.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: reviews.isEmpty ? null : onReviewChanged,
      validator:
          (value) =>
              validateIncomingTalentPromotionStabilizationFollowUpRequired(
                value,
                'a stabilization review',
              ),
    );
  }
}

/// Classification controls for promotion stabilization follow-up actions.
class IncomingTalentPromotionStabilizationFollowUpClassificationFields
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpActionDraft draft;
  final ValueChanged<IncomingTalentPromotionStabilizationFollowUpActionType>
  onActionTypeChanged;
  final ValueChanged<IncomingTalentPromotionStabilizationFollowUpPriority>
  onPriorityChanged;
  final ValueChanged<IncomingTalentPromotionStabilizationFollowUpStatus>
  onStatusChanged;

  const IncomingTalentPromotionStabilizationFollowUpClassificationFields({
    super.key,
    required this.draft,
    required this.onActionTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IncomingTalentDevelopmentProgramResponsiveRow(
          children: [
            DropdownButtonFormField<
              IncomingTalentPromotionStabilizationFollowUpActionType
            >(
              initialValue: draft.actionType,
              decoration: const InputDecoration(
                labelText: 'Action type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.handshake_outlined),
              ),
              items:
                  IncomingTalentPromotionStabilizationFollowUpActionType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onActionTypeChanged(value);
              },
              validator:
                  validateIncomingTalentPromotionStabilizationFollowUpActionType,
            ),
            DropdownButtonFormField<
              IncomingTalentPromotionStabilizationFollowUpPriority
            >(
              initialValue: draft.priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high_outlined),
              ),
              items:
                  IncomingTalentPromotionStabilizationFollowUpPriority.values
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
              validator:
                  validateIncomingTalentPromotionStabilizationFollowUpPriority,
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<
          IncomingTalentPromotionStabilizationFollowUpStatus
        >(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentPromotionStabilizationFollowUpStatus.values
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
          validator: validateIncomingTalentPromotionStabilizationFollowUpStatus,
        ),
      ],
    );
  }
}

/// Due-date control for promotion stabilization follow-up actions.
class IncomingTalentPromotionStabilizationFollowUpDueDateField
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationFollowUpActionDraft draft;
  final VoidCallback onTap;

  const IncomingTalentPromotionStabilizationFollowUpDueDateField({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramDateButton(
      label: 'Due',
      date: draft.dueDate,
      onTap: onTap,
      error: validateIncomingTalentPromotionStabilizationFollowUpDueDate(
        draft.dueDate,
        draft.asOfDate,
      ),
    );
  }
}

/// Submit controls and completeness signal for promotion follow-up actions.
class IncomingTalentPromotionStabilizationFollowUpFormActions
    extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionStabilizationFollowUpFormActions({
    super.key,
    required this.completionRatio,
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HrisProgressBar(
          value: completionRatio,
          color: canSubmit ? const Color(0xFF059669) : const Color(0xFFD97706),
          label: canSubmit ? 'Follow-up ready' : 'Follow-up draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key(
                'incoming-talent-promotion-stabilization-follow-up-submit',
              ),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Save follow-up'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion stabilization follow-up picker')
Widget incomingTalentPromotionStabilizationFollowUpReviewPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpReviewPicker(
          reviews: [_previewReview],
          selectedReviewId: _previewReview.id,
          onReviewChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization follow-up classification')
Widget incomingTalentPromotionStabilizationFollowUpClassificationPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpClassificationFields(
          draft: _previewDraft,
          onActionTypeChanged: (_) {},
          onPriorityChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization follow-up due date')
Widget incomingTalentPromotionStabilizationFollowUpDueDatePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpDueDateField(
          draft: _previewDraft,
          onTap: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization follow-up actions')
Widget incomingTalentPromotionStabilizationFollowUpFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFollowUpFormActions(
          completionRatio: 0.9,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewReview = IncomingTalentPromotionStabilizationReview(
  id: 'promotion-stabilization-review-preview',
  implementationId: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  reviewerName: 'Engineering people panel',
  outcome: IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  status: IncomingTalentPromotionStabilizationStatus.followUpRequired,
  reviewDate: DateTime(2026, 7, 7),
  followUpDate: DateTime(2026, 7, 21),
  confidenceScore: 2,
  managerFeedback: 'Manager needs clearer operating support after promotion.',
  employeeFeedback: 'Employee needs clearer promotion goals and cadence.',
  evidenceSummary: 'Promotion evidence and manager feedback reviewed.',
  supportPlan: 'Schedule support checkpoint and clarify success measures.',
  sourceAction: IncomingTalentPromotionImplementationAction.titleUpdate,
  sourceImplementationStatus:
      IncomingTalentPromotionImplementationStatus.completed,
  sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
  createdAt: DateTime(2026, 7, 7),
);

final _previewDraft =
    IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview(
      review: _previewReview,
      asOfDate: DateTime(2026, 7, 9),
    );
