import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile that shows execution progress for one assurance remediation track.
class IncomingTalentOperatingAssuranceExecutionTile extends StatelessWidget {
  final IncomingTalentOperatingAssuranceExecutionTrack track;

  const IncomingTalentOperatingAssuranceExecutionTile({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingAssuranceExecutionStatusColor(
      track.status,
    );

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
                      track.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: track.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: track.normalizedExecutionRatio,
            color: color,
            label:
                '${(track.normalizedExecutionRatio * 100).round()}% execution ready',
          ),
          const SizedBox(height: 10),
          Text(
            track.nextStep,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            track.blocker,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (track.completionEvidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              track.completionEvidence.first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: _dueLabel(track),
              ),
              TalentMetaLabel(
                icon: Icons.person_outline,
                label: track.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.inventory_2_outlined,
                label:
                    '${track.completionEvidence.length} ${_plural(track.completionEvidence.length, 'proof')}',
              ),
              TalentMetaLabel(
                icon: Icons.link_outlined,
                label:
                    '${track.linkedEscalationCount} linked ${_plural(track.linkedEscalationCount, 'escalation')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingAssuranceExecutionStatusColor(
  IncomingTalentOperatingAssuranceExecutionStatus status,
) {
  return switch (status) {
    IncomingTalentOperatingAssuranceExecutionStatus.blocked => const Color(
      0xFFDC2626,
    ),
    IncomingTalentOperatingAssuranceExecutionStatus.recovery => const Color(
      0xFFD97706,
    ),
    IncomingTalentOperatingAssuranceExecutionStatus.dueToday => const Color(
      0xFF2563EB,
    ),
    IncomingTalentOperatingAssuranceExecutionStatus.inProgress => const Color(
      0xFF059669,
    ),
  };
}

IconData _statusIcon(IncomingTalentOperatingAssuranceExecutionStatus status) {
  return switch (status) {
    IncomingTalentOperatingAssuranceExecutionStatus.blocked =>
      Icons.block_outlined,
    IncomingTalentOperatingAssuranceExecutionStatus.recovery =>
      Icons.restore_outlined,
    IncomingTalentOperatingAssuranceExecutionStatus.dueToday =>
      Icons.today_outlined,
    IncomingTalentOperatingAssuranceExecutionStatus.inProgress =>
      Icons.play_circle_outline,
  };
}

String _dueLabel(IncomingTalentOperatingAssuranceExecutionTrack track) {
  return switch (track.dueHealth) {
    IncomingTalentOperatingAssuranceExecutionDueHealth.overdue =>
      'Overdue ${DateFormat('MMM d').format(track.dueDate)}',
    IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday => 'Today',
    IncomingTalentOperatingAssuranceExecutionDueHealth.upcoming => DateFormat(
      'MMM d',
    ).format(track.dueDate),
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent assurance execution tile')
Widget incomingTalentOperatingAssuranceExecutionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingAssuranceExecutionTile(
          track: _previewTrack(),
        ),
      ),
    ),
  );
}

IncomingTalentOperatingAssuranceExecutionTrack _previewTrack() {
  return IncomingTalentOperatingAssuranceExecutionTrack(
    id: 'assurance-execution-assurance-remediation-people-operations-risk',
    remediationActionId: 'assurance-remediation-people-operations-risk',
    status: IncomingTalentOperatingAssuranceExecutionStatus.blocked,
    dueHealth: IncomingTalentOperatingAssuranceExecutionDueHealth.overdue,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    title: 'People Operations Talent Partner execution - Risk council',
    detail: '2 open gaps with 3 completion proofs required',
    blocker: '3 linked escalations must be cleared before assurance closure.',
    nextStep:
        'Unblock linked risk council escalations with People Operations Talent Partner.',
    dueDate: DateTime(2026, 6, 10),
    executionRatio: 0.26,
    openGapCount: 2,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    completionEvidence: [
      'Attach decision notes, owner commitment, and follow-up acceptance.',
      'Owner confirmation for 2 gaps.',
      'HRIS closure note for risk council assurance.',
    ],
    gapIds: ['evidence-risk-overdue', 'evidence-risk-linked'],
  );
}
