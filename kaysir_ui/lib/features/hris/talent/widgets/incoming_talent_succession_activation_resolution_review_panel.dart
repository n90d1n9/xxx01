import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_activation_resolution_review_provider.dart';
import 'incoming_talent_succession_activation_resolution_review_form.dart';
import 'incoming_talent_succession_activation_resolution_review_tile.dart';

class IncomingTalentSuccessionActivationResolutionReviewPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionActivationResolutionReviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyEscalations = ref.watch(
      resolutionReadySuccessionActivationEscalationsProvider,
    );
    final reviews = ref.watch(
      filteredIncomingTalentSuccessionActivationResolutionReviewsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionActivationResolutionReviewSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Resolution reviews',
      subtitle: summary.nextAction,
      emptyMessage: 'No resolution reviews',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyEscalations.length}',
            ),
            HrisMetricStripItem(
              label: 'Cleared',
              value: '${summary.clearedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value:
                  '${summary.monitorCount + summary.reopenCount + summary.panelReviewCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionActivationResolutionReviewForm(),
        if (reviews.isEmpty)
          const HrisListSurface(child: Text('No resolution reviews yet.'))
        else
          for (final review in reviews.take(3))
            IncomingTalentSuccessionActivationResolutionReviewTile(
              review: review,
            ),
      ],
    );
  }
}
