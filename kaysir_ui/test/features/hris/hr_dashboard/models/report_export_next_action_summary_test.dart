import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_next_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test(
    'report export next action asks ready jobs to download before expiry',
    () {
      final summary = ReportExportNextActionSummary.fromJob(
        _job(
          status: ReportGenerationStatus.ready,
          requestedAt: DateTime(2026, 5, 31, 9, 30),
          completedAt: DateTime(2026, 5, 31, 9, 31),
        ),
      );

      expect(summary.kind, ReportExportNextActionKind.download);
      expect(summary.label, 'Download before Jun 7');
      expect(summary.isActionable, isTrue);
    },
  );

  test('report export next action describes active work', () {
    final queued = ReportExportNextActionSummary.fromJob(
      _job(status: ReportGenerationStatus.queued),
    );
    final generating = ReportExportNextActionSummary.fromJob(
      _job(status: ReportGenerationStatus.generating),
    );

    expect(queued.kind, ReportExportNextActionKind.wait);
    expect(queued.label, 'Queued for generation');
    expect(queued.isActionable, isFalse);
    expect(generating.kind, ReportExportNextActionKind.wait);
    expect(generating.label, 'Wait for completion');
    expect(generating.isActionable, isFalse);
  });

  test('report export next action asks failed jobs to retry', () {
    final summary = ReportExportNextActionSummary.fromJob(
      _job(status: ReportGenerationStatus.failed),
    );

    expect(summary.kind, ReportExportNextActionKind.retry);
    expect(summary.label, 'Retry generation');
    expect(summary.isActionable, isTrue);
  });
}

ReportGenerationJob _job({
  required ReportGenerationStatus status,
  DateTime? requestedAt,
  DateTime? completedAt,
}) {
  final requested = requestedAt ?? DateTime(2026, 5, 31, 9, 30);
  return ReportGenerationJob(
    id: 'report',
    report: _turnoverReport,
    request: const ReportGenerationRequest(),
    status: status,
    requestedAt: requested,
    completedAt: completedAt,
  );
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);
