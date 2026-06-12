import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../states/incoming_talent_risk_council_queue_provider.dart';
import 'incoming_talent_risk_council_queue_tile.dart';

/// Compact council queue panel for reviewing talent risks that need governance.
class IncomingTalentRiskCouncilQueuePanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilQueuePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentRiskCouncilQueueItemsProvider);
    final summary = ref.watch(incomingTalentRiskCouncilQueueSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.groups_2_outlined,
      title: 'Talent risk council queue',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council items',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Items', value: '${summary.totalItems}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(label: 'Watch', value: '${summary.watchCount}'),
            HrisMetricStripItem(
              label: 'People',
              value: '${summary.candidateCount}',
            ),
            if (summary.promotionResolutionReviewCount > 0)
              HrisMetricStripItem(
                label: 'Promo reviews',
                value: '${summary.promotionResolutionReviewCount}',
              ),
          ],
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No talent risks are queued for council review.'),
          )
        else
          for (final item in items.take(4))
            IncomingTalentRiskCouncilQueueTile(item: item),
      ],
    );
  }
}

@Preview(name: 'Talent risk council queue panel')
Widget incomingTalentRiskCouncilQueuePanelPreview() {
  final items = [_previewQueueItem];

  return ProviderScope(
    overrides: [
      incomingTalentRiskCouncilQueueItemsProvider.overrideWithValue(items),
      incomingTalentRiskCouncilQueueSummaryProvider.overrideWithValue(
        IncomingTalentRiskCouncilQueueSummary.fromItems(items),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilQueuePanel(),
        ),
      ),
    ),
  );
}

final _previewQueueItem = IncomingTalentRiskCouncilQueueItem(
  id: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  severity: IncomingTalentRiskCouncilQueueSeverity.watch,
  title: 'Promotion resolution review risk',
  detail: '1 promotion resolution review still carries residual role risk.',
  recommendedAction:
      'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
  dueDate: DateTime(2026, 6, 10),
  signalCount: 1,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
);
