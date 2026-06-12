import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_story_contract.dart';
import 'package:tenun_showcase/story/chart_story_contract_docs.dart';

void main() {
  test('chart story contract docs render markdown from contract metadata', () {
    final markdown = chartStoryContractMarkdown(
      title: 'Line / Operations',
      contract: ChartStoryContract(
        section: 'By Data Shape',
        dataShape: 'Cartesian',
        family: 'Line',
        variant: 'Operations',
        summary: 'Reusable trend chart.',
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
            key: 'mode',
            label: 'Mode | Variant',
            group: 'Data',
            options: ['Regular', 'Large'],
            defaultValue: 'Regular',
          ),
        ],
        sampleJson: const {
          'type': 'line',
          'series': [
            {
              'name': 'Revenue',
              'data': [1, 2, 3],
            },
          ],
        },
        sampleCode: 'TenunChartFromJson(jsonConfig: chartPayload)',
      ),
    );

    expect(markdown, startsWith('# Line / Operations'));
    expect(markdown, contains('Reusable trend chart.'));
    expect(markdown, contains('| Data Shape | Cartesian |'));
    expect(markdown, contains('## Use Cases'));
    expect(markdown, contains('- Operational KPIs'));
    expect(markdown, contains('## Knobs'));
    expect(markdown, contains('Mode \\| Variant'));
    expect(markdown, contains('```json'));
    expect(markdown, contains('"type": "line"'));
    expect(markdown, contains('```dart'));
    expect(markdown, contains('TenunChartFromJson'));
  });
}
