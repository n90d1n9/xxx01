import 'report_export_queue_filter.dart';
import 'report_export_queue_search_query.dart';

class ReportExportQueueEmptyGuidance {
  final ReportExportQueueFilter filter;
  final ReportExportQueueSearchQuery searchQuery;

  const ReportExportQueueEmptyGuidance({
    required this.filter,
    required this.searchQuery,
  });

  bool get hasStatusConstraint => filter != ReportExportQueueFilter.all;

  bool get hasSearchConstraint => searchQuery.isActive;

  bool get canClearAll => hasStatusConstraint && hasSearchConstraint;

  String get message {
    if (hasStatusConstraint && hasSearchConstraint) {
      return 'No ${_filterScopeLabel(filter)} match "${searchQuery.displayValue}"';
    }

    if (hasSearchConstraint) return searchQuery.emptyMessage();

    return filter.emptyMessage();
  }
}

String _filterScopeLabel(ReportExportQueueFilter filter) {
  return switch (filter) {
    ReportExportQueueFilter.all => 'exports',
    ReportExportQueueFilter.ready => 'ready exports',
    ReportExportQueueFilter.active => 'in-progress exports',
    ReportExportQueueFilter.failed => 'retry-needed exports',
  };
}
