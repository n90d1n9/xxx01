import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import '../states/incoming_talent_risk_council_follow_up_provider.dart';
import 'incoming_talent_risk_council_follow_up_form.dart';
import 'incoming_talent_risk_council_follow_up_tile.dart';

/// Council follow-up panel for creating and operating decision commitments.
class IncomingTalentRiskCouncilFollowUpPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilFollowUpPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyDecisions = ref.watch(
      followUpReadyTalentRiskCouncilDecisionsProvider,
    );
    final followUps = ref.watch(
      filteredIncomingTalentRiskCouncilFollowUpsProvider,
    );
    final summary = ref.watch(incomingTalentRiskCouncilFollowUpSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.next_plan_outlined,
      title: 'Talent risk council follow-ups',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council follow-ups',
      children: [
        HrisMetricStrip(
          items: _followUpMetrics(
            readyCount: readyDecisions.length,
            summary: summary,
          ),
        ),
        IncomingTalentRiskCouncilFollowUpForm(decisions: readyDecisions),
        if (followUps.isEmpty)
          const HrisListSurface(
            child: Text('No risk council follow-ups created yet.'),
          )
        else
          for (final followUp in followUps.take(3))
            IncomingTalentRiskCouncilFollowUpTile(
              followUp: followUp,
              onStart:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentRiskCouncilFollowUpStatus.inProgress,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentRiskCouncilFollowUpStatus.blocked,
                  ),
              onEscalate:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentRiskCouncilFollowUpStatus.escalated,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentRiskCouncilFollowUpStatus.completed,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentRiskCouncilFollowUp followUp,
    IncomingTalentRiskCouncilFollowUpStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentRiskCouncilFollowUpsProvider.notifier,
    );

    switch (status) {
      case IncomingTalentRiskCouncilFollowUpStatus.inProgress:
        notifier.start(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.blocked:
        notifier.block(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.escalated:
        notifier.escalate(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.completed:
        notifier.complete(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.planned:
        break;
    }
  }
}

List<HrisMetricStripItem> _followUpMetrics({
  required int readyCount,
  required IncomingTalentRiskCouncilFollowUpSummary summary,
}) {
  return [
    HrisMetricStripItem(label: 'Ready', value: '$readyCount'),
    HrisMetricStripItem(label: 'Due soon', value: '${summary.dueSoonCount}'),
    HrisMetricStripItem(label: 'Blocked', value: '${summary.blockedCount}'),
    HrisMetricStripItem(label: 'Escalated', value: '${summary.escalatedCount}'),
    if (summary.promotionResolutionReviewCount > 0)
      HrisMetricStripItem(
        label: 'Promo follow-ups',
        value: '${summary.promotionResolutionReviewCount}',
      ),
  ];
}

@Preview(name: 'Talent risk council follow-up panel')
Widget incomingTalentRiskCouncilFollowUpPanelPreview() {
  final followUps = [_previewFollowUp];

  return ProviderScope(
    overrides: [
      followUpReadyTalentRiskCouncilDecisionsProvider.overrideWithValue(
        const [],
      ),
      filteredIncomingTalentRiskCouncilFollowUpsProvider.overrideWithValue(
        followUps,
      ),
      incomingTalentRiskCouncilFollowUpSummaryProvider.overrideWithValue(
        IncomingTalentRiskCouncilFollowUpSummary.fromFollowUps(
          followUps: followUps,
          asOfDate: DateTime(2026, 6, 11),
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilFollowUpPanel(),
        ),
      ),
    ),
  );
}

final _previewFollowUp = IncomingTalentRiskCouncilFollowUp(
  id: 'talent-risk-council-follow-up-preview',
  decisionId: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  decisionMakerName: 'Talent Council',
  followUpOwnerName: 'People Operations Promotion Stabilization Partner',
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
  status: IncomingTalentRiskCouncilFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 7, 11),
  actionPlan:
      'Review promotion stabilization evidence and decide whether monitoring can close.',
  successCriteria:
      'Role-risk evidence, manager checkpoint, and council disposition are recorded.',
  blockerNote: '',
  escalationReason: '',
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);
