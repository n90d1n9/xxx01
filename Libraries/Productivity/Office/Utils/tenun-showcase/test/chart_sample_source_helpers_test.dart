import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_source_audit.dart';
import 'package:tenun_showcase/example/chart_sample_source_helpers.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/chart_sample_test_fixtures.dart';

void main() {
  test('sample options clone payloads and toggle common overlays', () {
    final source = <String, dynamic>{
      'type': 'bar',
      'legend': {'show': true, 'position': 'top'},
      'tooltip': {'show': true, 'trigger': 'axis'},
      'series': [
        {
          'name': 'Sales',
          'data': [10, 20, 30],
        },
      ],
    };

    final adjusted = chartSampleJsonWithOptions(
      source,
      const ChartSampleShowcaseOptions(showLegend: false, showTooltip: false),
    );

    expect(adjusted['legend'], containsPair('show', false));
    expect(adjusted['tooltip'], containsPair('show', false));
    expect(adjusted['legend'], containsPair('position', 'top'));
    expect(adjusted['tooltip'], containsPair('trigger', 'axis'));
    expect((source['legend'] as Map<String, dynamic>)['show'], isTrue);
    expect((source['tooltip'] as Map<String, dynamic>)['show'], isTrue);
    expect(identical(adjusted['series'], source['series']), isFalse);
  });

  test('sample text helpers expose pretty JSON and copy-ready Dart code', () {
    final json = chartSampleJsonWithOptions(
      testBarSampleJson,
      const ChartSampleShowcaseOptions(),
    );

    final jsonText = chartSampleJsonText(json);
    final codeText = chartSampleCodeText(json);

    expect(jsonText, contains('"type": "bar"'));
    expect(jsonText, contains('"legend": {'));
    expect(codeText, contains('TenunChartFromJson('));
    expect(codeText, contains('jsonConfig: const <String, dynamic>{'));
    expect(codeText, contains('padding: const EdgeInsets.all(8)'));
  });

  test('sample options expose reusable presentation presets', () {
    const compact = ChartSampleShowcaseOptions.compact;
    final sourceOnly = ChartSampleShowcaseOptions.sourceOnly.copyWith(
      chartPadding: 12.5,
      sourcePanelHeight: 120,
      sourcePanelMinWidth: 260,
      showSampleCode: false,
    );
    final json = chartSampleJsonWithOptions(testBarSampleJson, sourceOnly);
    final codeText = chartSampleCodeText(
      json,
      chartPadding: sourceOnly.chartPadding,
    );

    expect(compact.showSampleSource, isFalse);
    expect(compact.showChart, isTrue);
    expect(sourceOnly.showSampleTitle, isFalse);
    expect(sourceOnly.showChart, isFalse);
    expect(sourceOnly.showSampleJson, isTrue);
    expect(sourceOnly.showSampleCode, isFalse);
    expect(sourceOnly.sourcePanelHeight, 120);
    expect(sourceOnly.sourcePanelMinWidth, 260);
    expect(codeText, contains('padding: const EdgeInsets.all(12.5)'));
  });

  test('focused registry samples produce stable copy-ready source', () {
    final report = auditFocusedChartSampleSources();

    expect(
      report.issues,
      isEmpty,
      reason: report.issues
          .map(
            (issue) =>
                '${issue.familyId}/${issue.sampleTitle}: '
                '${issue.caseId} ${issue.code} ${issue.message}',
          )
          .join('\n'),
    );
    expect(report.isValid, isTrue);
    expect(report.familyCount, ChartSamplesRegistry.focusedFamilies.length);
    expect(report.sampleCount, ChartSamplesRegistry.focusedSamples.length);
    expect(report.caseCount, chartSampleSourceAuditDefaultCases.length);
    expect(report.checkedSourceCount, report.sampleCount * report.caseCount);
    expect(report.familyResults, hasLength(report.familyCount));
    expect(report.caseResults, hasLength(report.caseCount));
    expect(report.familyResults.first.issueCount, 0);
    expect(
      report.familyResults.first.checkedSourceCount,
      report.familyResults.first.sampleCount * report.caseCount,
    );
    expect(report.caseResults.first.issueCount, 0);
    expect(report.caseResults.first.checkedSourceCount, report.sampleCount);
    expect(report.toJson(), containsPair('issueCount', 0));
    expect(
      (report.toJson()['caseResults'] as List).first,
      containsPair('issueCount', 0),
    );
    expect(
      (report.toJson()['familyResults'] as List).first,
      containsPair(
        'checkedSourceCount',
        report.familyResults.first.checkedSourceCount,
      ),
    );
  });

  test('source audit catches unencodable JSON and empty custom code', () {
    final family = ChartShowcaseFamily(
      id: 'broken',
      title: 'Broken',
      description: 'Broken source examples.',
      samples: [
        ChartShowcaseSample('Bad JSON', 180, {
          'type': 'bar',
          'series': [Object()],
        }),
        const ChartShowcaseSample(
          'Empty Code',
          180,
          testBarSampleJson,
          code: '   ',
        ),
      ],
    );

    final report = auditChartSampleSources(
      [family],
      cases: [chartSampleSourceAuditDefaultCases.first],
    );

    expect(report.isValid, isFalse);
    expect(report.issueCodes, [
      'SAMPLE_JSON_NOT_ENCODABLE',
      'EMPTY_CUSTOM_CODE',
    ]);
    expect(report.issueCodeCounts, {
      'EMPTY_CUSTOM_CODE': 1,
      'SAMPLE_JSON_NOT_ENCODABLE': 1,
    });
    expect(report.familyResults.single.checkedSourceCount, 2);
    expect(report.familyResults.single.issueCount, 2);
    expect(report.caseResults.single.checkedSourceCount, 2);
    expect(report.caseResults.single.issueCount, 2);
    expect(report.toJson(), containsPair('checkedSourceCount', 2));
    expect(
      report.toJson(),
      containsPair('issueCodeCounts', report.issueCodeCounts),
    );
  });

  test('source audit catches blank and duplicate case metadata', () {
    final report = auditChartSampleSources(
      const [],
      cases: const [
        ChartSampleSourceAuditCase(
          id: '',
          label: '',
          options: ChartSampleShowcaseOptions(),
        ),
        ChartSampleSourceAuditCase(
          id: 'duplicate',
          label: 'First',
          options: ChartSampleShowcaseOptions(),
        ),
        ChartSampleSourceAuditCase(
          id: 'Duplicate',
          label: 'Second',
          options: ChartSampleShowcaseOptions(showTooltip: false),
        ),
      ],
    );

    expect(report.isValid, isFalse);
    expect(report.caseCount, 3);
    expect(report.checkedSourceCount, 0);
    expect(report.familyResults, isEmpty);
    expect(report.caseResults.map((result) => result.issueCount), [2, 0, 1]);
    expect(report.caseResults.map((result) => result.checkedSourceCount), [
      0,
      0,
      0,
    ]);
    expect(report.issueCodes, [
      'CASE_ID_EMPTY',
      'CASE_LABEL_EMPTY',
      'DUPLICATE_CASE_ID',
    ]);
    expect(report.issueCodeCounts, {
      'CASE_ID_EMPTY': 1,
      'CASE_LABEL_EMPTY': 1,
      'DUPLICATE_CASE_ID': 1,
    });
    expect(
      report.issues.firstWhere((issue) => issue.code == 'DUPLICATE_CASE_ID'),
      isA<ChartSampleSourceAuditIssue>()
          .having((issue) => issue.caseId, 'caseId', 'Duplicate')
          .having((issue) => issue.caseLabel, 'caseLabel', 'Second')
          .having((issue) => issue.sampleIndex, 'sampleIndex', 2),
    );
  });
}
