import 'package:flutter/material.dart';

import '../story/chart_story_groups.dart';
import '../story/chart_story_catalog_presets.dart';
import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_tier_coverage.dart';
import 'chart_story_catalog_explorer_parts.dart';

class ChartStoryCatalogExplorerExample extends StatefulWidget {
  const ChartStoryCatalogExplorerExample({
    super.key,
    required this.catalog,
    this.title = 'Story Catalog Explorer',
    this.subtitle,
    this.initialQuery = '',
    this.initialTier,
    this.initialCategory,
    this.initialGroupId,
    this.initialSection,
    this.initialDataShape,
    this.initialFamily,
    this.initialContractStatus = ChartStoryContractStatusFilter.all,
    this.maxVisibleEntries = 24,
  });

  final ChartStoryCatalog catalog;
  final String title;
  final String? subtitle;
  final String initialQuery;
  final String? initialTier;
  final String? initialCategory;
  final String? initialGroupId;
  final String? initialSection;
  final String? initialDataShape;
  final String? initialFamily;
  final ChartStoryContractStatusFilter initialContractStatus;
  final int maxVisibleEntries;

  @override
  State<ChartStoryCatalogExplorerExample> createState() =>
      _ChartStoryCatalogExplorerExampleState();
}

class _ChartStoryCatalogExplorerExampleState
    extends State<ChartStoryCatalogExplorerExample> {
  late final TextEditingController _queryController;
  ChartCatalogExplorerSelection _selection =
      const ChartCatalogExplorerSelection();
  ChartCatalogResultSortMode _sortMode = ChartCatalogResultSortMode.catalog;
  ChartCatalogResultGroupMode _groupMode = ChartCatalogResultGroupMode.category;

  bool get _hasActiveFilters => _filters.hasActiveFilters;

  ChartCatalogExplorerFilters get _filters {
    return _selection.toFilters(query: _queryController.text);
  }

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery)
      ..addListener(_handleQueryChanged);
    _selection = ChartCatalogExplorerSelection.fromInitials(
      tier: widget.initialTier,
      categoryLabel: widget.initialCategory,
      groupId: widget.initialGroupId,
      section: widget.initialSection,
      dataShape: widget.initialDataShape,
      family: widget.initialFamily,
      contractStatus: widget.initialContractStatus,
    );
  }

  @override
  void didUpdateWidget(ChartStoryCatalogExplorerExample oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialQuery != oldWidget.initialQuery &&
        _queryController.text != widget.initialQuery) {
      _setQueryText(widget.initialQuery);
    }

    var nextSelection = _selection;

    if (widget.initialTier != oldWidget.initialTier) {
      nextSelection = nextSelection.copyWith(tier: widget.initialTier);
    }

    if (widget.initialCategory != oldWidget.initialCategory) {
      nextSelection = nextSelection.copyWith(
        categoryLabel: widget.initialCategory,
      );
    }

    if (widget.initialGroupId != oldWidget.initialGroupId) {
      nextSelection = nextSelection.copyWith(groupId: widget.initialGroupId);
    }

    if (widget.initialSection != oldWidget.initialSection) {
      nextSelection = nextSelection.copyWith(section: widget.initialSection);
    }

    if (widget.initialDataShape != oldWidget.initialDataShape) {
      nextSelection = nextSelection.copyWith(
        dataShape: widget.initialDataShape,
      );
    }

    if (widget.initialFamily != oldWidget.initialFamily) {
      nextSelection = nextSelection.copyWith(family: widget.initialFamily);
    }

    if (widget.initialContractStatus != oldWidget.initialContractStatus) {
      nextSelection = nextSelection.withContractStatus(
        widget.initialContractStatus,
      );
    }

    if (nextSelection != _selection) {
      _selection = nextSelection;
    }
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_handleQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    setState(() {});
  }

  void _setQueryText(String value) {
    _queryController
      ..removeListener(_handleQueryChanged)
      ..text = value
      ..addListener(_handleQueryChanged);
  }

  void _clearQuery() {
    if (_queryController.text.isEmpty) {
      return;
    }

    _setQueryText('');
    setState(() {});
  }

  void _clearTier() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.tier));
  }

  void _clearSection() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.section));
  }

  void _clearGroup() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.group));
  }

  void _clearCategory() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.category));
  }

  void _clearDataShape() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.dataShape));
  }

  void _clearFamily() {
    _setSelection(_selection.clearFacet(ChartCatalogExplorerFacet.family));
  }

  void _clearContractStatus() {
    _setSelection(_selection.clearContractStatus());
  }

  void _clearFilters() {
    if (!_hasActiveFilters) {
      return;
    }

    _setQueryText('');
    setState(() {
      _selection = const ChartCatalogExplorerSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contractCoverage = ChartStoryContractCoverage.fromCatalog(
      widget.catalog,
    );
    final snapshot = ChartCatalogExplorerSnapshot.fromCatalog(
      catalog: widget.catalog,
      filters: _filters,
      sortMode: _sortMode,
      maxVisibleEntries: widget.maxVisibleEntries,
    );

    return ColoredBox(
      color: colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartCatalogExplorerHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              groupCount: widget.catalog.groupCount,
              storyCount: widget.catalog.storyCount,
              categoryCount: widget.catalog.categoryCount,
              sectionCount: widget.catalog.sections.length,
              dataShapeCount: widget.catalog.dataShapes.length,
              familyCount: widget.catalog.families.length,
            ),
            const SizedBox(height: 14),
            ChartCatalogContractCoverageSummary(coverage: contractCoverage),
            const SizedBox(height: 14),
            ChartCatalogTierReadinessSummary(
              summaries: chartStoryTierContractCoverageSummaries(
                widget.catalog,
              ),
            ),
            const SizedBox(height: 18),
            ChartCatalogExplorerFilterPanel(
              catalog: widget.catalog,
              filters: _filters,
              snapshot: snapshot,
              queryController: _queryController,
              selectedPresetId: _selectedPresetId,
              onPresetSelected: _applyPreset,
              onTierSelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.tier, value);
              },
              onContractStatusSelected: (status) {
                _setSelection(_selection.withContractStatus(status));
              },
              onCategorySelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.category, value);
              },
              onGroupSelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.group, value);
              },
              onSectionSelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.section, value);
              },
              onDataShapeSelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.dataShape, value);
              },
              onFamilySelected: (value) {
                _toggleFacet(ChartCatalogExplorerFacet.family, value);
              },
              onClearQuery: _clearQuery,
              onClearTier: _clearTier,
              onClearCategory: _clearCategory,
              onClearGroup: _clearGroup,
              onClearSection: _clearSection,
              onClearDataShape: _clearDataShape,
              onClearFamily: _clearFamily,
              onClearContractStatus: _clearContractStatus,
              onClearAll: _clearFilters,
              groupLabelForValue: _groupLabel,
              groupFacetLabelForValue: _groupFacetLabel,
            ),
            const SizedBox(height: 18),
            ChartCatalogExplorerResultPanel(
              snapshot: snapshot,
              sortMode: _sortMode,
              groupMode: _groupMode,
              hasActiveFilters: _hasActiveFilters,
              onSortModeChanged: (sortMode) {
                setState(() {
                  _sortMode = sortMode;
                });
              },
              onGroupModeChanged: (groupMode) {
                setState(() {
                  _groupMode = groupMode;
                });
              },
              onClearFilters: _clearFilters,
            ),
          ],
        ),
      ),
    );
  }

  String? get _selectedPresetId {
    for (final preset in chartStoryCatalogPresets) {
      if (_filtersMatchPreset(preset)) {
        return preset.id;
      }
    }

    return null;
  }

  bool _filtersMatchPreset(ChartStoryCatalogPreset preset) {
    return _filters.matchesPreset(preset);
  }

  void _applyPreset(ChartStoryCatalogPreset preset) {
    _setQueryText(preset.query);
    setState(() {
      _selection = ChartCatalogExplorerSelection.fromPreset(preset);
    });
  }

  void _toggleFacet(ChartCatalogExplorerFacet facet, String value) {
    _setSelection(_selection.toggleFacet(facet, value));
  }

  void _setSelection(ChartCatalogExplorerSelection selection) {
    if (selection == _selection) {
      return;
    }

    setState(() {
      _selection = selection;
    });
  }

  String _groupLabel(String groupId) {
    return widget.catalog.groupById(groupId)?.label ?? groupId;
  }

  String _groupFacetLabel(String groupId) {
    final group = widget.catalog.groupById(groupId);
    if (group == null) {
      return groupId;
    }

    return '${group.label} (${group.category.label})';
  }
}
