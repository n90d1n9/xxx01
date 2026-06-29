import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'incoming_talent_succession_coverage_council_follow_up_form.dart';
import 'incoming_talent_succession_coverage_council_follow_up_tile.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpPanel
    extends ConsumerWidget {
  const IncomingTalentSuccessionCoverageCouncilFollowUpPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyDecisions = ref.watch(
      followUpReadyCoverageCouncilDecisionsProvider,
    );
    final followUps = ref.watch(
      filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionCoverageCouncilFollowUpSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.next_plan_outlined,
      title: 'Coverage council follow-ups',
      subtitle: summary.nextAction,
      emptyMessage: 'No coverage council follow-ups',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyDecisions.length}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Escalated',
              value: '${summary.escalatedCount}',
            ),
          ],
        ),
        IncomingTalentSuccessionCoverageCouncilFollowUpForm(
          decisions: readyDecisions,
        ),
        if (followUps.isEmpty)
          const HrisListSurface(
            child: Text('No council follow-ups created yet.'),
          )
        else
          for (final followUp in followUps.take(3))
            IncomingTalentSuccessionCoverageCouncilFollowUpTile(
              followUp: followUp,
              onStart:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                        .inProgress,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                        .blocked,
                  ),
              onEscalate:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                        .escalated,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    followUp,
                    IncomingTalentSuccessionCoverageCouncilFollowUpStatus
                        .completed,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionCoverageCouncilFollowUp followUp,
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionCoverageCouncilFollowUpsProvider.notifier,
    );

    switch (status) {
      case IncomingTalentSuccessionCoverageCouncilFollowUpStatus.inProgress:
        notifier.start(followUp.id);
      case IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked:
        notifier.block(followUp.id);
      case IncomingTalentSuccessionCoverageCouncilFollowUpStatus.escalated:
        notifier.escalate(followUp.id);
      case IncomingTalentSuccessionCoverageCouncilFollowUpStatus.completed:
        notifier.complete(followUp.id);
      case IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned:
        break;
    }
  }
}
