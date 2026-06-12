import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_timing_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  test('report export timing summary describes completed jobs', () {
    final summary = ReportExportTimingSummary.fromJob(
      ReportGenerationJob(
        id: 'job-1',
        report: report,
        request: const ReportGenerationRequest(),
        status: ReportGenerationStatus.ready,
        requestedAt: DateTime(2026, 5, 31, 9, 30),
        completedAt: DateTime(2026, 5, 31, 9, 42),
      ),
    );

    expect(summary.startedLabel, 'Started 09:30');
    expect(summary.statusLabel, 'Completed 09:42');
    expect(summary.durationLabel, '12m runtime');
    expect(summary.labels, ['Started 09:30', 'Completed 09:42', '12m runtime']);
  });

  test('report export timing summary describes failed and active jobs', () {
    final failed = ReportExportTimingSummary.fromJob(
      ReportGenerationJob(
        id: 'job-2',
        report: report,
        request: const ReportGenerationRequest(),
        status: ReportGenerationStatus.failed,
        requestedAt: DateTime(2026, 5, 31, 9, 30),
        completedAt: DateTime(2026, 5, 31, 10, 35),
      ),
    );
    final generating = ReportExportTimingSummary.fromJob(
      ReportGenerationJob(
        id: 'job-3',
        report: report,
        request: const ReportGenerationRequest(),
        status: ReportGenerationStatus.generating,
        requestedAt: DateTime(2026, 5, 31, 9, 30),
      ),
    );

    expect(failed.statusLabel, 'Failed 10:35');
    expect(failed.durationLabel, '1h 5m runtime');
    expect(generating.labels, ['Started 09:30', 'Generating now']);
  });
}
