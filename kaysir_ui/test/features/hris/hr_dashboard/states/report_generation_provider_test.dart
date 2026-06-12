import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';
import 'package:kaysir/features/hris/hr_dashboard/services/report_generation_service.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/report_generation_provider.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  test(
    'report generation controller tracks submit to ready lifecycle',
    () async {
      final now = DateTime(2026, 5, 31, 9, 30);
      final container = ProviderContainer(
        overrides: [
          reportGenerationClockProvider.overrideWithValue(() => now),
          reportGenerationDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      final future = container
          .read(reportGenerationJobsProvider.notifier)
          .submit(report, const ReportGenerationRequest());

      final active = container.read(reportGenerationJobsProvider).single;
      expect(active.status, ReportGenerationStatus.generating);
      expect(active.requestedAt, now);

      final ready = await future;

      expect(ready.status, ReportGenerationStatus.ready);
      expect(ready.completedAt, now);
      expect(container.read(reportGenerationJobsProvider), [ready]);
    },
  );

  test('report generation controller marks failed service responses', () async {
    final now = DateTime(2026, 5, 31, 9, 30);
    final container = ProviderContainer(
      overrides: [
        reportGenerationClockProvider.overrideWithValue(() => now),
        reportGenerationServiceProvider.overrideWithValue(
          const _FailingReportGenerationService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final failed = await container
        .read(reportGenerationJobsProvider.notifier)
        .submit(report, const ReportGenerationRequest());

    expect(failed.status, ReportGenerationStatus.failed);
    expect(failed.completedAt, now);
    expect(failed.failureMessage, contains('Export failed'));
    expect(container.read(reportGenerationJobsProvider).single, failed);
  });

  test(
    'report generation controller keeps the newest history entries',
    () async {
      final container = ProviderContainer(
        overrides: [
          reportGenerationDelayProvider.overrideWithValue(Duration.zero),
          reportGenerationHistoryLimitProvider.overrideWithValue(2),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(reportGenerationJobsProvider.notifier);

      await controller.submit(report, const ReportGenerationRequest());
      await controller.submit(
        report,
        const ReportGenerationRequest(format: ReportFileFormat.csv),
      );
      await controller.submit(
        report,
        const ReportGenerationRequest(format: ReportFileFormat.excel),
      );

      final jobs = container.read(reportGenerationJobsProvider);
      expect(jobs, hasLength(2));
      expect(jobs.map((job) => job.request.format), [
        ReportFileFormat.excel,
        ReportFileFormat.csv,
      ]);
    },
  );

  test('report generation controller clears finished jobs only', () async {
    final now = DateTime(2026, 5, 31, 9, 30);
    final holdActive = _HoldingReportGenerationService();
    final container = ProviderContainer(
      overrides: [
        reportGenerationClockProvider.overrideWithValue(() => now),
        reportGenerationServiceProvider.overrideWithValue(holdActive),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(reportGenerationJobsProvider.notifier);
    final ready = await controller.submit(
      report,
      const ReportGenerationRequest(),
    );
    final activeFuture = controller.submit(
      report,
      const ReportGenerationRequest(format: ReportFileFormat.csv),
    );

    expect(ready.status, ReportGenerationStatus.ready);
    expect(container.read(reportGenerationJobsProvider), hasLength(2));

    controller.clearCompleted();

    final jobs = container.read(reportGenerationJobsProvider);
    expect(jobs, hasLength(1));
    expect(jobs.single.status, ReportGenerationStatus.generating);

    holdActive.complete();
    await activeFuture;
  });

  test('report generation controller retries failed jobs only', () async {
    final service = _FailFirstReportGenerationService();
    final container = ProviderContainer(
      overrides: [reportGenerationServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final controller = container.read(reportGenerationJobsProvider.notifier);
    final failed = await controller.submit(
      report,
      const ReportGenerationRequest(),
    );
    final ready = await controller.submit(
      report,
      const ReportGenerationRequest(format: ReportFileFormat.csv),
    );

    expect(failed.status, ReportGenerationStatus.failed);
    expect(ready.status, ReportGenerationStatus.ready);

    final retried = await controller.retryFailed();

    expect(retried, hasLength(1));
    expect(retried.single.status, ReportGenerationStatus.ready);
    expect(retried.single.request, failed.request);
    expect(service.calls, 3);
    expect(
      container
          .read(reportGenerationJobsProvider)
          .where((job) => job.request == ready.request),
      hasLength(1),
    );
  });
}

class _FailingReportGenerationService implements ReportGenerationService {
  const _FailingReportGenerationService();

  @override
  Future<void> generate(
    ReportType report,
    ReportGenerationRequest request,
  ) async {
    throw StateError('Export failed');
  }
}

class _HoldingReportGenerationService implements ReportGenerationService {
  final _active = Completer<void>();
  var _calls = 0;

  void complete() => _active.complete();

  @override
  Future<void> generate(
    ReportType report,
    ReportGenerationRequest request,
  ) async {
    _calls++;
    if (_calls == 1) return;

    await _active.future;
  }
}

class _FailFirstReportGenerationService implements ReportGenerationService {
  var calls = 0;

  @override
  Future<void> generate(
    ReportType report,
    ReportGenerationRequest request,
  ) async {
    calls++;
    if (calls == 1) throw StateError('Export failed');
  }
}
