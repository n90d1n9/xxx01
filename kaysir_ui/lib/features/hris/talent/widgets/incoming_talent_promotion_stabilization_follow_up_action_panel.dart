import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import '../states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_form.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_tile.dart';

/// Panel for resolving risky post-promotion stabilization reviews.
class IncomingTalentPromotionStabilizationFollowUpActionPanel
    extends ConsumerWidget {
  const IncomingTalentPromotionStabilizationFollowUpActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyReviews = ref.watch(
      promotionStabilizationFollowUpReadyReviewsProvider,
    );
    final actions = ref.watch(
      filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentPromotionStabilizationFollowUpActionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.add_task_outlined,
      title: 'Promotion follow-ups',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion follow-up action data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyReviews.length}',
            ),
            HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
            HrisMetricStripItem(
              label: 'Escalated',
              value: '${summary.escalatedCount}',
            ),
            HrisMetricStripItem(label: 'Due', value: '${summary.dueSoonCount}'),
          ],
        ),
        HrisProgressBar(
          value: summary.averageProgress,
          color: HrisColors.primary,
          label:
              '${(summary.averageProgress * 100).round()}% follow-up progress',
        ),
        const IncomingTalentPromotionStabilizationFollowUpActionForm(),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No promotion stabilization follow-ups created yet.'),
          )
        else
          for (final action in actions)
            IncomingTalentPromotionStabilizationFollowUpActionTile(
              action: action,
            ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion stabilization follow-up panel')
Widget incomingTalentPromotionStabilizationFollowUpActionPanelPreview() {
  final actions = [_previewAction];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider
          .overrideWithValue(actions),
      incomingTalentPromotionStabilizationFollowUpActionSummaryProvider
          .overrideWithValue(
            IncomingTalentPromotionStabilizationFollowUpActionSummary.fromActions(
              actions: actions,
              asOfDate: DateTime(2026, 7, 9),
            ),
          ),
      promotionStabilizationFollowUpReadyReviewsProvider.overrideWithValue(
        const [],
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionStabilizationFollowUpActionPanel(),
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentPromotionStabilizationFollowUpAction(
  id: 'promotion-stabilization-follow-up-preview',
  reviewId: 'promotion-stabilization-review-preview',
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
  status: IncomingTalentPromotionStabilizationFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 7, 21),
  actionPlan:
      'Run manager coaching checkpoint and clarify promotion success measures.',
  successCriteria:
      'Manager and employee confirm clear expectations and support cadence.',
  escalationNote: 'Escalate if progress is not confirmed by the due date.',
  resolutionNote: '',
  sourceOutcome:
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  sourceReviewStatus:
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
  sourceConfidenceScore: 2,
  createdAt: DateTime(2026, 7, 9),
);
