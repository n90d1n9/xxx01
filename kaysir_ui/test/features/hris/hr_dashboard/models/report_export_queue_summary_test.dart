import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('report export queue summary counts status groups', () {
    final summary = ReportExportQueueSummary.fromJobs([
      _job('queued', ReportGenerationStatus.queued),
      _job('generating', ReportGenerationStatus.generating),
      _job('ready', ReportGenerationStatus.ready),
      _job('failed', ReportGenerationStatus.failed),
    ]);

    expect(summary.total, 4);
    expect(summary.readyCount, 1);
    expect(summary.activeCount, 2);
    expect(summary.failedCount, 1);
    expect(summary.downloadableCount, 1);
    expect(summary.finishedCount, 2);
    expect(summary.hasActiveExports, isTrue);
    expect(summary.hasDownloadableExports, isTrue);
    expect(summary.hasFailedExports, isTrue);
    expect(summary.hasFinishedExports, isTrue);
    expect(summary.downloadReadyLabel, 'Download ready (1)');
    expect(summary.retryFailedLabel, 'Retry failed (1)');
    expect(summary.clearFinishedLabel, 'Clear finished (2)');
    expect(summary.statusGroupCount, 3);
    expect(summary.hasMultipleStatusGroups, isTrue);
    expect(summary.trackedLabel, '4 tracked');
  });

  test('report export queue summary stays quiet for completed work', () {
    final summary = ReportExportQueueSummary.fromJobs([
      _job('ready-a', ReportGenerationStatus.ready),
      _job('ready-b', ReportGenerationStatus.ready),
    ]);

    expect(summary.readyCount, 2);
    expect(summary.activeCount, 0);
    expect(summary.failedCount, 0);
    expect(summary.downloadableCount, 2);
    expect(summary.finishedCount, 2);
    expect(summary.hasActiveExports, isFalse);
    expect(summary.hasDownloadableExports, isTrue);
    expect(summary.hasFailedExports, isFalse);
    expect(summary.hasFinishedExports, isTrue);
    expect(summary.downloadReadyLabel, 'Download ready (2)');
    expect(summary.retryFailedLabel, 'Retry failed (0)');
    expect(summary.clearFinishedLabel, 'Clear finished (2)');
    expect(summary.statusGroupCount, 1);
    expect(summary.hasMultipleStatusGroups, isFalse);
  });
}

ReportGenerationJob _job(String id, ReportGenerationStatus status) {
  return ReportGenerationJob(
    id: id,
    report: _report,
    request: const ReportGenerationRequest(),
    status: status,
    requestedAt: DateTime(2026, 6, 1, 10),
  );
}

const _report = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates',
  icon: Icons.people_alt_outlined,
);
