import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_compliance_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('report export compliance summary labels standard reports internal', () {
    final summary = ReportExportComplianceSummary.fromRequest(
      report: _turnoverReport,
      request: const ReportGenerationRequest(),
    );

    expect(summary.sensitivity, ReportExportSensitivity.internal);
    expect(summary.label, 'Internal');
    expect(summary.needsCarefulHandling, isFalse);
  });

  test('report export compliance summary labels raw exports confidential', () {
    final summary = ReportExportComplianceSummary.fromRequest(
      report: _turnoverReport,
      request: const ReportGenerationRequest(includeRawData: true),
    );

    expect(summary.sensitivity, ReportExportSensitivity.confidential);
    expect(summary.label, 'Confidential');
    expect(summary.needsCarefulHandling, isTrue);
  });

  test('report export compliance summary flags payroll-style reports', () {
    final summary = ReportExportComplianceSummary.fromRequest(
      report: const ReportType(
        name: 'Compensation Report',
        description: 'Salary and benefit movement by department',
        icon: Icons.payments_outlined,
      ),
      request: const ReportGenerationRequest(),
    );

    expect(summary.sensitivity, ReportExportSensitivity.payrollSensitive);
    expect(summary.label, 'Payroll-sensitive');
    expect(summary.needsCarefulHandling, isTrue);
  });
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);
