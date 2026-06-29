import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_selection_review_models.dart';

class EmployeeDirectorySelectionReviewPanel extends StatelessWidget {
  final EmployeeDirectorySelectionReview review;

  const EmployeeDirectorySelectionReviewPanel({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-selection-review-panel'),
      icon: Icons.fact_check_outlined,
      title: 'Selection review',
      subtitle:
          review.hasSelection
              ? '${review.selectedCount} selected profiles across ${review.departmentCount} departments'
              : 'Select rows to review cohort mix before bulk updates',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Selected',
              value: '${review.selectedCount}',
            ),
            HrisMetricStripItem(
              label: 'Watchlist',
              value: '${review.watchlistCount}',
            ),
            HrisMetricStripItem(
              label: 'Avg rating',
              value: review.averagePerformance.toStringAsFixed(1),
            ),
            HrisMetricStripItem(
              label: 'Avg tenure',
              value: '${review.averageTenureMonths} mo',
            ),
          ],
        ),
        HrisResponsivePanelGrid(
          breakpoint: 820,
          panels: [
            _SelectionReviewInfoTile(
              icon: Icons.account_tree_outlined,
              color: HrisColors.primary,
              label: 'Primary department',
              value: review.primaryDepartment,
              detail: '${review.departmentCount} departments selected',
            ),
            _SelectionReviewInfoTile(
              icon: Icons.location_city_outlined,
              color: const Color(0xFF0F766E),
              label: 'Primary location',
              value: review.primaryLocation,
              detail: '${review.locationCount} locations selected',
            ),
            _SelectionReviewInfoTile(
              icon: Icons.verified_user_outlined,
              color: const Color(0xFF7C3AED),
              label: 'Status mix',
              value: review.statusMixLabel,
              detail: '${review.onboardingCount} onboarding profiles',
            ),
            _SelectionReviewInfoTile(
              icon: Icons.workspace_premium_outlined,
              color: const Color(0xFFD97706),
              label: 'High performers',
              value: '${review.highPerformerCount}',
              detail: 'Included in selected cohort',
            ),
          ],
        ),
        ...review.signals.map(
          (signal) => _SelectionReviewSignalTile(
            key: ValueKey(
              'employee-directory-selection-signal-${signal.title}',
            ),
            signal: signal,
          ),
        ),
      ],
    );
  }
}

class _SelectionReviewInfoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;

  const _SelectionReviewInfoTile({
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

class _SelectionReviewSignalTile extends StatelessWidget {
  final EmployeeDirectorySelectionSignal signal;

  const _SelectionReviewSignalTile({super.key, required this.signal});

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

IconData _priorityIcon(EmployeeDirectorySelectionSignalPriority priority) {
  switch (priority) {
    case EmployeeDirectorySelectionSignalPriority.critical:
      return Icons.priority_high_outlined;
    case EmployeeDirectorySelectionSignalPriority.elevated:
      return Icons.warning_amber_outlined;
    case EmployeeDirectorySelectionSignalPriority.steady:
      return Icons.task_alt_outlined;
  }
}

Color _priorityColor(EmployeeDirectorySelectionSignalPriority priority) {
  switch (priority) {
    case EmployeeDirectorySelectionSignalPriority.critical:
      return const Color(0xFFB91C1C);
    case EmployeeDirectorySelectionSignalPriority.elevated:
      return const Color(0xFFD97706);
    case EmployeeDirectorySelectionSignalPriority.steady:
      return HrisColors.primary;
  }
}
