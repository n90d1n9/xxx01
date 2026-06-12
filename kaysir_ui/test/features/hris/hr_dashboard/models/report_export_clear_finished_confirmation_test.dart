import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_clear_finished_confirmation.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_summary.dart';

void main() {
  test('clear finished confirmation summarizes mixed finished exports', () {
    final confirmation = ReportExportClearFinishedConfirmation.fromSummary(
      const ReportExportQueueSummary(
        total: 3,
        readyCount: 1,
        activeCount: 1,
        failedCount: 1,
      ),
    );

    expect(confirmation.finishedCount, 2);
    expect(confirmation.title, 'Clear finished exports?');
    expect(
      confirmation.primaryMessage,
      'This removes 2 finished exports from the recent queue.',
    );
    expect(
      confirmation.statusBreakdown,
      'Includes 1 ready export and 1 failed export. Active exports stay visible.',
    );
    expect(confirmation.confirmLabel, 'Clear 2 exports');
  });

  test('clear finished confirmation handles singular labels', () {
    final confirmation = ReportExportClearFinishedConfirmation.fromSummary(
      const ReportExportQueueSummary(
        total: 2,
        readyCount: 1,
        activeCount: 1,
        failedCount: 0,
      ),
    );

    expect(confirmation.primaryMessage, contains('1 finished export'));
    expect(
      confirmation.statusBreakdown,
      startsWith('Includes 1 ready export.'),
    );
    expect(confirmation.confirmLabel, 'Clear 1 export');
  });
}
