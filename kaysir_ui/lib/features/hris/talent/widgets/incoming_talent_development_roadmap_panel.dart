import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_roadmap_provider.dart';
import 'incoming_talent_development_roadmap_form.dart';
import 'incoming_talent_development_roadmap_tile.dart';

class IncomingTalentDevelopmentRoadmapPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentRoadmapPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roadmaps = ref.watch(
      filteredIncomingTalentDevelopmentRoadmapsProvider,
    );
    final summary = ref.watch(incomingTalentDevelopmentRoadmapSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.add_road_outlined,
      title: 'Development roadmaps',
      subtitle: summary.nextAction,
      emptyMessage: 'No development roadmap data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount}',
            ),
            HrisMetricStripItem(label: 'Risk', value: '${summary.atRiskCount}'),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentRoadmapForm(),
        if (roadmaps.isEmpty)
          const HrisListSurface(
            child: Text('No development roadmaps created yet.'),
          )
        else
          for (final roadmap in roadmaps)
            IncomingTalentDevelopmentRoadmapTile(roadmap: roadmap),
      ],
    );
  }
}
