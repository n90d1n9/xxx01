import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_story_builders.dart';
import 'package:tenun_showcase/story/chart_story_contract.dart';
import 'package:tenun_showcase/story/chart_story_contract_coverage.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';
import 'package:tenun_showcase/story/chart_story_tier_coverage.dart';

void main() {
  test('chart story contract coverage summarizes migration readiness', () {
    final readyStory = chartStory(
      name: 'Charts/Test Coverage/Ready',
      description: 'Ready story',
      contract: ChartStoryContract(
        section: 'Test Coverage',
        family: 'Ready',
        knobs: const [
          ChartStoryKnobSpec.boolean(key: 'showTooltip', label: 'Show Tooltip'),
        ],
        sampleJson: const {'type': 'line'},
        sampleCode: 'TenunChartFromJson(jsonConfig: chartJson)',
      ),
      builder: (context) => const SizedBox(),
    );
    final partialStory = chartStory(
      name: 'Charts/Test Coverage/Partial',
      description: 'Partial story',
      contract: ChartStoryContract(section: 'Test Coverage', family: 'Partial'),
      builder: (context) => const SizedBox(),
    );
    final plainStory = chartStory(
      name: 'Charts/Test Coverage/Plain',
      description: 'Plain story',
      builder: (context) => const SizedBox(),
    );
    final catalog = ChartStoryCatalog([
      ChartStoryGroup(
        id: 'test-coverage',
        label: 'Test Coverage',
        description: 'Test coverage fixture group.',
        stories: [readyStory, partialStory, plainStory],
      ),
    ]);

    final coverage = ChartStoryContractCoverage.fromCatalog(catalog);

    expect(coverage.totalCount, 3);
    expect(coverage.contractedCount, 2);
    expect(coverage.readyCount, 1);
    expect(coverage.knobCount, 1);
    expect(coverage.sampleJsonCount, 1);
    expect(coverage.sampleCodeCount, 1);
    expect(coverage.missingContractCount, 1);
    expect(coverage.gapCount, 2);
    expect(coverage.isComplete, isFalse);
    expect(chartStoryContractCoverageRatioLabel(coverage.readyRatio), '33%');

    final partialGap = coverage.gaps.firstWhere(
      (gap) => gap.entry.name == partialStory.name,
    );
    expect(partialGap.missingParts, ['knobs', 'sample JSON', 'sample code']);
    expect(partialGap.missingLabel, 'knobs, sample JSON, sample code');
    expect(
      chartStoryContractMissingParts(catalog.entryByName(partialStory.name)!),
      ['knobs', 'sample JSON', 'sample code'],
    );
    expect(
      chartStoryContractReadinessLabel(catalog.entryByName(partialStory.name)!),
      'Needs work',
    );
    expect(
      chartStoryContractReadinessLabel(catalog.entryByName(readyStory.name)!),
      'Ready',
    );

    final plainGap = coverage.gaps.firstWhere(
      (gap) => gap.entry.name == plainStory.name,
    );
    expect(plainGap.missingParts, [
      'contract',
      'knobs',
      'sample JSON',
      'sample code',
    ]);
    expect(
      chartStoryContractReadinessLabel(catalog.entryByName(plainStory.name)!),
      'Needs contract',
    );
    expect(
      chartStoryMatchesContractStatus(
        catalog.entryByName(readyStory.name)!,
        ChartStoryContractStatusFilter.ready,
      ),
      isTrue,
    );
    expect(
      chartStoryMatchesContractStatus(
        catalog.entryByName(partialStory.name)!,
        ChartStoryContractStatusFilter.needsWork,
      ),
      isTrue,
    );
    expect(
      chartStoryMatchesContractStatus(
        catalog.entryByName(plainStory.name)!,
        ChartStoryContractStatusFilter.needsContract,
      ),
      isTrue,
    );
    expect(
      chartStoryMatchesContractStatus(
        catalog.entryByName(partialStory.name)!,
        ChartStoryContractStatusFilter.needsSampleJson,
      ),
      isTrue,
    );
    expect(ChartStoryContractStatusFilter.needsSampleJson.label, 'Needs JSON');
    expect(
      () => coverage.entries.add(catalog.entries.first),
      throwsUnsupportedError,
    );
    expect(() => partialGap.missingParts.add('extra'), throwsUnsupportedError);
  });

  test('chart story tier coverage summarizes readiness by package tier', () {
    final coreReadyStory = chartStory(
      name: 'Charts/Tier Coverage/Core/Ready',
      description: 'Ready core story',
      contract: ChartStoryContract(
        section: 'Tier Coverage',
        family: 'Core',
        knobs: const [
          ChartStoryKnobSpec.boolean(key: 'showTooltip', label: 'Show Tooltip'),
        ],
        sampleJson: const {'type': 'bar'},
        sampleCode: 'TenunChartFromJson(jsonConfig: chartJson)',
      ),
      builder: (context) => const SizedBox(),
    );
    final coreGapStory = chartStory(
      name: 'Charts/Tier Coverage/Core/Gap',
      description: 'Core gap story',
      builder: (context) => const SizedBox(),
    );
    final proReadyStory = chartStory(
      name: 'Charts/Tier Coverage/Pro/Ready',
      description: 'Ready pro story',
      contract: ChartStoryContract(
        section: 'Tier Coverage',
        family: 'Pro',
        knobs: const [
          ChartStoryKnobSpec.boolean(key: 'showTooltip', label: 'Show Tooltip'),
        ],
        sampleJson: const {'type': 'heatmap'},
        sampleCode: 'TenunChartFromJson(jsonConfig: chartJson)',
      ),
      builder: (context) => const SizedBox(),
    );

    final catalog = ChartStoryCatalog([
      ChartStoryGroup(
        id: 'tier-core',
        label: 'Tier Core',
        description: 'Core tier fixture group.',
        stories: [coreReadyStory, coreGapStory],
      ),
      ChartStoryGroup(
        id: 'tier-pro',
        label: 'Tier Pro',
        description: 'Pro tier fixture group.',
        tier: ChartStoryTier.pro,
        stories: [proReadyStory],
      ),
    ]);

    final summaries = chartStoryTierContractCoverageSummaries(catalog);
    final coreSummary = summaries.singleWhere(
      (summary) => summary.tierKey == ChartStoryTier.core.key,
    );
    final proSummary = summaries.singleWhere(
      (summary) => summary.tierKey == ChartStoryTier.pro.key,
    );

    expect(summaries, hasLength(2));
    expect(coreSummary.tierLabel, 'Core');
    expect(coreSummary.totalCount, 2);
    expect(coreSummary.readyCount, 1);
    expect(coreSummary.gapCount, 1);
    expect(chartStoryContractCoverageRatioLabel(coreSummary.readyRatio), '50%');
    expect(proSummary.tierLabel, 'Pro');
    expect(proSummary.totalCount, 1);
    expect(proSummary.readyCount, 1);
    expect(proSummary.gapCount, 0);
    expect(() => summaries.add(proSummary), throwsUnsupportedError);
  });
}
