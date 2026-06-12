import 'chart_story_contract_coverage.dart';
import 'chart_story_groups.dart';

class ChartStoryCatalogPreset {
  const ChartStoryCatalogPreset({
    required this.id,
    required this.label,
    required this.description,
    this.query = '',
    this.tier,
    this.categoryLabel,
    this.groupId,
    this.section,
    this.dataShape,
    this.family,
    this.contractStatus = ChartStoryContractStatusFilter.all,
  });

  final String id;
  final String label;
  final String description;
  final String query;
  final String? tier;
  final String? categoryLabel;
  final String? groupId;
  final String? section;
  final String? dataShape;
  final String? family;
  final ChartStoryContractStatusFilter contractStatus;

  bool get hasFilters {
    return query.trim().isNotEmpty ||
        tier != null ||
        categoryLabel != null ||
        groupId != null ||
        section != null ||
        dataShape != null ||
        family != null ||
        contractStatus != ChartStoryContractStatusFilter.all;
  }

  bool matchesEntry(ChartStoryEntry entry) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isNotEmpty && !entry.matchesQuery(normalizedQuery)) {
      return false;
    }

    if (tier != null && entry.tierKey != tier) {
      return false;
    }

    if (categoryLabel != null && entry.categoryLabel != categoryLabel) {
      return false;
    }

    if (groupId != null && entry.groupId != groupId) {
      return false;
    }

    if (section != null && entry.section != section) {
      return false;
    }

    if (dataShape != null && entry.dataShape != dataShape) {
      return false;
    }

    if (family != null && entry.family != family) {
      return false;
    }

    if (contractStatus != ChartStoryContractStatusFilter.all &&
        !chartStoryMatchesContractStatus(entry, contractStatus)) {
      return false;
    }

    return true;
  }

  List<ChartStoryEntry> entriesIn(ChartStoryCatalog catalog) {
    return List.unmodifiable(catalog.entries.where(matchesEntry));
  }
}

const chartStoryCatalogPresets = [
  ChartStoryCatalogPreset(
    id: 'all',
    label: 'All stories',
    description: 'Reset to the full catalog.',
  ),
  ChartStoryCatalogPreset(
    id: 'review-gaps',
    label: 'Review gaps',
    description: 'Stories that still need contract, knob, JSON, or code work.',
    contractStatus: ChartStoryContractStatusFilter.needsWork,
  ),
  ChartStoryCatalogPreset(
    id: 'json-gaps',
    label: 'JSON gaps',
    description: 'Stories that still need sample JSON.',
    contractStatus: ChartStoryContractStatusFilter.needsSampleJson,
  ),
  ChartStoryCatalogPreset(
    id: 'core-tier',
    label: 'Core tier',
    description: 'Stories owned by the open-source core package.',
    tier: 'core',
  ),
  ChartStoryCatalogPreset(
    id: 'pro-tier',
    label: 'Pro tier',
    description: 'Commercial and enterprise-oriented chart stories.',
    tier: 'pro',
  ),
  ChartStoryCatalogPreset(
    id: 'core-shapes',
    label: 'Core shapes',
    description: 'Business-neutral core chart families and variants.',
    categoryLabel: 'Core Shapes',
  ),
  ChartStoryCatalogPreset(
    id: 'tooling',
    label: 'Tooling suite',
    description: 'Diagnostics, safety, export, performance, and authoring.',
    categoryLabel: 'Tooling',
  ),
  ChartStoryCatalogPreset(
    id: 'specialized',
    label: 'Specialized',
    description: 'Domain-oriented and specialized analytical charts.',
    categoryLabel: 'Domain & Specialized',
  ),
];
