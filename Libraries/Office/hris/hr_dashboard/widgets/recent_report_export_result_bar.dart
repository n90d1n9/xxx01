import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_result_summary.dart';

class RecentReportExportResultBar extends StatelessWidget {
  final ReportExportQueueResultSummary summary;
  final VoidCallback? onClearFilter;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearAll;

  const RecentReportExportResultBar({
    super.key,
    required this.summary,
    this.onClearFilter,
    this.onClearSearch,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!summary.isActive) return const SizedBox.shrink();

    final resultLabel = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.manage_search_rounded,
          color: HrisColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            summary.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (summary.hasFilter)
          _ConstraintChip(
            label: summary.filterChipLabel,
            tooltip: 'Remove export status constraint',
            onDeleted: onClearFilter,
          ),
        if (summary.hasSearch)
          _ConstraintChip(
            label: summary.searchChipLabel,
            tooltip: 'Remove export search constraint',
            onDeleted: onClearSearch,
          ),
        if (summary.canClearAll)
          TextButton.icon(
            key: const Key('recent-export-clear-constraints'),
            onPressed: onClearAll,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Clear all'),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 780) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [resultLabel, const SizedBox(height: 8), controls],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: resultLabel),
              const SizedBox(width: 12),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _ConstraintChip extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback? onDeleted;

  const _ConstraintChip({
    required this.label,
    required this.tooltip,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      deleteButtonTooltipMessage: tooltip,
      backgroundColor: HrisColors.surface,
      side: const BorderSide(color: HrisColors.border),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: HrisColors.ink,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
