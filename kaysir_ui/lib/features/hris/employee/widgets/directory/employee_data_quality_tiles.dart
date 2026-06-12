import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_quality_models.dart';
import 'employee_data_quality_styles.dart';

class EmployeeDataQualityScoreCard extends StatelessWidget {
  final EmployeeDataQualityProfile profile;

  const EmployeeDataQualityScoreCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final scoreColor = employeeDataQualityScoreColor(profile.score);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scoreBlock = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${profile.score}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HrisStatusPill(
                      label: employeeDataQualityScoreLabel(profile.score),
                      color: scoreColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.nextAction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final progress = HrisProgressBar(
            value: profile.score / 100,
            color: scoreColor,
            label:
                '${profile.openCount} open, ${profile.resolvedCount} resolved',
          );

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [scoreBlock, const SizedBox(height: 12), progress],
            );
          }

          return Row(
            children: [
              Expanded(child: scoreBlock),
              const SizedBox(width: 16),
              Expanded(child: progress),
            ],
          );
        },
      ),
    );
  }
}

class EmployeeDataQualitySummaryStrip extends StatelessWidget {
  final EmployeeDataQualityProfile profile;

  const EmployeeDataQualitySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
        HrisMetricStripItem(
          label: 'High risk',
          value: '${profile.highRiskCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(label: 'Waived', value: '${profile.waivedCount}'),
      ],
    );
  }
}

class EmployeeDataQualityIssueTile extends StatelessWidget {
  final EmployeeDataQualityIssue issue;
  final DateTime asOfDate;
  final VoidCallback onReview;
  final VoidCallback onResolve;
  final VoidCallback onWaive;
  final VoidCallback onReopen;

  const EmployeeDataQualityIssueTile({
    super.key,
    required this.issue,
    required this.asOfDate,
    required this.onReview,
    required this.onResolve,
    required this.onWaive,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = issue.isOverdue(asOfDate);
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeDataQualityStatusColor(issue.status);
    final severityColor = employeeDataQualitySeverityColor(issue.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeDataQualityTypeIcon(issue.type),
                  color: severityColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${issue.field} - ${issue.sourceLabel}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: overdue ? 'Overdue' : issue.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            issue.detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: issue.severity.label,
                color: severityColor,
              ),
              _MetaChip(icon: Icons.person_outline, label: issue.owner),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(issue.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
              _MetaChip(icon: Icons.category_outlined, label: issue.type.label),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children:
                  issue.isOpen
                      ? [
                        OutlinedButton.icon(
                          onPressed:
                              issue.status == EmployeeDataQualityStatus.open
                                  ? onReview
                                  : null,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Review'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onWaive,
                          icon: const Icon(Icons.do_not_disturb_on_outlined),
                          label: const Text('Waive'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: onResolve,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Resolve'),
                        ),
                      ]
                      : [
                        OutlinedButton.icon(
                          onPressed: onReopen,
                          icon: const Icon(Icons.replay_outlined),
                          label: const Text('Reopen'),
                        ),
                      ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: resolvedColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
