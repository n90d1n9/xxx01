import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_result_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_search_query.dart';

void main() {
  test('report export result summary stays quiet without constraints', () {
    final summary = ReportExportQueueResultSummary(
      totalCount: 3,
      visibleCount: 3,
      filter: ReportExportQueueFilter.all,
      searchQuery: const ReportExportQueueSearchQuery(''),
    );

    expect(summary.isActive, isFalse);
    expect(summary.label, 'Showing 3 exports');
    expect(summary.canClearAll, isFalse);
  });

  test('report export result summary describes status constraints', () {
    final summary = ReportExportQueueResultSummary(
      totalCount: 3,
      visibleCount: 1,
      filter: ReportExportQueueFilter.failed,
      searchQuery: const ReportExportQueueSearchQuery(''),
    );

    expect(summary.isActive, isTrue);
    expect(summary.hasFilter, isTrue);
    expect(summary.hasSearch, isFalse);
    expect(summary.label, 'Showing 1 of 3 tracked exports');
    expect(summary.filterChipLabel, 'Needs retry status');
  });

  test('report export result summary describes search constraints', () {
    final summary = ReportExportQueueResultSummary(
      totalCount: 1,
      visibleCount: 0,
      filter: ReportExportQueueFilter.all,
      searchQuery: const ReportExportQueueSearchQuery('  payroll  '),
    );

    expect(summary.isActive, isTrue);
    expect(summary.hasSearch, isTrue);
    expect(summary.label, 'Showing 0 of 1 tracked export');
    expect(summary.searchChipLabel, 'Search: "payroll"');
  });

  test(
    'report export result summary exposes clear all only for mixed constraints',
    () {
      final summary = ReportExportQueueResultSummary(
        totalCount: 4,
        visibleCount: 1,
        filter: ReportExportQueueFilter.ready,
        searchQuery: const ReportExportQueueSearchQuery('finance'),
      );

      expect(summary.hasFilter, isTrue);
      expect(summary.hasSearch, isTrue);
      expect(summary.canClearAll, isTrue);
    },
  );
}
