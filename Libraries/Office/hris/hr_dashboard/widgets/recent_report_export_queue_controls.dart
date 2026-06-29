import 'package:flutter/material.dart';

import '../models/report_export_queue_filter.dart';
import '../models/report_export_queue_sort.dart';
import '../models/report_export_queue_summary.dart';
import 'recent_report_export_filter_bar.dart';
import 'recent_report_export_search_field.dart';
import 'recent_report_export_sort_menu.dart';

class RecentReportExportQueueControls extends StatelessWidget {
  final ReportExportQueueSummary summary;
  final ReportExportQueueFilter selectedFilter;
  final ValueChanged<ReportExportQueueFilter> onFilterSelected;
  final ReportExportQueueSort selectedSort;
  final ValueChanged<ReportExportQueueSort> onSortSelected;
  final String searchText;
  final ValueChanged<String> onSearchChanged;

  const RecentReportExportQueueControls({
    super.key,
    required this.summary,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.selectedSort,
    required this.onSortSelected,
    required this.searchText,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchField =
        summary.total > 1
            ? RecentReportExportSearchField(
              value: searchText,
              onChanged: onSearchChanged,
            )
            : null;
    final filterBar =
        summary.hasMultipleStatusGroups
            ? RecentReportExportFilterBar(
              summary: summary,
              selectedFilter: selectedFilter,
              onSelected: onFilterSelected,
            )
            : null;
    final sortMenu =
        summary.total > 1
            ? RecentReportExportSortMenu(
              selectedSort: selectedSort,
              onSelected: onSortSelected,
            )
            : null;

    if (searchField == null && filterBar == null && sortMenu == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchField != null) searchField,
        if (searchField != null && (filterBar != null || sortMenu != null))
          const SizedBox(height: 10),
        if (filterBar != null || sortMenu != null)
          _FilterSortControls(filterBar: filterBar, sortMenu: sortMenu),
      ],
    );
  }
}

class _FilterSortControls extends StatelessWidget {
  final Widget? filterBar;
  final Widget? sortMenu;

  const _FilterSortControls({required this.filterBar, required this.sortMenu});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (filterBar != null) filterBar!,
              if (filterBar != null && sortMenu != null)
                const SizedBox(height: 10),
              if (sortMenu != null) sortMenu!,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filterBar != null) Expanded(child: filterBar!),
            if (filterBar != null && sortMenu != null)
              const SizedBox(width: 12),
            if (sortMenu != null) sortMenu!,
          ],
        );
      },
    );
  }
}
