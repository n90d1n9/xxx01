import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_date_section.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('report export date sections group contiguous requested days', () {
    final morning = _job('morning', DateTime(2026, 6, 1, 9));
    final afternoon = _job('afternoon', DateTime(2026, 6, 1, 15));
    final yesterday = _job('yesterday', DateTime(2026, 5, 31, 12));

    final sections = ReportExportQueueDateSection.fromJobs([
      morning,
      afternoon,
      yesterday,
    ]);

    expect(sections, hasLength(2));
    expect(sections.first.label, 'Jun 1, 2026');
    expect(sections.first.countLabel, '2 exports');
    expect(sections.first.readyCount, 2);
    expect(sections.first.activeCount, 0);
    expect(sections.first.failedCount, 0);
    expect(
      sections.first.statusCounts.map((statusCount) => statusCount.label),
      ['2 ready'],
    );
    expect(sections.first.jobs, [morning, afternoon]);
    expect(sections.last.label, 'May 31, 2026');
    expect(sections.last.countLabel, '1 export');
    expect(sections.last.jobs, [yesterday]);
  });

  test('report export date sections preserve non-contiguous sort order', () {
    final firstToday = _job('first-today', DateTime(2026, 6, 1, 9));
    final yesterday = _job('yesterday', DateTime(2026, 5, 31, 12));
    final secondToday = _job('second-today', DateTime(2026, 6, 1, 15));

    final sections = ReportExportQueueDateSection.fromJobs([
      firstToday,
      yesterday,
      secondToday,
    ]);

    expect(sections, hasLength(3));
    expect(sections.map((section) => section.jobs.single), [
      firstToday,
      yesterday,
      secondToday,
    ]);
  });

  test(
    'report export date sections summarize status counts by attention order',
    () {
      final ready = _job(
        'ready',
        DateTime(2026, 6, 1, 9),
        status: ReportGenerationStatus.ready,
      );
      final queued = _job(
        'queued',
        DateTime(2026, 6, 1, 10),
        status: ReportGenerationStatus.queued,
      );
      final generating = _job(
        'generating',
        DateTime(2026, 6, 1, 11),
        status: ReportGenerationStatus.generating,
      );
      final failed = _job(
        'failed',
        DateTime(2026, 6, 1, 12),
        status: ReportGenerationStatus.failed,
      );

      final section =
          ReportExportQueueDateSection.fromJobs([
            ready,
            queued,
            generating,
            failed,
          ]).single;

      expect(section.readyCount, 1);
      expect(section.activeCount, 2);
      expect(section.failedCount, 1);
      expect(section.readyJobs, [ready]);
      expect(section.retryableJobs, [failed]);
      expect(section.hasDownloadableExports, isTrue);
      expect(section.hasRetryableExports, isTrue);
      expect(section.downloadReadyLabel, 'Download day (1)');
      expect(section.retryFailedLabel, 'Retry day (1)');
      expect(section.statusCounts.map((statusCount) => statusCount.label), [
        '1 retry',
        '2 in progress',
        '1 ready',
      ]);
    },
  );
}

ReportGenerationJob _job(
  String id,
  DateTime requestedAt, {
  ReportGenerationStatus status = ReportGenerationStatus.ready,
}) {
  return ReportGenerationJob(
    id: id,
    report: _report,
    request: const ReportGenerationRequest(),
    status: status,
    requestedAt: requestedAt,
  );
}

const _report = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates',
  icon: Icons.people_alt_outlined,
);
