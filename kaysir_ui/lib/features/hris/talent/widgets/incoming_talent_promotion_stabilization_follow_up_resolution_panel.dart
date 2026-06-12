import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import '../states/incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_form.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_tile.dart';

/// Panel for reviewing outcomes after promotion follow-up work closes.
class IncomingTalentPromotionStabilizationFollowUpResolutionPanel
    extends ConsumerWidget {
  const IncomingTalentPromotionStabilizationFollowUpResolutionPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyActions = ref.watch(
      resolutionReadyPromotionStabilizationFollowUpActionsProvider,
    );
    final resolutions = ref.watch(
      filteredIncomingTalentPromotionStabilizationFollowUpResolutionsProvider,
    );
    final summary = ref.watch(
      incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Promotion resolution reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion resolution review data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyActions.length}',
            ),
            HrisMetricStripItem(
              label: 'Stable',
              value: '${summary.stabilizedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value:
                  '${summary.monitorCount + summary.reopenedCount + summary.escalatedCount}',
            ),
            HrisMetricStripItem(
              label: 'Confidence',
              value: summary.averageConfidenceAfter.toStringAsFixed(1),
            ),
          ],
        ),
        const IncomingTalentPromotionStabilizationFollowUpResolutionForm(),
        if (resolutions.isEmpty)
          const HrisListSurface(
            child: Text('No promotion follow-up resolution reviews yet.'),
          )
        else
          for (final resolution in resolutions.take(3))
            IncomingTalentPromotionStabilizationFollowUpResolutionTile(
              resolution: resolution,
            ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion follow-up resolution panel')
Widget incomingTalentPromotionFollowUpResolutionPanelPreview() {
  final actions = [_previewAction];
  final resolutions = [_previewResolution];

  return ProviderScope(
    overrides: [
      resolutionReadyPromotionStabilizationFollowUpActionsProvider
          .overrideWithValue(actions),
      filteredIncomingTalentPromotionStabilizationFollowUpResolutionsProvider
          .overrideWithValue(resolutions),
      incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider
          .overrideWithValue(
            IncomingTalentPromotionStabilizationFollowUpResolutionSummary.fromResolutions(
              resolutions,
            ),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationFollowUpResolutionPanel(),
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

final _previewResolution = IncomingTalentPromotionStabilizationFollowUpResolution(
  id: 'promotion-follow-up-resolution-preview',
  actionId: 'promotion-follow-up-preview',
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
  reviewerName: 'Engineering HRBP',
  actionType:
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
  actionPriority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
  actionStatus: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
  actionDueDate: DateTime(2026, 7, 21),
  reviewDate: DateTime(2026, 7, 28),
  outcome:
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized,
  confidenceBefore: 3,
  confidenceAfter: 4,
  residualRiskCount: 0,
  evidenceSummary:
      'Promotion follow-up evidence confirms success criteria were met.',
  managerNote:
      'Manager confirms the promoted employee is operating with clarity.',
  nextAction:
      'Archive stabilization evidence and return to standard promotion cadence.',
  nextReviewDate: DateTime(2026, 9, 11),
  createdAt: DateTime(2026, 7, 28),
);
