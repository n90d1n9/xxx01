import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_coverage_dashboard_provider.dart';
import '../states/incoming_talent_succession_coverage_review_provider.dart';
import 'incoming_talent_succession_coverage_review_form.dart';
import 'incoming_talent_succession_coverage_review_tile.dart';

class IncomingTalentSuccessionCoverageReviewPanel extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(
      incomingTalentSuccessionCoverageDashboardProvider,
    );
    final reviews = ref.watch(
      filteredIncomingTalentSuccessionCoverageReviewsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageReviewSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Coverage reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage reviews',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Score',
              value: '${dashboard.coverageScore}%',
            ),
            HrisMetricStripItem(
              label: 'Reviews',
              value: '${summary.totalReviews}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionCoverageReviewForm(),
        if (reviews.isEmpty)
          const HrisListSurface(child: Text('No coverage reviews yet.'))
        else
          for (final review in reviews.take(3))
            IncomingTalentSuccessionCoverageReviewTile(review: review),
      ],
    );
  }
}
