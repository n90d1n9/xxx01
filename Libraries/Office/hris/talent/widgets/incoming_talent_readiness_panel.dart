import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_readiness.dart';
import '../models/incoming_talent_readiness_summary.dart';
import 'talent_meta_label.dart';

class IncomingTalentReadinessPanel extends StatelessWidget {
  final List<IncomingTalentReadiness> readiness;
  final IncomingTalentReadinessSummary summary;

  const IncomingTalentReadinessPanel({
    super.key,
    required this.readiness,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Incoming readiness',
      icon: Icons.assignment_turned_in_outlined,
      subtitle:
          '${summary.totalCount} handoffs · '
          '${(summary.checklistCompletionRate * 100).round()}% checklist',
      emptyMessage: 'No incoming handoffs match filters',
      children:
          readiness.isEmpty
              ? const []
              : [
                HrisMetricStrip(
                  items: [
                    HrisMetricStripItem(
                      label: 'Ready',
                      value: '${summary.readyCount}',
                    ),
                    HrisMetricStripItem(
                      label: 'Attention',
                      value: '${summary.attentionCount}',
                    ),
                    HrisMetricStripItem(
                      label: 'Blocked',
                      value: '${summary.blockedCount}',
                    ),
                    HrisMetricStripItem(
                      label: 'Evidence',
                      value: '${summary.evidenceBackedCount}',
                    ),
                  ],
                ),
                for (final item in readiness)
                  _IncomingTalentReadinessTile(readiness: item),
              ],
    );
  }
}

class _IncomingTalentReadinessTile extends StatelessWidget {
  final IncomingTalentReadiness readiness;

  const _IncomingTalentReadinessTile({required this.readiness});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(readiness.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_add_alt_1_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      readiness.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      readiness.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: readiness.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            readiness.talentFocus,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: readiness.checklistCompletionRatio,
            color: color,
            label:
                '${readiness.completedRequiredChecklistCount}/'
                '${readiness.requiredChecklistCount} required tasks complete',
          ),
          const SizedBox(height: 10),
          Text(
            readiness.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: readiness.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: readiness.managerName,
              ),
              TalentMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(readiness.targetStartDate),
              ),
              TalentMetaLabel(
                icon: Icons.speed_outlined,
                label: '${readiness.readinessScore}% ready',
              ),
              if (readiness.pendingRequiredChecklistCount > 0)
                TalentMetaLabel(
                  icon: Icons.pending_actions_outlined,
                  label:
                      '${readiness.pendingRequiredChecklistCount} tasks pending',
                ),
              if (readiness.acceptedProgramMilestoneCount > 0)
                TalentMetaLabel(
                  icon: Icons.task_alt_outlined,
                  label:
                      '${readiness.acceptedProgramMilestoneCount} milestones',
                ),
              if (readiness.roleReadyProgramCompletionCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label:
                      '${readiness.roleReadyProgramCompletionCount} role-ready',
                ),
              if (readiness.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.report_problem_outlined,
                  label:
                      '${readiness.programCompletionExtensionCount} extensions',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentReadinessStatus status) {
  return switch (status) {
    IncomingTalentReadinessStatus.ready => const Color(0xFF059669),
    IncomingTalentReadinessStatus.attention => const Color(0xFFD97706),
    IncomingTalentReadinessStatus.blocked => const Color(0xFFDC2626),
  };
}
