import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import '../states/incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_decision_form.dart';
import 'incoming_talent_risk_council_decision_tile.dart';

/// Council decision panel with ready queue work, form entry, and recent decisions.
class IncomingTalentRiskCouncilDecisionPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilDecisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyItems = ref.watch(
      decisionReadyTalentRiskCouncilQueueItemsProvider,
    );
    final decisions = ref.watch(
      filteredIncomingTalentRiskCouncilDecisionsProvider,
    );
    final summary = ref.watch(incomingTalentRiskCouncilDecisionSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Talent risk council decisions',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council decisions',
      children: [
        HrisMetricStrip(
          items: _decisionMetrics(
            readyCount: readyItems.length,
            summary: summary,
          ),
        ),
        const IncomingTalentRiskCouncilDecisionForm(),
        if (decisions.isEmpty)
          const HrisListSurface(
            child: Text('No talent risk council decisions recorded yet.'),
          )
        else
          for (final decision in decisions.take(3))
            IncomingTalentRiskCouncilDecisionTile(decision: decision),
      ],
    );
  }
}

List<HrisMetricStripItem> _decisionMetrics({
  required int readyCount,
  required IncomingTalentRiskCouncilDecisionSummary summary,
}) {
  return [
    HrisMetricStripItem(label: 'Ready', value: '$readyCount'),
    HrisMetricStripItem(label: 'Decisions', value: '${summary.totalDecisions}'),
    HrisMetricStripItem(label: 'Escalated', value: '${summary.escalatedCount}'),
    HrisMetricStripItem(label: 'Watch', value: '${summary.attentionCount}'),
    if (summary.promotionResolutionReviewCount > 0)
      HrisMetricStripItem(
        label: 'Promo reviews',
        value: '${summary.promotionResolutionReviewCount}',
      ),
  ];
}

@Preview(name: 'Talent risk council decision panel')
Widget incomingTalentRiskCouncilDecisionPanelPreview() {
  final decisions = [_previewDecision];

  return ProviderScope(
    overrides: [
      decisionReadyTalentRiskCouncilQueueItemsProvider.overrideWithValue(
        const [],
      ),
      filteredIncomingTalentRiskCouncilDecisionsProvider.overrideWithValue(
        decisions,
      ),
      incomingTalentRiskCouncilDecisionSummaryProvider.overrideWithValue(
        IncomingTalentRiskCouncilDecisionSummary.fromDecisions(decisions),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilDecisionPanel(),
        ),
      ),
    ),
  );
}

final _previewDecision = IncomingTalentRiskCouncilDecision(
  id: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  decisionMakerName: 'Talent Council',
  ownerName: 'People Operations Promotion Stabilization Partner',
  decisionDate: DateTime(2026, 6, 11),
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  commitmentSummary:
      'Council will monitor promotion stabilization risk at the next talent risk council.',
  minutesNote:
      'Residual role-risk evidence needs manager checkpoint and closure disposition.',
  followUpDate: DateTime(2026, 7, 11),
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);
