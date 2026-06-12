import 'chart_story_contract_coverage.dart';
import 'chart_story_groups.dart';
import 'chart_story_tier.dart';

class ChartStoryTierContractCoverage {
  const ChartStoryTierContractCoverage({
    required this.tierKey,
    required this.tierLabel,
    required this.coverage,
  });

  final String tierKey;
  final String tierLabel;
  final ChartStoryContractCoverage coverage;

  int get totalCount => coverage.totalCount;

  int get readyCount => coverage.readyCount;

  int get gapCount => coverage.gapCount;

  double get readyRatio => coverage.readyRatio;
}

List<ChartStoryTierContractCoverage> chartStoryTierContractCoverageSummaries(
  ChartStoryCatalog catalog,
) {
  return List.unmodifiable([
    for (final tierKey in catalog.tierKeys)
      ChartStoryTierContractCoverage(
        tierKey: tierKey,
        tierLabel: chartStoryTierLabelForKey(tierKey),
        coverage: ChartStoryContractCoverage.fromEntries(
          catalog.entriesForTier(tierKey),
        ),
      ),
  ]);
}
