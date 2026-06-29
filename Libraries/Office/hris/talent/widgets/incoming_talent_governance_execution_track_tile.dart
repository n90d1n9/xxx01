import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'talent_meta_label.dart';

/// Tile for one executive talent governance execution track.
class IncomingTalentGovernanceExecutionTrackTile extends StatelessWidget {
  final IncomingTalentGovernanceExecutionTrack track;

  const IncomingTalentGovernanceExecutionTrackTile({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceExecutionStatusColor(track);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(track.status), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      track.overdue ? 'Overdue' : track.status.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: track.overdue ? 'Overdue' : track.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: track.normalizedProgressRatio,
            color: color,
            label:
                '${(track.normalizedProgressRatio * 100).round()}% execution progress',
          ),
          const SizedBox(height: 10),
          Text(
            track.actionPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (track.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              track.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: track.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(track.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${track.signalCount} ${_plural(track.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${track.decisionCount} ${_plural(track.decisionCount, 'decision')}',
              ),
              TalentMetaLabel(
                icon: Icons.checklist_outlined,
                label:
                    '${track.readinessTaskCount} prep ${_plural(track.readinessTaskCount, 'task')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceExecutionStatusColor(
  IncomingTalentGovernanceExecutionTrack track,
) {
  if (track.overdue) {
    return const Color(0xFFDC2626);
  }

  return switch (track.status) {
    IncomingTalentGovernanceExecutionStatus.blocked => const Color(0xFFDC2626),
    IncomingTalentGovernanceExecutionStatus.awaitingDecision => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery => const Color(
      0xFF7C3AED,
    ),
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation => const Color(
      0xFF2563EB,
    ),
    IncomingTalentGovernanceExecutionStatus.inProgress => const Color(
      0xFF059669,
    ),
    IncomingTalentGovernanceExecutionStatus.completed => const Color(
      0xFF15803D,
    ),
  };
}

IconData _statusIcon(IncomingTalentGovernanceExecutionStatus status) {
  return switch (status) {
    IncomingTalentGovernanceExecutionStatus.blocked =>
      Icons.report_problem_outlined,
    IncomingTalentGovernanceExecutionStatus.awaitingDecision =>
      Icons.gavel_outlined,
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery =>
      Icons.article_outlined,
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation =>
      Icons.assignment_ind_outlined,
    IncomingTalentGovernanceExecutionStatus.inProgress =>
      Icons.play_circle_outline,
    IncomingTalentGovernanceExecutionStatus.completed =>
      Icons.check_circle_outline,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution track tile')
Widget incomingTalentGovernanceExecutionTrackTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionTrackTile(track: _previewTrack),
      ),
    ),
  );
}

final _previewTrack = IncomingTalentGovernanceExecutionTrack(
  id:
      'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
  ledgerItemId:
      'talent-governance-decision-ledger:review-pack-governance-lane-assurance',
  status: IncomingTalentGovernanceExecutionStatus.blocked,
  title: 'Execute assurance approval decision',
  actionPlan:
      'Unblock publish assurance approval decision before assigning follow-through.',
  evidenceExpectation:
      'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
  blockerNote: 'Readiness blockers must be resolved before execution can move.',
  ownerName: 'People Risk and Assurance',
  dueDate: DateTime(2026, 6, 11),
  progressRatio: 0.1,
  signalCount: 5,
  decisionCount: 3,
  readinessTaskCount: 1,
  overdue: true,
);
