import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_profile_timeline_provider.dart';
import 'incoming_talent_profile_timeline_tile.dart';

class IncomingTalentProfileTimelinePanel extends ConsumerWidget {
  const IncomingTalentProfileTimelinePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelines = ref.watch(filteredIncomingTalentProfileTimelinesProvider);
    final summary = ref.watch(incomingTalentProfileTimelineSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Talent profile timeline',
      subtitle: summary.nextAction,
      emptyMessage: 'No profile timelines',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Profiles',
              value: '${summary.totalProfiles}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionProfiles}',
            ),
            HrisMetricStripItem(
              label: 'Open actions',
              value: '${summary.openTalentActions}',
            ),
          ],
        ),
        if (timelines.isEmpty)
          const HrisListSurface(
            child: Text('Complete outcome reviews to build profile timelines.'),
          )
        else
          for (final timeline in timelines.take(4))
            IncomingTalentProfileTimelineTile(timeline: timeline),
      ],
    );
  }
}
