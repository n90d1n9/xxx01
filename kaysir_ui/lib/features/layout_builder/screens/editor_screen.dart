import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/component_preset.dart';
import '../models/grid_setting.dart';
import '../models/layout_config.dart';
import '../models/layout_drag_preview.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/component_preset_provider.dart';
import '../provider/layout_data_binding_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import '../widgets/active_filter_bar.dart';
import '../widgets/auto_grid_occupancy_overlay.dart';
import '../widgets/com_drop_target.dart';
import '../widgets/canvas_viewport.dart';
import '../widgets/component_property_editor.dart';
import '../widgets/editor_shortcuts.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/filtered_empty_state.dart';
import '../widgets/grid_background.dart';
import '../widgets/layout_binding_component_factory.dart';
import '../widgets/layout_data_panel.dart';
import '../widgets/layout_diagnostics_panel.dart';
import '../widgets/layout_drag_preview_overlay.dart';
import '../widgets/layout_preview.dart';
import '../widgets/layer_panel.dart';
import '../widgets/marquee_selection_layer.dart';
import '../widgets/smart_alignment_guides.dart';
import '../widgets/version_history_panel.dart';
import 'component_layer.dart';

const double _paletteDragFeedbackWidth = 236;

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  static const routePath = '/layout-builder';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final previewState = ref.watch(responsivePreviewProvider);
    final viewportState = ref.watch(canvasViewportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Layout Builder')),
      body: Column(
        children: [
          const EditorToolbar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _EditorSidebar(),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    child: ClipRect(
                      child:
                          previewState.isPreviewMode
                              ? const PreviewShortcutScope(
                                child: LayoutPreview(),
                              )
                              : EditorShortcutScope(
                                child: LayoutCanvasViewport(
                                  canvasSize: layoutState.config.canvasSize,
                                  child: ComponentDropTarget(
                                    onHover: (data, position) {
                                      final preview = _layoutDropPreviewForData(
                                        data,
                                        position,
                                        existingComponents:
                                            layoutState.components,
                                        config: layoutState.config,
                                        gridSettings: layoutState.gridSettings,
                                      );
                                      ref
                                          .read(canvasViewportProvider.notifier)
                                          .setLayoutDragPreview(preview);
                                    },
                                    onExit:
                                        () =>
                                            ref
                                                .read(
                                                  canvasViewportProvider
                                                      .notifier,
                                                )
                                                .clearLayoutDragPreview(),
                                    onDrop: (data, position) {
                                      if (data is ComponentType) {
                                        ref
                                            .read(layoutStateProvider.notifier)
                                            .addComponentFromTypeWithDropResolution(
                                              data,
                                              position,
                                            );
                                      }
                                      if (data is ComponentPreset) {
                                        ref
                                            .read(layoutStateProvider.notifier)
                                            .addComponentsFromPresetWithDropResolution(
                                              data.components,
                                              position,
                                            );
                                      }
                                      if (data is _StarterBlock) {
                                        ref
                                            .read(layoutStateProvider.notifier)
                                            .addComponentsWithDropResolution(
                                              data.componentsAt(position),
                                            );
                                      }
                                      if (data is LayoutBindingPreview) {
                                        ref
                                            .read(layoutStateProvider.notifier)
                                            .addComponentWithDropResolution(
                                              createBoundTextLabelFromBinding(
                                                data,
                                                position,
                                              ),
                                            );
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        const GridBackground(),
                                        if (viewportState.showAutoGridOccupancy)
                                          AutoGridOccupancyOverlay(
                                            components: layoutState.components,
                                            config: layoutState.config,
                                            selectedComponentIds:
                                                layoutState
                                                    .selectedComponentIds,
                                            preview:
                                                viewportState.autoGridPreview,
                                          ),
                                        MarqueeSelectionLayer(
                                          components: layoutState.components,
                                        ),
                                        ComponentLayer(
                                          components: layoutState.components,
                                          canvasSize:
                                              layoutState.config.canvasSize,
                                        ),
                                        LayoutDragPreviewOverlay(
                                          preview:
                                              viewportState.layoutDragPreview,
                                        ),
                                        const SmartAlignmentGuides(),
                                        if (layoutState.components.isEmpty)
                                          const IgnorePointer(
                                            child: _EmptyWorkspaceHint(),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
                const ComponentPropertyEditor(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorSidebar extends ConsumerWidget {
  const _EditorSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final issueCount = ref.watch(
      layoutStateProvider.select(
        (state) => layoutDiagnosticIssueCount(
          state.components,
          bindings: bindings,
          layoutConfig: state.config,
        ),
      ),
    );

    return SizedBox(
      width: 260,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        child: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: [
                  const Tab(icon: Icon(Icons.add_box_outlined), text: 'Add'),
                  const Tab(icon: Icon(Icons.layers_outlined), text: 'Layers'),
                  const Tab(
                    icon: Icon(Icons.data_object_outlined),
                    text: 'Data',
                  ),
                  Tab(
                    icon: Icon(Icons.fact_check_outlined),
                    text: issueCount == 0 ? 'Issues' : 'Issues $issueCount',
                  ),
                  const Tab(icon: Icon(Icons.history), text: 'History'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _ComponentPalette(),
                    LayerPanel(),
                    LayoutDataPanel(),
                    LayoutDiagnosticsPanel(),
                    VersionHistoryPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComponentPalette extends ConsumerStatefulWidget {
  const _ComponentPalette();

  @override
  ConsumerState<_ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends ConsumerState<_ComponentPalette> {
  late final TextEditingController _searchController;
  var _query = '';
  var _filter = _PaletteFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final componentCount = ref.watch(
      layoutStateProvider.select((state) => state.components.length),
    );
    final presetsAsync = ref.watch(componentPresetProvider);
    final allPresets = presetsAsync.maybeWhen(
      data: (presets) => presets,
      orElse: () => const <ComponentPreset>[],
    );
    final filteredTypes = ComponentType.values
        .where(_matchesFilter)
        .where(_matchesQuery)
        .toList(growable: false);
    final filteredStarterBlocks = _starterBlocks
        .where(_matchesStarterBlockFilter)
        .where(_matchesStarterBlock)
        .toList(growable: false);
    final filteredPresets = presetsAsync.maybeWhen(
      data:
          (presets) => presets
              .where(_matchesPresetFilter)
              .where(_matchesPreset)
              .toList(growable: false),
      orElse: () => const <ComponentPreset>[],
    );
    final presetCount = presetsAsync.maybeWhen(
      data: (presets) => presets.length,
      orElse: () => 0,
    );
    final showEmptySearch = presetsAsync.maybeWhen(
      data:
          (_) =>
              filteredTypes.isEmpty &&
              filteredStarterBlocks.isEmpty &&
              filteredPresets.isEmpty,
      orElse: () => false,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summaryItems = [
      '${filteredTypes.length} components',
      '${filteredStarterBlocks.length} blocks',
      if (presetCount > 0 || _filter == _PaletteFilter.presets)
        '${filteredPresets.length} presets',
    ];
    final summaryText = summaryItems.join(' - ');
    final hasQuery = _query.isNotEmpty;
    final hasPaletteFilter = _filter != _PaletteFilter.all;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Components', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search components',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                !hasQuery
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear search',
                      onPressed: _clearPaletteSearch,
                    ),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.widgets_outlined, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                summaryText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in _PaletteFilter.values)
              _PaletteFilterChip(
                filter: filter,
                count: _filterCount(filter, allPresets),
                selected: _filter == filter,
                onSelected: () => setState(() => _filter = filter),
              ),
          ],
        ),
        if (hasQuery || hasPaletteFilter) ...[
          const SizedBox(height: 10),
          ActiveFilterBar(
            tokens: [
              if (hasQuery)
                ActiveFilterToken(
                  icon: Icons.search,
                  label: 'Search "$_query"',
                  clearTooltip: 'Clear search filter',
                  onClear: _clearPaletteSearch,
                ),
              if (hasPaletteFilter)
                ActiveFilterToken(
                  icon: _categoryIcon(_filter),
                  label: 'Filter ${_categoryLabel(_filter)}',
                  clearTooltip: 'Clear palette filter',
                  onClear: () => setState(() => _filter = _PaletteFilter.all),
                ),
            ],
            onClearAll: _clearPaletteFilters,
          ),
        ],
        const SizedBox(height: 12),
        if (filteredStarterBlocks.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.view_quilt_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Starter Blocks',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final block in filteredStarterBlocks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Draggable<_StarterBlock>(
                data: block,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: SizedBox(
                  width: _paletteDragFeedbackWidth,
                  child: _StarterBlockTile(block: block, elevated: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.45,
                  child: _StarterBlockTile(block: block),
                ),
                child: _StarterBlockTile(
                  block: block,
                  onTap: () {
                    final offset = 32.0 + (componentCount % 8) * 20;
                    ref
                        .read(layoutStateProvider.notifier)
                        .addComponents(
                          block.componentsAt(Offset(offset, offset)),
                        );
                  },
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
        if (filteredTypes.isNotEmpty && filteredStarterBlocks.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.widgets_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Components', style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        for (final type in filteredTypes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Draggable<ComponentType>(
              data: type,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: SizedBox(
                width: _paletteDragFeedbackWidth,
                child: _PaletteTile(type: type, elevated: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.45,
                child: _PaletteTile(type: type),
              ),
              child: _PaletteTile(
                type: type,
                onTap: () {
                  final offset = 32.0 + (componentCount % 8) * 20;
                  ref
                      .read(layoutStateProvider.notifier)
                      .addComponentFromType(type, Offset(offset, offset));
                },
              ),
            ),
          ),
        ...presetsAsync.when(
          data: (_) {
            if (filteredPresets.isEmpty) return const <Widget>[];

            return [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.bookmarks_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Presets', style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final preset in filteredPresets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Draggable<ComponentPreset>(
                    data: preset,
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: SizedBox(
                      width: _paletteDragFeedbackWidth,
                      child: _PresetTile(preset: preset, elevated: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.45,
                      child: _PresetTile(preset: preset),
                    ),
                    child: _PresetTile(
                      preset: preset,
                      onDelete: () => _deletePreset(context, preset),
                      onTap: () {
                        final offset = 32.0 + (componentCount % 8) * 20;
                        ref
                            .read(layoutStateProvider.notifier)
                            .addComponentsFromPreset(
                              preset.components,
                              Offset(offset, offset),
                            );
                      },
                    ),
                  ),
                ),
            ];
          },
          loading:
              () => const [
                SizedBox(height: 8),
                LinearProgressIndicator(minHeight: 2),
              ],
          error:
              (error, stackTrace) => const [
                SizedBox(height: 8),
                _PresetLoadError(),
              ],
        ),
        if (showEmptySearch)
          FilteredEmptyState(
            title: 'No components found',
            onAction:
                hasQuery || hasPaletteFilter ? _clearPaletteFilters : null,
          ),
      ],
    );
  }

  bool _matchesFilter(ComponentType type) {
    if (_filter == _PaletteFilter.blocks || _filter == _PaletteFilter.presets) {
      return false;
    }
    return _filter == _PaletteFilter.all || _categoryForType(type) == _filter;
  }

  bool _matchesQuery(ComponentType type) {
    final normalizedQuery = _query.toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return type.label.toLowerCase().contains(normalizedQuery) ||
        type.key.toLowerCase().contains(normalizedQuery) ||
        type.name.toLowerCase().contains(normalizedQuery) ||
        _paletteSubtitle(type).toLowerCase().contains(normalizedQuery);
  }

  bool _matchesPresetFilter(ComponentPreset preset) {
    if (_filter == _PaletteFilter.blocks) return false;
    if (_filter == _PaletteFilter.presets) return true;
    return _filter == _PaletteFilter.all ||
        preset.components.any(
          (component) => _categoryForType(component.type) == _filter,
        );
  }

  bool _matchesPreset(ComponentPreset preset) {
    final normalizedQuery = _query.toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchableValues = [
      preset.name,
      preset.description ?? '',
      if (preset.isBlock) 'block',
      for (final component in preset.components) ...[
        component.type.label,
        component.type.key,
        component.type.name,
        _paletteSubtitle(component.type),
        ...component.properties.attributes.values.map((value) => '$value'),
      ],
      _presetSizeLabel(preset),
    ];

    return searchableValues.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  bool _matchesStarterBlockFilter(_StarterBlock block) {
    if (_filter == _PaletteFilter.presets) return false;
    if (_filter == _PaletteFilter.blocks) return true;
    return _filter == _PaletteFilter.all || block.categories.contains(_filter);
  }

  bool _matchesStarterBlock(_StarterBlock block) {
    final normalizedQuery = _query.toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final previewComponents = block.componentsAt(Offset.zero);
    final searchableValues = [
      block.id,
      block.name,
      block.description,
      block.footprintLabel,
      for (final component in previewComponents) ...[
        component.type.label,
        component.type.key,
        component.type.name,
        ...component.properties.attributes.values.map((value) => '$value'),
      ],
    ];

    return searchableValues.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  void _clearPaletteSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearPaletteFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = _PaletteFilter.all;
    });
  }

  int _filterCount(_PaletteFilter filter, List<ComponentPreset> presets) {
    if (filter == _PaletteFilter.blocks) return _starterBlocks.length;
    if (filter == _PaletteFilter.presets) return presets.length;

    final typeCount =
        ComponentType.values
            .where(
              (type) =>
                  filter == _PaletteFilter.all ||
                  _categoryForType(type) == filter,
            )
            .length;
    final presetCount =
        presets
            .where(
              (preset) =>
                  filter == _PaletteFilter.all ||
                  preset.components.any(
                    (component) => _categoryForType(component.type) == filter,
                  ),
            )
            .length;
    final blockCount =
        _starterBlocks
            .where(
              (block) =>
                  filter == _PaletteFilter.all ||
                  block.categories.contains(filter),
            )
            .length;

    return typeCount + presetCount + blockCount;
  }

  Future<void> _deletePreset(
    BuildContext context,
    ComponentPreset preset,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Preset'),
            content: Text('Delete "${preset.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    await ref.read(componentPresetRepositoryProvider).deletePreset(preset.id);
    ref.invalidate(componentPresetProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Preset "${preset.name}" deleted')));
  }
}

enum _PaletteFilter { all, pos, input, content, blocks, presets }

LayoutDragPreview? _layoutDropPreviewForData(
  Object data,
  Offset position, {
  required List<ComponentData> existingComponents,
  required LayoutConfig config,
  required GridSettings gridSettings,
}) {
  final dropComponents = _dropPreviewComponentsForData(data, position);
  if (dropComponents.isEmpty) return null;

  return layoutDropPreviewFor(
    existingComponents: existingComponents,
    dropComponents: dropComponents,
    config: config,
    gridSettings: gridSettings,
  );
}

List<ComponentData> _dropPreviewComponentsForData(
  Object data,
  Offset position,
) {
  if (data is ComponentType) {
    return [
      ComponentData.create(
        id: 'drop-preview-${data.key}',
        type: data,
        position: position,
      ),
    ];
  }

  if (data is ComponentPreset) {
    return _componentsShiftedToPosition(data.components, position);
  }

  if (data is _StarterBlock) {
    return data.componentsAt(position);
  }

  if (data is LayoutBindingPreview) {
    return [createBoundTextLabelFromBinding(data, position)];
  }

  return const <ComponentData>[];
}

List<ComponentData> _componentsShiftedToPosition(
  List<ComponentData> components,
  Offset position,
) {
  if (components.isEmpty) return const <ComponentData>[];

  final bounds = _componentListBounds(components);
  final positionDelta = position - bounds.topLeft;

  return [
    for (var index = 0; index < components.length; index++)
      components[index].copyWith(
        id: 'drop-preview-preset-$index',
        position: components[index].position + positionDelta,
        isLocked: false,
        isVisible: true,
      ),
  ];
}

Rect _componentListBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    left = math.min(left, component.position.dx);
    top = math.min(top, component.position.dy);
    right = math.max(right, component.position.dx + component.size.width);
    bottom = math.max(bottom, component.position.dy + component.size.height);
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

class _StarterBlock {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Size size;
  final Set<_PaletteFilter> categories;
  final List<ComponentData> Function(Offset origin) buildComponents;

  const _StarterBlock({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.size,
    required this.categories,
    required this.buildComponents,
  });

  String get footprintLabel => '${size.width.round()}x${size.height.round()}';

  List<ComponentData> componentsAt(Offset origin) => buildComponents(origin);
}

final List<_StarterBlock> _starterBlocks = [
  _StarterBlock(
    id: 'cafe-counter',
    name: 'Cafe Counter',
    description: 'Products, cart, hold actions, and checkout controls.',
    icon: Icons.local_cafe_outlined,
    size: const Size(720, 500),
    categories: const {
      _PaletteFilter.pos,
      _PaletteFilter.input,
      _PaletteFilter.content,
    },
    buildComponents:
        (origin) => [
          _starterComponent(
            type: ComponentType.textLabel,
            origin: origin,
            offset: Offset.zero,
            size: const Size(420, 48),
            attributes: const {
              'text': 'Cafe Counter',
              'fontSize': 22,
              'fontWeight': 700,
            },
          ),
          _starterComponent(
            type: ComponentType.buttonGrid,
            origin: origin,
            offset: const Offset(0, 64),
            size: const Size(420, 300),
            attributes: const {
              'columns': 3,
              'maxProducts': 9,
              'showPrice': true,
            },
          ),
          _starterComponent(
            type: ComponentType.cartPanel,
            origin: origin,
            offset: const Offset(444, 0),
            size: const Size(276, 360),
            attributes: const {'title': 'Current Order'},
          ),
          _starterComponent(
            type: ComponentType.functionPanel,
            origin: origin,
            offset: const Offset(444, 376),
            size: const Size(276, 124),
            attributes: const {
              'actions': ['Pay', 'Discount', 'Void', 'Print'],
              'columns': 2,
              'buttonStyle': 'filled',
              'compact': true,
            },
          ),
          _starterComponent(
            type: ComponentType.customButton,
            origin: origin,
            offset: const Offset(0, 380),
            size: const Size(204, 56),
            attributes: const {'label': 'Hold Order'},
          ),
          _starterComponent(
            type: ComponentType.customButton,
            origin: origin,
            offset: const Offset(216, 380),
            size: const Size(204, 56),
            attributes: const {'label': 'New Customer'},
          ),
        ],
  ),
  _StarterBlock(
    id: 'retail-checkout',
    name: 'Retail Checkout',
    description: 'Dense product grid with basket, numpad, and payment actions.',
    icon: Icons.storefront_outlined,
    size: const Size(760, 520),
    categories: const {
      _PaletteFilter.pos,
      _PaletteFilter.input,
      _PaletteFilter.content,
    },
    buildComponents:
        (origin) => [
          _starterComponent(
            type: ComponentType.textLabel,
            origin: origin,
            offset: Offset.zero,
            size: const Size(392, 44),
            attributes: const {
              'text': 'Retail Checkout',
              'fontSize': 22,
              'fontWeight': 700,
            },
          ),
          _starterComponent(
            type: ComponentType.buttonGrid,
            origin: origin,
            offset: const Offset(0, 56),
            size: const Size(392, 344),
            attributes: const {
              'columns': 4,
              'maxProducts': 16,
              'showPrice': true,
            },
          ),
          _starterComponent(
            type: ComponentType.cartPanel,
            origin: origin,
            offset: const Offset(416, 0),
            size: const Size(344, 330),
            attributes: const {'title': 'Basket', 'compact': true},
          ),
          _starterComponent(
            type: ComponentType.numpad,
            origin: origin,
            offset: const Offset(416, 346),
            size: const Size(212, 174),
            attributes: const {'showDisplay': false, 'buttonStyle': 'tonal'},
          ),
          _starterComponent(
            type: ComponentType.functionPanel,
            origin: origin,
            offset: const Offset(640, 346),
            size: const Size(120, 174),
            attributes: const {
              'actions': ['Pay', 'Cash', 'Card', 'Return'],
              'columns': 1,
              'buttonStyle': 'filled',
              'compact': true,
            },
          ),
          _starterComponent(
            type: ComponentType.customButton,
            origin: origin,
            offset: const Offset(0, 416),
            size: const Size(188, 56),
            attributes: const {'label': 'Scan Item'},
          ),
          _starterComponent(
            type: ComponentType.customButton,
            origin: origin,
            offset: const Offset(204, 416),
            size: const Size(188, 56),
            attributes: const {'label': 'Lookup'},
          ),
        ],
  ),
  _StarterBlock(
    id: 'payment-sidebar',
    name: 'Payment Sidebar',
    description:
        'Stacked order summary, separator, numpad, and tender buttons.',
    icon: Icons.payments_outlined,
    size: const Size(320, 620),
    categories: const {
      _PaletteFilter.pos,
      _PaletteFilter.input,
      _PaletteFilter.content,
    },
    buildComponents:
        (origin) => [
          _starterComponent(
            type: ComponentType.cartPanel,
            origin: origin,
            offset: Offset.zero,
            size: const Size(320, 300),
            attributes: const {'title': 'Order', 'compact': true},
          ),
          _starterComponent(
            type: ComponentType.separator,
            origin: origin,
            offset: const Offset(0, 314),
            size: const Size(320, 28),
            attributes: const {
              'label': 'Payment',
              'dashed': true,
              'thickness': 2,
            },
          ),
          _starterComponent(
            type: ComponentType.numpad,
            origin: origin,
            offset: const Offset(0, 356),
            size: const Size(192, 264),
            attributes: const {
              'displayValue': '{{cart.total}}',
              'buttonStyle': 'tonal',
            },
          ),
          _starterComponent(
            type: ComponentType.functionPanel,
            origin: origin,
            offset: const Offset(204, 356),
            size: const Size(116, 264),
            attributes: const {
              'actions': ['Cash', 'Card', 'Split', 'Void', 'Receipt'],
              'columns': 1,
              'buttonStyle': 'filled',
              'compact': true,
            },
          ),
        ],
  ),
  _StarterBlock(
    id: 'kiosk-menu',
    name: 'Kiosk Menu',
    description: 'Hero visual, specials grid, compact cart, and start button.',
    icon: Icons.touch_app_outlined,
    size: const Size(620, 500),
    categories: const {_PaletteFilter.pos, _PaletteFilter.content},
    buildComponents:
        (origin) => [
          _starterComponent(
            type: ComponentType.imageHolder,
            origin: origin,
            offset: Offset.zero,
            size: const Size(620, 160),
            attributes: const {'showPlaceholder': true},
          ),
          _starterComponent(
            type: ComponentType.textLabel,
            origin: origin,
            offset: const Offset(24, 176),
            size: const Size(280, 44),
            attributes: const {
              'text': 'Today Specials',
              'fontSize': 22,
              'fontWeight': 700,
            },
          ),
          _starterComponent(
            type: ComponentType.buttonGrid,
            origin: origin,
            offset: const Offset(24, 236),
            size: const Size(372, 264),
            attributes: const {
              'columns': 3,
              'maxProducts': 6,
              'showPrice': true,
            },
          ),
          _starterComponent(
            type: ComponentType.cartPanel,
            origin: origin,
            offset: const Offset(412, 176),
            size: const Size(208, 244),
            attributes: const {'title': 'Selection', 'compact': true},
          ),
          _starterComponent(
            type: ComponentType.customButton,
            origin: origin,
            offset: const Offset(412, 436),
            size: const Size(208, 64),
            attributes: const {'label': 'Start Order'},
          ),
        ],
  ),
];

ComponentData _starterComponent({
  required ComponentType type,
  required Offset origin,
  required Offset offset,
  Size? size,
  Map<String, dynamic> attributes = const {},
  ComponentStyle? style,
}) {
  final component = ComponentData.create(
    type: type,
    position: origin + offset,
    size: size,
  );

  return component.copyWith(
    style: style ?? component.style,
    properties: component.properties.copyWith(
      attributes: {...component.properties.attributes, ...attributes},
    ),
  );
}

class _PaletteFilterChip extends StatelessWidget {
  final _PaletteFilter filter;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _PaletteFilterChip({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(_categoryIcon(filter), size: 16),
      label: Text('${_categoryLabel(filter)} $count'),
      selected: selected,
      onSelected: (_) => onSelected(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

_PaletteFilter _categoryForType(ComponentType type) {
  switch (type) {
    case ComponentType.buttonGrid:
    case ComponentType.cartPanel:
    case ComponentType.functionPanel:
    case ComponentType.customButton:
      return _PaletteFilter.pos;
    case ComponentType.numpad:
      return _PaletteFilter.input;
    case ComponentType.textLabel:
    case ComponentType.imageHolder:
    case ComponentType.separator:
      return _PaletteFilter.content;
  }
}

IconData _categoryIcon(_PaletteFilter filter) {
  switch (filter) {
    case _PaletteFilter.all:
      return Icons.widgets_outlined;
    case _PaletteFilter.pos:
      return Icons.point_of_sale_outlined;
    case _PaletteFilter.input:
      return Icons.pin_outlined;
    case _PaletteFilter.content:
      return Icons.dashboard_customize_outlined;
    case _PaletteFilter.blocks:
      return Icons.view_quilt_outlined;
    case _PaletteFilter.presets:
      return Icons.bookmarks_outlined;
  }
}

String _categoryLabel(_PaletteFilter filter) {
  switch (filter) {
    case _PaletteFilter.all:
      return 'All';
    case _PaletteFilter.pos:
      return 'POS';
    case _PaletteFilter.input:
      return 'Input';
    case _PaletteFilter.content:
      return 'Content';
    case _PaletteFilter.blocks:
      return 'Blocks';
    case _PaletteFilter.presets:
      return 'Presets';
  }
}

String _paletteSubtitle(ComponentType type) {
  switch (type) {
    case ComponentType.buttonGrid:
      return 'POS products';
    case ComponentType.cartPanel:
      return 'Order summary';
    case ComponentType.numpad:
      return 'Numeric input';
    case ComponentType.functionPanel:
      return 'Checkout actions';
    case ComponentType.customButton:
      return 'Single action';
    case ComponentType.textLabel:
      return 'Static text';
    case ComponentType.imageHolder:
      return 'Visual block';
    case ComponentType.separator:
      return 'Divider';
  }
}

class _StarterBlockTile extends StatelessWidget {
  final _StarterBlock block;
  final VoidCallback? onTap;
  final bool elevated;

  const _StarterBlockTile({
    required this.block,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final componentCount = block.componentsAt(Offset.zero).length;

    return Material(
      color: colorScheme.surface,
      elevation: elevated ? 4 : 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _StarterBlockPreviewThumbnail(block: block),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(block.icon, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            block.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      block.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _PaletteMetaChip(
                          icon: Icons.view_quilt_outlined,
                          label: 'Block',
                        ),
                        _PaletteMetaChip(
                          icon: Icons.widgets_outlined,
                          label:
                              componentCount == 1
                                  ? '1 part'
                                  : '$componentCount parts',
                        ),
                        _PaletteMetaChip(
                          icon: Icons.aspect_ratio_outlined,
                          label: block.footprintLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarterBlockPreviewThumbnail extends StatelessWidget {
  static const _previewSize = Size(68, 50);

  final _StarterBlock block;

  const _StarterBlockPreviewThumbnail({required this.block});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final components = block.componentsAt(Offset.zero);
    final scaleX = _previewSize.width / block.size.width;
    final scaleY = _previewSize.height / block.size.height;

    return Tooltip(
      message: '${block.name} starter block',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SizedBox.fromSize(
            size: _previewSize,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (final component in components)
                  _StarterBlockPreviewPart(
                    component: component,
                    left: component.position.dx * scaleX,
                    top: component.position.dy * scaleY,
                    width:
                        (component.size.width * scaleX)
                            .clamp(3.0, _previewSize.width)
                            .toDouble(),
                    height:
                        (component.size.height * scaleY)
                            .clamp(3.0, _previewSize.height)
                            .toDouble(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterBlockPreviewPart extends StatelessWidget {
  final ComponentData component;
  final double left;
  final double top;
  final double width;
  final double height;

  const _StarterBlockPreviewPart({
    required this.component,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showIcon = width >= 14 && height >= 14;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _starterPreviewColor(component.type, colorScheme),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child:
            showIcon
                ? Center(
                  child: Icon(
                    component.type.icon,
                    size: height.clamp(10.0, 16.0).toDouble(),
                    color: _starterPreviewIconColor(
                      component.type,
                      colorScheme,
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}

Color _starterPreviewColor(ComponentType type, ColorScheme colorScheme) {
  switch (type) {
    case ComponentType.buttonGrid:
      return colorScheme.primaryContainer;
    case ComponentType.cartPanel:
      return colorScheme.secondaryContainer;
    case ComponentType.numpad:
      return colorScheme.tertiaryContainer;
    case ComponentType.functionPanel:
      return colorScheme.errorContainer;
    case ComponentType.customButton:
      return colorScheme.primary.withValues(alpha: 0.22);
    case ComponentType.textLabel:
      return colorScheme.surface;
    case ComponentType.imageHolder:
      return colorScheme.surfaceContainerHigh;
    case ComponentType.separator:
      return colorScheme.outlineVariant;
  }
}

Color _starterPreviewIconColor(ComponentType type, ColorScheme colorScheme) {
  switch (type) {
    case ComponentType.buttonGrid:
      return colorScheme.onPrimaryContainer;
    case ComponentType.cartPanel:
      return colorScheme.onSecondaryContainer;
    case ComponentType.numpad:
      return colorScheme.onTertiaryContainer;
    case ComponentType.functionPanel:
      return colorScheme.onErrorContainer;
    case ComponentType.customButton:
      return colorScheme.primary;
    case ComponentType.textLabel:
    case ComponentType.imageHolder:
    case ComponentType.separator:
      return colorScheme.onSurfaceVariant;
  }
}

class _PaletteTile extends StatelessWidget {
  final ComponentType type;
  final VoidCallback? onTap;
  final bool elevated;

  const _PaletteTile({required this.type, this.onTap, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewComponent = ComponentData.create(
      type: type,
      position: Offset.zero,
    );

    return Material(
      color: colorScheme.surface,
      elevation: elevated ? 4 : 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _PalettePreviewThumbnail(component: previewComponent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _paletteSubtitle(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _PaletteMetaChip(
                          icon: _categoryIcon(_categoryForType(type)),
                          label: _categoryLabel(_categoryForType(type)),
                        ),
                        _PaletteMetaChip(
                          icon: Icons.aspect_ratio_outlined,
                          label:
                              '${type.defaultSize.width.round()}x${type.defaultSize.height.round()}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final ComponentPreset preset;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool elevated;

  const _PresetTile({
    required this.preset,
    this.onTap,
    this.onDelete,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final components = preset.components
        .map((component) => component.copyWith(isVisible: true))
        .toList(growable: false);
    final component = components.first;
    final typeCount =
        components.map((component) => component.type).toSet().length;
    final eventCount = components.fold<int>(
      0,
      (count, component) => count + component.properties.events.length,
    );
    final responsiveCount = components.fold<int>(
      0,
      (count, component) => count + component.responsiveProperties.length,
    );

    return Material(
      color: colorScheme.surface,
      elevation: elevated ? 4 : 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _PresetPreviewThumbnail(components: components),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _presetSubtitle(preset),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _PaletteMetaChip(
                          icon:
                              preset.isBlock
                                  ? Icons.view_quilt_outlined
                                  : _categoryIcon(
                                    _categoryForType(component.type),
                                  ),
                          label:
                              preset.isBlock
                                  ? '${components.length} layers'
                                  : _categoryLabel(
                                    _categoryForType(component.type),
                                  ),
                        ),
                        _PaletteMetaChip(
                          icon:
                              typeCount == 1
                                  ? component.type.icon
                                  : Icons.category_outlined,
                          label:
                              typeCount == 1 ? component.type.label : 'Mixed',
                        ),
                        _PaletteMetaChip(
                          icon: Icons.aspect_ratio_outlined,
                          label: _presetSizeLabel(preset),
                        ),
                        if (eventCount > 0)
                          _PaletteMetaChip(
                            icon: Icons.bolt_outlined,
                            label:
                                eventCount == 1
                                    ? '1 event'
                                    : '$eventCount events',
                          ),
                        if (responsiveCount > 0)
                          _PaletteMetaChip(
                            icon: Icons.devices_outlined,
                            label:
                                responsiveCount == 1
                                    ? '1 device'
                                    : '$responsiveCount devices',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete preset',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetPreviewThumbnail extends StatelessWidget {
  static const _previewSize = Size(68, 50);

  final List<ComponentData> components;

  const _PresetPreviewThumbnail({required this.components});

  @override
  Widget build(BuildContext context) {
    if (components.length == 1) {
      return _PalettePreviewThumbnail(component: components.first);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final bounds = _presetBounds(components);
    final scaleX = _previewSize.width / bounds.width.clamp(1, double.infinity);
    final scaleY =
        _previewSize.height / bounds.height.clamp(1, double.infinity);
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final width = bounds.width * scale;
    final height = bounds.height * scale;

    return Tooltip(
      message: '${components.length} layer preset',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SizedBox.fromSize(
            size: _previewSize,
            child: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    for (final component in components)
                      Positioned(
                        left: (component.position.dx - bounds.left) * scale,
                        top: (component.position.dy - bounds.top) * scale,
                        width: component.size.width * scale,
                        height: component.size.height * scale,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _starterPreviewColor(
                              component.type,
                              colorScheme,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              component.type.icon,
                              size: (12 * scale).clamp(6, 12).toDouble(),
                              color: _starterPreviewIconColor(
                                component.type,
                                colorScheme,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PalettePreviewThumbnail extends StatelessWidget {
  static const _previewSize = Size(68, 50);

  final ComponentData component;

  const _PalettePreviewThumbnail({required this.component});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final swatchWidth = _previewSize.width * 0.72;
    final swatchHeight = _previewSize.height * 0.62;

    return Tooltip(
      message: '${component.type.label} preview',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SizedBox.fromSize(
            size: _previewSize,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _starterPreviewColor(component.type, colorScheme),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SizedBox(
                  width: swatchWidth,
                  height: swatchHeight,
                  child: Center(
                    child: Icon(
                      component.type.icon,
                      size: 18,
                      color: _starterPreviewIconColor(
                        component.type,
                        colorScheme,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaletteMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetLoadError extends StatelessWidget {
  const _PresetLoadError();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Presets unavailable',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _presetSubtitle(ComponentPreset preset) {
  final description = preset.description;

  if (description != null && description.trim().isNotEmpty) {
    return description.trim();
  }

  if (preset.components.length == 1) {
    return '${preset.component.type.label} - ${_presetSizeLabel(preset)}';
  }

  return '${preset.components.length} components - ${_presetSizeLabel(preset)}';
}

String _presetSizeLabel(ComponentPreset preset) {
  final bounds = _presetBounds(preset.components);
  return '${bounds.width.round()}x${bounds.height.round()}';
}

Rect _presetBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    left = left < component.position.dx ? left : component.position.dx;
    top = top < component.position.dy ? top : component.position.dy;
    right =
        right > component.position.dx + component.size.width
            ? right
            : component.position.dx + component.size.width;
    bottom =
        bottom > component.position.dy + component.size.height
            ? bottom
            : component.position.dy + component.size.height;
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

class _EmptyWorkspaceHint extends StatelessWidget {
  const _EmptyWorkspaceHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Add or drag a component to start',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black45),
      ),
    );
  }
}
