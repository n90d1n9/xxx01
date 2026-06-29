import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_action_models.dart';
import '../states/incoming_talent_risk_council_commitment_action_provider.dart';
import 'incoming_talent_risk_council_commitment_action_form.dart';
import 'incoming_talent_risk_council_commitment_action_tile.dart';

class IncomingTalentRiskCouncilCommitmentActionPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilCommitmentActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCommitments = ref.watch(
      actionReadyTalentRiskCouncilCommitmentsProvider,
    );
    final actions = ref.watch(
      filteredIncomingTalentRiskCouncilCommitmentActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Talent risk council commitment actions',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent risk council commitment actions',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyCommitments.length}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value: '${summary.waitingEvidenceCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        IncomingTalentRiskCouncilCommitmentActionForm(
          commitments: readyCommitments,
        ),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No council commitment actions created yet.'),
          )
        else
          for (final action in actions.take(3))
            IncomingTalentRiskCouncilCommitmentActionTile(
              action: action,
              onStart:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentRiskCouncilCommitmentActionStatus.inProgress,
                  ),
              onRequestEvidence:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentRiskCouncilCommitmentActionStatus
                        .waitingEvidence,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
                  ),
              onEscalate:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentRiskCouncilCommitmentActionStatus.escalated,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    action,
                    IncomingTalentRiskCouncilCommitmentActionStatus.completed,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentRiskCouncilCommitmentAction action,
    IncomingTalentRiskCouncilCommitmentActionStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentRiskCouncilCommitmentActionsProvider.notifier,
    );

    switch (status) {
      case IncomingTalentRiskCouncilCommitmentActionStatus.inProgress:
        notifier.start(action.id);
      case IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence:
        notifier.requestEvidence(action.id);
      case IncomingTalentRiskCouncilCommitmentActionStatus.blocked:
        notifier.block(action.id);
      case IncomingTalentRiskCouncilCommitmentActionStatus.escalated:
        notifier.escalate(action.id);
      case IncomingTalentRiskCouncilCommitmentActionStatus.completed:
        notifier.complete(action.id);
      case IncomingTalentRiskCouncilCommitmentActionStatus.planned:
        break;
    }
  }
}
