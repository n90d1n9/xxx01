import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_program_completion_provider.dart';
import 'incoming_talent_development_program_completion_form.dart';
import 'incoming_talent_development_program_completion_tile.dart';

class IncomingTalentDevelopmentProgramCompletionPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentProgramCompletionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyMilestones = ref.watch(completionReadyProgramMilestonesProvider);
    final completions = ref.watch(
      filteredIncomingTalentDevelopmentProgramCompletionsProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentProgramCompletionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.workspace_premium_outlined,
      title: 'Program completions',
      subtitle: summary.nextAction,
      emptyMessage: 'No program completion data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyMilestones.length}',
            ),
            HrisMetricStripItem(
              label: 'Role ready',
              value: '${summary.roleReadyCount}',
            ),
            HrisMetricStripItem(
              label: 'Extensions',
              value: '${summary.extensionCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg score',
              value: summary.averageScore.toStringAsFixed(0),
            ),
          ],
        ),
        const IncomingTalentDevelopmentProgramCompletionForm(),
        if (completions.isEmpty)
          const HrisListSurface(
            child: Text('No program completions closed yet.'),
          )
        else
          for (final completion in completions)
            IncomingTalentDevelopmentProgramCompletionTile(
              completion: completion,
            ),
      ],
    );
  }
}
