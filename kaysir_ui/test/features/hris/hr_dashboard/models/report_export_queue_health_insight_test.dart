import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_health_insight.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_summary.dart';

void main() {
  test('report export queue health prioritizes failed exports', () {
    final insight = ReportExportQueueHealthInsight.fromSummary(
      const ReportExportQueueSummary(
        total: 4,
        readyCount: 1,
        activeCount: 2,
        failedCount: 1,
      ),
    );

    expect(insight.tone, ReportExportQueueHealthTone.attention);
    expect(insight.label, 'Attention');
    expect(insight.headline, '1 failed export needs retry');
    expect(
      insight.detail,
      'Review failed files before downloading or clearing the rest of the queue.',
    );
    expect(insight.suggestedFilter, ReportExportQueueFilter.failed);
    expect(insight.actionLabel, 'Review failed');
  });

  test('report export queue health highlights downloadable exports', () {
    final insight = ReportExportQueueHealthInsight.fromSummary(
      const ReportExportQueueSummary(
        total: 2,
        readyCount: 2,
        activeCount: 0,
        failedCount: 0,
      ),
    );

    expect(insight.tone, ReportExportQueueHealthTone.ready);
    expect(insight.label, 'Downloadable');
    expect(insight.headline, '2 completed exports are ready to download');
    expect(insight.suggestedFilter, ReportExportQueueFilter.ready);
    expect(insight.actionLabel, 'View ready');
  });

  test('report export queue health describes active generation', () {
    final insight = ReportExportQueueHealthInsight.fromSummary(
      const ReportExportQueueSummary(
        total: 1,
        readyCount: 0,
        activeCount: 1,
        failedCount: 0,
      ),
    );

    expect(insight.tone, ReportExportQueueHealthTone.active);
    expect(insight.label, 'Processing');
    expect(insight.headline, '1 active export is still generating');
    expect(insight.suggestedFilter, ReportExportQueueFilter.active);
    expect(insight.actionLabel, 'View progress');
  });

  test('report export queue health handles an empty queue', () {
    final insight = ReportExportQueueHealthInsight.fromSummary(
      const ReportExportQueueSummary(
        total: 0,
        readyCount: 0,
        activeCount: 0,
        failedCount: 0,
      ),
    );

    expect(insight.tone, ReportExportQueueHealthTone.clear);
    expect(insight.label, 'Clear');
    expect(insight.headline, 'Export queue is empty');
    expect(insight.suggestedFilter, isNull);
    expect(insight.actionLabel, isNull);
  });
}
