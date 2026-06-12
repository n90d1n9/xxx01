import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_story_contract_panel.dart';
import 'package:tenun_showcase/story/chart_story_contract.dart';

void main() {
  testWidgets('chart story contract panel renders metadata and sources', (
    tester,
  ) async {
    final contract = ChartStoryContract(
      summary: 'Reusable line chart story.',
      tags: const ['line', 'trend'],
      useCases: const ['Operational KPIs', 'Learning progress'],
      knobs: const [
        ChartStoryKnobSpec.boolean(
          key: 'showTooltip',
          label: 'Show Tooltip',
          group: 'Interaction',
          defaultValue: true,
        ),
        ChartStoryKnobSpec.options(
          key: 'dataMode',
          label: 'Data Mode',
          group: 'Data',
          options: ['Regular', 'Large'],
          defaultValue: 'Regular',
        ),
      ],
      sampleJson: const {'type': 'line'},
      sampleCode: 'TenunChartFromJson(jsonConfig: chartJson)',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartStoryContractPanel(
            contract: contract,
            title: 'Line',
            sourcePanelHeight: 120,
          ),
        ),
      ),
    );

    expect(find.text('Reusable line chart story.'), findsOneWidget);
    expect(find.text('Use cases'), findsOneWidget);
    expect(find.text('Operational KPIs'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('trend'), findsOneWidget);
    expect(find.text('Knobs'), findsOneWidget);
    expect(find.text('Interaction'), findsOneWidget);
    expect(find.text('Show Tooltip: true'), findsOneWidget);
    expect(find.text('Data Mode: Regular'), findsOneWidget);
    expect(find.text('Sample JSON'), findsOneWidget);
    expect(find.text('Dart Code'), findsOneWidget);
    expect(find.text('Docs Markdown'), findsOneWidget);
    expect(find.textContaining('"type": "line"'), findsWidgets);
    expect(find.textContaining('# Line'), findsOneWidget);
    expect(find.textContaining('TenunChartFromJson'), findsWidgets);
  });
}
