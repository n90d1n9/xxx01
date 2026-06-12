import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_parts.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';

void main() {
  test('catalog explorer parts barrel exposes public modules', () {
    const filters = ChartCatalogExplorerFilters(query: 'bar chart');
    final exportedWidgetTypes = <Type>[
      ChartCatalogCountBadge,
      ChartCatalogChipLabel,
      ChartCatalogFilterInputChip,
      ChartCatalogFacetChip,
      ChartCatalogResultSortControl,
      ChartCatalogResultGroupControl,
      ChartCatalogFacetWrap,
      ChartCatalogExplorerFilterPanel,
      ChartCatalogPresetWrap,
      ChartCatalogActiveFilterSummary,
      ChartCatalogContractStatusFilterWrap,
      ChartCatalogExplorerHeader,
      ChartCatalogContractCoverageSummary,
      ChartCatalogExplorerResultPanel,
      ChartCatalogGroupedResultList,
      ChartCatalogResultTile,
      ChartCatalogStoryContractDisclosure,
      ChartCatalogStoryContractStarterDisclosure,
      ChartCatalogEntryMetadataWrap,
      ChartCatalogTierChip,
      ChartCatalogContractReadinessChip,
      ChartCatalogMetadataChip,
      ChartCatalogTierReadinessSummary,
    ];

    expect(filters.hasActiveFilters, isTrue);
    expect(
      const ChartCatalogExplorerSelection(
        categoryLabel: 'Core Shapes',
      ).toFilters(query: 'heatmap').hasActiveFilters,
      isTrue,
    );
    expect(
      ChartCatalogExplorerSnapshot.fromCatalog(
        catalog: chartStoryCatalog,
        filters: filters,
        sortMode: ChartCatalogResultSortMode.catalog,
        maxVisibleEntries: 1,
      ).visibleEntryCount,
      lessThanOrEqualTo(1),
    );
    expect(ChartCatalogResultSortMode.catalog.name, 'catalog');
    expect(ChartCatalogResultGroupMode.category.name, 'category');
    expect(
      chartStoryTierIcon(ChartStoryTier.pro),
      Icons.workspace_premium_outlined,
    );
    expect(
      chartStoryTierDescriptionForKey(ChartStoryTier.pro.key),
      ChartStoryTier.pro.description,
    );
    expect(exportedWidgetTypes, hasLength(23));
  });
}
