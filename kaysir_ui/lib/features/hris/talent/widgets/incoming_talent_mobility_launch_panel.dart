import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_mobility_launch_checklist_provider.dart';
import 'incoming_talent_mobility_launch_form.dart';
import 'incoming_talent_mobility_launch_tile.dart';

class IncomingTalentMobilityLaunchPanel extends ConsumerWidget {
  const IncomingTalentMobilityLaunchPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyMatches = ref.watch(
      launchReadyIncomingTalentMobilityMatchesProvider,
    );
    final checklists = ref.watch(
      filteredIncomingTalentMobilityLaunchChecklistsProvider,
    );
    final summary = ref.watch(
      incomingTalentMobilityLaunchChecklistSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Mobility launch checklist',
      subtitle: summary.nextAction,
      emptyMessage: 'No mobility launch checklists',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Accepted',
              value: '${readyMatches.length}',
            ),
            HrisMetricStripItem(label: 'Ready', value: '${summary.readyCount}'),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        IncomingTalentMobilityLaunchForm(matches: readyMatches),
        if (checklists.isEmpty)
          const HrisListSurface(
            child: Text('No mobility launch checklists submitted yet.'),
          )
        else
          for (final checklist in checklists.take(3))
            IncomingTalentMobilityLaunchTile(
              checklist: checklist,
              onReady:
                  () => ref
                      .read(
                        incomingTalentMobilityLaunchChecklistsProvider.notifier,
                      )
                      .markReady(checklist.id),
              onBlock:
                  () => ref
                      .read(
                        incomingTalentMobilityLaunchChecklistsProvider.notifier,
                      )
                      .block(checklist.id),
              onLaunch:
                  () => ref
                      .read(
                        incomingTalentMobilityLaunchChecklistsProvider.notifier,
                      )
                      .launch(checklist.id),
            ),
      ],
    );
  }
}
