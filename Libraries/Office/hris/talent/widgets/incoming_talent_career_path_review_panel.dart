import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_career_path_review_provider.dart';
import 'incoming_talent_career_path_review_form.dart';
import 'incoming_talent_career_path_review_tile.dart';

class IncomingTalentCareerPathReviewPanel extends ConsumerWidget {
  const IncomingTalentCareerPathReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(filteredIncomingTalentCareerPathReviewsProvider);
    final summary = ref.watch(incomingTalentCareerPathReviewSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Career path reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No career path review data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Progress',
              value: '${summary.progressingCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg level',
              value: summary.averageReviewedLevel.toStringAsFixed(1),
            ),
          ],
        ),
        const IncomingTalentCareerPathReviewForm(),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('No career path reviews recorded yet.'),
          )
        else
          for (final review in reviews)
            IncomingTalentCareerPathReviewTile(review: review),
      ],
    );
  }
}
