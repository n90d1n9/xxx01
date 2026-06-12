import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/recent_report_exports.dart';

void main() {
  testWidgets('recent report exports stays hidden without jobs', (
    tester,
  ) async {
    await _pumpRecentExports(tester, jobs: const []);

    expect(find.text('Recent exports'), findsNothing);
  });

  testWidgets('recent report exports downloads ready jobs', (tester) async {
    final downloads = <ReportGenerationJob>[];
    final job = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
        includeRawData: true,
      ),
    );

    await _pumpRecentExports(tester, jobs: [job], onDownload: downloads.add);

    expect(find.text('Recent exports'), findsOneWidget);
    expect(find.text('1 tracked'), findsOneWidget);
    expect(find.text('Ready exports'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Needs retry'), findsOneWidget);
    expect(
      find.text('turnover-report-engineering-last-quarter.csv'),
      findsOneWidget,
    );
    expect(
      find.text('Turnover Report - Last Quarter - Engineering - 09:30'),
      findsOneWidget,
    );
    expect(find.text('Started 09:30'), findsOneWidget);
    expect(find.text('Completed 09:31'), findsOneWidget);
    expect(find.text('1m runtime'), findsOneWidget);
    expect(
      find.text('Executive summary + Trend charts + Raw data export'),
      findsOneWidget,
    );
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('Est. 2.3 MB', skipOffstage: false), findsOneWidget);
    expect(
      find.text('~1m 20s generation', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Confidential', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Download before Jun 7', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Download turnover-report-engineering-last-quarter.csv'),
    );
    await tester.pump();

    expect(downloads, [job]);
  });

  testWidgets('recent report exports retries failed jobs', (tester) async {
    final retries = <ReportGenerationJob>[];
    final job = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
    );

    await _pumpRecentExports(tester, jobs: [job], onRetry: retries.add);

    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Needs retry'), findsOneWidget);
    expect(find.text('Failed 09:31'), findsOneWidget);
    expect(find.text('Could not generate report.'), findsOneWidget);
    expect(find.text('Retry generation', skipOffstage: false), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retries, [job]);
  });

  testWidgets('recent report exports shows progress for active jobs', (
    tester,
  ) async {
    await _pumpRecentExports(
      tester,
      width: 420,
      jobs: [
        _job(id: 'queued-report', status: ReportGenerationStatus.queued),
        _job(
          id: 'generating-report',
          status: ReportGenerationStatus.generating,
        ),
      ],
    );

    expect(find.text('2 tracked'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Generating'), findsOneWidget);
    expect(find.text('Waiting in queue'), findsOneWidget);
    expect(find.text('Generating now'), findsOneWidget);
    expect(find.text('Executive summary + Trend charts'), findsNWidgets(2));
    expect(find.text('Queued for generation'), findsOneWidget);
    expect(find.text('Wait for completion'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.text('Retry'), findsNothing);
    expect(find.byIcon(Icons.download_rounded), findsNothing);
  });

  testWidgets('recent report exports filters visible jobs by status', (
    tester,
  ) async {
    final readyJob = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
        format: ReportFileFormat.excel,
      ),
    );
    final activeJob = _job(
      id: 'active-report',
      status: ReportGenerationStatus.generating,
      request: const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.marketing,
      ),
    );
    final failedJob = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        period: ReportPeriod.lastYear,
        department: ReportDepartmentScope.hr,
        format: ReportFileFormat.csv,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [readyJob, activeJob, failedJob],
      onRetry: (_) {},
    );

    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('Ready (1)'), findsOneWidget);
    expect(find.text('In progress (1)'), findsOneWidget);
    expect(find.text('Needs retry (1)'), findsOneWidget);
    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(activeJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsOneWidget);

    await tester.tap(find.byKey(const Key('recent-export-filter-failed')));
    await tester.pump();

    expect(find.text(readyJob.fileName), findsNothing);
    expect(find.text(activeJob.fileName), findsNothing);
    expect(find.text(failedJob.fileName), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recent-export-filter-active')));
    await tester.pump();

    expect(find.text(readyJob.fileName), findsNothing);
    expect(find.text(activeJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('recent report exports groups visible jobs by requested date', (
    tester,
  ) async {
    final juneMorning = _job(
      id: 'june-morning',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 6, 1, 9, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final juneAfternoon = _job(
      id: 'june-afternoon',
      status: ReportGenerationStatus.generating,
      requestedAt: DateTime(2026, 6, 1, 15, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.engineering,
      ),
    );
    final mayExport = _job(
      id: 'may-export',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 8, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [mayExport, juneMorning, juneAfternoon],
    );

    expect(find.text('Jun 1, 2026'), findsOneWidget);
    expect(find.text('2 exports'), findsOneWidget);
    expect(find.text('1 in progress'), findsOneWidget);
    expect(find.text('1 ready'), findsNWidgets(2));
    expect(find.text('May 31, 2026'), findsOneWidget);
    expect(find.text('1 export'), findsOneWidget);
    expect(_isAbove(tester, 'Jun 1, 2026', juneAfternoon.fileName), isTrue);
    expect(
      _isAbove(tester, juneAfternoon.fileName, juneMorning.fileName),
      isTrue,
    );
    expect(_isAbove(tester, juneMorning.fileName, 'May 31, 2026'), isTrue);
    expect(_isAbove(tester, 'May 31, 2026', mayExport.fileName), isTrue);
  });

  testWidgets('recent report exports runs date-scoped queue actions', (
    tester,
  ) async {
    final downloaded = <ReportGenerationJob>[];
    final retried = <ReportGenerationJob>[];
    final juneReadyMorning = _job(
      id: 'june-ready-morning',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 6, 1, 9, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final juneReadyAfternoon = _job(
      id: 'june-ready-afternoon',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 6, 1, 15, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.engineering,
      ),
    );
    final juneFailed = _job(
      id: 'june-failed',
      status: ReportGenerationStatus.failed,
      requestedAt: DateTime(2026, 6, 1, 16, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );
    final mayReady = _job(
      id: 'may-ready',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 8, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [mayReady, juneReadyMorning, juneReadyAfternoon, juneFailed],
      onDownloadReady: downloaded.addAll,
      onRetry: retried.add,
    );

    expect(
      find.byKey(const Key('recent-export-date-download-2026-06-01-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recent-export-date-retry-2026-06-01-0')),
      findsOneWidget,
    );
    expect(find.text('Download day (2)'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('recent-export-date-download-2026-06-01-0')),
    );
    await tester.pump();

    expect(downloaded, [juneReadyAfternoon, juneReadyMorning]);
    expect(retried, isEmpty);

    await tester.tap(
      find.byKey(const Key('recent-export-date-retry-2026-06-01-0')),
    );
    await tester.pump();

    expect(retried, [juneFailed]);
  });

  testWidgets('recent report exports collapses date sections', (tester) async {
    final downloaded = <ReportGenerationJob>[];
    final juneReady = _job(
      id: 'june-ready',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 6, 1, 9, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final juneFailed = _job(
      id: 'june-failed',
      status: ReportGenerationStatus.failed,
      requestedAt: DateTime(2026, 6, 1, 10, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );
    final mayReady = _job(
      id: 'may-ready',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 8, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [mayReady, juneReady, juneFailed],
      onDownloadReady: downloaded.addAll,
      onRetry: (_) {},
    );

    expect(find.text(juneReady.fileName), findsOneWidget);
    expect(find.text(juneFailed.fileName), findsOneWidget);
    expect(find.text(mayReady.fileName), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse Jun 1, 2026'));
    await tester.pump();

    expect(find.text('Jun 1, 2026'), findsOneWidget);
    expect(find.text('2 exports'), findsOneWidget);
    expect(find.text(juneReady.fileName), findsNothing);
    expect(find.text(juneFailed.fileName), findsNothing);
    expect(find.text(mayReady.fileName), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('recent-export-date-download-2026-06-01-0')),
    );
    await tester.pump();

    expect(downloaded, [juneReady]);

    await tester.tap(find.byTooltip('Expand Jun 1, 2026'));
    await tester.pump();

    expect(find.text(juneReady.fileName), findsOneWidget);
    expect(find.text(juneFailed.fileName), findsOneWidget);
  });

  testWidgets('recent report exports collapses and expands all date sections', (
    tester,
  ) async {
    final juneReady = _job(
      id: 'june-ready',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 6, 1, 9, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final mayReady = _job(
      id: 'may-ready',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 8, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );

    await _pumpRecentExports(tester, width: 420, jobs: [mayReady, juneReady]);

    expect(find.text('2 days visible'), findsOneWidget);
    expect(find.text(juneReady.fileName), findsOneWidget);
    expect(find.text(mayReady.fileName), findsOneWidget);

    await tester.tap(find.text('Collapse all'));
    await tester.pump();

    expect(find.text('2 days visible - 2 collapsed'), findsOneWidget);
    expect(find.text('Jun 1, 2026'), findsOneWidget);
    expect(find.text('May 31, 2026'), findsOneWidget);
    expect(find.text(juneReady.fileName), findsNothing);
    expect(find.text(mayReady.fileName), findsNothing);

    await tester.tap(find.text('Expand all'));
    await tester.pump();

    expect(find.text('2 days visible'), findsOneWidget);
    expect(find.text(juneReady.fileName), findsOneWidget);
    expect(find.text(mayReady.fileName), findsOneWidget);
  });

  testWidgets('recent report exports surfaces queue health and focuses it', (
    tester,
  ) async {
    final readyJob = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final activeJob = _job(
      id: 'active-report',
      status: ReportGenerationStatus.generating,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );
    final failedJob = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [readyJob, activeJob, failedJob],
      onRetry: (_) {},
    );

    expect(find.text('Export queue health'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('1 failed export needs retry'), findsOneWidget);
    expect(find.text('Review failed'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recent-export-health-focus')));
    await tester.pump();

    expect(find.text('Showing 1 of 3 tracked exports'), findsOneWidget);
    expect(find.text(readyJob.fileName), findsNothing);
    expect(find.text(activeJob.fileName), findsNothing);
    expect(find.text(failedJob.fileName), findsOneWidget);
  });

  testWidgets('recent report exports summarizes and clears constraints', (
    tester,
  ) async {
    final readyJob = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final activeJob = _job(
      id: 'active-report',
      status: ReportGenerationStatus.generating,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );
    final failedJob = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [readyJob, activeJob, failedJob],
      onRetry: (_) {},
    );

    await tester.tap(find.byKey(const Key('recent-export-filter-failed')));
    await tester.pump();

    expect(find.text('Showing 1 of 3 tracked exports'), findsOneWidget);
    expect(find.text('Needs retry status'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove export status constraint'));
    await tester.pump();

    expect(find.text('Showing 1 of 3 tracked exports'), findsNothing);
    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(activeJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsOneWidget);

    final searchField = find.byKey(const Key('recent-export-search-field'));
    await tester.enterText(searchField, 'finance');
    await tester.pump();

    expect(find.text('Showing 1 of 3 tracked exports'), findsOneWidget);
    expect(find.text('Search: "finance"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recent-export-filter-ready')));
    await tester.pump();

    expect(find.text('Ready status'), findsOneWidget);
    expect(
      find.byKey(const Key('recent-export-clear-constraints')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('recent-export-clear-constraints')));
    await tester.pump();

    expect(find.text('Showing 1 of 3 tracked exports'), findsNothing);
    expect(find.text('Ready status'), findsNothing);
    expect(find.text('Search: "finance"'), findsNothing);
    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(activeJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsOneWidget);
  });

  testWidgets('recent report exports clears empty state constraints', (
    tester,
  ) async {
    final readyJob = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final activeJob = _job(
      id: 'active-report',
      status: ReportGenerationStatus.generating,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );
    final failedJob = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [readyJob, activeJob, failedJob],
      onRetry: (_) {},
    );

    await tester.tap(find.byKey(const Key('recent-export-filter-failed')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('recent-export-search-field')),
      'finance',
    );
    await tester.pump();

    expect(
      find.text('No retry-needed exports match "finance"'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recent-export-empty-clear-search')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recent-export-empty-clear-filter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recent-export-empty-clear-all')),
      findsOneWidget,
    );

    final clearSearch = find.byKey(
      const Key('recent-export-empty-clear-search'),
    );
    await tester.ensureVisible(clearSearch);
    await tester.pump();
    await tester.tap(clearSearch);
    await tester.pump();

    expect(find.text(failedJob.fileName), findsOneWidget);
    expect(find.text(readyJob.fileName), findsNothing);

    await tester.enterText(
      find.byKey(const Key('recent-export-search-field')),
      'finance',
    );
    await tester.pump();
    final clearFilter = find.byKey(
      const Key('recent-export-empty-clear-filter'),
    );
    await tester.ensureVisible(clearFilter);
    await tester.pump();
    await tester.tap(clearFilter);
    await tester.pump();

    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsNothing);

    await tester.tap(find.byKey(const Key('recent-export-filter-failed')));
    await tester.pump();
    final clearAll = find.byKey(const Key('recent-export-empty-clear-all'));
    await tester.ensureVisible(clearAll);
    await tester.pump();
    await tester.tap(clearAll);
    await tester.pump();

    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(activeJob.fileName), findsOneWidget);
    expect(find.text(failedJob.fileName), findsOneWidget);
  });

  testWidgets('recent report exports searches visible jobs by metadata', (
    tester,
  ) async {
    final engineeringCsv = _job(
      id: 'engineering-ready',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
        includeRawData: true,
      ),
    );
    final marketingPdf = _job(
      id: 'marketing-ready',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );
    final hrFailed = _job(
      id: 'hr-failed',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
        format: ReportFileFormat.excel,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [engineeringCsv, marketingPdf, hrFailed],
      onRetry: (_) {},
    );

    final searchField = find.byKey(const Key('recent-export-search-field'));
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'engineering csv');
    await tester.pump();

    expect(find.text(engineeringCsv.fileName), findsOneWidget);
    expect(find.text(marketingPdf.fileName), findsNothing);
    expect(find.text(hrFailed.fileName), findsNothing);

    await tester.enterText(searchField, 'failed hr');
    await tester.pump();

    expect(find.text(engineeringCsv.fileName), findsNothing);
    expect(find.text(marketingPdf.fileName), findsNothing);
    expect(find.text(hrFailed.fileName), findsOneWidget);

    await tester.enterText(searchField, 'benefits');
    await tester.pump();

    expect(find.text('No exports match "benefits"'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear export search'));
    await tester.pump();

    expect(find.text(engineeringCsv.fileName), findsOneWidget);
    expect(find.text(marketingPdf.fileName), findsOneWidget);
    expect(find.text(hrFailed.fileName), findsOneWidget);
  });

  testWidgets('recent report exports resets stale filters after job updates', (
    tester,
  ) async {
    final readyJob = _job(
      id: 'ready-report',
      status: ReportGenerationStatus.ready,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final activeJob = _job(
      id: 'active-report',
      status: ReportGenerationStatus.generating,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.marketing,
      ),
    );
    final failedJob = _job(
      id: 'failed-report',
      status: ReportGenerationStatus.failed,
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.hr,
      ),
    );

    await _pumpRecentExports(
      tester,
      jobs: [readyJob, activeJob, failedJob],
      onRetry: (_) {},
    );
    await tester.tap(find.byKey(const Key('recent-export-filter-failed')));
    await tester.pump();

    expect(find.text(failedJob.fileName), findsOneWidget);
    expect(find.text(readyJob.fileName), findsNothing);

    await _pumpRecentExports(tester, jobs: [readyJob, activeJob]);

    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Needs retry (0)'), findsOneWidget);
    expect(find.text('No exports need retry'), findsNothing);
    expect(find.text(failedJob.fileName), findsNothing);
    expect(find.text(readyJob.fileName), findsOneWidget);
    expect(find.text(activeJob.fileName), findsOneWidget);
  });

  testWidgets('recent report exports clears finished jobs from the header', (
    tester,
  ) async {
    var cleared = false;

    await _pumpRecentExports(
      tester,
      jobs: [
        _job(id: 'ready-report', status: ReportGenerationStatus.ready),
        _job(id: 'active-report', status: ReportGenerationStatus.generating),
      ],
      onClearFinished: () => cleared = true,
    );

    expect(find.text('Clear finished (1)'), findsOneWidget);

    await tester.tap(find.text('Clear finished (1)'));
    await _pumpDialogFrame(tester);

    expect(cleared, isFalse);
    expect(find.text('Clear finished exports?'), findsOneWidget);
    expect(
      find.text('This removes 1 finished export from the recent queue.'),
      findsOneWidget,
    );
    expect(
      find.text('Includes 1 ready export. Active exports stay visible.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await _pumpDialogFrame(tester);

    expect(cleared, isFalse);
    expect(find.text('Clear finished exports?'), findsNothing);

    await tester.tap(find.text('Clear finished (1)'));
    await _pumpDialogFrame(tester);
    await tester.tap(find.text('Clear 1 export'));
    await _pumpDialogFrame(tester);

    expect(cleared, isTrue);
  });

  testWidgets('recent report exports retries failed jobs from the header', (
    tester,
  ) async {
    var retried = false;

    await _pumpRecentExports(
      tester,
      jobs: [
        _job(id: 'failed-report', status: ReportGenerationStatus.failed),
        _job(id: 'ready-report', status: ReportGenerationStatus.ready),
      ],
      onRetryFailed: () => retried = true,
    );

    expect(find.text('Retry failed (1)'), findsOneWidget);
    expect(find.text('Clear finished'), findsNothing);

    await tester.tap(find.text('Retry failed (1)'));
    await tester.pump();

    expect(retried, isTrue);
  });

  testWidgets(
    'recent report exports downloads all ready jobs from the header',
    (tester) async {
      final downloaded = <ReportGenerationJob>[];
      final readyPdf = _job(
        id: 'ready-pdf',
        status: ReportGenerationStatus.ready,
      );
      final generating = _job(
        id: 'generating-report',
        status: ReportGenerationStatus.generating,
      );
      final readyCsv = _job(
        id: 'ready-csv',
        status: ReportGenerationStatus.ready,
        request: const ReportGenerationRequest(format: ReportFileFormat.csv),
      );

      await _pumpRecentExports(
        tester,
        jobs: [readyPdf, generating, readyCsv],
        onDownloadReady: downloaded.addAll,
      );

      expect(find.text('Download ready (2)'), findsOneWidget);

      await tester.tap(find.text('Download ready (2)'));
      await tester.pump();

      expect(downloaded, [readyPdf, readyCsv]);
    },
  );

  testWidgets('recent report exports sorts visible jobs from the menu', (
    tester,
  ) async {
    final older = _job(
      id: 'older-report',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 8, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.finance,
      ),
    );
    final newer = _job(
      id: 'newer-report',
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 10, 30),
      request: const ReportGenerationRequest(
        department: ReportDepartmentScope.engineering,
      ),
    );

    await _pumpRecentExports(tester, jobs: [older, newer]);

    expect(find.text('Newest first'), findsOneWidget);
    expect(_isAbove(tester, newer.fileName, older.fileName), isTrue);

    await tester.tap(find.byKey(const Key('recent-export-sort-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oldest first'));
    await tester.pumpAndSettle();

    expect(find.text('Oldest first'), findsOneWidget);
    expect(_isAbove(tester, older.fileName, newer.fileName), isTrue);
  });
}

Future<void> _pumpRecentExports(
  WidgetTester tester, {
  required List<ReportGenerationJob> jobs,
  double width = 900,
  ValueChanged<ReportGenerationJob>? onDownload,
  ValueChanged<List<ReportGenerationJob>>? onDownloadReady,
  ValueChanged<ReportGenerationJob>? onRetry,
  VoidCallback? onRetryFailed,
  VoidCallback? onClearFinished,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: RecentReportExports(
              jobs: jobs,
              onDownload: onDownload,
              onDownloadReady: onDownloadReady,
              onRetry: onRetry,
              onRetryFailed: onRetryFailed,
              onClearFinished: onClearFinished,
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpDialogFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

ReportGenerationJob _job({
  required String id,
  required ReportGenerationStatus status,
  ReportGenerationRequest request = const ReportGenerationRequest(),
  DateTime? requestedAt,
}) {
  final requested = requestedAt ?? DateTime(2026, 5, 31, 9, 30);
  return ReportGenerationJob(
    id: id,
    report: _turnoverReport,
    request: request,
    status: status,
    requestedAt: requested,
    completedAt:
        status == ReportGenerationStatus.ready ||
                status == ReportGenerationStatus.failed
            ? requested.add(const Duration(minutes: 1))
            : null,
    failureMessage:
        status == ReportGenerationStatus.failed
            ? 'Could not generate report.'
            : null,
  );
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);

bool _isAbove(WidgetTester tester, String topText, String bottomText) {
  return tester.getTopLeft(find.text(topText)).dy <
      tester.getTopLeft(find.text(bottomText)).dy;
}
