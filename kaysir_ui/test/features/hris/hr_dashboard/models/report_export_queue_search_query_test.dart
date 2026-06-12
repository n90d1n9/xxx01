import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_search_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('inactive report export search returns all jobs', () {
    final jobs = [
      _job('ready', ReportGenerationStatus.ready),
      _job('failed', ReportGenerationStatus.failed),
    ];

    final query = ReportExportQueueSearchQuery('   ');

    expect(query.isActive, isFalse);
    expect(query.apply(jobs), jobs);
    expect(query.emptyMessage(), 'No exports tracked yet');
  });

  test(
    'report export search matches file scope format and status metadata',
    () {
      final engineeringCsv = _job(
        'engineering-ready',
        ReportGenerationStatus.ready,
        request: const ReportGenerationRequest(
          period: ReportPeriod.lastQuarter,
          department: ReportDepartmentScope.engineering,
          format: ReportFileFormat.csv,
        ),
      );
      final hrFailed = _job(
        'hr-failed',
        ReportGenerationStatus.failed,
        request: const ReportGenerationRequest(
          department: ReportDepartmentScope.hr,
          format: ReportFileFormat.excel,
        ),
      );
      final marketingPdf = _job(
        'marketing-active',
        ReportGenerationStatus.generating,
        request: const ReportGenerationRequest(
          department: ReportDepartmentScope.marketing,
        ),
      );
      final jobs = [engineeringCsv, hrFailed, marketingPdf];

      expect(ReportExportQueueSearchQuery('engineering csv').apply(jobs), [
        engineeringCsv,
      ]);
      expect(ReportExportQueueSearchQuery('failed hr').apply(jobs), [hrFailed]);
    },
  );

  test('report export search matches content and compliance labels', () {
    final confidential = _job(
      'confidential-ready',
      ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(includeRawData: true),
    );
    final payrollSensitive = _job(
      'payroll-ready',
      ReportGenerationStatus.ready,
      report: _compensationReport,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final internal = _job('internal-ready', ReportGenerationStatus.ready);
    final jobs = [confidential, payrollSensitive, internal];

    expect(ReportExportQueueSearchQuery('raw confidential').apply(jobs), [
      confidential,
    ]);
    expect(
      ReportExportQueueSearchQuery('payroll-sensitive finance').apply(jobs),
      [payrollSensitive],
    );
  });

  test('report export search empty message uses trimmed query copy', () {
    final query = ReportExportQueueSearchQuery('  benefits  ');

    expect(query.emptyMessage(), 'No exports match "benefits"');
  });
}

ReportGenerationJob _job(
  String id,
  ReportGenerationStatus status, {
  ReportType report = _turnoverReport,
  ReportGenerationRequest request = const ReportGenerationRequest(),
}) {
  return ReportGenerationJob(
    id: id,
    report: report,
    request: request,
    status: status,
    requestedAt: DateTime(2026, 6, 1, 10),
  );
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);

const _compensationReport = ReportType(
  name: 'Compensation Report',
  description: 'Salary and benefit movement by department',
  icon: Icons.payments_outlined,
);
