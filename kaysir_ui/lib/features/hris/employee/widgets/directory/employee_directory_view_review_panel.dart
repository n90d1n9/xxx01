import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_view_review_models.dart';

class EmployeeDirectoryViewReviewPanel extends StatelessWidget {
  final EmployeeDirectoryViewReview review;

  const EmployeeDirectoryViewReviewPanel({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-view-review-panel'),
      icon: Icons.rule_folder_outlined,
      title: 'View readiness',
      subtitle:
          '${review.viewName}: ${review.visibleCount} of ${review.totalCount} profiles visible',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Focus', value: review.focusLabel),
            HrisMetricStripItem(
              label: 'Coverage',
              value: '${review.coveragePercent}%',
            ),
            HrisMetricStripItem(
              label: 'Readiness',
              value: '${review.readinessScore}%',
            ),
            HrisMetricStripItem(
              label: 'Issues',
              value: '${review.affectedVisibleCount}',
            ),
          ],
        ),
        HrisResponsivePanelGrid(
          breakpoint: 820,
          panels: [
            _ViewReviewTile(
              icon: Icons.filter_alt_outlined,
              color: HrisColors.primary,
              label: 'Filter stack',
              value: review.filterStackLabel,
              detail: review.filterStackDetail,
            ),
            _ViewReviewTile(
              icon: Icons.sort_outlined,
              color: const Color(0xFF0F766E),
              label: 'Sort order',
              value: review.sortLabel,
              detail: 'Controls how the active employee table is ordered.',
            ),
            _ViewReviewTile(
              icon: Icons.verified_outlined,
              color: const Color(0xFF7C3AED),
              label: 'Quality gate',
              value: review.qualityGateLabel,
              detail: review.qualityGateDetail,
            ),
            _ViewReviewTile(
              icon: Icons.playlist_add_check_outlined,
              color: const Color(0xFFD97706),
              label: 'Bulk scope',
              value: review.bulkScopeLabel,
              detail: review.bulkScopeDetail,
            ),
          ],
        ),
        ...review.signals.map(
          (signal) => _ViewReviewSignalTile(
            key: ValueKey('employee-directory-view-signal-${signal.title}'),
            signal: signal,
          ),
        ),
      ],
    );
  }
}

class _ViewReviewTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;

  const _ViewReviewTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
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
}

class _ViewReviewSignalTile extends StatelessWidget {
  final EmployeeDirectoryViewReviewSignal signal;

  const _ViewReviewSignalTile({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(signal.priority);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_priorityIcon(signal.priority), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        signal.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: signal.priority.label, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  signal.detail,
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
}

IconData _priorityIcon(EmployeeDirectoryViewReviewSignalPriority priority) {
  switch (priority) {
    case EmployeeDirectoryViewReviewSignalPriority.critical:
      return Icons.priority_high_outlined;
    case EmployeeDirectoryViewReviewSignalPriority.elevated:
      return Icons.warning_amber_outlined;
    case EmployeeDirectoryViewReviewSignalPriority.steady:
      return Icons.task_alt_outlined;
  }
}

Color _priorityColor(EmployeeDirectoryViewReviewSignalPriority priority) {
  switch (priority) {
    case EmployeeDirectoryViewReviewSignalPriority.critical:
      return const Color(0xFFB91C1C);
    case EmployeeDirectoryViewReviewSignalPriority.elevated:
      return const Color(0xFFD97706);
    case EmployeeDirectoryViewReviewSignalPriority.steady:
      return HrisColors.primary;
  }
}
