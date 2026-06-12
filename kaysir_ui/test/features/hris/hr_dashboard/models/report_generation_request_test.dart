import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  test('report generation request exposes deterministic defaults', () {
    const request = ReportGenerationRequest();

    expect(request.period, ReportPeriod.last30Days);
    expect(request.department, ReportDepartmentScope.all);
    expect(request.format, ReportFileFormat.pdf);
    expect(request.includeExecutiveSummary, isTrue);
    expect(request.includeTrendCharts, isTrue);
    expect(request.includeRawData, isFalse);
    expect(request.contentSummary, 'Executive summary + Trend charts');
    expect(request.validationMessage, isNull);
    expect(
      request.exportFileNameFor(report),
      'turnover-report-all-departments-last-30-days.pdf',
    );
  });

  test('report generation request copies selected scope and format', () {
    final request = const ReportGenerationRequest().copyWith(
      period: ReportPeriod.lastQuarter,
      department: ReportDepartmentScope.engineering,
      format: ReportFileFormat.csv,
      includeTrendCharts: false,
      includeRawData: true,
    );

    expect(request.scopeLabel, 'Engineering');
    expect(request.contentSummary, 'Executive summary + Raw data export');
    expect(
      request.exportFileNameFor(report),
      'turnover-report-engineering-last-quarter.csv',
    );
    expect(
      request,
      const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
        includeTrendCharts: false,
        includeRawData: true,
      ),
    );
  });

  test('report generation request validates empty report contents', () {
    final request = const ReportGenerationRequest().copyWith(
      includeExecutiveSummary: false,
      includeTrendCharts: false,
    );

    expect(request.hasSelectedContent, isFalse);
    expect(request.contentLabels, isEmpty);
    expect(request.contentSummary, 'No package sections selected');
    expect(request.validationMessage, 'Select at least one report section');
  });
}
