import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_career_path_provider.dart';
import 'incoming_talent_career_path_form.dart';
import 'incoming_talent_career_path_tile.dart';

class IncomingTalentCareerPathPanel extends ConsumerWidget {
  const IncomingTalentCareerPathPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careerPaths = ref.watch(filteredIncomingTalentCareerPathsProvider);
    final summary = ref.watch(incomingTalentCareerPathSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Career path matrix',
      subtitle: summary.nextAction,
      emptyMessage: 'No career path data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg gap',
              value: summary.averageGap.toStringAsFixed(1),
            ),
          ],
        ),
        const IncomingTalentCareerPathForm(),
        if (careerPaths.isEmpty)
          const HrisListSurface(child: Text('No career paths created yet.'))
        else
          for (final careerPath in careerPaths)
            IncomingTalentCareerPathTile(careerPath: careerPath),
      ],
    );
  }
}
