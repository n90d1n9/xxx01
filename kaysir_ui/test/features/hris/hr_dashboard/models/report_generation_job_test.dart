import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  test('report generation job derives action state from status', () {
    final requestedAt = DateTime(2026, 5, 31, 9, 30);
    final job = ReportGenerationJob(
      id: 'job-1',
      report: report,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
        format: ReportFileFormat.excel,
      ),
      status: ReportGenerationStatus.generating,
      requestedAt: requestedAt,
    );

    expect(job.fileName, 'turnover-report-finance-last-30-days.xlsx');
    expect(job.status.isActive, isTrue);
    expect(job.canDownload, isFalse);
    expect(job.canRetry, isFalse);

    final ready = job.copyWith(
      status: ReportGenerationStatus.ready,
      completedAt: DateTime(2026, 5, 31, 9, 31),
    );

    expect(ready.status.isActive, isFalse);
    expect(ready.canDownload, isTrue);
    expect(ready.canRetry, isFalse);
    expect(ready.requestedAt, requestedAt);
  });

  test('failed report generation job exposes retry state', () {
    final failed = ReportGenerationJob(
      id: 'job-2',
      report: report,
      request: const ReportGenerationRequest(),
      status: ReportGenerationStatus.failed,
      requestedAt: DateTime(2026, 5, 31, 9, 30),
      failureMessage: 'Network unavailable',
    );

    expect(failed.canRetry, isTrue);
    expect(failed.canDownload, isFalse);
    expect(failed.failureMessage, 'Network unavailable');
  });
}
