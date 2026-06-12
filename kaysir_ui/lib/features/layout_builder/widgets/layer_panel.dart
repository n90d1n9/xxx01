import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_data_binding_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';
import 'active_filter_bar.dart';
import 'filtered_empty_state.dart';
import 'layout_diagnostics_panel.dart';

class LayerPanel extends ConsumerStatefulWidget {
  const LayerPanel({super.key});

  @override
  ConsumerState<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends ConsumerState<LayerPanel> {
  static const _estimatedLayerTileExtent = 72.0;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  var _query = '';
  var _filter = _LayerFilter.all;
  String? _selectionAnchorId;
  ComponentType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutState = ref.watch(layoutStateProvider);
    final currentDevice = ref.watch(
      responsivePreviewProvider.select((state) => state.currentDevice),
    );
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final components = layoutState.components.reversed.toList(growable: false);
    final diagnosticSummaries = layoutDiagnosticSummariesByComponent(
      layoutState.components,
      bindings: bindings,
      layoutConfig: layoutState.config,
    );
    final typeCounts = _componentTypeCounts(components);
    final hiddenLayerCount =
        components.where((component) => !component.isVisible).length;
    final lockedLayerCount =
        components.where((component) => component.isLocked).length;
    final canRestoreVisibility = layoutState.visibilitySnapshot != null;
    final filteredComponents = components
        .where(
          (component) => _matchesLayer(
            component,
            layoutState.selectedComponentIds,
            diagnosticSummaries,
          ),
        )
        .toList(growable: false);
    final hasQuery = _query.isNotEmpty;
    final hasTypeFilter = _typeFilter != null;
    final hasActiveFilter = _filter != _LayerFilter.all || hasTypeFilter;
    final filterCountComponents =
        hasTypeFilter
            ? components
                .where((component) => component.type == _typeFilter)
                .toList(growable: false)
            : components;
    final canReorder = !hasQuery && !hasActiveFilter;
    final displayedComponents = canReorder ? components : filteredComponents;
    final selectedLayerIndex = _selectedLayerIndex(
      displayedComponents,
      layoutState.selectedComponentId,
      layoutState.selectedComponentIds,
    );
    final canScrollToSelection = selectedLayerIndex >= 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showBulkActions =
        filteredComponents.isNotEmpty && (hasQuery || hasActiveFilter);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                enabled: components.isNotEmpty,
                decoration: InputDecoration(
                  hintText: 'Search layers',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _query.isEmpty
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              if (components.isNotEmpty) ...[
                const SizedBox(height: 8),
                _LayerSummaryStrip(
                  components: components,
                  selectedIds: layoutState.selectedComponentIds,
                  diagnosticSummaries: diagnosticSummaries,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${filteredComponents.length} of ${components.length} layers',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Tooltip(
                      message:
                          canScrollToSelection
                              ? 'Scroll to selected layer'
                              : layoutState.selectedComponentIds.isEmpty
                              ? 'No layer selected'
                              : 'Selected layer is hidden by filters',
                      child: IconButton(
                        icon: const Icon(Icons.center_focus_strong, size: 20),
                        onPressed:
                            canScrollToSelection
                                ? () => _scrollToLayerIndex(selectedLayerIndex)
                                : null,
                      ),
                    ),
                    if (hiddenLayerCount > 0 ||
                        lockedLayerCount > 0 ||
                        canRestoreVisibility)
                      _LayerRecoveryMenu(
                        hiddenCount: hiddenLayerCount,
                        lockedCount: lockedLayerCount,
                        canRestoreVisibility: canRestoreVisibility,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _LayerTypeFilterMenu(
                        selectedType: _typeFilter,
                        counts: typeCounts,
                        onSelected:
                            (type) => setState(() => _typeFilter = type),
                      ),
                    ),
                    if (hasQuery || hasActiveFilter) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Clear layer filters',
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          onPressed: _clearLayerFilters,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in _LayerFilter.values)
                      _LayerFilterChip(
                        filter: filter,
                        count: _filterCount(
                          filter,
                          filterCountComponents,
                          layoutState.selectedComponentIds,
                          diagnosticSummaries,
                        ),
                        selected: _filter == filter,
                        onSelected: () => setState(() => _filter = filter),
                      ),
                  ],
                ),
                if (hasQuery || hasActiveFilter) ...[
                  const SizedBox(height: 8),
                  ActiveFilterBar(
                    tokens: [
                      if (_query.isNotEmpty)
                        ActiveFilterToken(
                          icon: Icons.search,
                          label: 'Search "$_query"',
                          clearTooltip: 'Clear search filter',
                          onClear: _clearLayerSearch,
                        ),
                      if (_typeFilter != null)
                        ActiveFilterToken(
                          icon: _typeFilter!.icon,
                          label: 'Type ${_typeFilter!.label}',
                          clearTooltip: 'Clear type filter',
                          onClear: () => setState(() => _typeFilter = null),
                        ),
                      if (_filter != _LayerFilter.all)
                        ActiveFilterToken(
                          icon: _layerFilterIcon(_filter),
                          label: 'Filter ${_layerFilterLabel(_filter)}',
                          clearTooltip: 'Clear state filter',
                          onClear:
                              () => setState(() => _filter = _LayerFilter.all),
                        ),
                    ],
                    onClearAll: _clearLayerFilters,
                  ),
                ],
                if (showBulkActions) ...[
                  const SizedBox(height: 8),
                  _ShownLayerActions(
                    componentIds:
                        filteredComponents
                            .map((component) => component.id)
                            .toSet(),
                  ),
                ],
              ],
            ],
          ),
        ),
        Expanded(
          child:
              components.isEmpty
                  ? const Center(child: Text('No layers yet'))
                  : filteredComponents.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FilteredEmptyState(
                        title: 'No layers found',
                        onAction:
                            hasQuery || hasActiveFilter
                                ? _clearLayerFilters
                                : null,
                      ),
                    ),
                  )
                  : !canReorder
                  ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: filteredComponents.length,
                    itemBuilder: (context, index) {
                      final component = filteredComponents[index];

                      return _LayerTile(
                        key: ValueKey(component.id),
                        component: component,
                        index: index,
                        currentDevice: currentDevice,
                        isSelected: layoutState.selectedComponentIds.contains(
                          component.id,
                        ),
                        diagnosticSummary: diagnosticSummaries[component.id],
                        canReorder: false,
                        onSelect:
                            () => _selectLayerFromPanel(
                              component,
                              filteredComponents,
                            ),
                        onToggleSelection:
                            () => _toggleLayerFromPanel(
                              component,
                              filteredComponents,
                            ),
                      );
                    },
                  )
                  : ReorderableListView.builder(
                    scrollController: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    buildDefaultDragHandles: false,
                    itemCount: components.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final reordered = [...components];
                      final moved = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, moved);

                      ref
                          .read(layoutStateProvider.notifier)
                          .reorderComponents(
                            reordered.reversed
                                .map((component) => component.id)
                                .toList(),
                          );
                    },
                    itemBuilder: (context, index) {
                      final component = components[index];

                      return _LayerTile(
                        key: ValueKey(component.id),
                        component: component,
                        index: index,
                        currentDevice: currentDevice,
                        isSelected: layoutState.selectedComponentIds.contains(
                          component.id,
                        ),
                        diagnosticSummary: diagnosticSummaries[component.id],
                        onSelect:
                            () => _selectLayerFromPanel(component, components),
                        onToggleSelection:
                            () => _toggleLayerFromPanel(component, components),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  int _selectedLayerIndex(
    List<ComponentData> components,
    String? selectedComponentId,
    Set<String> selectedComponentIds,
  ) {
    if (selectedComponentId != null) {
      final primaryIndex = components.indexWhere(
        (component) => component.id == selectedComponentId,
      );
      if (primaryIndex >= 0) return primaryIndex;
    }

    if (selectedComponentIds.isEmpty) return -1;
    return components.indexWhere(
      (component) => selectedComponentIds.contains(component.id),
    );
  }

  void _scrollToLayerIndex(int index) {
    if (index < 0) return;

    void scroll() {
      if (!_scrollController.hasClients) return;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final targetOffset =
          (index * _estimatedLayerTileExtent).clamp(0.0, maxOffset).toDouble();

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    if (_scrollController.hasClients) {
      scroll();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
    }
  }

  void _selectLayerFromPanel(
    ComponentData component,
    List<ComponentData> displayedComponents,
  ) {
    if (_isRangeSelectionPressed()) {
      _selectLayerRange(component, displayedComponents, addToExisting: false);
      return;
    }

    ref.read(layoutStateProvider.notifier).selectComponent(component.id);
    _selectionAnchorId = component.id;
  }

  void _toggleLayerFromPanel(
    ComponentData component,
    List<ComponentData> displayedComponents,
  ) {
    if (_isRangeSelectionPressed()) {
      _selectLayerRange(component, displayedComponents, addToExisting: true);
      return;
    }

    ref
        .read(layoutStateProvider.notifier)
        .toggleComponentSelection(component.id);
    _selectionAnchorId = component.id;
  }

  void _selectLayerRange(
    ComponentData component,
    List<ComponentData> displayedComponents, {
    required bool addToExisting,
  }) {
    final anchorId = _selectionAnchorId;
    final anchorIndex =
        anchorId == null
            ? -1
            : displayedComponents.indexWhere(
              (component) => component.id == anchorId,
            );
    final targetIndex = displayedComponents.indexWhere(
      (item) => item.id == component.id,
    );
    if (anchorIndex < 0 || targetIndex < 0) {
      ref.read(layoutStateProvider.notifier).selectComponent(component.id);
      _selectionAnchorId = component.id;
      return;
    }

    final start = anchorIndex < targetIndex ? anchorIndex : targetIndex;
    final end = anchorIndex > targetIndex ? anchorIndex : targetIndex;
    final ids =
        displayedComponents
            .sublist(start, end + 1)
            .map((component) => component.id)
            .toSet();

    ref
        .read(layoutStateProvider.notifier)
        .selectComponents(ids, addToExisting: addToExisting);
  }

  bool _isRangeSelectionPressed() {
    final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
    return pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.shiftRight);
  }

  bool _matchesLayer(
    ComponentData component,
    Set<String> selectedIds,
    Map<String, LayoutComponentDiagnosticSummary> diagnosticSummaries,
  ) {
    final typeFilter = _typeFilter;
    if (typeFilter != null && component.type != typeFilter) return false;
    if (!_matchesFilter(component, selectedIds, diagnosticSummaries)) {
      return false;
    }

    final normalizedQuery = _query.toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    final diagnosticSummary = diagnosticSummaries[component.id];

    final searchableValues = [
      component.id,
      component.type.key,
      component.type.name,
      component.type.label,
      _layerName(component),
      if (component.properties.parentId != null) 'group grouped',
      if (component.properties.parentId != null) component.properties.parentId!,
      if (component.responsiveProperties.isNotEmpty) 'responsive',
      if (diagnosticSummary?.hasIssues ?? false) 'issues',
      if (diagnosticSummary?.hasWarnings ?? false) 'warnings',
      ...?diagnosticSummary?.diagnosticTitles,
      ...component.responsiveProperties.keys,
      ...component.properties.attributes.values.map((value) => '$value'),
      ...component.properties.events.keys,
      ...component.properties.events.values,
    ];

    return searchableValues.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  bool _matchesFilter(
    ComponentData component,
    Set<String> selectedIds,
    Map<String, LayoutComponentDiagnosticSummary> diagnosticSummaries,
  ) {
    switch (_filter) {
      case _LayerFilter.all:
        return true;
      case _LayerFilter.issues:
        return diagnosticSummaries[component.id]?.hasIssues ?? false;
      case _LayerFilter.hidden:
        return !component.isVisible;
      case _LayerFilter.locked:
        return component.isLocked;
      case _LayerFilter.events:
        return component.properties.events.isNotEmpty;
      case _LayerFilter.responsive:
        return component.responsiveProperties.isNotEmpty;
      case _LayerFilter.grouped:
        return component.properties.parentId != null;
      case _LayerFilter.selected:
        return selectedIds.contains(component.id);
    }
  }

  int _filterCount(
    _LayerFilter filter,
    List<ComponentData> components,
    Set<String> selectedIds,
    Map<String, LayoutComponentDiagnosticSummary> diagnosticSummaries,
  ) {
    switch (filter) {
      case _LayerFilter.all:
        return components.length;
      case _LayerFilter.issues:
        return components
            .where(
              (component) =>
                  diagnosticSummaries[component.id]?.hasIssues ?? false,
            )
            .length;
      case _LayerFilter.hidden:
        return components.where((component) => !component.isVisible).length;
      case _LayerFilter.locked:
        return components.where((component) => component.isLocked).length;
      case _LayerFilter.events:
        return components
            .where((component) => component.properties.events.isNotEmpty)
            .length;
      case _LayerFilter.responsive:
        return components
            .where((component) => component.responsiveProperties.isNotEmpty)
            .length;
      case _LayerFilter.grouped:
        return components
            .where((component) => component.properties.parentId != null)
            .length;
      case _LayerFilter.selected:
        return components
            .where((component) => selectedIds.contains(component.id))
            .length;
    }
  }

  Map<ComponentType, int> _componentTypeCounts(List<ComponentData> components) {
    final counts = <ComponentType, int>{};
    for (final component in components) {
      counts.update(component.type, (count) => count + 1, ifAbsent: () => 1);
    }

    return counts;
  }

  void _clearLayerSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearLayerFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = _LayerFilter.all;
      _typeFilter = null;
    });
  }
}

class _LayerSummaryStrip extends StatelessWidget {
  final List<ComponentData> components;
  final Set<String> selectedIds;
  final Map<String, LayoutComponentDiagnosticSummary> diagnosticSummaries;

  const _LayerSummaryStrip({
    required this.components,
    required this.selectedIds,
    required this.diagnosticSummaries,
  });

  @override
  Widget build(BuildContext context) {
    final hiddenCount =
        components.where((component) => !component.isVisible).length;
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final eventCount =
        components
            .where((component) => component.properties.events.isNotEmpty)
            .length;
    final responsiveCount =
        components
            .where((component) => component.responsiveProperties.isNotEmpty)
            .length;
    final groupedCount =
        components
            .where((component) => component.properties.parentId != null)
            .length;
    final selectedCount =
        components
            .where((component) => selectedIds.contains(component.id))
            .length;
    final issueCount =
        components
            .where(
              (component) =>
                  diagnosticSummaries[component.id]?.hasIssues ?? false,
            )
            .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _LayerSummaryPill(
            icon: Icons.layers_outlined,
            label: 'Total',
            count: components.length,
          ),
          _LayerSummaryPill(
            icon: Icons.report_problem_outlined,
            label: 'Issues',
            count: issueCount,
            emphasized: issueCount > 0,
          ),
          _LayerSummaryPill(
            icon: Icons.visibility_off_outlined,
            label: 'Hidden',
            count: hiddenCount,
          ),
          _LayerSummaryPill(
            icon: Icons.lock_outline,
            label: 'Locked',
            count: lockedCount,
          ),
          _LayerSummaryPill(
            icon: Icons.bolt_outlined,
            label: 'Events',
            count: eventCount,
          ),
          _LayerSummaryPill(
            icon: Icons.devices_outlined,
            label: 'Responsive',
            count: responsiveCount,
          ),
          _LayerSummaryPill(
            icon: Icons.account_tree_outlined,
            label: 'Grouped',
            count: groupedCount,
          ),
          _LayerSummaryPill(
            icon: Icons.check_circle_outline,
            label: 'Selected',
            count: selectedCount,
          ),
        ],
      ),
    );
  }
}

class _LayerSummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool emphasized;

  const _LayerSummaryPill({
    required this.icon,
    required this.label,
    required this.count,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color:
              emphasized
                  ? colorScheme.errorContainer
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  emphasized
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              '$label $count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    emphasized
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerRecoveryMenu extends ConsumerWidget {
  final int hiddenCount;
  final int lockedCount;
  final bool canRestoreVisibility;

  const _LayerRecoveryMenu({
    required this.hiddenCount,
    required this.lockedCount,
    required this.canRestoreVisibility,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_LayerRecoveryAction>(
      tooltip: 'Layer recovery',
      icon: const Icon(Icons.restore),
      onSelected: (action) {
        final notifier = ref.read(layoutStateProvider.notifier);
        switch (action) {
          case _LayerRecoveryAction.restoreVisibility:
            notifier.restoreVisibilitySnapshot();
            break;
          case _LayerRecoveryAction.showAll:
            notifier.showAllComponents();
            break;
          case _LayerRecoveryAction.unlockAll:
            notifier.unlockAllComponents();
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              enabled: canRestoreVisibility,
              value: _LayerRecoveryAction.restoreVisibility,
              child: const _ShownLayerActionItem(
                icon: Icons.restore_outlined,
                label: 'Restore previous visibility',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: hiddenCount > 0,
              value: _LayerRecoveryAction.showAll,
              child: _ShownLayerActionItem(
                icon: Icons.visibility_outlined,
                label: 'Show all hidden ($hiddenCount)',
              ),
            ),
            PopupMenuItem(
              enabled: lockedCount > 0,
              value: _LayerRecoveryAction.unlockAll,
              child: _ShownLayerActionItem(
                icon: Icons.lock_open_outlined,
                label: 'Unlock all locked ($lockedCount)',
              ),
            ),
          ],
    );
  }
}

enum _LayerRecoveryAction { restoreVisibility, showAll, unlockAll }

class _LayerTypeFilterMenu extends StatelessWidget {
  final ComponentType? selectedType;
  final Map<ComponentType, int> counts;
  final ValueChanged<ComponentType?> onSelected;

  const _LayerTypeFilterMenu({
    required this.selectedType,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedType = this.selectedType;
    final activeCount =
        selectedType == null
            ? counts.values.fold<int>(0, (total, count) => total + count)
            : counts[selectedType] ?? 0;

    return PopupMenuButton<int>(
      tooltip: 'Filter by component type',
      onSelected:
          (index) => onSelected(index < 0 ? null : ComponentType.values[index]),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: -1,
              child: _LayerTypeMenuItem(
                icon: Icons.layers_outlined,
                label: 'All types',
                count: counts.values.fold<int>(
                  0,
                  (total, count) => total + count,
                ),
              ),
            ),
            const PopupMenuDivider(),
            for (final type in ComponentType.values)
              PopupMenuItem(
                enabled: (counts[type] ?? 0) > 0,
                value: type.index,
                child: _LayerTypeMenuItem(
                  icon: type.icon,
                  label: type.label,
                  count: counts[type] ?? 0,
                ),
              ),
          ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              selectedType == null
                  ? colorScheme.surface
                  : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                selectedType == null
                    ? colorScheme.outlineVariant
                    : colorScheme.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selectedType?.icon ?? Icons.category_outlined,
              size: 18,
              color:
                  selectedType == null
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedType == null ? 'All types' : selectedType.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color:
                      selectedType == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$activeCount',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    selectedType == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color:
                  selectedType == null
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerTypeMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _LayerTypeMenuItem({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text('$count'),
      ],
    );
  }
}

class _ShownLayerActions extends ConsumerWidget {
  final Set<String> componentIds;

  const _ShownLayerActions({required this.componentIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final viewportNotifier = ref.read(canvasViewportProvider.notifier);
    final selectedShownCount = ref.watch(
      layoutStateProvider.select(
        (state) =>
            componentIds.where(state.selectedComponentIds.contains).length,
      ),
    );
    final visibleShownCount = ref.watch(
      layoutStateProvider.select(
        (state) =>
            state.components
                .where(
                  (component) =>
                      componentIds.contains(component.id) &&
                      component.isVisible,
                )
                .length,
      ),
    );
    final groupedShownCount = ref.watch(
      layoutStateProvider.select(
        (state) =>
            state.components
                .where(
                  (component) =>
                      componentIds.contains(component.id) &&
                      component.properties.parentId != null,
                )
                .length,
      ),
    );
    final renameableShownCount = ref.watch(
      layoutStateProvider.select(
        (state) =>
            state.components
                .where(
                  (component) =>
                      componentIds.contains(component.id) &&
                      !component.isLocked,
                )
                .length,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.select_all_outlined, size: 18),
            label: Text('Select shown (${componentIds.length})'),
            onPressed: () => notifier.selectComponents(componentIds),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<_ShownLayerAction>(
          tooltip: 'Shown layer actions',
          icon: const Icon(Icons.more_horiz),
          onSelected:
              (action) => _applyAction(
                context,
                ref,
                notifier,
                viewportNotifier,
                action,
              ),
          itemBuilder: (context) {
            final errorColor = Theme.of(context).colorScheme.error;
            return [
              PopupMenuItem(
                value: _ShownLayerAction.fitSelection,
                enabled: visibleShownCount > 0,
                child: _ShownLayerActionItem(
                  icon: Icons.center_focus_strong_outlined,
                  label: 'Select and fit shown ($visibleShownCount)',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _ShownLayerAction.invertSelection,
                child: _ShownLayerActionItem(
                  icon: Icons.swap_horiz,
                  label: 'Invert shown selection',
                ),
              ),
              PopupMenuItem(
                value: _ShownLayerAction.deselectSelection,
                enabled: selectedShownCount > 0,
                child: _ShownLayerActionItem(
                  icon: Icons.remove_circle_outline,
                  label: 'Deselect shown ($selectedShownCount)',
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _ShownLayerAction.rename,
                enabled: renameableShownCount > 0,
                child: _ShownLayerActionItem(
                  icon: Icons.drive_file_rename_outline,
                  label: 'Rename shown ($renameableShownCount)',
                ),
              ),
              PopupMenuItem(
                value: _ShownLayerAction.copy,
                child: _ShownLayerActionItem(
                  icon: Icons.copy_outlined,
                  label: 'Copy shown (${componentIds.length})',
                ),
              ),
              PopupMenuItem(
                value: _ShownLayerAction.duplicate,
                child: _ShownLayerActionItem(
                  icon: Icons.content_copy_outlined,
                  label: 'Duplicate shown (${componentIds.length})',
                ),
              ),
              PopupMenuItem(
                value: _ShownLayerAction.group,
                enabled: componentIds.length > 1,
                child: _ShownLayerActionItem(
                  icon: Icons.link,
                  label: 'Group shown (${componentIds.length})',
                ),
              ),
              PopupMenuItem(
                value: _ShownLayerAction.ungroup,
                enabled: groupedShownCount > 0,
                child: _ShownLayerActionItem(
                  icon: Icons.link_off,
                  label: 'Ungroup shown ($groupedShownCount)',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _ShownLayerAction.hide,
                child: _ShownLayerActionItem(
                  icon: Icons.visibility_off_outlined,
                  label: 'Hide shown',
                ),
              ),
              const PopupMenuItem(
                value: _ShownLayerAction.show,
                child: _ShownLayerActionItem(
                  icon: Icons.visibility_outlined,
                  label: 'Show shown',
                ),
              ),
              const PopupMenuItem(
                value: _ShownLayerAction.showOnly,
                child: _ShownLayerActionItem(
                  icon: Icons.filter_alt_outlined,
                  label: 'Show only shown',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _ShownLayerAction.bringToFront,
                child: _ShownLayerActionItem(
                  icon: Icons.flip_to_front,
                  label: 'Bring shown to front',
                ),
              ),
              const PopupMenuItem(
                value: _ShownLayerAction.sendToBack,
                child: _ShownLayerActionItem(
                  icon: Icons.flip_to_back,
                  label: 'Send shown to back',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _ShownLayerAction.lock,
                child: _ShownLayerActionItem(
                  icon: Icons.lock_outline,
                  label: 'Lock shown',
                ),
              ),
              const PopupMenuItem(
                value: _ShownLayerAction.unlock,
                child: _ShownLayerActionItem(
                  icon: Icons.lock_open_outlined,
                  label: 'Unlock shown',
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _ShownLayerAction.delete,
                child: _ShownLayerActionItem(
                  icon: Icons.delete_outline,
                  label: 'Delete shown (${componentIds.length})',
                  color: errorColor,
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  void _applyAction(
    BuildContext context,
    WidgetRef ref,
    LayoutStateNotifier notifier,
    CanvasViewportNotifier viewportNotifier,
    _ShownLayerAction action,
  ) {
    switch (action) {
      case _ShownLayerAction.fitSelection:
        notifier.selectComponents(componentIds);
        viewportNotifier.fitSelection();
        break;
      case _ShownLayerAction.invertSelection:
        notifier.invertComponentsSelection(componentIds);
        break;
      case _ShownLayerAction.deselectSelection:
        notifier.deselectComponents(componentIds);
        break;
      case _ShownLayerAction.rename:
        _showBatchRenameShownDialog(context, ref, componentIds);
        break;
      case _ShownLayerAction.copy:
        notifier.copyComponents(componentIds);
        break;
      case _ShownLayerAction.duplicate:
        notifier.duplicateComponents(componentIds);
        break;
      case _ShownLayerAction.group:
        notifier.groupComponents(componentIds);
        break;
      case _ShownLayerAction.ungroup:
        notifier.ungroupComponents(componentIds);
        break;
      case _ShownLayerAction.hide:
        notifier.setComponentsVisibility(componentIds, false);
        break;
      case _ShownLayerAction.show:
        notifier.setComponentsVisibility(componentIds, true);
        break;
      case _ShownLayerAction.showOnly:
        notifier.showOnlyComponents(componentIds);
        break;
      case _ShownLayerAction.bringToFront:
        notifier.bringComponentsToFront(componentIds);
        break;
      case _ShownLayerAction.sendToBack:
        notifier.sendComponentsToBack(componentIds);
        break;
      case _ShownLayerAction.lock:
        notifier.setComponentsLock(componentIds, true);
        break;
      case _ShownLayerAction.unlock:
        notifier.setComponentsLock(componentIds, false);
        break;
      case _ShownLayerAction.delete:
        notifier.removeComponents(componentIds);
        break;
    }
  }
}

Future<void> _showBatchRenameShownDialog(
  BuildContext context,
  WidgetRef ref,
  Set<String> componentIds,
) {
  final components =
      ref
          .read(layoutStateProvider)
          .components
          .reversed
          .where(
            (component) =>
                componentIds.contains(component.id) && !component.isLocked,
          )
          .toList();
  if (components.isEmpty) return Future.value();

  return showDialog<void>(
    context: context,
    builder:
        (dialogContext) => _BatchRenameShownDialog(
          components: components,
          onApply: (namesById) {
            ref.read(layoutStateProvider.notifier).renameComponents(namesById);
            Navigator.of(dialogContext).pop();
          },
        ),
  );
}

class _BatchRenameShownDialog extends StatefulWidget {
  final List<ComponentData> components;
  final ValueChanged<Map<String, String>> onApply;

  const _BatchRenameShownDialog({
    required this.components,
    required this.onApply,
  });

  @override
  State<_BatchRenameShownDialog> createState() =>
      _BatchRenameShownDialogState();
}

class _BatchRenameShownDialogState extends State<_BatchRenameShownDialog> {
  late final TextEditingController _prefixController;
  late final TextEditingController _baseController;
  late final TextEditingController _suffixController;
  late final TextEditingController _startController;
  late final TextEditingController _digitsController;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController();
    _baseController = TextEditingController(text: _initialBaseName());
    _suffixController = TextEditingController();
    _startController = TextEditingController(text: '1');
    _digitsController = TextEditingController(text: '1');

    for (final controller in [
      _prefixController,
      _baseController,
      _suffixController,
      _startController,
      _digitsController,
    ]) {
      controller.addListener(_refreshPreview);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _prefixController,
      _baseController,
      _suffixController,
      _startController,
      _digitsController,
    ]) {
      controller.removeListener(_refreshPreview);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewNamesById = _previewNamesById();
    final changedNamesById = _changedNamesById(previewNamesById);
    final previewComponents = widget.components.take(5).toList();
    final extraCount = widget.components.length - previewComponents.length;

    return AlertDialog(
      title: Text('Rename shown (${widget.components.length})'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prefixController,
                      decoration: const InputDecoration(
                        labelText: 'Prefix',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _suffixController,
                      decoration: const InputDecoration(
                        labelText: 'Suffix',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _baseController,
                      decoration: const InputDecoration(
                        labelText: 'Base name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: 'Start',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: _digitsController,
                      decoration: const InputDecoration(
                        labelText: 'Digits',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < previewComponents.length; index++)
                _BatchRenamePreviewRow(
                  currentName: _layerName(previewComponents[index]),
                  nextName: previewNamesById[previewComponents[index].id] ?? '',
                ),
              if (extraCount > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+$extraCount more',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              changedNamesById.isEmpty
                  ? null
                  : () => widget.onApply(changedNamesById),
          child: const Text('Rename'),
        ),
      ],
    );
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  String _initialBaseName() {
    final firstType = widget.components.first.type;
    final sameType = widget.components.every(
      (component) => component.type == firstType,
    );

    return sameType ? firstType.label : 'Layer';
  }

  Map<String, String> _previewNamesById() {
    final namesById = <String, String>{};
    for (var index = 0; index < widget.components.length; index++) {
      final component = widget.components[index];
      namesById[component.id] = _nextName(component, index);
    }

    return namesById;
  }

  Map<String, String> _changedNamesById(Map<String, String> previewNamesById) {
    final namesById = <String, String>{};
    for (final component in widget.components) {
      final nextName = previewNamesById[component.id];
      if (nextName != null && nextName != _layerName(component)) {
        namesById[component.id] = nextName;
      }
    }

    return namesById;
  }

  String _nextName(ComponentData component, int index) {
    final prefix = _prefixController.text.trim();
    final base = _baseController.text.trim();
    final suffix = _suffixController.text.trim();
    final startNumber = int.tryParse(_startController.text.trim()) ?? 1;
    final digitCount = int.tryParse(_digitsController.text.trim()) ?? 1;
    final number = startNumber + index;
    final numberLabel =
        digitCount <= 1 ? '$number' : '$number'.padLeft(digitCount, '0');
    final coreName = base.isEmpty ? _layerName(component) : base;

    return [
      if (prefix.isNotEmpty) prefix,
      coreName,
      numberLabel,
      if (suffix.isNotEmpty) suffix,
    ].join(' ');
  }
}

class _BatchRenamePreviewRow extends StatelessWidget {
  final String currentName;
  final String nextName;

  const _BatchRenamePreviewRow({
    required this.currentName,
    required this.nextName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nextName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShownLayerActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ShownLayerActionItem({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: color == null ? null : TextStyle(color: color)),
      ],
    );
  }
}

enum _ShownLayerAction {
  fitSelection,
  invertSelection,
  deselectSelection,
  rename,
  copy,
  duplicate,
  group,
  ungroup,
  hide,
  show,
  showOnly,
  bringToFront,
  sendToBack,
  lock,
  unlock,
  delete,
}

enum _LayerFilter {
  all,
  issues,
  hidden,
  locked,
  events,
  responsive,
  grouped,
  selected,
}

IconData _layerFilterIcon(_LayerFilter filter) {
  switch (filter) {
    case _LayerFilter.all:
      return Icons.layers_outlined;
    case _LayerFilter.issues:
      return Icons.report_problem_outlined;
    case _LayerFilter.hidden:
      return Icons.visibility_off_outlined;
    case _LayerFilter.locked:
      return Icons.lock_outline;
    case _LayerFilter.events:
      return Icons.bolt_outlined;
    case _LayerFilter.responsive:
      return Icons.devices_outlined;
    case _LayerFilter.grouped:
      return Icons.account_tree_outlined;
    case _LayerFilter.selected:
      return Icons.check_circle_outline;
  }
}

String _layerFilterLabel(_LayerFilter filter) {
  switch (filter) {
    case _LayerFilter.all:
      return 'All';
    case _LayerFilter.issues:
      return 'Issues';
    case _LayerFilter.hidden:
      return 'Hidden';
    case _LayerFilter.locked:
      return 'Locked';
    case _LayerFilter.events:
      return 'Events';
    case _LayerFilter.responsive:
      return 'Responsive';
    case _LayerFilter.grouped:
      return 'Grouped';
    case _LayerFilter.selected:
      return 'Selected';
  }
}

class _LayerFilterChip extends StatelessWidget {
  final _LayerFilter filter;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _LayerFilterChip({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(_layerFilterIcon(filter), size: 16),
      label: Text('${_layerFilterLabel(filter)} $count'),
      selected: selected,
      onSelected: (_) => onSelected(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LayerTile extends ConsumerStatefulWidget {
  final ComponentData component;
  final int index;
  final DeviceType currentDevice;
  final bool isSelected;
  final LayoutComponentDiagnosticSummary? diagnosticSummary;
  final bool canReorder;
  final VoidCallback onSelect;
  final VoidCallback onToggleSelection;

  const _LayerTile({
    super.key,
    required this.component,
    required this.index,
    required this.currentDevice,
    required this.isSelected,
    required this.onSelect,
    required this.onToggleSelection,
    this.diagnosticSummary,
    this.canReorder = true,
  });

  @override
  ConsumerState<_LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends ConsumerState<_LayerTile> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  var _isRenaming = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _layerName(widget.component));
    _nameFocusNode = FocusNode(debugLabel: 'Layer name editor');
  }

  @override
  void didUpdateWidget(covariant _LayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isRenaming && oldWidget.component != widget.component) {
      _nameController.text = _layerName(widget.component);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final index = widget.index;
    final currentDevice = widget.currentDevice;
    final isSelected = widget.isSelected;
    final canReorder = widget.canReorder;
    final onSelect = widget.onSelect;
    final onToggleSelection = widget.onToggleSelection;
    final notifier = ref.read(layoutStateProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final diagnosticSummary = widget.diagnosticSummary;
    final groupId = component.properties.parentId;
    final isGrouped = groupId != null;
    final groupMemberCount =
        groupId == null
            ? 0
            : ref.watch(
              layoutStateProvider.select(
                (state) =>
                    state.components
                        .where(
                          (component) =>
                              component.properties.parentId == groupId,
                        )
                        .length,
              ),
            );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onSelect,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (canReorder)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Tooltip(
                      message: 'Reorder layer',
                      child: Icon(Icons.drag_indicator, size: 20),
                    ),
                  )
                else
                  Tooltip(
                    message: 'Clear search and filters to reorder',
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.42,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Tooltip(
                  message:
                      isSelected ? 'Remove from selection' : 'Select layer',
                  child: Checkbox(
                    value: isSelected,
                    visualDensity: VisualDensity.compact,
                    onChanged: (_) => onToggleSelection(),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(component.type.icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isRenaming)
                        TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          autofocus: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _commitRename,
                          onSubmitted: (_) => _commitRename(),
                          onTapOutside: (_) => _commitRename(),
                        )
                      else
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: _startRename,
                          child: Text(
                            _layerName(component),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      Text(
                        '${component.position.dx.round()}, ${component.position.dy.round()} - ${component.size.width.round()}x${component.size.height.round()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (groupId != null) ...[
                        const SizedBox(height: 3),
                        _GroupBadge(
                          groupId: groupId,
                          memberCount: groupMemberCount,
                        ),
                      ],
                      if (component.responsiveProperties.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        _ResponsiveOverrideBadges(
                          overrideKeys: component.responsiveProperties.keys,
                          currentDevice: currentDevice,
                        ),
                      ],
                      if (component.properties.events.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        _EventBadges(events: component.properties.events),
                      ],
                      if (diagnosticSummary != null &&
                          diagnosticSummary.hasIssues) ...[
                        const SizedBox(height: 3),
                        _LayerIssueBadges(summary: diagnosticSummary),
                      ],
                    ],
                  ),
                ),
                _LayerIconButton(
                  icon:
                      component.isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                  tooltip:
                      component.isVisible ? 'Hide component' : 'Show component',
                  selected: component.isVisible,
                  onPressed:
                      () => notifier.toggleComponentVisibility(component.id),
                ),
                _LayerIconButton(
                  icon:
                      component.isLocked
                          ? Icons.lock
                          : Icons.lock_open_outlined,
                  tooltip:
                      component.isLocked
                          ? 'Unlock component'
                          : 'Lock component',
                  selected: component.isLocked,
                  onPressed: () => notifier.toggleComponentLock(component.id),
                ),
                PopupMenuButton<_LayerAction>(
                  tooltip: 'Layer actions',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) => _handleAction(component, action),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: _LayerAction.rename,
                          child: Text('Rename'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.duplicate,
                          child: Text('Duplicate'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.focus,
                          child: Text('Fit Selection'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.selectSameType,
                          child: Text('Select Same Type'),
                        ),
                        PopupMenuItem(
                          value: _LayerAction.showOnlyThis,
                          child: Text(
                            isGrouped
                                ? 'Show Only This Group'
                                : 'Show Only This Layer',
                          ),
                        ),
                        if (isGrouped)
                          const PopupMenuItem(
                            value: _LayerAction.ungroupThisGroup,
                            child: Text('Ungroup This Group'),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: _LayerAction.bringForward,
                          child: Text('Bring Forward'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.bringToFront,
                          child: Text('Bring to Front'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.sendBackward,
                          child: Text('Send Backward'),
                        ),
                        const PopupMenuItem(
                          value: _LayerAction.sendToBack,
                          child: Text('Send to Back'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: _LayerAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAction(ComponentData component, _LayerAction action) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final viewportNotifier = ref.read(canvasViewportProvider.notifier);
    notifier.selectComponent(component.id);

    switch (action) {
      case _LayerAction.rename:
        _startRename();
        break;
      case _LayerAction.duplicate:
        notifier.duplicateSelectedComponent();
        break;
      case _LayerAction.focus:
        viewportNotifier.fitSelection();
        break;
      case _LayerAction.selectSameType:
        notifier.selectComponentsByType(component.type);
        break;
      case _LayerAction.showOnlyThis:
        notifier.showOnlySelectedComponents();
        break;
      case _LayerAction.ungroupThisGroup:
        notifier.ungroupComponents({component.id});
        break;
      case _LayerAction.bringForward:
        notifier.bringForward(component.id);
        break;
      case _LayerAction.bringToFront:
        notifier.bringToFront(component.id);
        break;
      case _LayerAction.sendBackward:
        notifier.sendBackward(component.id);
        break;
      case _LayerAction.sendToBack:
        notifier.sendToBack(component.id);
        break;
      case _LayerAction.delete:
        notifier.removeComponent(component.id);
        break;
    }
  }

  void _startRename() {
    _nameController.text = _layerName(widget.component);
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.text.length,
    );
    setState(() => _isRenaming = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameFocusNode.requestFocus();
    });
  }

  void _commitRename() {
    if (!_isRenaming) return;

    final currentName = _layerName(widget.component);
    final nextName = _nameController.text.trim();
    setState(() => _isRenaming = false);

    if (nextName.isEmpty || nextName == currentName) {
      _nameController.text = currentName;
      return;
    }

    ref
        .read(layoutStateProvider.notifier)
        .renameComponent(widget.component.id, nextName);
  }
}

class _GroupBadge extends StatelessWidget {
  final String groupId;
  final int memberCount;

  const _GroupBadge({required this.groupId, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = memberCount == 1 ? 'Group' : 'Group $memberCount';

    return Tooltip(
      message: 'Group $groupId',
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 11,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveOverrideBadges extends StatelessWidget {
  final Iterable<String> overrideKeys;
  final DeviceType currentDevice;

  const _ResponsiveOverrideBadges({
    required this.overrideKeys,
    required this.currentDevice,
  });

  @override
  Widget build(BuildContext context) {
    final devices =
        overrideKeys
            .map(_deviceFromKey)
            .whereType<DeviceType>()
            .toSet()
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));

    if (devices.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final device in devices)
          _ResponsiveOverrideBadge(
            device: device,
            isCurrent: device == currentDevice,
          ),
      ],
    );
  }
}

class _ResponsiveOverrideBadge extends StatelessWidget {
  final DeviceType device;
  final bool isCurrent;

  const _ResponsiveOverrideBadge({
    required this.device,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        isCurrent ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final foreground =
        isCurrent ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: '${_deviceLabel(device)} override',
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isCurrent ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          _deviceAbbreviation(device),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EventBadges extends StatelessWidget {
  final Map<String, String> events;

  const _EventBadges({required this.events});

  @override
  Widget build(BuildContext context) {
    final entries =
        events.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final entry in entries.take(2))
          _EventBadge(eventName: entry.key, handler: entry.value),
        if (entries.length > 2) _EventCountBadge(count: entries.length - 2),
      ],
    );
  }
}

class _EventBadge extends StatelessWidget {
  final String eventName;
  final String handler;

  const _EventBadge({required this.eventName, required this.handler});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: '$eventName -> $handler',
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 11,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 3),
            Text(
              _eventAbbreviation(eventName),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCountBadge extends StatelessWidget {
  final int count;

  const _EventCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LayerIssueBadges extends StatelessWidget {
  final LayoutComponentDiagnosticSummary summary;

  const _LayerIssueBadges({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (summary.warningCount > 0)
          _LayerIssueBadge(
            icon: Icons.report_problem_outlined,
            label: 'W ${summary.warningCount}',
            tooltip: _issueTooltip(
              '${summary.warningCount} warning issues',
              summary.warningTitles,
            ),
            isWarning: true,
          ),
        if (summary.noteCount > 0)
          _LayerIssueBadge(
            icon: Icons.info_outline,
            label: 'N ${summary.noteCount}',
            tooltip: _issueTooltip(
              '${summary.noteCount} notes',
              summary.noteTitles,
            ),
          ),
      ],
    );
  }
}

String _issueTooltip(String summary, List<String> titles) {
  if (titles.isEmpty) return summary;

  final visibleTitles = titles.take(4).map((title) => '- $title').join('\n');
  final overflow = titles.length > 4 ? '\n+${titles.length - 4} more' : '';

  return '$summary\n$visibleTitles$overflow';
}

class _LayerIssueBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool isWarning;

  const _LayerIssueBadge({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        isWarning ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final foreground =
        isWarning
            ? colorScheme.onErrorContainer
            : colorScheme.onPrimaryContainer;

    return Tooltip(
      message: tooltip,
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _layerName(ComponentData component) {
  final attributes = component.properties.attributes;
  final customName =
      attributes['name'] ?? attributes['label'] ?? attributes['text'];

  if (customName is String && customName.trim().isNotEmpty) {
    return customName.trim();
  }

  return component.type.label;
}

String _eventAbbreviation(String eventName) {
  switch (eventName) {
    case 'onTap':
      return 'Tap';
    case 'onLongPress':
      return 'Long';
    case 'onSubmit':
      return 'Submit';
    case 'onFocus':
      return 'Focus';
    case 'onValueChanged':
      return 'Value';
    default:
      return eventName.replaceFirst(RegExp(r'^on'), '');
  }
}

DeviceType? _deviceFromKey(String key) {
  for (final device in DeviceType.values) {
    if (device.name == key) return device;
  }

  return null;
}

String _deviceLabel(DeviceType device) {
  switch (device) {
    case DeviceType.mobile:
      return 'Mobile';
    case DeviceType.tablet:
      return 'Tablet';
    case DeviceType.desktop:
      return 'Desktop';
    case DeviceType.custom:
      return 'Custom';
  }
}

String _deviceAbbreviation(DeviceType device) {
  switch (device) {
    case DeviceType.mobile:
      return 'M';
    case DeviceType.tablet:
      return 'T';
    case DeviceType.desktop:
      return 'D';
    case DeviceType.custom:
      return 'C';
  }
}

class _LayerIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  const _LayerIconButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: selected ? Theme.of(context).colorScheme.primary : null,
        onPressed: onPressed,
      ),
    );
  }
}

enum _LayerAction {
  rename,
  duplicate,
  focus,
  selectSameType,
  showOnlyThis,
  ungroupThisGroup,
  bringForward,
  bringToFront,
  sendBackward,
  sendToBack,
  delete,
}
