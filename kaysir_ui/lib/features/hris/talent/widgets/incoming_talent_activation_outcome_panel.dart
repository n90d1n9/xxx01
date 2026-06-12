import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_activation_outcome_provider.dart';
import 'incoming_talent_activation_outcome_form.dart';
import 'incoming_talent_activation_outcome_tile.dart';

class IncomingTalentActivationOutcomePanel extends ConsumerWidget {
  const IncomingTalentActivationOutcomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(
      filteredIncomingTalentActivationOutcomeReviewsProvider,
    );
    final summary = ref.watch(incomingTalentActivationOutcomeSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.verified_outlined,
      title: 'Activation outcomes',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation outcome data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Stable',
              value: '${summary.stabilizedCount}',
            ),
            HrisMetricStripItem(
              label: 'Support',
              value: '${summary.extendedSupportCount}',
            ),
            HrisMetricStripItem(
              label: 'Escalated',
              value: '${summary.escalatedCount}',
            ),
          ],
        ),
        IncomingTalentActivationOutcomeForm(),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('No outcome reviews submitted yet.'),
          )
        else
          for (final review in reviews)
            IncomingTalentActivationOutcomeTile(review: review),
      ],
    );
  }
}
