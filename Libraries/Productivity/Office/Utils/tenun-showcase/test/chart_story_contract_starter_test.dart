import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_story_builders.dart';
import 'package:tenun_showcase/story/chart_story_contract_starter.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';

void main() {
  test('chart story contract starter builds copy-ready scaffold code', () {
    final story = chartStory(
      name: 'Charts/By Data Shape/Cartesian/Bar/Grouped',
      description: "Grouped student's growth by cohort.",
      builder: (context) => const SizedBox(),
    );
    final catalog = ChartStoryCatalog([
      ChartStoryGroup(
        id: 'test-contract-starter',
        label: 'Test Contract Starter',
        description: 'Test contract starter fixture group.',
        stories: [story],
      ),
    ]);
    final entry = catalog.entryByName(story.name)!;

    final starter = chartStoryContractStarterForEntry(entry);

    expect(starter.variableName, 'byDataShapeCartesianBarGroupedStoryContract');
    expect(
      starter.code,
      contains(
        'final byDataShapeCartesianBarGroupedStoryContract = '
        'ChartStoryContract(',
      ),
    );
    expect(starter.code, contains("section: 'By Data Shape'"));
    expect(starter.code, contains("dataShape: 'Cartesian'"));
    expect(starter.code, contains("family: 'Bar'"));
    expect(starter.code, contains("variant: 'Grouped'"));
    expect(starter.code, contains(r"Grouped student\'s growth by cohort."));
    expect(starter.code, contains("'type': 'bar'"));
    expect(starter.code, contains('TenunChartFromJson('));
  });

  test('chart story contract starter bundle limits generated scaffolds', () {
    final stories = [
      for (final name in ['Alpha', 'Beta', 'Gamma'])
        chartStory(
          name: 'Charts/Test Bundle/$name',
          description: '$name story',
          builder: (context) => const SizedBox(),
        ),
    ];
    final catalog = ChartStoryCatalog([
      ChartStoryGroup(
        id: 'test-contract-bundle',
        label: 'Test Contract Bundle',
        description: 'Test contract bundle fixture group.',
        stories: stories,
      ),
    ]);

    final bundle = chartStoryContractStarterBundleForEntries(
      catalog.entries,
      limit: 2,
    );

    expect(bundle.count, 2);
    expect(bundle.hiddenCount, 1);
    expect(bundle.code, contains('testBundleAlphaStoryContract'));
    expect(bundle.code, contains('testBundleBetaStoryContract'));
    expect(bundle.code, isNot(contains('testBundleGammaStoryContract')));
  });
}
