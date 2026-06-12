import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document_requirement.dart';
import '../models/company_employee_document_gap.dart';
import '../models/company_employee_document_gap_recommendation.dart';
import 'company_status_styles.dart';

class CompanyEmployeeDocumentGapPanel extends StatelessWidget {
  final List<CompanyEmployeeDocumentGap> gaps;
  final List<CompanyEmployeeDocumentGapRecommendation> recommendations;
  final DateTime asOfDate;
  final ValueChanged<String> onGenerateRequest;
  final ValueChanged<String> onMarkVerified;
  final ValueChanged<String> onWaive;

  const CompanyEmployeeDocumentGapPanel({
    super.key,
    required this.gaps,
    required this.recommendations,
    required this.asOfDate,
    required this.onGenerateRequest,
    required this.onMarkVerified,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final readyCount =
        gaps.where((gap) => !gap.requiresAttention(asOfDate)).length;
    final effectiveRecommendations =
        recommendations.isEmpty
            ? buildCompanyEmployeeDocumentGapRecommendations(
              gaps: gaps,
              asOfDate: asOfDate,
            )
            : recommendations;
    final recommendationsByGapId = {
      for (final recommendation in effectiveRecommendations)
        recommendation.gapId: recommendation,
    };
    final gapsById = {for (final gap in gaps) gap.id: gap};
    final orderedGaps = [
      for (final recommendation in effectiveRecommendations)
        if (gapsById[recommendation.gapId] != null)
          gapsById[recommendation.gapId]!,
      for (final gap in gaps)
        if (!recommendationsByGapId.containsKey(gap.id)) gap,
    ];
    final criticalCount =
        effectiveRecommendations
            .where(
              (recommendation) =>
                  recommendation.priority ==
                  CompanyEmployeeDocumentGapPriority.critical,
            )
            .length;
    final highCount =
        effectiveRecommendations
            .where(
              (recommendation) =>
                  recommendation.priority ==
                  CompanyEmployeeDocumentGapPriority.high,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.assignment_late_outlined,
      title: 'Employee Document Gap Queue',
      subtitle:
          '$readyCount clear of ${gaps.length} employee evidence checks'
          '${criticalCount == 0 ? '' : ', $criticalCount critical'}'
          '${highCount == 0 ? '' : ', $highCount high'}',
      emptyMessage: 'No matching employee document gaps',
      children:
          orderedGaps
              .map(
                (gap) => _EmployeeDocumentGapTile(
                  gap: gap,
                  recommendation:
                      recommendationsByGapId[gap.id] ??
                      CompanyEmployeeDocumentGapRecommendation.fromGap(
                        gap: gap,
                        asOfDate: asOfDate,
                      ),
                  asOfDate: asOfDate,
                  onGenerateRequest: () => onGenerateRequest(gap.id),
                  onMarkVerified: () => onMarkVerified(gap.id),
                  onWaive: () => onWaive(gap.id),
                ),
              )
              .toList(),
    );
  }
}

class _EmployeeDocumentGapTile extends StatelessWidget {
  final CompanyEmployeeDocumentGap gap;
  final CompanyEmployeeDocumentGapRecommendation recommendation;
  final DateTime asOfDate;
  final VoidCallback onGenerateRequest;
  final VoidCallback onMarkVerified;
  final VoidCallback onWaive;

  const _EmployeeDocumentGapTile({
    required this.gap,
    required this.recommendation,
    required this.asOfDate,
    required this.onGenerateRequest,
    required this.onMarkVerified,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final issues = gap.issues(asOfDate);
    final statusColor = companyEmployeeDocumentGapStatusColor(gap.status);
    final priorityColor = companyEmployeeDocumentGapPriorityColor(
      recommendation.priority,
    );

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
                      gap.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gap.entityName} - ${gap.stage.label} - ${gap.requirementName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(label: gap.status.label, color: statusColor),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: recommendation.priority.label,
                    color: priorityColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Job', value: gap.jobProfileCode),
              HrisMetricStripItem(
                label: 'Verified',
                value:
                    '${gap.verifiedDocumentCount}/${gap.requiredDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${gap.missingDocumentCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Pending',
                value: '${gap.pendingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Rejected',
                value: '${gap.rejectedDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${gap.openRequestCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value: gap.ownerName.trim().isEmpty ? 'Missing' : gap.ownerName,
              ),
              HrisMetricStripItem(label: 'Due', value: _dueLabel()),
              HrisMetricStripItem(
                label: 'Coverage',
                value: '${(gap.coverageRatio * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GapRecommendationCallout(
            recommendation: recommendation,
            color: priorityColor,
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
                          color:
                              issue == CompanyEmployeeDocumentGapIssue.overdue
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Waive'),
                ),
                OutlinedButton.icon(
                  onPressed: onMarkVerified,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Mark verified'),
                ),
                FilledButton.icon(
                  onPressed: onGenerateRequest,
                  icon: const Icon(Icons.outbox_outlined),
                  label: const Text('Generate request'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dueLabel() {
    final days = gap.daysUntilDue(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = gap.dueDate.month.toString().padLeft(2, '0');
    final day = gap.dueDate.day.toString().padLeft(2, '0');
    return '${gap.dueDate.year}-$month-$day (${days}d)';
  }
}

class _GapRecommendationCallout extends StatelessWidget {
  final CompanyEmployeeDocumentGapRecommendation recommendation;
  final Color color;

  const _GapRecommendationCallout({
    required this.recommendation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconFor(recommendation.priority),
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  recommendation.rationale,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(CompanyEmployeeDocumentGapPriority priority) {
    switch (priority) {
      case CompanyEmployeeDocumentGapPriority.low:
        return Icons.check_circle_outline;
      case CompanyEmployeeDocumentGapPriority.medium:
        return Icons.track_changes_outlined;
      case CompanyEmployeeDocumentGapPriority.high:
        return Icons.priority_high_outlined;
      case CompanyEmployeeDocumentGapPriority.critical:
        return Icons.report_problem_outlined;
    }
  }
}
