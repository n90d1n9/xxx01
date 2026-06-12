import 'package:flutter/material.dart';

import '../../analytics/survey_response_review_insights.dart';
import '../../models/survey_response.dart';
import '../../models/survey_response_review.dart';
import 'survey_dashboard_shared.dart';
import 'survey_metric_card.dart';

typedef SurveyResponseReviewStatusChanged =
    void Function(SurveyResponse response, SurveyResponseReviewStatus status);

/// Shows response review metrics, queue items, and optional decision actions.
class SurveyResponseReviewPanel extends StatelessWidget {
  final SurveyResponseReviewInsights insights;
  final SurveyResponseReviewStatusChanged? onStatusChanged;

  const SurveyResponseReviewPanel({
    super.key,
    required this.insights,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final queue = insights.reviewQueue(limit: 6);

    return SurveySectionStack(
      children: [
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.rate_review_outlined,
              label: 'Pending',
              value: insights.pendingReviewCount.toString(),
              detail: '${(insights.reviewProgress * 100).round()}% reviewed',
            ),
            SurveyMetricCard(
              icon: Icons.verified_outlined,
              label: 'Approved',
              value: insights.approvedCount.toString(),
              detail: '${insights.rejectedCount} rejected',
            ),
            SurveyMetricCard(
              icon: Icons.flag_outlined,
              label: 'Follow-up',
              value: insights.needsFollowUpCount.toString(),
              detail: 'Needs action',
            ),
          ],
        ),
        const SurveySectionHeader(title: 'Human Review Queue'),
        if (queue.isEmpty)
          const SurveyEmptyState(
            icon: Icons.verified_user_outlined,
            title: 'No responses awaiting review',
            subtitle: 'Submitted responses have a review decision.',
          )
        else ...[
          if (onStatusChanged == null) ...[
            const _ReviewReadOnlyNotice(),
            const SizedBox(height: 10),
          ],
          ...queue.map(
            (item) =>
                _ReviewQueueTile(item: item, onStatusChanged: onStatusChanged),
          ),
        ],
      ],
    );
  }
}

/// Renders a compact permission note when review decisions are unavailable.
class _ReviewReadOnlyNotice extends StatelessWidget {
  const _ReviewReadOnlyNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.visibility_outlined, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Review decisions are read-only for this role.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a single response queued for human review.
class _ReviewQueueTile extends StatelessWidget {
  final SurveyResponseReviewItem item;
  final SurveyResponseReviewStatusChanged? onStatusChanged;

  const _ReviewQueueTile({required this.item, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final response = item.response;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.respondentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detailText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ReviewStatusChip(status: response.reviewStatus),
              ],
            ),
            if (onStatusChanged != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: const Text('Approve'),
                    onPressed: () => onStatusChanged!(
                      response,
                      SurveyResponseReviewStatus.approved,
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Follow-up'),
                    onPressed: () => onStatusChanged!(
                      response,
                      SurveyResponseReviewStatus.needsFollowUp,
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.block_outlined, size: 18),
                    label: const Text('Reject'),
                    onPressed: () => onStatusChanged!(
                      response,
                      SurveyResponseReviewStatus.rejected,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _detailText {
    final collector = item.response.collectorName;
    final signalText = item.signalCount == 0
        ? 'No quality flags'
        : '${item.signalCount} quality signal${item.signalCount == 1 ? '' : 's'}';
    final criticalText = item.hasCriticalSignal ? ' • critical' : '';
    final collectorText = collector == null || collector.isEmpty
        ? ''
        : ' • $collector';
    return '${item.survey.title}$collectorText • $signalText$criticalText';
  }
}

/// Displays the current human-review decision state.
class _ReviewStatusChip extends StatelessWidget {
  final SurveyResponseReviewStatus status;

  const _ReviewStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case SurveyResponseReviewStatus.pending:
        return colorScheme.primary;
      case SurveyResponseReviewStatus.approved:
        return colorScheme.primary;
      case SurveyResponseReviewStatus.rejected:
        return colorScheme.error;
      case SurveyResponseReviewStatus.needsFollowUp:
        return colorScheme.tertiary;
    }
  }
}
