import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_retention_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test(
    'report export retention summary expires ready jobs after retention',
    () {
      final summary = ReportExportRetentionSummary.fromJob(
        _job(
          status: ReportGenerationStatus.ready,
          requestedAt: DateTime(2026, 5, 31, 9, 30),
          completedAt: DateTime(2026, 5, 31, 9, 31),
        ),
      );

      expect(summary.hasExpiry, isTrue);
      expect(summary.expiresAt, DateTime(2026, 6, 7, 9, 31));
      expect(summary.expiryLabel, 'Expires Jun 7');
    },
  );

  test('report export retention summary falls back to request time', () {
    final summary = ReportExportRetentionSummary.fromJob(
      _job(
        status: ReportGenerationStatus.ready,
        requestedAt: DateTime(2026, 12, 29, 14, 0),
      ),
    );

    expect(summary.expiresAt, DateTime(2027, 1, 5, 14, 0));
    expect(summary.expiryLabel, 'Expires Jan 5');
  });

  test('report export retention summary stays hidden for unavailable jobs', () {
    final summary = ReportExportRetentionSummary.fromJob(
      _job(status: ReportGenerationStatus.generating),
    );

    expect(summary.hasExpiry, isFalse);
    expect(summary.expiryLabel, isNull);
  });
}

ReportGenerationJob _job({
  required ReportGenerationStatus status,
  DateTime? requestedAt,
  DateTime? completedAt,
}) {
  return ReportGenerationJob(
    id: 'report',
    report: _turnoverReport,
    request: const ReportGenerationRequest(),
    status: status,
    requestedAt: requestedAt ?? DateTime(2026, 5, 31, 9, 30),
    completedAt: completedAt,
  );
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);
