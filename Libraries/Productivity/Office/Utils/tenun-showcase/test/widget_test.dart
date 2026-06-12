// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';

import 'package:tenun_showcase/example/chart_export_lab_example.dart';
import 'package:tenun_showcase/example/performance_diagnostics_example.dart';
import 'package:tenun_showcase/example/shape_aware_switch_diff.dart';
import 'package:tenun_showcase/example/shape_aware_switch_panel.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_example.dart';
import 'package:tenun_showcase/example/tenun_chart_json_force_type_example.dart';
import 'package:tenun_showcase/main.dart';

import 'support/showcase_widget_test_harness.dart';

void main() {
  setUp(registerAllChartsForTest);

  testWidgets('Showcase app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());
    await tester.pump(showcaseStoryPumpDuration);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Simple charts story renders from Storybook', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/By Data Shape/Cartesian/Simple Charts',
    );

    expect(find.byType(SimpleChartsShowcaseExample), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI ML story renders ROC JSON colors', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/By Data Shape/AI & Machine Learning',
    );

    expect(find.text('AI/ML Evaluation Charts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Registry health story renders capability matrix', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/Tools/Registry Health Matrix',
    );

    expect(find.text('Registry Health'), findsOneWidget);
    expect(find.text('Readiness'), findsWidgets);
    expect(find.text('Readiness Gates'), findsOneWidget);
    expect(find.text('Action Plan'), findsWidgets);
    expect(find.text('Showcase Coverage'), findsWidgets);
    expect(find.text('Coverage Thresholds'), findsOneWidget);
    expect(find.text('Starter Template Backlog'), findsOneWidget);
    expect(find.text('Sample Audit'), findsWidgets);
    expect(find.text('Source Audit'), findsWidgets);
    expect(find.text('Source Map'), findsOneWidget);
    expect(find.text('Source Map Audit'), findsOneWidget);
    expect(find.text('Simple Sources'), findsOneWidget);
    expect(find.text('Simple Source Audit'), findsOneWidget);
    expect(find.text('Type Naming'), findsWidgets);
    expect(find.text('Type Cleanup'), findsWidgets);
    expect(find.text('Rename Plan'), findsOneWidget);
    expect(find.text('Patch Ops'), findsWidgets);
    expect(find.text('Patch Preview'), findsWidgets);
    expect(find.text('Manifest Work'), findsWidgets);
    expect(find.text('Capability Matrix'), findsOneWidget);
    expect(find.text('Runtime Switch Groups'), findsOneWidget);
    expect(find.text('API Contracts'), findsOneWidget);
    expect(find.text('API Contract Summary'), findsOneWidget);
    expect(find.text('API Contract Usage Matrix'), findsOneWidget);
    expect(find.text('API Contract Matrix'), findsOneWidget);
    expect(find.text('Payload Contract Summary'), findsOneWidget);
    expect(find.text('Payload Contract Matrix'), findsOneWidget);
    expect(find.text('Audit Errors'), findsOneWidget);
    expect(find.text('Copy Health JSON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Payload Doctor story renders diagnostics', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/Tools/Payload Doctor',
    );

    expect(find.text('Payload Doctor'), findsWidgets);
    expect(find.text('Missing sankey links'), findsOneWidget);
    expect(find.textContaining('MISSING_NODE_LINK_FIELDS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shape-aware switch panel shows manual compatibility status', (
    WidgetTester tester,
  ) async {
    await pumpShowcaseBody(
      tester,
      width: 780,
      height: 720,
      settle: true,
      child: const ShapeAwareSwitchPanel(
        showPayloadInspector: false,
        baseJsonConfig: {
          'type': 'bar',
          'xAxis': {
            'data': ['A', 'B', 'C'],
          },
          'series': [
            {
              'name': 'Sales',
              'data': [10, 20, 30],
            },
          ],
        },
        manualTargets: [ChartType.line, ChartType.treemap],
        preferredOrder: [ChartType.line, ChartType.area],
      ),
    );

    expect(find.textContaining('Manual switch:'), findsWidgets);
    expect(
      find.textContaining('Payload validation: render-safe'),
      findsOneWidget,
    );
    expect(find.textContaining('Current: bar'), findsOneWidget);

    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Current: line'), findsOneWidget);
    expect(
      find.textContaining('Payload validation: render-safe'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test(
    'shape-aware diff ranks pinned paths and summarizes payload changes',
    () {
      final before = {
        'type': 'bar',
        'dataMode': 'category',
        'sampling': {'enabled': false, 'threshold': 500},
        'series': [
          {
            'name': 'Sales',
            'data': [10, 20, 30],
          },
        ],
        'visual': {'palette': 'blue'},
      };
      final after = {
        'type': 'line',
        'dataMode': 'category',
        'sampling': {'enabled': true, 'threshold': 200},
        'series': [
          {
            'name': 'Sales',
            'data': [10, 22, 34],
          },
        ],
        'visual': {'palette': 'blue'},
      };

      final paths = ShapeAwareSwitchDiff.collectPaths(before, after);
      final ranked = ShapeAwareSwitchDiff.rankPaths(paths);
      final pinned = ShapeAwareSwitchDiff.visiblePaths(paths, pinnedOnly: true);
      final summary = ShapeAwareSwitchDiff.semanticSummary(before, after);

      expect(ranked.first, 'type');
      expect(pinned, contains('sampling.enabled'));
      expect(pinned, contains('series[0].data[1]'));
      expect(summary, contains('type: bar → line'));
      expect(summary, contains('sampling:'));
    },
  );

  testWidgets('forceType guardrails example renders custom switch fallback', (
    WidgetTester tester,
  ) async {
    await pumpShowcaseBody(
      tester,
      width: 760,
      height: 460,
      settle: true,
      child: const TenunChartJsonForceTypeExample(),
    );

    expect(find.text('TenunChartJson forceType guardrails'), findsOneWidget);
    expect(find.text('Custom switch fallback'), findsOneWidget);
    expect(find.text('Blocked target: treemap'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Performance diagnostics story renders runtime metrics', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/Tools/Performance Diagnostics Lab',
    );

    expect(find.byType(PerformanceDiagnosticsExample), findsOneWidget);
    expect(find.text('Performance Diagnostics Lab'), findsWidgets);
    expect(find.text('Runtime Diagnostics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chart export lab story renders export controls', (
    WidgetTester tester,
  ) async {
    await pumpChartStorybook(
      tester,
      initialStory: 'Charts/Tools/Chart Export Lab',
    );

    expect(find.byType(ChartExportLabExample), findsOneWidget);
    expect(find.text('Chart Export Lab'), findsWidgets);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('XLSX'), findsOneWidget);
    expect(find.text('PNG'), findsOneWidget);
    expect(find.text('JPEG'), findsOneWidget);
    expect(find.text('Export Result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Simple charts handle narrow preview width', (
    WidgetTester tester,
  ) async {
    await pumpShowcaseBody(
      tester,
      width: 220,
      height: 760,
      settle: true,
      child: const SimpleChartsShowcaseExample(),
    );

    expect(find.byType(SimpleChartsShowcaseExample), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
