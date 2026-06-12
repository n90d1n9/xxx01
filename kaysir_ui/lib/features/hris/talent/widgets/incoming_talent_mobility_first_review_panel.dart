import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_first_review_provider.dart';
import 'incoming_talent_mobility_first_review_form.dart';
import 'incoming_talent_mobility_first_review_tile.dart';

class IncomingTalentMobilityFirstReviewPanel extends ConsumerWidget {
  const IncomingTalentMobilityFirstReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyChecklists = ref.watch(
      firstReviewReadyMobilityLaunchChecklistsProvider,
    );
    final reviews = ref.watch(
      filteredIncomingTalentMobilityFirstReviewsProvider,
    );
    final summary = ref.watch(incomingTalentMobilityFirstReviewSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.rate_review_outlined,
      title: 'Mobility first review',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility first reviews',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyChecklists.length}',
            ),
            HrisMetricStripItem(
              label: 'Strong',
              value: '${summary.acceleratingCount + summary.stableCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.watchCount + summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg',
              value: summary.averageConfidence.toStringAsFixed(1),
            ),
          ],
        ),
        IncomingTalentMobilityFirstReviewForm(checklists: readyChecklists),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('No mobility first reviews submitted yet.'),
          )
        else
          for (final review in reviews.take(3))
            IncomingTalentMobilityFirstReviewTile(review: review),
      ],
    );
  }
}
