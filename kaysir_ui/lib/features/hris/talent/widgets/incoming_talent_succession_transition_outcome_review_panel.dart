import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_transition_outcome_review_provider.dart';
import 'incoming_talent_succession_transition_outcome_review_form.dart';
import 'incoming_talent_succession_transition_outcome_review_tile.dart';

class IncomingTalentSuccessionTransitionOutcomeReviewPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionTransitionOutcomeReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyInterventions = ref.watch(
      outcomeReadySuccessionTransitionInterventionsProvider,
    );
    final reviews = ref.watch(
      filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionTransitionOutcomeReviewSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Transition outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No transition outcomes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyInterventions.length}',
            ),
            HrisMetricStripItem(
              label: 'Stable',
              value: '${summary.stabilizedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionTransitionOutcomeReviewForm(),
        if (reviews.isEmpty)
          const HrisListSurface(child: Text('No transition outcomes yet.'))
        else
          for (final review in reviews.take(3))
            IncomingTalentSuccessionTransitionOutcomeReviewTile(review: review),
      ],
    );
  }
}
