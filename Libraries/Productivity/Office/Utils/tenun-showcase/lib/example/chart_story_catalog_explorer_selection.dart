import '../story/chart_story_catalog_presets.dart';
import '../story/chart_story_contract_coverage.dart';
import 'chart_story_catalog_explorer_state.dart';

enum ChartCatalogExplorerFacet {
  tier,
  category,
  group,
  section,
  dataShape,
  family,
}

class ChartCatalogExplorerSelection {
  const ChartCatalogExplorerSelection({
    this.tier,
    this.categoryLabel,
    this.groupId,
    this.section,
    this.dataShape,
    this.family,
    this.contractStatus = ChartStoryContractStatusFilter.all,
  });

  factory ChartCatalogExplorerSelection.fromInitials({
    String? tier,
    String? categoryLabel,
    String? groupId,
    String? section,
    String? dataShape,
    String? family,
    ChartStoryContractStatusFilter contractStatus =
        ChartStoryContractStatusFilter.all,
  }) {
    return ChartCatalogExplorerSelection(
      tier: tier,
      categoryLabel: categoryLabel,
      groupId: groupId,
      section: section,
      dataShape: dataShape,
      family: family,
      contractStatus: contractStatus,
    );
  }

  factory ChartCatalogExplorerSelection.fromPreset(
    ChartStoryCatalogPreset preset,
  ) {
    return ChartCatalogExplorerSelection(
      tier: preset.tier,
      categoryLabel: preset.categoryLabel,
      groupId: preset.groupId,
      section: preset.section,
      dataShape: preset.dataShape,
      family: preset.family,
      contractStatus: preset.contractStatus,
    );
  }

  final String? tier;
  final String? categoryLabel;
  final String? groupId;
  final String? section;
  final String? dataShape;
  final String? family;
  final ChartStoryContractStatusFilter contractStatus;

  ChartCatalogExplorerFilters toFilters({required String query}) {
    return ChartCatalogExplorerFilters(
      query: query,
      tier: tier,
      categoryLabel: categoryLabel,
      groupId: groupId,
      section: section,
      dataShape: dataShape,
      family: family,
      contractStatus: contractStatus,
    );
  }

  ChartCatalogExplorerSelection copyWith({
    Object? tier = _unchanged,
    Object? categoryLabel = _unchanged,
    Object? groupId = _unchanged,
    Object? section = _unchanged,
    Object? dataShape = _unchanged,
    Object? family = _unchanged,
    ChartStoryContractStatusFilter? contractStatus,
  }) {
    return ChartCatalogExplorerSelection(
      tier: tier == _unchanged ? this.tier : tier as String?,
      categoryLabel: categoryLabel == _unchanged
          ? this.categoryLabel
          : categoryLabel as String?,
      groupId: groupId == _unchanged ? this.groupId : groupId as String?,
      section: section == _unchanged ? this.section : section as String?,
      dataShape: dataShape == _unchanged
          ? this.dataShape
          : dataShape as String?,
      family: family == _unchanged ? this.family : family as String?,
      contractStatus: contractStatus ?? this.contractStatus,
    );
  }

  ChartCatalogExplorerSelection toggleFacet(
    ChartCatalogExplorerFacet facet,
    String value,
  ) {
    final currentValue = valueForFacet(facet);
    return withFacet(facet, currentValue == value ? null : value);
  }

  ChartCatalogExplorerSelection clearFacet(ChartCatalogExplorerFacet facet) {
    if (valueForFacet(facet) == null) {
      return this;
    }

    return withFacet(facet, null);
  }

  ChartCatalogExplorerSelection withFacet(
    ChartCatalogExplorerFacet facet,
    String? value,
  ) {
    return switch (facet) {
      ChartCatalogExplorerFacet.tier => copyWith(tier: value),
      ChartCatalogExplorerFacet.category => copyWith(categoryLabel: value),
      ChartCatalogExplorerFacet.group => copyWith(groupId: value),
      ChartCatalogExplorerFacet.section => copyWith(section: value),
      ChartCatalogExplorerFacet.dataShape => copyWith(dataShape: value),
      ChartCatalogExplorerFacet.family => copyWith(family: value),
    };
  }

  String? valueForFacet(ChartCatalogExplorerFacet facet) {
    return switch (facet) {
      ChartCatalogExplorerFacet.tier => tier,
      ChartCatalogExplorerFacet.category => categoryLabel,
      ChartCatalogExplorerFacet.group => groupId,
      ChartCatalogExplorerFacet.section => section,
      ChartCatalogExplorerFacet.dataShape => dataShape,
      ChartCatalogExplorerFacet.family => family,
    };
  }

  ChartCatalogExplorerSelection withContractStatus(
    ChartStoryContractStatusFilter status,
  ) {
    return copyWith(contractStatus: status);
  }

  ChartCatalogExplorerSelection clearContractStatus() {
    if (contractStatus == ChartStoryContractStatusFilter.all) {
      return this;
    }

    return copyWith(contractStatus: ChartStoryContractStatusFilter.all);
  }

  @override
  bool operator ==(Object other) {
    return other is ChartCatalogExplorerSelection &&
        tier == other.tier &&
        categoryLabel == other.categoryLabel &&
        groupId == other.groupId &&
        section == other.section &&
        dataShape == other.dataShape &&
        family == other.family &&
        contractStatus == other.contractStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      tier,
      categoryLabel,
      groupId,
      section,
      dataShape,
      family,
      contractStatus,
    );
  }
}

const _unchanged = Object();
