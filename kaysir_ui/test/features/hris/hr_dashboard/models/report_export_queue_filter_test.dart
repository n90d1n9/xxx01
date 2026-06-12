import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('report export queue filters match status groups', () {
    final ready = _job('ready', ReportGenerationStatus.ready);
    final queued = _job('queued', ReportGenerationStatus.queued);
    final generating = _job('generating', ReportGenerationStatus.generating);
    final failed = _job('failed', ReportGenerationStatus.failed);
    final jobs = [ready, queued, generating, failed];

    expect(ReportExportQueueFilter.all.apply(jobs), jobs);
    expect(ReportExportQueueFilter.ready.apply(jobs), [ready]);
    expect(ReportExportQueueFilter.active.apply(jobs), [queued, generating]);
    expect(ReportExportQueueFilter.failed.apply(jobs), [failed]);
  });

  test('report export queue filters expose empty-state copy', () {
    expect(
      ReportExportQueueFilter.ready.emptyMessage(),
      'No ready exports yet',
    );
    expect(
      ReportExportQueueFilter.active.emptyMessage(),
      'No reports in progress',
    );
    expect(
      ReportExportQueueFilter.failed.emptyMessage(),
      'No exports need retry',
    );
  });

  test('report export queue filters normalize unavailable selections', () {
    final summary = ReportExportQueueSummary.fromJobs([
      _job('ready', ReportGenerationStatus.ready),
      _job('generating', ReportGenerationStatus.generating),
    ]);

    expect(ReportExportQueueFilter.ready.countIn(summary), 1);
    expect(ReportExportQueueFilter.failed.countIn(summary), 0);
    expect(ReportExportQueueFilter.failed.isAvailableIn(summary), isFalse);
    expect(
      ReportExportQueueFilter.normalize(
        selected: ReportExportQueueFilter.failed,
        summary: summary,
      ),
      ReportExportQueueFilter.all,
    );
    expect(
      ReportExportQueueFilter.normalize(
        selected: ReportExportQueueFilter.active,
        summary: summary,
      ),
      ReportExportQueueFilter.active,
    );
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
