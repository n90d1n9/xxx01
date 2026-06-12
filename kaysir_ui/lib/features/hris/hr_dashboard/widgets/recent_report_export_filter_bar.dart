import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_export_queue_filter.dart';
import '../models/report_export_queue_summary.dart';

class RecentReportExportFilterBar extends StatelessWidget {
  final ReportExportQueueSummary summary;
  final ReportExportQueueFilter selectedFilter;
  final ValueChanged<ReportExportQueueFilter> onSelected;

  const RecentReportExportFilterBar({
    super.key,
    required this.summary,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          ReportExportQueueFilter.values.map((filter) {
            final count = filter.countIn(summary);
            final disabled = !filter.isAvailableIn(summary);

            return ChoiceChip(
              key: Key('recent-export-filter-${filter.name}'),
              label: Text('${filter.shortLabel} ($count)'),
              selected: selectedFilter == filter,
              onSelected: disabled ? null : (_) => onSelected(filter),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              selectedColor: HrisColors.primary.withValues(alpha: 0.12),
              side: BorderSide(
                color:
                    selectedFilter == filter
                        ? HrisColors.primary
                        : HrisColors.border,
              ),
              labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    disabled
                        ? HrisColors.muted.withValues(alpha: 0.7)
                        : selectedFilter == filter
                        ? HrisColors.primary
                        : HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            );
          }).toList(),
    );
  }
}
