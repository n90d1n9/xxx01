import 'package:flutter/material.dart';

import 'chart_sample_explorer_controls.dart';
import 'chart_sample_explorer_logic.dart';
import 'chart_sample_family_catalog.dart';
import 'chart_sample_panels.dart';
import 'chart_samples_registry.dart';

export 'chart_sample_explorer_controls.dart';
export 'chart_sample_family_catalog.dart';
export 'chart_sample_panels.dart';
export 'chart_sample_source_helpers.dart';
export 'chart_showcase_tier.dart';

class ChartSampleFamilyExplorer extends StatefulWidget {
  const ChartSampleFamilyExplorer({
    super.key,
    required this.families,
    this.options = const ChartSampleShowcaseOptions(),
    this.padding = const EdgeInsets.all(12),
    this.initialFamilyId,
    this.showSearch = true,
    this.showTierFilters = true,
    this.showTypeFilters = true,
    this.showSort = true,
    this.showStats = true,
  });

  final List<ChartShowcaseFamily> families;
  final ChartSampleShowcaseOptions options;
  final EdgeInsetsGeometry padding;
  final String? initialFamilyId;
  final bool showSearch;
  final bool showTierFilters;
  final bool showTypeFilters;
  final bool showSort;
  final bool showStats;

  @override
  State<ChartSampleFamilyExplorer> createState() =>
      _ChartSampleFamilyExplorerState();
}

class _ChartSampleFamilyExplorerState extends State<ChartSampleFamilyExplorer> {
  String? _selectedFamilyId;
  ChartShowcaseTierFilter _selectedTierFilter = ChartShowcaseTierFilter.all;
  String? _selectedChartType;
  ChartFamilySortMode _sortMode = ChartFamilySortMode.curated;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFamilyId = resolveChartFamilyId(
      families: widget.families,
      requestedId: widget.initialFamilyId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChartSampleFamilyExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasSelection = chartFamilyIdExists(
      families: widget.families,
      familyId: _selectedFamilyId,
    );
    if (!hasSelection || oldWidget.initialFamilyId != widget.initialFamilyId) {
      _selectedFamilyId = resolveChartFamilyId(
        families: widget.families,
        requestedId: widget.initialFamilyId,
      );
    }
    _selectedTierFilter = sanitizeSelectedTierFilter(
      families: widget.families,
      selectedTierFilter: _selectedTierFilter,
    );
    _selectedChartType = _sanitizeSelectedChartType();
    _selectedFamilyId = _visibleFamilyId();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = chartFamilyExplorerSnapshot(
      families: widget.families,
      query: _query,
      selectedTierFilter: _selectedTierFilter,
      selectedChartType: _selectedChartType,
      selectedFamilyId: _selectedFamilyId,
      sortMode: widget.showSort ? _sortMode : ChartFamilySortMode.curated,
    );
    final typeScopeFamilyCount = chartShowcaseFamiliesForTier(
      widget.families,
      _selectedTierFilter,
    ).length;
    final onChartTypeSelected = _chartTypeSelectionHandler;

    return SingleChildScrollView(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSearch) ...[
            ChartSampleFamilySearchField(
              controller: _searchController,
              resultLabel: chartFamilyResultLabel(
                visibleCount: snapshot.filteredFamilies.length,
                totalCount: widget.families.length,
                filtered: snapshot.hasActiveFilters,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                  _selectedFamilyId = _visibleFamilyId();
                });
              },
              clearTooltip:
                  _selectedTierFilter == ChartShowcaseTierFilter.all &&
                      _selectedChartType == null
                  ? 'Clear search'
                  : 'Clear filters',
              onClear: snapshot.hasActiveFilters ? _clearFilters : null,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.showTierFilters && snapshot.tierOptions.length > 1) ...[
            ChartTierFilterStrip(
              options: snapshot.tierOptions,
              totalFamilyCount: widget.families.length,
              selectedTierFilter: _selectedTierFilter,
              onSelected: _setSelectedTierFilter,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.showTypeFilters && snapshot.typeOptions.isNotEmpty) ...[
            ChartTypeFilterStrip(
              options: snapshot.typeOptions,
              totalFamilyCount: typeScopeFamilyCount,
              selectedType: _selectedChartType,
              onSelected: _setSelectedChartType,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.showStats) ...[
            ChartFamilyStatsStrip(
              visibleStats: snapshot.visibleStats,
              totalStats: snapshot.totalStats,
              filtered: snapshot.hasActiveFilters,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.showSort && snapshot.filteredFamilies.length > 1) ...[
            ChartFamilySortControl(mode: _sortMode, onChanged: _setSortMode),
            const SizedBox(height: 12),
          ],
          if (snapshot.filteredFamilies.isEmpty)
            const ChartSampleFamilyEmptyState()
          else
            ChartSampleFamilyCatalogWrap(
              families: snapshot.filteredFamilies,
              selectedFamilyId: snapshot.selectedFamily?.id,
              onFamilySelected: (family) {
                setState(() {
                  _selectedFamilyId = family.id;
                });
              },
              onChartTypeSelected: onChartTypeSelected,
            ),
          if (snapshot.selectedFamily != null) ...[
            const SizedBox(height: 22),
            ChartSampleFamilyHeader(
              family: snapshot.selectedFamily!,
              onChartTypeSelected: onChartTypeSelected,
            ),
            if (snapshot.hasActiveFilters &&
                snapshot.selectedSamples.length !=
                    snapshot.selectedFamily!.sampleCount) ...[
              const SizedBox(height: 8),
              ChartSampleResultLabel(
                visibleCount: snapshot.selectedSamples.length,
                totalCount: snapshot.selectedFamily!.sampleCount,
              ),
            ],
            const SizedBox(height: 18),
            ChartSampleList(
              samples: snapshot.selectedSamples,
              options: widget.options,
            ),
          ],
        ],
      ),
    );
  }

  ValueChanged<String>? get _chartTypeSelectionHandler {
    if (widget.showTypeFilters) {
      return _setSelectedChartType;
    }
    if (widget.showSearch) {
      return _setSearchQuery;
    }
    return null;
  }

  void _setSelectedChartType(String? type) {
    final nextType = type?.trim();
    setState(() {
      _selectedChartType = nextType == null || nextType.isEmpty
          ? null
          : nextType;
      _selectedFamilyId = _visibleFamilyId();
    });
  }

  void _setSelectedTierFilter(ChartShowcaseTierFilter tierFilter) {
    setState(() {
      _selectedTierFilter = sanitizeSelectedTierFilter(
        families: widget.families,
        selectedTierFilter: tierFilter,
      );
      _selectedChartType = _sanitizeSelectedChartType();
      _selectedFamilyId = _visibleFamilyId();
    });
  }

  void _setSortMode(ChartFamilySortMode mode) {
    setState(() {
      _sortMode = mode;
      _selectedFamilyId = _visibleFamilyId();
    });
  }

  void _setSearchQuery(String value) {
    final query = value.trim();
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() {
      _query = query;
      _selectedFamilyId = _visibleFamilyId();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTierFilter = ChartShowcaseTierFilter.all;
      _selectedChartType = null;
      _selectedFamilyId = _visibleFamilyId();
    });
  }

  String? _visibleFamilyId() {
    return resolveVisibleChartFamilyId(
      families: widget.families,
      query: _query,
      selectedTierFilter: _selectedTierFilter,
      selectedChartType: _selectedChartType,
      selectedFamilyId: _selectedFamilyId,
      sortMode: widget.showSort ? _sortMode : ChartFamilySortMode.curated,
    );
  }

  String? _sanitizeSelectedChartType() {
    return sanitizeSelectedChartType(
      families: chartShowcaseFamiliesForTier(
        widget.families,
        _selectedTierFilter,
      ),
      selectedChartType: _selectedChartType,
    );
  }
}
