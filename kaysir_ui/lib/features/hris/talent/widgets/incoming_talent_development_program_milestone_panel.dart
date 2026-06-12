import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_program_milestone_provider.dart';
import 'incoming_talent_development_program_milestone_form.dart';
import 'incoming_talent_development_program_milestone_tile.dart';

class IncomingTalentDevelopmentProgramMilestonePanel extends ConsumerWidget {
  const IncomingTalentDevelopmentProgramMilestonePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(
      filteredIncomingTalentDevelopmentProgramMilestonesProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentProgramMilestoneSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Program milestones',
      subtitle: summary.nextAction,
      emptyMessage: 'No program milestone data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Submitted',
              value: '${summary.submittedCount}',
            ),
            HrisMetricStripItem(
              label: 'Revisions',
              value: '${summary.revisionCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentProgramMilestoneForm(),
        if (milestones.isEmpty)
          const HrisListSurface(
            child: Text('No program milestone reviews created yet.'),
          )
        else
          for (final milestone in milestones)
            IncomingTalentDevelopmentProgramMilestoneTile(milestone: milestone),
      ],
    );
  }
}
