import 'report_export_queue_filter.dart';
import 'report_export_queue_search_query.dart';

class ReportExportQueueResultSummary {
  final int totalCount;
  final int visibleCount;
  final ReportExportQueueFilter filter;
  final ReportExportQueueSearchQuery searchQuery;

  const ReportExportQueueResultSummary({
    required this.totalCount,
    required this.visibleCount,
    required this.filter,
    required this.searchQuery,
  });

  bool get hasFilter => filter != ReportExportQueueFilter.all;

  bool get hasSearch => searchQuery.isActive;

  bool get isActive => hasFilter || hasSearch;

  bool get canClearAll => hasFilter && hasSearch;

  String get label {
    if (!isActive) return 'Showing ${_countedExportLabel(visibleCount)}';

    return 'Showing $visibleCount of ${_countedTrackedLabel(totalCount)}';
  }

  String get filterChipLabel => '${filter.shortLabel} status';

  String get searchChipLabel => 'Search: "${searchQuery.displayValue}"';
}

String _countedExportLabel(int count) {
  return '$count ${count == 1 ? 'export' : 'exports'}';
}

String _countedTrackedLabel(int count) {
  return '$count tracked ${count == 1 ? 'export' : 'exports'}';
}
