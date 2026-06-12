import 'package:flutter/widgets.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'chart_story_contract_coverage.dart';
import 'chart_story_groups.dart';
import 'chart_story_tier.dart';

const _allFacetValue = '__all__';

class ChartCatalogExplorerKnobs {
  const ChartCatalogExplorerKnobs({
    required this.initialQuery,
    required this.initialTier,
    required this.initialCategory,
    required this.initialGroupId,
    required this.initialSection,
    required this.initialDataShape,
    required this.initialFamily,
    required this.initialContractStatus,
    required this.maxVisibleEntries,
  });

  final String initialQuery;
  final String? initialTier;
  final String? initialCategory;
  final String? initialGroupId;
  final String? initialSection;
  final String? initialDataShape;
  final String? initialFamily;
  final ChartStoryContractStatusFilter initialContractStatus;
  final int maxVisibleEntries;
}

ChartCatalogExplorerKnobs chartCatalogExplorerKnobs(
  BuildContext context,
  ChartStoryCatalog catalog, {
  String initialQuery = '',
  String? initialTier,
  String? initialCategory,
  String? initialGroupId,
  String? initialSection,
  String? initialDataShape,
  String? initialFamily,
  ChartStoryContractStatusFilter initialContractStatus =
      ChartStoryContractStatusFilter.all,
  int initialMaxVisibleEntries = 24,
}) {
  final tier = context.knobs.options<String>(
    label: 'Catalog Tier',
    initial: _initialFacetValue(catalog.tierKeys, initialTier),
    options: _facetOptions(
      'All tiers',
      catalog.tierKeys,
      labelForValue: chartStoryTierLabelForKey,
    ),
  );
  final categoryLabels = [
    for (final category in catalog.categories) category.label,
  ];
  final category = context.knobs.options<String>(
    label: 'Catalog Category',
    initial: _initialFacetValue(categoryLabels, initialCategory),
    options: _facetOptions('All categories', categoryLabels),
  );
  final group = context.knobs.options<String>(
    label: 'Catalog Group',
    initial: _initialFacetValue([
      for (final group in catalog.groups) group.id,
    ], initialGroupId),
    options: _groupFacetOptions(catalog),
  );
  final section = context.knobs.options<String>(
    label: 'Catalog Section',
    initial: _initialFacetValue(catalog.sections, initialSection),
    options: _facetOptions('All sections', catalog.sections),
  );
  final dataShape = context.knobs.options<String>(
    label: 'Catalog Data Shape',
    initial: _initialFacetValue(catalog.dataShapes, initialDataShape),
    options: _facetOptions('All data shapes', catalog.dataShapes),
  );
  final family = context.knobs.options<String>(
    label: 'Catalog Family',
    initial: _initialFacetValue(catalog.families, initialFamily),
    options: _facetOptions('All families', catalog.families),
  );
  final contractStatus = context.knobs.options<ChartStoryContractStatusFilter>(
    label: 'Catalog Contract Status',
    initial: initialContractStatus,
    options: [
      for (final status in chartStoryContractStatusFilters)
        Option(label: status.label, value: status),
    ],
  );

  return ChartCatalogExplorerKnobs(
    initialQuery: context.knobs.text(
      label: 'Catalog Search',
      initial: initialQuery,
    ),
    initialTier: _nullableFacetValue(tier),
    initialCategory: _nullableFacetValue(category),
    initialGroupId: _nullableFacetValue(group),
    initialSection: _nullableFacetValue(section),
    initialDataShape: _nullableFacetValue(dataShape),
    initialFamily: _nullableFacetValue(family),
    initialContractStatus: contractStatus,
    maxVisibleEntries: context.knobs.sliderInt(
      label: 'Catalog Result Limit',
      initial: initialMaxVisibleEntries.clamp(6, 80),
      min: 6,
      max: 80,
      divisions: 74,
    ),
  );
}

String _initialFacetValue(List<String> values, String? initialValue) {
  if (initialValue != null && values.contains(initialValue)) {
    return initialValue;
  }

  return _allFacetValue;
}

String? _nullableFacetValue(String value) {
  return value == _allFacetValue ? null : value;
}

List<Option<String>> _facetOptions(
  String allLabel,
  List<String> values, {
  String Function(String value)? labelForValue,
}) {
  return [
    Option(label: allLabel, value: _allFacetValue),
    for (final value in values)
      Option(label: labelForValue?.call(value) ?? value, value: value),
  ];
}

List<Option<String>> _groupFacetOptions(ChartStoryCatalog catalog) {
  return [
    const Option(label: 'All groups', value: _allFacetValue),
    for (final group in catalog.groups)
      Option(
        label: '${group.label} (${group.category.label})',
        value: group.id,
      ),
  ];
}
