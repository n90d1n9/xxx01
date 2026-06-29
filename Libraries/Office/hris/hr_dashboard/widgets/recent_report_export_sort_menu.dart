import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_sort.dart';

class RecentReportExportSortMenu extends StatelessWidget {
  final ReportExportQueueSort selectedSort;
  final ValueChanged<ReportExportQueueSort> onSelected;

  const RecentReportExportSortMenu({
    super.key,
    required this.selectedSort,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ReportExportQueueSort>(
      key: const Key('recent-export-sort-menu'),
      tooltip: 'Sort recent exports',
      onSelected: onSelected,
      itemBuilder:
          (context) =>
              ReportExportQueueSort.values.map((sort) {
                return PopupMenuItem(
                  value: sort,
                  child: Row(
                    children: [
                      Icon(
                        sort == selectedSort
                            ? Icons.check_rounded
                            : Icons.sort_rounded,
                        color:
                            sort == selectedSort
                                ? HrisColors.primary
                                : HrisColors.muted,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(sort.label),
                    ],
                  ),
                );
              }).toList(),
      child: _SortMenuButton(label: selectedSort.label),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  final String label;

  const _SortMenuButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort_rounded, color: HrisColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.expand_more_rounded,
            color: HrisColors.muted,
            size: 16,
          ),
        ],
      ),
    );
  }
}
