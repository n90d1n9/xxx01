import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_showcase/example/performance_diagnostics_example.dart';
import 'package:tenun_showcase/example/performance_diagnostics_utils.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  String? clipboardText;

  setUp(() {
    registerAllChartsForTest();
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              clipboardText = (call.arguments as Map?)?['text'] as String?;
              return null;
            case 'Clipboard.getData':
              return {'text': clipboardText};
            case 'Clipboard.hasStrings':
              return {'value': clipboardText?.isNotEmpty ?? false};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpDiagnostics(WidgetTester tester) async {
    await pumpShowcaseBody(
      tester,
      physicalSize: const Size(1300, 950),
      width: 1100,
      height: 780,
      settle: true,
      child: const PerformanceDiagnosticsExample(
        initialPoints: 1600,
        initialUseIsolate: false,
      ),
    );
  }

  Future<void> scrollReportUntilVisible(
    WidgetTester tester,
    Finder scrollable,
    String text, {
    int maxScrolls = 14,
  }) async {
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) return;

    for (var i = 0; i < maxScrolls; i++) {
      await tester.drag(scrollable, const Offset(0, -120));
      await tester.pumpAndSettle();
      if (finder.evaluate().isNotEmpty) return;
    }

    fail('Could not find visible diagnostics text "$text".');
  }

  testWidgets('shows processor cache and timing diagnostics', (tester) async {
    await pumpDiagnostics(tester);

    expect(find.text('Performance Diagnostics Lab'), findsOneWidget);
    expect(find.text('Runtime Diagnostics'), findsOneWidget);
    expect(find.text('Cache Stats'), findsOneWidget);
    expect(find.text('Extraction Cache'), findsWidgets);
    expect(find.text('Run Diagnostics'), findsOneWidget);
    expect(find.text('Cache Hit'), findsOneWidget);
    expect(find.text('Effective Points'), findsOneWidget);
    expect(find.text('Sample Input'), findsOneWidget);
    expect(find.text('Output Points'), findsOneWidget);
    expect(find.text('Downsampled'), findsOneWidget);
    expect(find.text('Cache Health'), findsOneWidget);

    final diagnosticsScroll = find.byType(Scrollable, skipOffstage: false).last;

    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Performance Summary',
    );
    expect(
      find.text('Performance Summary', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Overall Severity', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Sampling Reduction', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'End-to-End');
    expect(find.text('End-to-End', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Snapshot Export',
    );
    expect(find.text('Snapshot Export', skipOffstage: false), findsOneWidget);
    expect(find.text('Snapshot Ready', skipOffstage: false), findsOneWidget);
    expect(find.text('Snapshot Sections', skipOffstage: false), findsOneWidget);
    expect(find.text('Snapshot History', skipOffstage: false), findsOneWidget);
    expect(find.text('Snapshot Runtime', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Export Health');
    expect(find.text('Export Health', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Export Action');
    expect(find.text('Export Action', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Export Hint');
    expect(find.text('Export Hint', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Snapshot Fingerprint',
    );
    expect(find.text('Snapshot Fingerprint'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Support Bundle Fingerprint',
    );
    expect(find.text('Support Bundle Fingerprint'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Full Export Size',
    );
    expect(find.text('Full Export Size'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Compact Export Size',
    );
    expect(find.text('Compact Export Size'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Compact Reduction',
    );
    expect(find.text('Compact Reduction'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Support Bundle Size',
    );
    expect(find.text('Support Bundle Size'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Support Bundle Check',
    );
    expect(find.text('Support Bundle Check'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Support Bundle Summary',
    );
    expect(find.text('Support Bundle Summary'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Support Bundle Preview',
    );
    expect(find.text('Support Bundle Preview'), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Bundle Action');
    expect(find.text('Bundle Action'), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Bundle Points');
    expect(find.text('Bundle Points'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Copy Snapshot JSON',
    );
    expect(find.text('Copy Snapshot JSON'), findsOneWidget);
    expect(find.text('Copy Compact JSON'), findsOneWidget);
    expect(find.text('Copy Support Bundle'), findsOneWidget);
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Copy Snapshot JSON'),
        )
        .onPressed!();
    await tester.pump();
    expect(clipboardText, contains('"snapshotVersion": 1'));
    expect(clipboardText, contains('"lastReport"'));
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Copy Compact JSON',
    );
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Copy Compact JSON'),
        )
        .onPressed!();
    await tester.pump();
    expect(clipboardText, contains('"exportMode": "compact"'));
    expect(clipboardText, contains('"fingerprint"'));
    expect(clipboardText, isNot(contains('"lastReport"')));
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Copy Support Bundle',
    );
    tester
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Copy Support Bundle'),
        )
        .onPressed!();
    await tester.pump();
    expect(clipboardText, contains('"bundleVersion": 1'));
    expect(
      clipboardText,
      contains('"kind": "tenunPerformanceDiagnosticsSupportBundle"'),
    );
    expect(clipboardText, contains('"exportSummary"'));
    expect(clipboardText, contains('"compactSnapshot"'));
    expect(clipboardText, isNot(contains('"lastReport"')));
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Run Trend');
    expect(find.text('Run Trend', skipOffstage: false), findsOneWidget);
    expect(find.text('History Runs', skipOffstage: false), findsOneWidget);
    expect(find.text('Trend Health', skipOffstage: false), findsOneWidget);
    expect(find.text('Trend Action', skipOffstage: false), findsOneWidget);
    expect(find.text('Data Delta', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Output Delta');
    expect(
      find.text('Sample Input Delta', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Output Delta', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Duration Delta');
    expect(find.text('Reduction Delta', skipOffstage: false), findsOneWidget);
    expect(find.text('Cache Hit Delta', skipOffstage: false), findsOneWidget);
    expect(find.text('Duration Delta', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Trend Hint');
    expect(find.text('Trend Hint', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Run Aggregate');
    expect(find.text('Run Aggregate', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Aggregate Health',
    );
    expect(find.text('Aggregate Health', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Aggregate Action',
    );
    expect(find.text('Aggregate Action', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Avg Duration');
    expect(find.text('Avg Duration', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Duration Spread',
    );
    expect(find.text('Duration Spread', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Fastest / Slowest',
    );
    expect(find.text('Fastest / Slowest', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Run History');
    expect(find.text('Run History', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Sample Input Points',
    );
    expect(
      find.text('Sample Input Points', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Reduced Points');
    expect(find.text('Reduced Points', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Output Ratio');
    expect(find.text('Output Ratio', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Reduction Ratio',
    );
    expect(find.text('Reduction Ratio', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Result Cache Reason',
    );
    expect(
      find.text('Result Cache Reason', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Result Cache Action',
    );
    expect(
      find.text('Result Cache Action', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Result Cache Severity',
    );
    expect(
      find.text('Result Cache Severity', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Result Cache Hint',
    );
    expect(find.text('Result Cache Hint', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Eligible',
    );
    expect(
      find.text('Extraction Cache Eligible', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Reason',
    );
    expect(
      find.text('Extraction Cache Reason', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Action',
    );
    expect(
      find.text('Extraction Cache Action', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Severity',
    );
    expect(
      find.text('Extraction Cache Severity', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Hint',
    );
    expect(
      find.text('Extraction Cache Hint', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Policy Min Points',
    );
    expect(find.text('Policy Min Points', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Widget Runtime');
    expect(find.text('Widget Runtime'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Effective Points',
    );
    expect(
      find.text('Runtime Effective Points', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Sample Input',
    );
    expect(
      find.text('Runtime Sample Input', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Processor / Runtime Output',
    );
    expect(
      find.text('Processor / Runtime Output', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Severity',
    );
    expect(find.text('Runtime Severity', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Recommendation',
    );
    expect(
      find.text('Runtime Recommendation', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Action Required',
    );
    expect(
      find.text('Runtime Action Required', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Runtime Hint');
    expect(find.text('Runtime Hint', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Policy Source',
    );
    expect(
      find.text('Runtime Policy Source', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Large Data Threshold',
    );
    expect(
      find.text('Large Data Threshold', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Cache Pressure Limit',
    );
    expect(
      find.text('Cache Pressure Limit', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Rendered Ratio');
    expect(find.text('Rendered Ratio', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Reduction',
    );
    expect(find.text('Runtime Reduction', skipOffstage: false), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Runtime Sampling Reduction',
    );
    expect(
      find.text('Runtime Sampling Reduction', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('unavailable', skipOffstage: false), findsWidgets);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Processing Hit Rate',
    );
    expect(
      find.text('Processing Hit Rate', skipOffstage: false),
      findsOneWidget,
    );
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Render Object Cache',
    );
    expect(find.text('Render Object Cache'), findsOneWidget);
    await scrollReportUntilVisible(tester, diagnosticsScroll, 'Picture Cache');
    expect(find.text('Picture Cache'), findsOneWidget);
    await scrollReportUntilVisible(
      tester,
      diagnosticsScroll,
      'Extraction Cache Details',
    );
    expect(find.text('Extraction Cache Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can clear cache and rerun diagnostics', (tester) async {
    await pumpDiagnostics(tester);

    await tester.tap(find.text('Clear Cache'));
    await tester.pumpAndSettle();

    expect(find.text('Runtime Diagnostics'), findsOneWidget);
    expect(find.text('Cache Stats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('builds diagnostics signal and chart payload', () {
    final signal = PerformanceDiagnosticsData.buildSignal(32);
    final payload = PerformanceDiagnosticsData.buildChartPayload(
      chartType: ChartType.area,
      dataMode: ChartDataMode.large,
      samplingStrategy: SamplingStrategy.minMax,
      renderThreshold: 12,
      signal: signal,
    );

    expect(signal, hasLength(32));
    expect(payload['type'], 'area');
    expect(payload['dataMode'], 'large');
    expect(payload['sampling']['enabled'], isTrue);
    expect(payload['sampling']['threshold'], 12);
    expect(payload['series'][0]['data'], same(signal));
    expect(PerformanceDiagnosticsData.renderedPointCount(payload), 12);
  });

  test('builds diagnostics history entries from async reports', () async {
    final output = await AsyncChartProcessor.processAsyncWithReport(
      [
        Series(
          type: ChartType.line,
          data: List.generate(20, (index) => index.toDouble()),
        ),
      ],
      renderThreshold: 5,
      samplingStrategy: SamplingStrategy.nth,
      useIsolate: false,
      useCache: false,
    );

    final entry = PerformanceDiagnosticsHistoryEntry.fromReport(
      output.report,
      run: 7,
    );
    final json = entry.toJson();

    expect(entry.run, 7);
    expect(entry.outputPointCount, 5);
    expect(entry.sampleInputPointCount, 20);
    expect(entry.wasDownsampled, isTrue);
    expect(entry.samplingReductionRatio, closeTo(0.75, 1e-9));
    expect(json['run'], 7);
    expect(json['outputPointCount'], 5);
    expect(json['sampleInputPointCount'], 20);
    expect(json['path'], isA<String>());
  });

  test('summarizes diagnostics history trend deltas', () {
    const previous = PerformanceDiagnosticsHistoryEntry(
      run: 1,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.25,
      cacheHit: false,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 12),
    );
    const latest = PerformanceDiagnosticsHistoryEntry(
      run: 2,
      dataPointCount: 120,
      sampleInputPointCount: 70,
      outputPointCount: 18,
      samplingReductionRatio: 0.8,
      cacheHitRate: 0.5,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 7),
    );

    final summary = PerformanceDiagnosticsHistorySummary.fromEntries([
      latest,
      previous,
    ]);
    final json = summary.toJson();

    expect(summary.runCount, 2);
    expect(summary.hasPrevious, isTrue);
    expect(summary.dataPointDelta, 20);
    expect(summary.sampleInputPointDelta, -10);
    expect(summary.outputPointDelta, -2);
    expect(summary.samplingReductionDelta, closeTo(0.05, 1e-9));
    expect(summary.cacheHitRateDelta, closeTo(0.25, 1e-9));
    expect(summary.totalDurationDelta, const Duration(milliseconds: -5));
    expect(summary.totalDurationDeltaRatio, closeTo(-5 / 12, 1e-9));
    expect(
      summary.recommendation,
      PerformanceDiagnosticsTrendRecommendation.improved,
    );
    expect(summary.severity, PerformanceDiagnosticsTrendSeverity.info);
    expect(summary.recommendationHint, contains('improved'));
    expect(json['latestRun'], 2);
    expect(json['previousRun'], 1);
    expect(json['outputPointDelta'], -2);
    expect(json['totalDurationDeltaMicros'], -5000);
    expect(json['trendSeverity'], 'info');
    expect(json['trendRecommendation'], 'improved');
  });

  test('classifies diagnostics trend regressions', () {
    const previous = PerformanceDiagnosticsHistoryEntry(
      run: 1,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );

    const slowLatest = PerformanceDiagnosticsHistoryEntry(
      run: 2,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 13),
    );
    final slowSummary = PerformanceDiagnosticsHistorySummary.fromEntries([
      slowLatest,
      previous,
    ]);
    expect(
      slowSummary.recommendation,
      PerformanceDiagnosticsTrendRecommendation.reviewDurationRegression,
    );
    expect(slowSummary.severity, PerformanceDiagnosticsTrendSeverity.warning);

    const cacheLatest = PerformanceDiagnosticsHistoryEntry(
      run: 3,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.4,
      cacheHit: false,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );
    final cacheSummary = PerformanceDiagnosticsHistorySummary.fromEntries([
      cacheLatest,
      previous,
    ]);
    expect(
      cacheSummary.recommendation,
      PerformanceDiagnosticsTrendRecommendation.reviewCacheRegression,
    );

    const samplingLatest = PerformanceDiagnosticsHistoryEntry(
      run: 4,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 35,
      samplingReductionRatio: 0.5,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );
    final samplingSummary = PerformanceDiagnosticsHistorySummary.fromEntries([
      samplingLatest,
      previous,
    ]);
    expect(
      samplingSummary.recommendation,
      PerformanceDiagnosticsTrendRecommendation.reviewSamplingRegression,
    );
  });

  test('classifies baseline diagnostics trend as pending', () {
    const latest = PerformanceDiagnosticsHistoryEntry(
      run: 1,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );

    final summary = PerformanceDiagnosticsHistorySummary.fromEntries([latest]);

    expect(
      summary.recommendation,
      PerformanceDiagnosticsTrendRecommendation.collectAnotherRun,
    );
    expect(summary.severity, PerformanceDiagnosticsTrendSeverity.pending);
    expect(summary.recommendationHint, contains('baseline'));
  });

  test('aggregates diagnostics history runs', () {
    const slowest = PerformanceDiagnosticsHistoryEntry(
      run: 1,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.25,
      cacheHit: false,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 12),
    );
    const fastest = PerformanceDiagnosticsHistoryEntry(
      run: 2,
      dataPointCount: 120,
      sampleInputPointCount: 70,
      outputPointCount: 18,
      samplingReductionRatio: 0.8,
      cacheHitRate: 0.5,
      cacheHit: true,
      usedIsolate: true,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 7),
    );
    const middle = PerformanceDiagnosticsHistoryEntry(
      run: 3,
      dataPointCount: 80,
      sampleInputPointCount: 60,
      outputPointCount: 30,
      samplingReductionRatio: 0.5,
      cacheHitRate: 0.75,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: false,
      path: 'sync',
      totalDuration: Duration(milliseconds: 11),
    );

    final aggregate = PerformanceDiagnosticsHistoryAggregate.fromEntries([
      fastest,
      slowest,
      middle,
    ]);
    final json = aggregate.toJson();

    expect(aggregate.runCount, 3);
    expect(aggregate.averageDuration, const Duration(milliseconds: 10));
    expect(aggregate.fastest.run, 2);
    expect(aggregate.slowest.run, 1);
    expect(aggregate.durationSpread, const Duration(milliseconds: 5));
    expect(aggregate.durationSpreadRatio, closeTo(0.5, 1e-9));
    expect(aggregate.averageDataPointCount, closeTo(100, 1e-9));
    expect(aggregate.averageSampleInputPointCount, closeTo(70, 1e-9));
    expect(aggregate.averageOutputPointCount, closeTo(68 / 3, 1e-9));
    expect(
      aggregate.averageSamplingReductionRatio,
      closeTo((0.75 + 0.8 + 0.5) / 3, 1e-9),
    );
    expect(aggregate.averageCacheHitRate, closeTo(0.5, 1e-9));
    expect(aggregate.cacheHitRunCount, 2);
    expect(aggregate.cacheHitRunRatio, closeTo(2 / 3, 1e-9));
    expect(aggregate.downsampledRunCount, 2);
    expect(aggregate.downsampledRunRatio, closeTo(2 / 3, 1e-9));
    expect(aggregate.isolateRunCount, 1);
    expect(aggregate.isolateRunRatio, closeTo(1 / 3, 1e-9));
    expect(aggregate.hasEnoughRunsForStability, isTrue);
    expect(aggregate.hasDurationVarianceWarning, isTrue);
    expect(
      aggregate.recommendation,
      PerformanceDiagnosticsAggregateRecommendation.reviewDurationVariance,
    );
    expect(aggregate.severity, PerformanceDiagnosticsAggregateSeverity.warning);
    expect(aggregate.recommendationHint, contains('Fastest and slowest'));
    expect(json['aggregateSeverity'], 'warning');
    expect(json['aggregateRecommendation'], 'reviewDurationVariance');
    expect(json['fastestRun'], 2);
    expect(json['slowestRun'], 1);
    expect(json['averageDurationMicros'], 10000);
    expect(json['durationSpreadMicros'], 5000);
    expect(json['durationSpreadRatio'], closeTo(0.5, 1e-9));
    expect(json['averageOutputPointCount'], closeTo(68 / 3, 1e-9));
  });

  test('builds diagnostics snapshot export payload', () async {
    final output = await AsyncChartProcessor.processAsyncWithReport(
      [
        Series(
          type: ChartType.line,
          data: List.generate(18, (index) => index.toDouble()),
        ),
      ],
      renderThreshold: 6,
      samplingStrategy: SamplingStrategy.nth,
      useIsolate: false,
      useCache: false,
    );
    final history = [
      PerformanceDiagnosticsHistoryEntry.fromReport(output.report, run: 1),
    ];

    final snapshot = PerformanceDiagnosticsSnapshot.tryCreate(
      firstReport: output.report,
      lastReport: output.report,
      widgetRuntime: null,
      cacheStats: ChartDataProcessor.processingCacheStats,
      diagnosticOutputPoints: output.report.outputPointCount,
      history: history,
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.hasFirstReport, isTrue);
    expect(snapshot.hasRuntimeDiagnostics, isFalse);
    expect(snapshot.historyRunCount, 1);
    expect(snapshot.topLevelKeys, contains('lastReport'));
    expect(snapshot.topLevelKeys, contains('trend'));
    expect(snapshot.topLevelKeys, contains('aggregate'));
    expect(
      snapshot.exportRecommendation(maxHistoryEntries: 1),
      PerformanceDiagnosticsExportRecommendation.collectRuntimeDiagnostics,
    );
    expect(
      snapshot.exportSeverity(maxHistoryEntries: 1),
      PerformanceDiagnosticsExportSeverity.info,
    );
    expect(
      snapshot.exportRecommendationHint(maxHistoryEntries: 1),
      contains('runtime'),
    );

    history.clear();
    expect(snapshot.historyRunCount, 1);

    final json = snapshot.toJson();
    final prettyJson = snapshot.toPrettyJson();
    final compactJson = snapshot.toCompactJson(maxHistoryEntries: 1);
    final prettyCompactJson = snapshot.toPrettyCompactJson(
      maxHistoryEntries: 1,
    );
    final supportBundleJson = snapshot.toSupportBundleJson(
      maxHistoryEntries: 1,
    );
    final prettySupportBundleJson = snapshot.toPrettySupportBundleJson(
      maxHistoryEntries: 1,
    );
    final emptyHistoryCompactJson = snapshot.toCompactJson(
      maxHistoryEntries: 0,
    );
    expect(json['snapshotVersion'], 1);
    expect(json['diagnosticOutputPoints'], output.report.outputPointCount);
    expect(json['hasFirstReport'], isTrue);
    expect(json['hasRuntimeDiagnostics'], isFalse);
    expect(json['firstReport'], isA<Map<String, dynamic>>());
    expect(json['lastReport'], isA<Map<String, dynamic>>());
    expect(json['cacheStats'], isA<Map<String, dynamic>>());
    expect(json['historyRunCount'], 1);
    expect(json['history'], hasLength(1));
    expect(json['trend'], isA<Map<String, dynamic>>());
    expect(json['aggregate'], isA<Map<String, dynamic>>());
    expect(prettyJson, contains('\n  "snapshotVersion": 1'));
    expect(prettyJson, contains('"lastReport"'));
    expect(compactJson['snapshotVersion'], 1);
    expect(compactJson['exportMode'], 'compact');
    expect(compactJson['latest'], isA<Map<String, dynamic>>());
    expect(compactJson['first'], isA<Map<String, dynamic>>());
    expect(compactJson['cache'], isA<Map<String, dynamic>>());
    expect(compactJson['history'], hasLength(1));
    expect(compactJson['includedHistoryRunCount'], 1);
    expect(compactJson['fingerprint'], isA<String>());
    expect(compactJson['fingerprint'], matches(RegExp(r'^[0-9a-f]{8}$')));
    expect(
      snapshot.compactFingerprint(maxHistoryEntries: 1),
      compactJson['fingerprint'],
    );
    expect(snapshot.fullExportBytes, greaterThan(0));
    expect(snapshot.compactExportBytes(maxHistoryEntries: 1), greaterThan(0));
    expect(snapshot.supportBundleBytes(maxHistoryEntries: 1), greaterThan(0));
    expect(
      snapshot.compactExportBytes(maxHistoryEntries: 1),
      lessThan(snapshot.fullExportBytes),
    );
    expect(
      snapshot.supportBundleBytes(maxHistoryEntries: 1),
      greaterThan(snapshot.compactExportBytes(maxHistoryEntries: 1)),
    );
    expect(
      snapshot.compactReductionRatio(maxHistoryEntries: 1),
      greaterThan(0),
    );
    expect(emptyHistoryCompactJson['history'], isEmpty);
    expect(emptyHistoryCompactJson['includedHistoryRunCount'], 0);
    expect(compactJson.containsKey('lastReport'), isFalse);
    expect(prettyCompactJson, contains('"exportMode": "compact"'));
    expect(prettyCompactJson, contains('"fingerprint"'));
    expect(prettyCompactJson, contains('"latest"'));
    expect(supportBundleJson['bundleVersion'], 1);
    expect(
      supportBundleJson['kind'],
      'tenunPerformanceDiagnosticsSupportBundle',
    );
    expect(supportBundleJson['maxHistoryEntries'], 1);
    expect(supportBundleJson['exportSummary'], isA<Map<String, dynamic>>());
    expect(supportBundleJson['compactSnapshot'], isA<Map<String, dynamic>>());
    expect(supportBundleJson['fingerprint'], isA<String>());
    expect(supportBundleJson['fingerprint'], matches(RegExp(r'^[0-9a-f]{8}$')));
    expect(
      snapshot.supportBundleFingerprint(maxHistoryEntries: 1),
      supportBundleJson['fingerprint'],
    );
    expect(prettySupportBundleJson, contains('"bundleVersion": 1'));
    expect(prettySupportBundleJson, contains('"exportSummary"'));
    expect(prettySupportBundleJson, contains('"compactSnapshot"'));
    expect(prettySupportBundleJson, isNot(contains('"lastReport"')));

    final bundleValidation = snapshot.validateSupportBundle(
      maxHistoryEntries: 1,
    );
    expect(bundleValidation.isValid, isTrue);
    expect(bundleValidation.hasWarnings, isFalse);
    expect(
      bundleValidation.severity,
      PerformanceDiagnosticsSupportBundleValidationSeverity.valid,
    );
    expect(bundleValidation.summary, contains('valid'));
    expect(bundleValidation.toJson()['severity'], 'valid');

    final stringValidation =
        PerformanceDiagnosticsSupportBundleValidator.validateJsonString(
          prettySupportBundleJson,
        );
    expect(stringValidation.isValid, isTrue);
    expect(
      stringValidation.severity,
      PerformanceDiagnosticsSupportBundleValidationSeverity.valid,
    );

    final tamperedBundle = snapshot.toSupportBundleJson(maxHistoryEntries: 1);
    tamperedBundle['fingerprint'] = '00000000';
    final tamperedValidation =
        PerformanceDiagnosticsSupportBundleValidator.validate(tamperedBundle);
    expect(tamperedValidation.isValid, isFalse);
    expect(
      tamperedValidation.severity,
      PerformanceDiagnosticsSupportBundleValidationSeverity.error,
    );
    expect(
      tamperedValidation.errors,
      contains('support bundle fingerprint mismatch.'),
    );

    final invalidJsonValidation =
        PerformanceDiagnosticsSupportBundleValidator.validateJsonString('{');
    expect(invalidJsonValidation.isValid, isFalse);
    expect(
      invalidJsonValidation.errors.single,
      contains('could not be decoded'),
    );

    final preview = snapshot.supportBundlePreview(maxHistoryEntries: 1);
    expect(preview.isValid, isTrue);
    expect(preview.validation.hasWarnings, isFalse);
    expect(preview.bundleVersion, 1);
    expect(preview.kind, 'tenunPerformanceDiagnosticsSupportBundle');
    expect(preview.maxHistoryEntries, 1);
    expect(preview.bundleFingerprint, supportBundleJson['fingerprint']);
    expect(preview.compactFingerprint, compactJson['fingerprint']);
    expect(preview.exportSeverity, 'info');
    expect(preview.exportRecommendation, 'collectRuntimeDiagnostics');
    expect(preview.diagnosticOutputPoints, output.report.outputPointCount);
    expect(preview.historyRunCount, 1);
    expect(preview.includedHistoryRunCount, 1);
    expect(preview.hasRuntimeDiagnostics, isFalse);
    expect(preview.sourceDataPointCount, output.report.dataPointCount);
    expect(preview.renderedDataPointCount, output.report.outputPointCount);
    expect(preview.summary, contains('collectRuntimeDiagnostics'));
    expect(preview.toJson()['valid'], isTrue);
    expect(preview.toJson()['compactFingerprint'], compactJson['fingerprint']);

    final stringPreview =
        PerformanceDiagnosticsSupportBundlePreview.fromJsonString(
          prettySupportBundleJson,
        );
    expect(stringPreview.isValid, isTrue);
    expect(stringPreview.bundleFingerprint, supportBundleJson['fingerprint']);

    final invalidPreview =
        PerformanceDiagnosticsSupportBundlePreview.fromJsonString('{');
    expect(invalidPreview.isValid, isFalse);
    expect(
      invalidPreview.validation.severity,
      PerformanceDiagnosticsSupportBundleValidationSeverity.error,
    );

    final exportSummary = snapshot.exportSummaryJson(maxHistoryEntries: 1);
    expect(exportSummary['severity'], 'info');
    expect(exportSummary['recommendation'], 'collectRuntimeDiagnostics');
    expect(exportSummary['recommendationHint'], contains('runtime'));
    expect(exportSummary['fullExportBytes'], snapshot.fullExportBytes);
    expect(
      exportSummary['compactExportBytes'],
      snapshot.compactExportBytes(maxHistoryEntries: 1),
    );
    expect(
      exportSummary['compactReductionRatio'],
      snapshot.compactReductionRatio(maxHistoryEntries: 1),
    );
    expect(
      exportSummary['compactFingerprint'],
      snapshot.compactFingerprint(maxHistoryEntries: 1),
    );
    expect(exportSummary['historyRunCount'], 1);
    expect(exportSummary['historyConfidenceRunCount'], 3);
    expect(exportSummary['hasRuntimeDiagnostics'], isFalse);

    final pending = PerformanceDiagnosticsSnapshot.tryCreate(
      firstReport: null,
      lastReport: null,
      widgetRuntime: null,
      cacheStats: ChartDataProcessor.processingCacheStats,
      diagnosticOutputPoints: 0,
      history: const [],
    );
    expect(pending, isNull);
  });

  test('classifies aggregate stability states', () {
    const baseline = PerformanceDiagnosticsHistoryEntry(
      run: 1,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );
    const stableWarm = PerformanceDiagnosticsHistoryEntry(
      run: 2,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 11),
    );
    const stableHot = PerformanceDiagnosticsHistoryEntry(
      run: 3,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );

    final pending = PerformanceDiagnosticsHistoryAggregate.fromEntries([
      baseline,
      stableWarm,
    ]);
    expect(
      pending.recommendation,
      PerformanceDiagnosticsAggregateRecommendation.collectMoreRuns,
    );
    expect(pending.severity, PerformanceDiagnosticsAggregateSeverity.pending);

    final stable = PerformanceDiagnosticsHistoryAggregate.fromEntries([
      baseline,
      stableWarm,
      stableHot,
    ]);
    expect(
      stable.recommendation,
      PerformanceDiagnosticsAggregateRecommendation.stable,
    );
    expect(stable.severity, PerformanceDiagnosticsAggregateSeverity.healthy);

    const cacheMiss = PerformanceDiagnosticsHistoryEntry(
      run: 4,
      dataPointCount: 100,
      sampleInputPointCount: 80,
      outputPointCount: 20,
      samplingReductionRatio: 0.75,
      cacheHitRate: 0.4,
      cacheHit: false,
      usedIsolate: false,
      wasDownsampled: true,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );
    final mixedCache = PerformanceDiagnosticsHistoryAggregate.fromEntries([
      baseline,
      stableHot,
      cacheMiss,
    ]);
    expect(
      mixedCache.recommendation,
      PerformanceDiagnosticsAggregateRecommendation.reviewCacheConsistency,
    );
    expect(mixedCache.severity, PerformanceDiagnosticsAggregateSeverity.info);

    const unsampled = PerformanceDiagnosticsHistoryEntry(
      run: 5,
      dataPointCount: 100,
      sampleInputPointCount: 100,
      outputPointCount: 100,
      samplingReductionRatio: 0,
      cacheHitRate: 0.7,
      cacheHit: true,
      usedIsolate: false,
      wasDownsampled: false,
      path: 'sync',
      totalDuration: Duration(milliseconds: 10),
    );
    final mixedSampling = PerformanceDiagnosticsHistoryAggregate.fromEntries([
      baseline,
      stableHot,
      unsampled,
    ]);
    expect(
      mixedSampling.recommendation,
      PerformanceDiagnosticsAggregateRecommendation.reviewSamplingConsistency,
    );
    expect(
      mixedSampling.severity,
      PerformanceDiagnosticsAggregateSeverity.info,
    );
  });

  test('formats signed diagnostics values', () {
    expect(PerformanceDiagnosticsFormat.signedInt(3, suffix: 'pts'), '+3 pts');
    expect(PerformanceDiagnosticsFormat.signedInt(-2, suffix: 'pts'), '-2 pts');
    expect(PerformanceDiagnosticsFormat.signedPercent(0.125), '+12.5%');
    expect(PerformanceDiagnosticsFormat.signedPercent(-0.5), '-50.0%');
    expect(
      PerformanceDiagnosticsFormat.signedMicros(
        const Duration(milliseconds: -3),
      ),
      '-3 ms',
    );
  });
}
