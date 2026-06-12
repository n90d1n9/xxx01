import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_empty_guidance.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_search_query.dart';

void main() {
  test(
    'report export empty guidance uses base queue copy without constraints',
    () {
      final guidance = ReportExportQueueEmptyGuidance(
        filter: ReportExportQueueFilter.all,
        searchQuery: const ReportExportQueueSearchQuery(''),
      );

      expect(guidance.hasStatusConstraint, isFalse);
      expect(guidance.hasSearchConstraint, isFalse);
      expect(guidance.canClearAll, isFalse);
      expect(guidance.message, 'No exports tracked yet');
    },
  );

  test('report export empty guidance describes status-only misses', () {
    final guidance = ReportExportQueueEmptyGuidance(
      filter: ReportExportQueueFilter.failed,
      searchQuery: const ReportExportQueueSearchQuery(''),
    );

    expect(guidance.hasStatusConstraint, isTrue);
    expect(guidance.hasSearchConstraint, isFalse);
    expect(guidance.canClearAll, isFalse);
    expect(guidance.message, 'No exports need retry');
  });

  test('report export empty guidance describes search-only misses', () {
    final guidance = ReportExportQueueEmptyGuidance(
      filter: ReportExportQueueFilter.all,
      searchQuery: const ReportExportQueueSearchQuery(' benefits '),
    );

    expect(guidance.hasStatusConstraint, isFalse);
    expect(guidance.hasSearchConstraint, isTrue);
    expect(guidance.canClearAll, isFalse);
    expect(guidance.message, 'No exports match "benefits"');
  });

  test('report export empty guidance scopes search misses inside a status', () {
    final guidance = ReportExportQueueEmptyGuidance(
      filter: ReportExportQueueFilter.failed,
      searchQuery: const ReportExportQueueSearchQuery('finance'),
    );

    expect(guidance.hasStatusConstraint, isTrue);
    expect(guidance.hasSearchConstraint, isTrue);
    expect(guidance.canClearAll, isTrue);
    expect(guidance.message, 'No retry-needed exports match "finance"');
  });
}
