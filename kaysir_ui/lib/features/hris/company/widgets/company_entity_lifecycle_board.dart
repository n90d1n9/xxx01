import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_entity_lifecycle.dart';
import 'company_status_styles.dart';

class CompanyEntityLifecycleBoard extends StatelessWidget {
  final List<CompanyEntityLifecycleMilestone> milestones;
  final DateTime asOfDate;
  final ValueChanged<String> onAdvance;
  final ValueChanged<String> onLaunch;

  const CompanyEntityLifecycleBoard({
    super.key,
    required this.milestones,
    required this.asOfDate,
    required this.onAdvance,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final ready =
        milestones
            .where((milestone) => !milestone.requiresAttention(asOfDate))
            .length;

    return HrisSectionPanel(
      icon: Icons.timeline_outlined,
      title: 'Entity Lifecycle Board',
      subtitle: '$ready/${milestones.length} milestones ready',
      emptyMessage: 'No matching entity lifecycle milestones',
      children:
          milestones
              .map(
                (milestone) => _LifecycleTile(
                  milestone: milestone,
                  asOfDate: asOfDate,
                  onAdvance: () => onAdvance(milestone.id),
                  onLaunch: () => onLaunch(milestone.id),
                ),
              )
              .toList(),
    );
  }
}

class _LifecycleTile extends StatelessWidget {
  final CompanyEntityLifecycleMilestone milestone;
  final DateTime asOfDate;
  final VoidCallback onAdvance;
  final VoidCallback onLaunch;

  const _LifecycleTile({
    required this.milestone,
    required this.asOfDate,
    required this.onAdvance,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyEntityLifecycleStatusColor(milestone.status);
    final issues = milestone.issues(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${milestone.entityName} - ${milestone.type.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: milestone.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: milestone.ownerName),
              HrisMetricStripItem(
                label: 'Target',
                value: _targetLabel(milestone),
              ),
              HrisMetricStripItem(
                label: 'Next',
                value: milestone.nextMilestone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: milestone.progressPercent / 100,
            color: statusColor,
            label: '${milestone.progressPercent}% complete',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label:
                    milestone.dependencySummary.trim().isEmpty
                        ? 'No dependencies mapped'
                        : milestone.dependencySummary,
                color: Colors.blueGrey,
              ),
              if (milestone.blocker.trim().isNotEmpty)
                HrisStatusPill(label: milestone.blocker, color: Colors.red),
            ],
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (milestone.status != CompanyEntityLifecycleStatus.launched &&
              milestone.status != CompanyEntityLifecycleStatus.archived) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onAdvance,
                  icon: const Icon(Icons.trending_up_outlined),
                  label: const Text('Advance'),
                ),
                FilledButton.icon(
                  onPressed: onLaunch,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Launch'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _targetLabel(CompanyEntityLifecycleMilestone milestone) {
    final days = milestone.daysUntilTarget(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    return '${_formatDate(milestone.targetDate)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
