import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../states/incoming_talent_promotion_decision_provider.dart';
import 'incoming_talent_promotion_decision_form.dart';
import 'incoming_talent_promotion_decision_tile.dart';

/// Panel for final promotion decisions and implementation follow-through.
class IncomingTalentPromotionDecisionPanel extends ConsumerWidget {
  const IncomingTalentPromotionDecisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(
      filteredIncomingTalentPromotionDecisionsProvider,
    );
    final summary = ref.watch(incomingTalentPromotionDecisionSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.how_to_reg_outlined,
      title: 'Promotion decisions',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion decision data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Promote',
              value: '${summary.promoteNowCount}',
            ),
            HrisMetricStripItem(label: 'Trial', value: '${summary.trialCount}'),
            HrisMetricStripItem(
              label: 'Deferred',
              value: '${summary.deferredCount}',
            ),
            HrisMetricStripItem(label: 'Due', value: '${summary.dueSoonCount}'),
          ],
        ),
        HrisProgressBar(
          value: summary.averageImplementationProgress,
          color: HrisColors.primary,
          label:
              '${(summary.averageImplementationProgress * 100).round()}% decision implementation',
        ),
        const IncomingTalentPromotionDecisionForm(),
        if (decisions.isEmpty)
          const HrisListSurface(
            child: Text('No promotion decisions saved yet.'),
          )
        else
          for (final decision in decisions)
            IncomingTalentPromotionDecisionTile(decision: decision),
      ],
    );
  }
}

@Preview(name: 'Talent promotion decision panel')
Widget incomingTalentPromotionDecisionPanelPreview() {
  final decisions = [_previewPanelDecision];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentPromotionDecisionsProvider.overrideWithValue(
        decisions,
      ),
      incomingTalentPromotionDecisionSummaryProvider.overrideWithValue(
        IncomingTalentPromotionDecisionSummary.fromDecisions(
          decisions: decisions,
          asOfDate: DateTime(2026, 6, 9),
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionDecisionPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelDecision = IncomingTalentPromotionDecision(
  id: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  outcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  status: IncomingTalentPromotionDecisionStatus.approved,
  compensationBandNote: 'Route L5 title and compensation band for approval.',
  implementationNote: 'Prepare promotion letter and HRIS title update.',
  riskControlNote: 'Confirm manager transition and backfill risk.',
  effectiveDate: DateTime(2026, 7, 9),
  followUpDate: DateTime(2026, 8, 8),
  sourceRating: IncomingTalentPromotionReadinessRating.readyNow,
  sourceReadinessStatus: IncomingTalentPromotionReadinessStatus.endorsed,
  createdAt: DateTime(2026, 6, 9),
);
