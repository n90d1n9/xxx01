import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_job.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/report_launcher_section.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  testWidgets('report launcher opens configuration and delegates generation', (
    tester,
  ) async {
    ReportType? generatedReport;
    ReportGenerationRequest? generatedRequest;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ReportLauncherSection(
              reportTypes: const [report],
              onGenerate: (report, request) async {
                generatedReport = report;
                generatedRequest = request;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Turnover Report'));
    await tester.pumpAndSettle();

    expect(find.text('Generate Turnover Report'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    expect(generatedReport, report);
    expect(generatedRequest, const ReportGenerationRequest());
  });

  testWidgets('report launcher surfaces recent exports and download actions', (
    tester,
  ) async {
    var downloaded = false;
    final downloadedReady = <ReportGenerationJob>[];
    var cleared = false;
    final job = ReportGenerationJob(
      id: 'job-1',
      report: report,
      request: const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
      ),
      status: ReportGenerationStatus.ready,
      requestedAt: DateTime(2026, 5, 31, 9, 30),
      completedAt: DateTime(2026, 5, 31, 9, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ReportLauncherSection(
                reportTypes: const [report],
                recentJobs: [job],
                onDownload: (_) => downloaded = true,
                onDownloadReady: downloadedReady.addAll,
                onClearFinished: () => cleared = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recent exports'), findsOneWidget);
    expect(
      find.text('turnover-report-engineering-last-quarter.csv'),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Download ready (1)'), findsOneWidget);
    expect(find.text('Clear finished (1)'), findsOneWidget);

    final downloadButton = find.byTooltip(
      'Download turnover-report-engineering-last-quarter.csv',
    );
    await tester.ensureVisible(downloadButton);
    await tester.tap(downloadButton);
    await tester.pump();

    expect(downloaded, isTrue);

    await tester.tap(find.text('Download ready (1)'));
    await tester.pump();

    expect(downloadedReady, [job]);

    await tester.tap(find.text('Clear finished (1)'));
    await tester.pumpAndSettle();

    expect(cleared, isFalse);
    expect(find.text('Clear finished exports?'), findsOneWidget);

    await tester.tap(find.text('Clear 1 export'));
    await tester.pumpAndSettle();

    expect(cleared, isTrue);
  });

  testWidgets('report launcher delegates bulk retry actions', (tester) async {
    var retriedFailed = false;
    final failedJob = ReportGenerationJob(
      id: 'job-1',
      report: report,
      request: const ReportGenerationRequest(),
      status: ReportGenerationStatus.failed,
      requestedAt: DateTime(2026, 5, 31, 9, 30),
      failureMessage: 'Could not generate report.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ReportLauncherSection(
                reportTypes: const [report],
                recentJobs: [failedJob],
                onRetryFailed: () => retriedFailed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Retry failed (1)'), findsOneWidget);

    await tester.tap(find.text('Retry failed (1)'));
    await tester.pump();

    expect(retriedFailed, isTrue);
  });
}
