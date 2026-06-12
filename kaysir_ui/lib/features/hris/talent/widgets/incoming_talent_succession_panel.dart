import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_provider.dart';
import 'incoming_talent_succession_candidate_tile.dart';

class IncomingTalentSuccessionPanel extends ConsumerWidget {
  const IncomingTalentSuccessionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(
      filteredIncomingTalentSuccessionCandidatesProvider,
    );
    final summary = ref.watch(incomingTalentSuccessionSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.workspace_premium_outlined,
      title: 'Succession readiness',
      subtitle: summary.nextAction,
      emptyMessage: 'No succession slate',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready now',
              value: '${summary.readyNowCount}',
            ),
            HrisMetricStripItem(
              label: 'Ready soon',
              value: '${summary.readySoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        if (candidates.isEmpty)
          const HrisListSurface(
            child: Text(
              'Build profile timelines to create a succession slate.',
            ),
          )
        else
          for (final candidate in candidates.take(4))
            IncomingTalentSuccessionCandidateTile(candidate: candidate),
      ],
    );
  }
}
