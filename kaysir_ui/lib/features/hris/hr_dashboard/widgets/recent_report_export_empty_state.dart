import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_empty_guidance.dart';

class RecentReportExportEmptyState extends StatelessWidget {
  final ReportExportQueueEmptyGuidance guidance;
  final VoidCallback? onClearFilter;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearAll;

  const RecentReportExportEmptyState({
    super.key,
    required this.guidance,
    this.onClearFilter,
    this.onClearSearch,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (guidance.hasSearchConstraint)
        _EmptyStateAction(
          key: const Key('recent-export-empty-clear-search'),
          icon: Icons.search_off_rounded,
          label: 'Clear search',
          onPressed: onClearSearch,
        ),
      if (guidance.hasStatusConstraint)
        _EmptyStateAction(
          key: const Key('recent-export-empty-clear-filter'),
          icon: Icons.filter_alt_off_outlined,
          label: 'Clear status',
          onPressed: onClearFilter,
        ),
      if (guidance.canClearAll)
        _EmptyStateAction(
          key: const Key('recent-export-empty-clear-all'),
          icon: Icons.close_rounded,
          label: 'Clear all',
          onPressed: onClearAll,
        ),
    ];

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;
          final content = _EmptyStateContent(guidance: guidance);
          final actionBar =
              actions.isEmpty
                  ? null
                  : Wrap(spacing: 8, runSpacing: 8, children: actions);

          if (isNarrow || actionBar == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                if (actionBar != null) ...[
                  const SizedBox(height: 10),
                  actionBar,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: content),
              const SizedBox(width: 12),
              actionBar,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  final ReportExportQueueEmptyGuidance guidance;

  const _EmptyStateContent({required this.guidance});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          guidance.hasSearchConstraint
              ? Icons.search_off_rounded
              : Icons.filter_alt_off_outlined,
          color: HrisColors.muted,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            guidance.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _EmptyStateAction({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
