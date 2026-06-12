import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'talent_meta_label.dart';

/// Tile for one governance execution evidence register item.
class IncomingTalentGovernanceExecutionEvidenceTile extends StatelessWidget {
  final IncomingTalentGovernanceExecutionEvidenceItem item;

  const IncomingTalentGovernanceExecutionEvidenceTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceExecutionEvidenceStatusColor(
      item.status,
    );
    final evidenceText =
        item.hasEvidence ? item.evidenceSummary : item.evidenceRequirement;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(item.status), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.hasEvidence ? 'Evidence attached' : 'Evidence due',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.normalizedReadinessRatio,
            color: color,
            label:
                '${(item.normalizedReadinessRatio * 100).round()}% audit readiness',
          ),
          const SizedBox(height: 10),
          Text(
            evidenceText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.ownerConfirmationNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.ownerConfirmationNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon:
                    item.hasEvidence
                        ? Icons.fact_check_outlined
                        : Icons.event_available_outlined,
                label: _dateLabel(item),
              ),
              TalentMetaLabel(
                icon: Icons.person_outline,
                label: item.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.report_problem_outlined,
                label: '${item.residualRiskCount} residual risks',
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${item.signalCount} ${_plural(item.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${item.decisionCount} ${_plural(item.decisionCount, 'decision')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceExecutionEvidenceStatusColor(
  IncomingTalentGovernanceExecutionEvidenceStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceExecutionEvidenceStatus.missing => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceExecutionEvidenceStatus.accepted => const Color(
      0xFF15803D,
    ),
    IncomingTalentGovernanceExecutionEvidenceStatus.monitor => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceExecutionEvidenceStatus.reopened => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceExecutionEvidenceStatus.escalated => const Color(
      0xFF7C3AED,
    ),
  };
}

IconData _statusIcon(IncomingTalentGovernanceExecutionEvidenceStatus status) {
  return switch (status) {
    IncomingTalentGovernanceExecutionEvidenceStatus.missing =>
      Icons.plagiarism_outlined,
    IncomingTalentGovernanceExecutionEvidenceStatus.accepted =>
      Icons.check_circle_outline,
    IncomingTalentGovernanceExecutionEvidenceStatus.monitor =>
      Icons.visibility_outlined,
    IncomingTalentGovernanceExecutionEvidenceStatus.reopened =>
      Icons.replay_outlined,
    IncomingTalentGovernanceExecutionEvidenceStatus.escalated =>
      Icons.priority_high_outlined,
  };
}

String _dateLabel(IncomingTalentGovernanceExecutionEvidenceItem item) {
  if (item.closureDate != null) {
    return 'Closed ${DateFormat('MMM d').format(item.closureDate!)}';
  }
  return 'Due ${DateFormat('MMM d').format(item.dueDate)}';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution evidence tile')
Widget incomingTalentGovernanceExecutionEvidenceTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionEvidenceTile(
          item: _previewItem,
        ),
      ),
    ),
  );
}

final _previewItem = IncomingTalentGovernanceExecutionEvidenceItem(
  id: 'talent-governance-execution-evidence:assurance',
  actionId: 'talent-governance-execution-action:assurance',
  trackId: 'talent-governance-execution:assurance',
  status: IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
  title: 'People Risk and Assurance - recover overdue',
  evidenceRequirement:
      'Attach assurance approval evidence, owner confirmation, and recovery note.',
  evidenceSummary:
      'Closure evidence confirms assurance approval follow-through is attached.',
  ownerConfirmationNote:
      'Owner confirms recovery evidence and governance cadence.',
  ownerName: 'People Risk and Assurance',
  reviewerName: 'People Risk and Assurance',
  dueDate: DateTime(2026, 6, 11),
  closureDate: DateTime(2026, 6, 12),
  nextReviewDate: DateTime(2026, 6, 26),
  residualRiskCount: 1,
  signalCount: 5,
  decisionCount: 3,
  readinessRatio: 0.7,
);
