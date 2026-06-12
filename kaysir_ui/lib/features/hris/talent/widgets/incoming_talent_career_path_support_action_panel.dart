import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_career_path_support_action_provider.dart';
import 'incoming_talent_career_path_support_action_form.dart';
import 'incoming_talent_career_path_support_action_tile.dart';

class IncomingTalentCareerPathSupportActionPanel extends ConsumerWidget {
  const IncomingTalentCareerPathSupportActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(
      filteredIncomingTalentCareerPathSupportActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentCareerPathSupportActionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.build_circle_outlined,
      title: 'Career support actions',
      subtitle: summary.nextAction,
      emptyMessage: 'No career support action data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        const IncomingTalentCareerPathSupportActionForm(),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No career support actions created yet.'),
          )
        else
          for (final action in actions)
            IncomingTalentCareerPathSupportActionTile(action: action),
      ],
    );
  }
}
