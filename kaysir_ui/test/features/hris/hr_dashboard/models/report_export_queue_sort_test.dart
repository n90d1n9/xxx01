import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_queue_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';

void main() {
  test('report export queue sort orders by recency', () {
    final older = _job('older', ReportGenerationStatus.ready, 9);
    final newer = _job('newer', ReportGenerationStatus.ready, 11);

    expect(ReportExportQueueSort.newest.apply([older, newer]), [newer, older]);
    expect(ReportExportQueueSort.oldest.apply([older, newer]), [older, newer]);
  });

  test('report export queue sort prioritizes attention states', () {
    final ready = _job('ready', ReportGenerationStatus.ready, 12);
    final generating = _job('generating', ReportGenerationStatus.generating, 8);
    final failed = _job('failed', ReportGenerationStatus.failed, 7);

    expect(ReportExportQueueSort.attention.apply([ready, generating, failed]), [
      failed,
      generating,
      ready,
    ]);
  });
}

ReportGenerationJob _job(String id, ReportGenerationStatus status, int hour) {
  return ReportGenerationJob(
    id: id,
    report: _report,
    request: const ReportGenerationRequest(),
    status: status,
    requestedAt: DateTime(2026, 6, 1, hour),
  );
}

const _report = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates',
  icon: Icons.people_alt_outlined,
);
