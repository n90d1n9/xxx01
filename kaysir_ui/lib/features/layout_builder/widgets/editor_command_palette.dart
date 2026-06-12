import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/shared_builder_adapter.dart';
import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_state.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_canvas_containment_action_service.dart';
import '../services/layout_canvas_placement_action_service.dart';
import '../services/layout_canvas_size_action_service.dart';
import '../services/layout_canvas_view_action_service.dart';
import '../services/layout_clear_spot_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../utils/layout_clear_spot_labels.dart';
import '../utils/selection_bounds.dart';
import 'active_filter_bar.dart';
import 'device_preview_toggle.dart';
import 'dialog_utils.dart';
import 'filtered_empty_state.dart';
import 'keyboard_shortcuts_dialog.dart';

const _pinnedCommandGroup = 'Pinned';
const _recentCommandGroup = 'Recent';
const _maxRecentCommandCount = 8;

final _pinnedEditorCommandIds = <String>{};
final _recentEditorCommandIds = <String>[];

Future<void> showEditorCommandPalette(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder:
        (context) =>
            _EditorCommandPaletteDialog(launcherContext: context, ref: ref),
  );
}

class _EditorCommandPaletteDialog extends ConsumerStatefulWidget {
  final BuildContext launcherContext;
  final WidgetRef ref;

  const _EditorCommandPaletteDialog({
    required this.launcherContext,
    required this.ref,
  });

  @override
  ConsumerState<_EditorCommandPaletteDialog> createState() =>
      _EditorCommandPaletteDialogState();
}

class _EditorCommandPaletteDialogState
    extends ConsumerState<_EditorCommandPaletteDialog> {
  static const _allCommandGroup = 'All';
  static const _commandRowExtent = 73.0;
  static const _fallbackPageCommandStep = 5;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  List<_EditorCommand> _visibleCommands = const [];
  String _selectedGroup = _allCommandGroup;
  int _highlightedIndex = -1;
  bool _showOnlyAvailable = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(
      debugLabel: 'Layout builder command search',
      onKeyEvent: _handleSearchKeyEvent,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final allCommands = _buildCommands(widget.launcherContext, widget.ref, ref);
    final searchedCommands = allCommands
        .where((command) => command.matches(query))
        .toList(growable: false);
    final matchingCommands =
        _showOnlyAvailable
            ? searchedCommands
                .where((command) => command.enabled)
                .toList(growable: false)
            : searchedCommands;
    final groups = _commandGroups(allCommands, matchingCommands);
    final commands = _commandsForGroup(_selectedGroup, matchingCommands);
    _visibleCommands = commands;
    final highlightedIndex = _effectiveHighlightedIndex(commands);
    final hasQuery = query.trim().isNotEmpty;
    final hasGroupFilter = _selectedGroup != _allCommandGroup;
    final hasActiveFilter = hasQuery || hasGroupFilter || _showOnlyAvailable;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      content: SizedBox(
        width: 540,
        height: 520,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search commands',
                suffixIcon:
                    hasQuery
                        ? IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Clear command search',
                          onPressed: _clearCommandSearch,
                        )
                        : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _handleQueryChanged(),
              onSubmitted: (_) => _runHighlightedCommand(commands),
            ),
            const SizedBox(height: 8),
            _CommandGroupFilters(
              groups: groups,
              selectedGroup: _selectedGroup,
              showOnlyAvailable: _showOnlyAvailable,
              onShowOnlyAvailableChanged: _toggleAvailableFilter,
              onSelected: _selectGroup,
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: 8),
              ActiveFilterBar(
                tokens: [
                  if (hasQuery)
                    ActiveFilterToken(
                      icon: Icons.search,
                      label: 'Search "$query"',
                      clearTooltip: 'Clear command search filter',
                      onClear: _clearCommandSearch,
                    ),
                  if (hasGroupFilter)
                    ActiveFilterToken(
                      icon: _commandGroupIcon(_selectedGroup),
                      label: 'Group $_selectedGroup',
                      clearTooltip: 'Clear command group filter',
                      onClear: _clearCommandGroup,
                    ),
                  if (_showOnlyAvailable)
                    ActiveFilterToken(
                      icon: Icons.offline_bolt_outlined,
                      label: 'Available only',
                      clearTooltip: 'Clear availability filter',
                      onClear: () => _toggleAvailableFilter(false),
                    ),
                ],
                onClearAll: _clearCommandFilters,
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child:
                  commands.isEmpty
                      ? _EmptyCommandState(
                        showOnlyAvailable: _showOnlyAvailable,
                        selectedGroup: _selectedGroup,
                        hasActiveFilters: hasActiveFilter,
                        onClearFilters: _clearCommandFilters,
                        onShowAll:
                            matchingCommands.isEmpty ||
                                    _selectedGroup == _allCommandGroup
                                ? null
                                : () => _selectGroup(_allCommandGroup),
                      )
                      : ListView.separated(
                        controller: _scrollController,
                        itemCount: commands.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final command = commands[index];
                          return _CommandTile(
                            command: command,
                            highlighted: index == highlightedIndex,
                            pinned: _pinnedEditorCommandIds.contains(
                              command.id,
                            ),
                            onHighlight: () => _highlightCommand(index),
                            onTogglePin: () => _togglePinnedCommand(command),
                            onRun: () => _runCommand(command),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _runCommand(_EditorCommand command) {
    if (!command.enabled) return;
    _recordRecentCommand(command);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.launcherContext.mounted) return;
      command.onRun();
    });
  }

  void _togglePinnedCommand(_EditorCommand command) {
    setState(() {
      if (!_pinnedEditorCommandIds.add(command.id)) {
        _pinnedEditorCommandIds.remove(command.id);
      }

      if (_selectedGroup == _pinnedCommandGroup &&
          _pinnedEditorCommandIds.isEmpty) {
        _selectedGroup = _allCommandGroup;
        _highlightedIndex = -1;
      }
    });
  }

  KeyEventResult _handleSearchKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _moveHighlight(1, distance: _visiblePageStep);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _moveHighlight(-1, distance: _visiblePageStep);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _jumpHighlight(toEnd: false);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _jumpHighlight(toEnd: true);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleQueryChanged() {
    setState(() {
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  void _selectGroup(String group) {
    if (_selectedGroup == group) return;
    setState(() {
      _selectedGroup = group;
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  void _toggleAvailableFilter(bool value) {
    if (_showOnlyAvailable == value) return;
    setState(() {
      _showOnlyAvailable = value;
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  void _clearCommandSearch() {
    if (_searchController.text.isEmpty) return;
    _searchController.clear();
    setState(() {
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  void _clearCommandGroup() {
    if (_selectedGroup == _allCommandGroup) return;
    setState(() {
      _selectedGroup = _allCommandGroup;
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  void _clearCommandFilters() {
    _searchController.clear();
    setState(() {
      _selectedGroup = _allCommandGroup;
      _showOnlyAvailable = false;
      _highlightedIndex = -1;
    });
    _scrollListToTop();
  }

  int get _visiblePageStep {
    if (!_scrollController.hasClients) return _fallbackPageCommandStep;
    final visibleRows =
        (_scrollController.position.viewportDimension / _commandRowExtent)
            .floor();
    return visibleRows < 1 ? 1 : visibleRows;
  }

  List<int> get _enabledCommandIndexes {
    return [
      for (var index = 0; index < _visibleCommands.length; index++)
        if (_visibleCommands[index].enabled) index,
    ];
  }

  void _moveHighlight(int direction, {int distance = 1}) {
    final enabledIndexes = _enabledCommandIndexes;
    if (enabledIndexes.isEmpty) return;

    final current = _effectiveHighlightedIndex(_visibleCommands);
    final currentIndex = enabledIndexes.indexOf(current);
    final offset = direction * distance;
    final nextIndex =
        currentIndex == -1
            ? (direction > 0 ? enabledIndexes.first : enabledIndexes.last)
            : enabledIndexes[(currentIndex + offset) % enabledIndexes.length];

    _highlightCommand(nextIndex, scrollIntoView: true);
  }

  void _jumpHighlight({required bool toEnd}) {
    final enabledIndexes = _enabledCommandIndexes;
    if (enabledIndexes.isEmpty) return;

    _highlightCommand(
      toEnd ? enabledIndexes.last : enabledIndexes.first,
      scrollIntoView: true,
    );
  }

  void _highlightCommand(int index, {bool scrollIntoView = false}) {
    if (index < 0 ||
        index >= _visibleCommands.length ||
        !_visibleCommands[index].enabled) {
      return;
    }

    if (_highlightedIndex != index) {
      setState(() {
        _highlightedIndex = index;
      });
    }

    if (scrollIntoView) {
      _scrollHighlightedIntoView(index);
    }
  }

  void _runHighlightedCommand(List<_EditorCommand> commands) {
    final highlightedIndex = _effectiveHighlightedIndex(commands);
    if (highlightedIndex == -1) return;
    _runCommand(commands[highlightedIndex]);
  }

  int _effectiveHighlightedIndex(List<_EditorCommand> commands) {
    if (_highlightedIndex >= 0 &&
        _highlightedIndex < commands.length &&
        commands[_highlightedIndex].enabled) {
      return _highlightedIndex;
    }

    return commands.indexWhere((command) => command.enabled);
  }

  void _scrollHighlightedIntoView(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final position = _scrollController.position;
      final rowTop = index * _commandRowExtent;
      final rowBottom = rowTop + _commandRowExtent;
      final visibleTop = position.pixels;
      final visibleBottom = visibleTop + position.viewportDimension;
      var target = position.pixels;

      if (rowTop < visibleTop) {
        target = rowTop;
      } else if (rowBottom > visibleBottom) {
        target = rowBottom - position.viewportDimension;
      }

      final clampedTarget =
          target
              .clamp(position.minScrollExtent, position.maxScrollExtent)
              .toDouble();
      if ((clampedTarget - position.pixels).abs() < 1) return;

      _scrollController.animateTo(
        clampedTarget,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _scrollListToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
  }
}

class _CommandGroupFilters extends StatelessWidget {
  final List<_CommandGroupFilter> groups;
  final String selectedGroup;
  final bool showOnlyAvailable;
  final ValueChanged<bool> onShowOnlyAvailableChanged;
  final ValueChanged<String> onSelected;

  const _CommandGroupFilters({
    required this.groups,
    required this.selectedGroup,
    required this.showOnlyAvailable,
    required this.onShowOnlyAvailableChanged,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              avatar: const Icon(Icons.offline_bolt_outlined, size: 16),
              label: const Text('Available only'),
              selected: showOnlyAvailable,
              onSelected: onShowOnlyAvailableChanged,
            ),
            const SizedBox(width: 8),
            for (final group in groups) ...[
              ChoiceChip(
                label: Text('${group.name} (${group.count})'),
                selected: selectedGroup == group.name,
                onSelected:
                    group.count == 0 && selectedGroup != group.name
                        ? null
                        : (_) => onSelected(group.name),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _commandGroupIcon(String group) {
  switch (group) {
    case _pinnedCommandGroup:
      return Icons.push_pin_outlined;
    case _recentCommandGroup:
      return Icons.history;
    case 'Command':
      return Icons.manage_search;
    case 'File':
      return Icons.folder_open;
    case 'Edit':
      return Icons.edit_outlined;
    case 'Canvas':
      return Icons.dashboard_customize_outlined;
    case 'View':
      return Icons.visibility_outlined;
    case 'Preview':
      return Icons.preview_outlined;
    case 'Selection':
      return Icons.select_all_outlined;
    case 'Layers':
      return Icons.layers_outlined;
    case 'Layout':
      return Icons.auto_awesome_motion_outlined;
    default:
      return Icons.category_outlined;
  }
}

class _CommandTile extends StatelessWidget {
  final _EditorCommand command;
  final bool highlighted;
  final bool pinned;
  final VoidCallback onHighlight;
  final VoidCallback onTogglePin;
  final VoidCallback onRun;

  const _CommandTile({
    required this.command,
    required this.highlighted,
    required this.pinned,
    required this.onHighlight,
    required this.onTogglePin,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shortcut = command.shortcut;
    final subtitle =
        !command.enabled && command.disabledReason != null
            ? '${command.group} - ${command.disabledReason}'
            : command.detail == null
            ? command.group
            : '${command.group} - ${command.detail}';

    return MouseRegion(
      onEnter: command.enabled ? (_) => onHighlight() : null,
      child: ListTile(
        enabled: command.enabled,
        selected: highlighted && command.enabled,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.42),
        leading: Icon(command.icon),
        title: Text(
          command.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shortcut != null) ...[
              Text(
                shortcut,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Tooltip(
              message: pinned ? 'Unpin command' : 'Pin command',
              child: IconButton(
                icon: Icon(
                  pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: onTogglePin,
              ),
            ),
          ],
        ),
        onTap: command.enabled ? onRun : null,
      ),
    );
  }
}

class _EmptyCommandState extends StatelessWidget {
  final bool showOnlyAvailable;
  final String selectedGroup;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onShowAll;

  const _EmptyCommandState({
    required this.showOnlyAvailable,
    required this.selectedGroup,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasMatchesOutsideGroup = onShowAll != null;
    final title =
        hasMatchesOutsideGroup
            ? showOnlyAvailable
                ? 'No available matches in $selectedGroup'
                : 'No matches in $selectedGroup'
            : showOnlyAvailable
            ? 'No available commands found'
            : 'No commands found';

    return Center(
      child: FilteredEmptyState(
        title: title,
        actionLabel: 'Clear filters',
        onAction: hasActiveFilters ? onClearFilters : null,
      ),
    );
  }
}

List<_EditorCommand> _buildCommands(
  BuildContext launcherContext,
  WidgetRef actionRef,
  WidgetRef ref,
) {
  final layoutState = ref.watch(layoutStateProvider);
  final previewState = ref.watch(responsivePreviewProvider);
  final viewportState = ref.watch(canvasViewportProvider);
  final layoutNotifier = actionRef.read(layoutStateProvider.notifier);
  final previewNotifier = actionRef.read(responsivePreviewProvider.notifier);
  final hasSelection = layoutState.selectedComponents.isNotEmpty;
  final selectedComponent =
      layoutState.selectedComponents.length == 1
          ? layoutState.selectedComponents.single
          : null;
  final hasMultiSelection = layoutState.selectedComponents.length > 1;
  final canResetSelectionDefaultSizes = layoutState.selectedComponents.any(
    (component) =>
        !component.isLocked &&
        !_isSameComponentSize(component.size, component.type.defaultSize),
  );
  final canDistribute = layoutState.selectedComponents.length > 2;
  final hasClipboard = layoutState.clipboard.isNotEmpty;
  final hasComponents = layoutState.components.isNotEmpty;
  final hiddenComponentIds = {
    for (final component in layoutState.components)
      if (!component.isVisible) component.id,
  };
  final lockedComponentIds = {
    for (final component in layoutState.components)
      if (component.isLocked) component.id,
  };
  final groupedComponentIds = {
    for (final component in layoutState.components)
      if (component.properties.parentId != null) component.id,
  };
  final responsiveComponentIds = {
    for (final component in layoutState.components)
      if (component.responsiveProperties.isNotEmpty) component.id,
  };
  final eventComponentIds = {
    for (final component in layoutState.components)
      if (component.properties.events.isNotEmpty) component.id,
  };
  final hiddenComponentCount = hiddenComponentIds.length;
  final lockedComponentCount = lockedComponentIds.length;
  final groupedComponentCount = groupedComponentIds.length;
  final responsiveComponentCount = responsiveComponentIds.length;
  final eventComponentCount = eventComponentIds.length;
  final componentTypeCounts = <ComponentType, int>{};
  for (final component in layoutState.components) {
    componentTypeCounts.update(
      component.type,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  final visibleComponentCount =
      layoutState.components.where((component) => component.isVisible).length;
  final hasVisibleComponents = visibleComponentCount > 0;
  final hasVisibleSelection = layoutState.selectedComponents.any(
    (component) => component.isVisible,
  );
  final hasVisibilitySnapshot = layoutState.visibilitySnapshot != null;
  final hasPinnedCommands = _pinnedEditorCommandIds.isNotEmpty;
  final hasRecentCommands = _recentEditorCommandIds.isNotEmpty;
  final hasRecentPreviewSizes = recentCustomPreviewSizePresets.isNotEmpty;
  final hasRecentCanvasZooms = recentCanvasZoomPresets.isNotEmpty;
  final zoomPercent = _zoomPercentLabel(viewportState.zoom);
  final gridGap = layoutState.gridSettings.gridSize.toDouble();
  final keyboardResizeStep =
      layoutState.gridSettings.snapToGrid ? gridGap : 1.0;
  final keyboardResizeDetail = '${keyboardResizeStep.round()} px step';
  final currentLayoutMechanism = layoutState.config.layoutMechanism;
  final layoutMechanismLabel = currentLayoutMechanism.label;
  final autoGridOccupancyReason =
      currentLayoutMechanism == LayoutMechanism.autoGrid
          ? null
          : 'Switch to Auto Grid first';
  final currentCanvasSize = layoutState.config.canvasSize;
  final rotatedCanvasSize = Size(
    currentCanvasSize.height,
    currentCanvasSize.width,
  );
  String? layoutMechanismReason(LayoutMechanism mechanism) =>
      currentLayoutMechanism == mechanism
          ? 'Already using ${mechanism.label}'
          : null;
  final canZoomIn = viewportState.zoom < CanvasViewportNotifier.maxZoom - 0.001;
  final canZoomOut =
      viewportState.zoom > CanvasViewportNotifier.minZoom + 0.001;
  final canResetZoom = (viewportState.zoom - 1).abs() >= 0.001;
  final selectionReason = hasSelection ? null : 'Select a component first';
  final tabularColumnStep =
      layoutState.config.tabularColumnWidth +
      layoutState.config.tabularColumnGap;
  final tabularRowStep = layoutState.config.tabularRowHeight;
  final autoGridColumnStep =
      layoutState.config.autoGridColumnWidth + layoutState.config.autoGridGap;
  final safeAutoGridRowHeight =
      layoutState.config.autoGridRowHeight < 24.0
          ? 24.0
          : layoutState.config.autoGridRowHeight;
  final autoGridRowStep =
      safeAutoGridRowHeight + layoutState.config.autoGridGap;
  final tabularColumnSpanOptions =
      <int>{1, 2, 3, 4, 6, layoutState.config.tabularColumnCount}
          .where((span) => span <= layoutState.config.tabularColumnCount)
          .toList()
        ..sort();
  final tabularRowSpanOptions = const [1, 2, 3, 4, 6];
  final autoGridColumnSpanOptions =
      <int>{1, 2, 3, 4, 6, layoutState.config.autoGridColumnCount}
          .where((span) => span <= layoutState.config.autoGridColumnCount)
          .toList()
        ..sort();
  final autoGridRowSpanOptions = const [1, 2, 3, 4, 6];
  final tabularSelectionReason =
      !hasSelection
          ? selectionReason
          : currentLayoutMechanism == LayoutMechanism.tabularColumns
          ? null
          : 'Switch to Tabular Columns first';
  final autoGridSelectionReason =
      !hasSelection
          ? selectionReason
          : currentLayoutMechanism == LayoutMechanism.autoGrid
          ? null
          : 'Switch to Auto Grid first';
  final multiSelectionReason =
      hasMultiSelection ? null : 'Select multiple components first';
  final distributeReason =
      canDistribute ? null : 'Select at least 3 components';
  final clipboardReason = hasClipboard ? null : 'Clipboard is empty';
  final componentReason = hasComponents ? null : 'Add a component first';
  final visibleComponentReason =
      hasVisibleComponents ? null : 'Add a visible component first';
  final autoGridVisibleReason =
      !hasVisibleComponents
          ? visibleComponentReason
          : currentLayoutMechanism == LayoutMechanism.autoGrid
          ? null
          : 'Switch to Auto Grid first';
  final autoGridConflictComponentIds =
      currentLayoutMechanism == LayoutMechanism.autoGrid
          ? layoutNotifier.visibleAutoGridConflictComponentIds()
          : const <String>{};
  final autoGridConflictCount = autoGridConflictComponentIds.length;
  final autoGridConflictReason =
      currentLayoutMechanism != LayoutMechanism.autoGrid
          ? 'Switch to Auto Grid first'
          : autoGridConflictCount > 0
          ? null
          : 'No visible Auto Grid conflicts';
  final autoGridMovableVisibleCount =
      layoutState.components
          .where((component) => component.isVisible && !component.isLocked)
          .length;
  final autoGridCompactReason =
      currentLayoutMechanism != LayoutMechanism.autoGrid
          ? 'Switch to Auto Grid first'
          : autoGridMovableVisibleCount > 0
          ? null
          : 'No unlocked visible components';
  final visibleSelectionReason =
      hasVisibleSelection ? null : 'Select a visible component first';
  final hiddenComponentReason =
      hiddenComponentCount > 0 ? null : 'No hidden components';
  final groupedComponentReason =
      groupedComponentCount > 0 ? null : 'No grouped components';
  final responsiveComponentReason =
      responsiveComponentCount > 0
          ? null
          : 'No components with responsive overrides';
  final eventComponentReason =
      eventComponentCount > 0 ? null : 'No components with events';
  final visibilitySnapshotReason =
      hasVisibilitySnapshot ? null : 'No previous visibility snapshot';
  final lockedComponentReason =
      lockedComponentCount > 0 ? null : 'No locked components';
  final pinnedReason = hasPinnedCommands ? null : 'No pinned commands';
  final recentReason = hasRecentCommands ? null : 'No recent commands';
  final recentPreviewSizeReason =
      hasRecentPreviewSizes ? null : 'No recent preview sizes';
  final recentCanvasZoomReason =
      hasRecentCanvasZooms ? null : 'No recent custom zooms';
  final previewReason = previewState.isPreviewMode ? null : 'Preview mode only';
  final resetPositionReason = _resetPositionDisabledReason(selectedComponent);
  final resetSizeReason = _resetSizeDisabledReason(selectedComponent);
  final resetSelectionDefaultSizeReason =
      !hasMultiSelection
          ? multiSelectionReason
          : canResetSelectionDefaultSizes
          ? null
          : 'Selected components already use default sizes or are locked';
  final clearSpotAction = LayoutClearSpotActionState.fromSelection(
    hasSelection: hasSelection,
    preview: layoutNotifier.selectedConflictResolutionPreview(),
  );

  return [
    _EditorCommand(
      commandId: 'command.clear-pinned',
      title: 'Clear pinned commands',
      group: 'Command',
      icon: Icons.push_pin_outlined,
      enabled: hasPinnedCommands,
      disabledReason: pinnedReason,
      detail: '${_pinnedEditorCommandIds.length} pinned',
      keywords: 'pin pinned unpin clear reset manage command palette',
      onRun: _pinnedEditorCommandIds.clear,
    ),
    _EditorCommand(
      commandId: 'command.clear-recent',
      title: 'Clear recent commands',
      group: 'Command',
      icon: Icons.history_toggle_off,
      enabled: hasRecentCommands,
      disabledReason: recentReason,
      detail: '${_recentEditorCommandIds.length} recent',
      keywords: 'recent history clear reset manage command palette',
      onRun: _recentEditorCommandIds.clear,
    ),
    _EditorCommand(
      commandId: 'command.clear-recent-preview-sizes',
      title: 'Clear recent preview sizes',
      group: 'Command',
      icon: Icons.aspect_ratio,
      enabled: hasRecentPreviewSizes,
      disabledReason: recentPreviewSizeReason,
      detail: '${recentCustomPreviewSizePresets.length} sizes',
      keywords:
          'recent custom preview size viewport clear reset manage responsive',
      onRun: clearRecentCustomPreviewSizes,
    ),
    _EditorCommand(
      commandId: 'command.clear-recent-canvas-zooms',
      title: 'Clear recent custom zooms',
      group: 'Command',
      icon: Icons.zoom_out_map,
      enabled: hasRecentCanvasZooms,
      disabledReason: recentCanvasZoomReason,
      detail: '${recentCanvasZoomPresets.length} zooms',
      keywords: 'recent custom zoom clear reset manage canvas view',
      onRun:
          () => layoutCanvasViewActionService.clearRecentZooms(launcherContext),
    ),
    _EditorCommand(
      commandId: 'command.keyboard-shortcuts',
      title: 'Keyboard shortcuts',
      group: 'Command',
      shortcut: 'Ctrl/Cmd+/',
      icon: Icons.keyboard_alt_outlined,
      keywords: 'help shortcut hotkey command reference',
      onRun: () => showKeyboardShortcutsDialog(launcherContext),
    ),
    _EditorCommand(
      title: 'Save layout',
      group: 'File',
      shortcut: 'Ctrl/Cmd+S',
      icon: Icons.save_outlined,
      keywords: 'persist update disk',
      onRun: layoutNotifier.saveLayout,
    ),
    _EditorCommand(
      title: 'Save as template',
      group: 'File',
      icon: Icons.save_as_outlined,
      keywords: 'template preset reusable library block',
      onRun: () {
        showSaveTemplateDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      title: 'Load template',
      group: 'File',
      icon: Icons.folder_open,
      keywords: 'template preset reusable library open',
      onRun: () {
        showLoadTemplateDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      title: 'Export layout JSON',
      group: 'File',
      icon: Icons.file_download_outlined,
      keywords: 'json backup download file share',
      onRun: () {
        showExportLayoutDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      commandId: 'file.copy-shared-builder-snapshot',
      title: 'Copy shared builder snapshot',
      group: 'File',
      icon: Icons.data_object,
      detail: '${layoutState.components.length} components',
      keywords: 'shared builder website bridge schema adapter json copy export',
      onRun: () => _copySharedBuilderSnapshot(launcherContext, layoutState),
    ),
    _EditorCommand(
      title: 'Import layout JSON',
      group: 'File',
      icon: Icons.file_upload_outlined,
      keywords: 'json restore upload file',
      onRun: () {
        showImportLayoutDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      title: 'Undo',
      group: 'Edit',
      shortcut: 'Ctrl/Cmd+Z',
      icon: Icons.undo,
      enabled: layoutState.canUndo,
      disabledReason: layoutState.canUndo ? null : 'No undo step',
      keywords: 'back revert history',
      onRun: layoutNotifier.undo,
    ),
    _EditorCommand(
      title: 'Redo',
      group: 'Edit',
      shortcut: 'Ctrl/Cmd+Y',
      icon: Icons.redo,
      enabled: layoutState.canRedo,
      disabledReason: layoutState.canRedo ? null : 'No redo step',
      keywords: 'forward repeat history',
      onRun: layoutNotifier.redo,
    ),
    _EditorCommand(
      title: 'Toggle grid',
      group: 'Canvas',
      shortcut: 'Alt+G',
      icon: layoutState.gridSettings.enabled ? Icons.grid_on : Icons.grid_off,
      keywords: 'background squares columns overlay',
      onRun: layoutNotifier.toggleGrid,
    ),
    _EditorCommand(
      title: 'Toggle snap',
      group: 'Canvas',
      shortcut: 'Alt+S',
      icon: Icons.grid_4x4,
      keywords: 'magnet snap-to-grid align',
      onRun: layoutNotifier.toggleSnapToGrid,
    ),
    _EditorCommand(
      title: 'Toggle precision guides',
      group: 'Canvas',
      shortcut: 'Alt+P',
      icon: Icons.straighten,
      keywords:
          'measure measurement ruler rulers distance guides spacing overlay',
      onRun:
          () => layoutCanvasViewActionService.togglePrecisionGuides(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title:
          viewportState.showAutoGridOccupancy
              ? 'Hide Auto Grid occupancy overlay'
              : 'Show Auto Grid occupancy overlay',
      group: 'Canvas',
      shortcut: 'Alt+O',
      icon: Icons.dashboard_customize_outlined,
      enabled: autoGridOccupancyReason == null,
      disabledReason: autoGridOccupancyReason,
      keywords:
          'auto grid occupancy occupied cells conflict overlay visibility tracks',
      onRun:
          () => layoutCanvasViewActionService.toggleAutoGridOccupancy(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Layout rules',
      group: 'Canvas',
      icon: Icons.tune,
      keywords: 'grid size opacity subgrid background snap tabular columns',
      onRun: () {
        showGridSettingsDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      title: 'Custom canvas size',
      group: 'Canvas',
      icon: Icons.edit_outlined,
      detail:
          '${currentCanvasSize.width.round()} x ${currentCanvasSize.height.round()}',
      keywords: 'canvas size custom width height dimensions',
      onRun: () {
        showCanvasSizeDialog(launcherContext, actionRef);
      },
    ),
    _EditorCommand(
      title: 'Rotate canvas size',
      group: 'Canvas',
      icon: Icons.screen_rotation,
      detail:
          '${currentCanvasSize.width.round()} x ${currentCanvasSize.height.round()} -> ${rotatedCanvasSize.width.round()} x ${rotatedCanvasSize.height.round()}',
      enabled: !_isSameCanvasSize(currentCanvasSize, rotatedCanvasSize),
      disabledReason:
          _isSameCanvasSize(currentCanvasSize, rotatedCanvasSize)
              ? 'Canvas is already square'
              : null,
      keywords: 'canvas size rotate orientation portrait landscape swap',
      onRun:
          () => layoutCanvasSizeActionService.rotateCanvasSize(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Fit canvas to content',
      group: 'Canvas',
      icon: Icons.fit_screen,
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords: 'canvas size fit content components bounds visible',
      onRun:
          () => layoutCanvasSizeActionService.fitCanvasToContent(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Trim canvas to content',
      group: 'Canvas',
      icon: Icons.crop_free,
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'canvas size trim crop content components bounds visible origin',
      onRun:
          () => layoutCanvasSizeActionService.trimCanvasToContent(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Fit canvas to selection',
      group: 'Canvas',
      icon: Icons.select_all_outlined,
      enabled: hasVisibleSelection,
      disabledReason: visibleSelectionReason,
      keywords: 'canvas size fit selection selected components bounds visible',
      onRun:
          () => layoutCanvasSizeActionService.fitCanvasToSelection(
            launcherContext,
            actionRef,
          ),
    ),
    for (final preset in layoutCanvasSizePresets)
      _EditorCommand(
        commandId: 'canvas.size.${preset.id}',
        title: 'Set canvas to ${preset.label}',
        group: 'Canvas',
        icon: _canvasSizePresetIcon(preset),
        detail: preset.dimensionLabel,
        enabled: !_isSameCanvasSize(currentCanvasSize, preset.size),
        disabledReason:
            _isSameCanvasSize(currentCanvasSize, preset.size)
                ? 'Canvas already ${preset.dimensionLabel}'
                : null,
        keywords:
            'canvas size preset width height ${preset.label.toLowerCase()} ${preset.dimensionLabel}',
        onRun: () => layoutNotifier.updateCanvasSize(preset.size),
      ),
    _EditorCommand(
      title: 'Zoom in',
      group: 'View',
      shortcut: 'Ctrl/Cmd+=',
      icon: Icons.zoom_in,
      enabled: canZoomIn,
      disabledReason: canZoomIn ? null : 'Already at maximum zoom',
      detail: zoomPercent,
      keywords: 'scale magnify enlarge canvas view',
      onRun:
          () =>
              layoutCanvasViewActionService.zoomIn(launcherContext, actionRef),
    ),
    _EditorCommand(
      title: 'Zoom out',
      group: 'View',
      shortcut: 'Ctrl/Cmd+-',
      icon: Icons.zoom_out,
      enabled: canZoomOut,
      disabledReason: canZoomOut ? null : 'Already at minimum zoom',
      detail: zoomPercent,
      keywords: 'scale shrink reduce canvas view',
      onRun:
          () =>
              layoutCanvasViewActionService.zoomOut(launcherContext, actionRef),
    ),
    _EditorCommand(
      title: 'Reset zoom',
      group: 'View',
      shortcut: 'Ctrl/Cmd+0',
      icon: Icons.restart_alt,
      enabled: canResetZoom,
      disabledReason: canResetZoom ? null : 'Zoom is already 100%',
      detail: zoomPercent,
      keywords: 'scale default actual size canvas view',
      onRun:
          () => layoutCanvasViewActionService.resetZoom(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Custom zoom',
      group: 'View',
      icon: Icons.edit_outlined,
      detail: zoomPercent,
      keywords: 'zoom preset scale exact custom percent percentage',
      onRun: () {
        showCanvasZoomDialog(launcherContext, actionRef);
      },
    ),
    for (final preset in layoutCanvasZoomPresets)
      _EditorCommand(
        commandId: 'view.zoom-preset-${(preset * 100).round()}',
        title: 'Set zoom to ${_zoomPercentLabel(preset)}',
        group: 'View',
        icon:
            (viewportState.zoom - preset).abs() < 0.001
                ? Icons.check
                : Icons.zoom_in_map,
        enabled: (viewportState.zoom - preset).abs() >= 0.001,
        disabledReason: 'Already at ${_zoomPercentLabel(preset)}',
        detail: zoomPercent,
        keywords:
            'zoom preset scale exact ${_zoomPercentLabel(preset)} ${(preset * 100).round()} percent',
        onRun:
            () => layoutCanvasViewActionService.setZoom(
              launcherContext,
              actionRef,
              preset,
            ),
      ),
    for (final preset in recentCanvasZoomPresets)
      _EditorCommand(
        commandId: 'view.recent-zoom-preset-${(preset * 100).round()}',
        title: 'Recent ${_zoomPercentLabel(preset)} zoom',
        group: 'View',
        icon:
            (viewportState.zoom - preset).abs() < 0.001
                ? Icons.check
                : Icons.history,
        enabled: (viewportState.zoom - preset).abs() >= 0.001,
        disabledReason: 'Already at ${_zoomPercentLabel(preset)}',
        detail: zoomPercent,
        keywords:
            'recent custom zoom preset scale exact ${_zoomPercentLabel(preset)} ${(preset * 100).round()} percent',
        onRun:
            () => layoutCanvasViewActionService.setZoom(
              launcherContext,
              actionRef,
              preset,
              rememberRecent: true,
            ),
      ),
    _EditorCommand(
      title: 'Fit canvas',
      group: 'View',
      shortcut: 'Ctrl/Cmd+1',
      icon: Icons.fit_screen,
      keywords: 'zoom view focus reset screen',
      onRun:
          () => layoutCanvasViewActionService.fitCanvas(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Fit selection',
      group: 'View',
      shortcut: 'Ctrl/Cmd+2',
      icon: Icons.center_focus_weak,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'zoom selected focus component',
      onRun:
          () => layoutCanvasViewActionService.fitSelection(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      commandId: 'preview.toggle-mode',
      title: previewState.isPreviewMode ? 'Edit canvas' : 'Preview layout',
      group: 'Preview',
      shortcut: 'Alt+R',
      icon:
          previewState.isPreviewMode
              ? Icons.edit_outlined
              : Icons.preview_outlined,
      keywords: 'responsive device simulate canvas',
      onRun: previewNotifier.togglePreviewMode,
    ),
    _EditorCommand(
      title: 'Toggle breakpoints',
      group: 'Preview',
      shortcut: 'Alt+B',
      icon: Icons.splitscreen_outlined,
      enabled: previewState.isPreviewMode,
      disabledReason: previewReason,
      keywords: 'responsive widths guides device',
      onRun: previewNotifier.toggleBreakpoints,
    ),
    _EditorCommand(
      title: 'Desktop preview',
      group: 'Preview',
      shortcut: 'Alt+1',
      icon: Icons.desktop_windows,
      detail: '1200 x 760',
      keywords: 'wide laptop monitor responsive',
      onRun: () => previewNotifier.setDevice(DeviceType.desktop),
    ),
    _EditorCommand(
      title: 'Tablet preview',
      group: 'Preview',
      shortcut: 'Alt+2',
      icon: Icons.tablet,
      detail: '768 x 1024',
      keywords: 'ipad medium responsive',
      onRun: () => previewNotifier.setDevice(DeviceType.tablet),
    ),
    _EditorCommand(
      title: 'Mobile preview',
      group: 'Preview',
      shortcut: 'Alt+3',
      icon: Icons.smartphone,
      detail: '390 x 844',
      keywords: 'phone handset small responsive',
      onRun: () => previewNotifier.setDevice(DeviceType.mobile),
    ),
    _EditorCommand(
      title: 'Custom preview size',
      group: 'Preview',
      icon: Icons.aspect_ratio,
      detail: '${previewState.width.round()} x ${previewState.height.round()}',
      keywords: 'custom responsive viewport width height size breakpoint',
      onRun: () {
        showCustomPreviewSizeDialog(launcherContext, actionRef);
      },
    ),
    for (final preset in builtInCustomPreviewSizePresets)
      _EditorCommand(
        title: '${preset.label} custom preview',
        group: 'Preview',
        icon: preset.icon,
        detail: '${preset.width} x ${preset.height}',
        keywords:
            'custom preset responsive viewport size ${preset.width} ${preset.height} ${preset.label.toLowerCase()}',
        onRun:
            () => previewNotifier.setCustomBreakpoint(
              preset.width.toDouble(),
              preset.height.toDouble(),
            ),
      ),
    for (final preset in recentCustomPreviewSizePresets)
      _EditorCommand(
        commandId: 'preview.recent-custom-${preset.width}x${preset.height}',
        title: 'Recent ${preset.width} x ${preset.height} preview',
        group: 'Preview',
        icon: Icons.history,
        detail: '${preset.width} x ${preset.height}',
        keywords:
            'recent custom preset responsive viewport size ${preset.width} ${preset.height}',
        onRun: () {
          rememberCustomPreviewSize(preset.width, preset.height);
          previewNotifier.setCustomBreakpoint(
            preset.width.toDouble(),
            preset.height.toDouble(),
          );
        },
      ),
    _EditorCommand(
      title: 'Cycle preview device forward',
      group: 'Preview',
      shortcut: 'Alt+Right',
      icon: Icons.arrow_forward,
      keywords: 'next responsive device',
      onRun: () => previewNotifier.cycleDevice(),
    ),
    _EditorCommand(
      title: 'Cycle preview device backward',
      group: 'Preview',
      shortcut: 'Alt+Left',
      icon: Icons.arrow_back,
      keywords: 'previous responsive device',
      onRun: () => previewNotifier.cycleDevice(reverse: true),
    ),
    _EditorCommand(
      title: 'Rotate preview size',
      group: 'Preview',
      icon: Icons.screen_rotation,
      detail: '${previewState.width.round()} x ${previewState.height.round()}',
      keywords:
          'custom orientation swap rotate width height portrait landscape',
      onRun: () {
        rememberRotatedPreviewSize(previewState);
        previewNotifier.rotateCurrentSize();
      },
    ),
    _EditorCommand(
      title: 'Select all components',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+A',
      icon: Icons.select_all_outlined,
      enabled: hasComponents,
      disabledReason: componentReason,
      keywords: 'everything all layers',
      onRun: layoutNotifier.selectAllComponents,
    ),
    _EditorCommand(
      title: 'Select hidden components',
      group: 'Selection',
      icon: Icons.visibility_off_outlined,
      enabled: hiddenComponentCount > 0,
      disabledReason: hiddenComponentReason,
      detail: '$hiddenComponentCount hidden',
      keywords: 'hidden invisible layers filter select',
      onRun: () => layoutNotifier.selectComponents(hiddenComponentIds),
    ),
    _EditorCommand(
      title: 'Select locked components',
      group: 'Selection',
      icon: Icons.lock_outline,
      enabled: lockedComponentCount > 0,
      disabledReason: lockedComponentReason,
      detail: '$lockedComponentCount locked',
      keywords: 'locked protected frozen layers filter select',
      onRun: () => layoutNotifier.selectComponents(lockedComponentIds),
    ),
    _EditorCommand(
      title: 'Select grouped components',
      group: 'Selection',
      icon: Icons.account_tree_outlined,
      enabled: groupedComponentCount > 0,
      disabledReason: groupedComponentReason,
      detail: '$groupedComponentCount grouped',
      keywords: 'group grouped parent layer filter select',
      onRun: () => layoutNotifier.selectComponents(groupedComponentIds),
    ),
    _EditorCommand(
      title: 'Select responsive components',
      group: 'Selection',
      icon: Icons.devices_outlined,
      enabled: responsiveComponentCount > 0,
      disabledReason: responsiveComponentReason,
      detail: '$responsiveComponentCount responsive',
      keywords: 'responsive override device breakpoint layer filter select',
      onRun: () => layoutNotifier.selectComponents(responsiveComponentIds),
    ),
    _EditorCommand(
      title: 'Select event components',
      group: 'Selection',
      icon: Icons.bolt_outlined,
      enabled: eventComponentCount > 0,
      disabledReason: eventComponentReason,
      detail: '$eventComponentCount events',
      keywords: 'event action handler tap submit layer filter select',
      onRun: () => layoutNotifier.selectComponents(eventComponentIds),
    ),
    for (final entry in componentTypeCounts.entries)
      _EditorCommand(
        commandId: 'selection.select-type-${entry.key.key}',
        title: 'Select ${entry.key.label} components',
        group: 'Selection',
        icon: entry.key.icon,
        detail: '${entry.value} layers',
        keywords:
            'type component layer filter select ${entry.key.key} ${entry.key.label.toLowerCase()}',
        onRun: () => layoutNotifier.selectComponentsByType(entry.key),
      ),
    _EditorCommand(
      title: 'Clear selection',
      group: 'Selection',
      shortcut: 'Esc',
      icon: Icons.close,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'deselect escape',
      onRun: layoutNotifier.clearSelection,
    ),
    _EditorCommand(
      title: 'Copy selection',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+C',
      icon: Icons.content_copy,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'clipboard clone',
      onRun: layoutNotifier.copySelectedComponent,
    ),
    _EditorCommand(
      title: 'Save selection as preset',
      group: 'Selection',
      icon: Icons.bookmark_add_outlined,
      detail: '${layoutState.selectedComponents.length} selected',
      enabled: hasVisibleSelection,
      disabledReason: visibleSelectionReason,
      keywords: 'preset reusable component block library save selection',
      onRun:
          () => showSaveSelectionPresetDialog(
            launcherContext,
            actionRef,
            layoutState.selectedComponents
                .where((component) => component.isVisible)
                .toList(growable: false),
          ),
    ),
    _EditorCommand(
      title: 'Copy selection bounds',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+Shift+B',
      icon: Icons.straighten,
      enabled: hasVisibleSelection,
      disabledReason: visibleSelectionReason,
      keywords: 'clipboard geometry x y width height coordinates',
      onRun:
          () => copyLayoutSelectionBounds(
            launcherContext,
            layoutState.selectedComponents,
          ),
    ),
    for (final format in LayoutBoundsCopyFormat.values.where(
      (format) => format != LayoutBoundsCopyFormat.text,
    ))
      _EditorCommand(
        commandId: 'selection.copy-bounds-${format.name}',
        title: 'Copy selection bounds as ${format.label}',
        group: 'Selection',
        icon: _copyBoundsFormatIcon(format),
        enabled: hasVisibleSelection,
        disabledReason: visibleSelectionReason,
        keywords:
            'clipboard geometry x y width height coordinates ${format.label.toLowerCase()}',
        onRun:
            () => copyLayoutSelectionBounds(
              launcherContext,
              layoutState.selectedComponents,
              format: format,
            ),
      ),
    _EditorCommand(
      title: 'Paste',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+V',
      icon: Icons.content_paste,
      enabled: hasClipboard,
      disabledReason: clipboardReason,
      keywords: 'clipboard insert',
      onRun: layoutNotifier.pasteComponent,
    ),
    _EditorCommand(
      title: 'Duplicate selection',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+D',
      icon: Icons.control_point_duplicate,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'copy clone repeat',
      onRun: layoutNotifier.duplicateSelectedComponent,
    ),
    _EditorCommand(
      title: 'Delete selection',
      group: 'Selection',
      shortcut: 'Delete',
      icon: Icons.delete_outline,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'remove trash erase',
      onRun: layoutNotifier.removeSelectedComponent,
    ),
    _EditorCommand(
      title: 'Toggle selection lock',
      group: 'Selection',
      shortcut: 'Alt+L',
      icon: Icons.lock_outline,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'unlock freeze protect move resize',
      onRun: layoutNotifier.toggleSelectedComponentLock,
    ),
    _EditorCommand(
      title: 'Toggle selection visibility',
      group: 'Selection',
      shortcut: 'Alt+V',
      icon: Icons.visibility_outlined,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'hide show eye layer',
      onRun: layoutNotifier.toggleSelectedComponentVisibility,
    ),
    _EditorCommand(
      title: 'Show only selection',
      group: 'Layers',
      icon: Icons.visibility,
      enabled: hasSelection,
      disabledReason: selectionReason,
      detail: '${layoutState.selectedComponents.length} selected',
      keywords: 'isolate focus selection hide others layers visibility',
      onRun: layoutNotifier.showOnlySelectedComponents,
    ),
    _EditorCommand(
      title: 'Show only hidden components',
      group: 'Layers',
      icon: Icons.visibility_off_outlined,
      enabled: hiddenComponentCount > 0,
      disabledReason: hiddenComponentReason,
      detail: '$hiddenComponentCount hidden',
      keywords: 'solo isolate focus hidden invisible layers visibility',
      onRun: () => layoutNotifier.showOnlyComponents(hiddenComponentIds),
    ),
    _EditorCommand(
      title: 'Show only locked components',
      group: 'Layers',
      icon: Icons.lock_outline,
      enabled: lockedComponentCount > 0,
      disabledReason: lockedComponentReason,
      detail: '$lockedComponentCount locked',
      keywords: 'solo isolate focus locked protected layers visibility',
      onRun: () => layoutNotifier.showOnlyComponents(lockedComponentIds),
    ),
    _EditorCommand(
      title: 'Show only grouped components',
      group: 'Layers',
      icon: Icons.account_tree_outlined,
      enabled: groupedComponentCount > 0,
      disabledReason: groupedComponentReason,
      detail: '$groupedComponentCount grouped',
      keywords: 'solo isolate focus grouped parent layers visibility',
      onRun: () => layoutNotifier.showOnlyComponents(groupedComponentIds),
    ),
    _EditorCommand(
      title: 'Show only responsive components',
      group: 'Layers',
      icon: Icons.devices_outlined,
      enabled: responsiveComponentCount > 0,
      disabledReason: responsiveComponentReason,
      detail: '$responsiveComponentCount responsive',
      keywords: 'solo isolate focus responsive override breakpoint visibility',
      onRun: () => layoutNotifier.showOnlyComponents(responsiveComponentIds),
    ),
    _EditorCommand(
      title: 'Show only event components',
      group: 'Layers',
      icon: Icons.bolt_outlined,
      enabled: eventComponentCount > 0,
      disabledReason: eventComponentReason,
      detail: '$eventComponentCount events',
      keywords: 'solo isolate focus event action handler visibility',
      onRun: () => layoutNotifier.showOnlyComponents(eventComponentIds),
    ),
    for (final entry in componentTypeCounts.entries)
      _EditorCommand(
        commandId: 'layers.show-only-type-${entry.key.key}',
        title: 'Show only ${entry.key.label} components',
        group: 'Layers',
        icon: entry.key.icon,
        detail: '${entry.value} layers',
        keywords:
            'solo isolate focus type component layer visibility ${entry.key.key} ${entry.key.label.toLowerCase()}',
        onRun:
            () => layoutNotifier.showOnlyComponents(
              layoutState.components
                  .where((component) => component.type == entry.key)
                  .map((component) => component.id)
                  .toSet(),
            ),
      ),
    _EditorCommand(
      title: 'Restore previous visibility',
      group: 'Layers',
      icon: Icons.restore_outlined,
      enabled: hasVisibilitySnapshot,
      disabledReason: visibilitySnapshotReason,
      detail: 'Undo solo visibility',
      keywords: 'solo isolate restore previous hidden shown layers visibility',
      onRun: layoutNotifier.restoreVisibilitySnapshot,
    ),
    _EditorCommand(
      title: 'Select layer above',
      group: 'Layers',
      shortcut: 'Alt+Up',
      icon: Icons.keyboard_arrow_up,
      enabled: hasComponents,
      disabledReason: componentReason,
      detail: '${layoutState.components.length} layers',
      keywords: 'cycle next layer above front selection',
      onRun: () => layoutNotifier.selectAdjacentLayer(towardFront: true),
    ),
    _EditorCommand(
      title: 'Select layer below',
      group: 'Layers',
      shortcut: 'Alt+Down',
      icon: Icons.keyboard_arrow_down,
      enabled: hasComponents,
      disabledReason: componentReason,
      detail: '${layoutState.components.length} layers',
      keywords: 'cycle previous layer below back selection',
      onRun: () => layoutNotifier.selectAdjacentLayer(towardFront: false),
    ),
    _EditorCommand(
      title: 'Show all components',
      group: 'Layers',
      icon: Icons.visibility_outlined,
      enabled: hiddenComponentCount > 0,
      disabledReason: hiddenComponentReason,
      detail: '$hiddenComponentCount hidden',
      keywords: 'show reveal hidden all layers components visibility',
      onRun: layoutNotifier.showAllComponents,
    ),
    _EditorCommand(
      title: 'Unlock all components',
      group: 'Layers',
      icon: Icons.lock_open_outlined,
      enabled: lockedComponentCount > 0,
      disabledReason: lockedComponentReason,
      detail: '$lockedComponentCount locked',
      keywords: 'unlock all locked layers components edit move resize',
      onRun: layoutNotifier.unlockAllComponents,
    ),
    _EditorCommand(
      title: 'Group selection',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+G',
      icon: Icons.group_work_outlined,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'combine merge wrap',
      onRun: layoutNotifier.groupSelectedComponents,
    ),
    _EditorCommand(
      title: 'Ungroup selection',
      group: 'Selection',
      shortcut: 'Ctrl/Cmd+Shift+G',
      icon: Icons.call_split_outlined,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'split separate unpack',
      onRun: layoutNotifier.ungroupSelectedComponents,
    ),
    _EditorCommand(
      title: 'Use Freeform layout rules',
      group: 'Layout',
      icon: Icons.open_with,
      detail: 'Manual positioning',
      enabled: layoutMechanismReason(LayoutMechanism.freeform) == null,
      disabledReason: layoutMechanismReason(LayoutMechanism.freeform),
      keywords: 'layout mechanism mode freeform manual absolute no grid',
      onRun:
          () => layoutNotifier.updateLayoutMechanism(LayoutMechanism.freeform),
    ),
    _EditorCommand(
      title: 'Use Grid layout rules',
      group: 'Layout',
      icon: Icons.grid_4x4,
      detail: '${gridGap.round()} px grid',
      enabled: layoutMechanismReason(LayoutMechanism.grid) == null,
      disabledReason: layoutMechanismReason(LayoutMechanism.grid),
      keywords: 'layout mechanism mode grid square snap rule',
      onRun: () => layoutNotifier.updateLayoutMechanism(LayoutMechanism.grid),
    ),
    _EditorCommand(
      title: 'Convert visible components to Grid',
      group: 'Layout',
      icon: Icons.auto_fix_high_outlined,
      detail: '$visibleComponentCount visible, ${gridGap.round()} px grid',
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'convert migrate normalize visible components grid layout snap position size',
      onRun: () => layoutNotifier.convertLayoutMechanism(LayoutMechanism.grid),
    ),
    _EditorCommand(
      title: 'Use Auto Grid layout rules',
      group: 'Layout',
      icon: Icons.dashboard_customize_outlined,
      detail:
          '${layoutState.config.autoGridColumnCount} columns, ${layoutState.config.autoGridGap.round()} px gap',
      enabled: layoutMechanismReason(LayoutMechanism.autoGrid) == null,
      disabledReason: layoutMechanismReason(LayoutMechanism.autoGrid),
      keywords: 'layout mechanism mode auto grid cards columns rows snap rule',
      onRun:
          () => layoutNotifier.updateLayoutMechanism(LayoutMechanism.autoGrid),
    ),
    _EditorCommand(
      title: 'Convert visible components to Auto Grid',
      group: 'Layout',
      icon: Icons.auto_fix_high_outlined,
      detail:
          '$visibleComponentCount visible, ${layoutState.config.autoGridColumnCount} columns',
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'convert migrate normalize visible components auto grid layout resolve conflicts snap',
      onRun:
          () => layoutNotifier.convertLayoutMechanism(LayoutMechanism.autoGrid),
    ),
    _EditorCommand(
      title: 'Arrange selection into Auto Grid',
      group: 'Layout',
      icon: Icons.view_module_outlined,
      detail: '${layoutState.config.autoGridColumnCount} columns',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords:
          'auto grid arrange pack selection wrap cards columns rows layout',
      onRun:
          () => layoutAutoGridActionService.arrangeSelection(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to free Auto Grid cells',
      group: 'Layout',
      icon: Icons.auto_fix_high_outlined,
      detail: 'Avoid occupied cells',
      shortcut: 'Alt+F',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords:
          'auto grid free cells collision overlap resolve pack selection layout',
      onRun:
          () => layoutAutoGridActionService.moveSelectionToFreeCells(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Select Auto Grid conflict partners',
      group: 'Layout',
      icon: Icons.manage_search_outlined,
      detail: 'Inspect overlapping components',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords:
          'auto grid conflict partner select inspect overlap collision cells',
      onRun:
          () => layoutAutoGridActionService.selectConflictPartnersForSelection(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Select visible Auto Grid conflicts',
      group: 'Layout',
      icon: Icons.manage_search_outlined,
      detail:
          autoGridConflictCount == 1
              ? '1 component in conflict'
              : '$autoGridConflictCount components in conflict',
      enabled: autoGridConflictReason == null,
      disabledReason: autoGridConflictReason,
      keywords:
          'auto grid select all visible conflicts overlaps collisions inspect cells',
      onRun:
          () => layoutAutoGridActionService.selectVisibleConflicts(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Resolve visible Auto Grid conflicts',
      group: 'Layout',
      icon: Icons.auto_fix_high_outlined,
      shortcut: 'Alt+Shift+F',
      detail:
          autoGridConflictCount == 1
              ? '1 component in conflict'
              : '$autoGridConflictCount components in conflict',
      enabled: autoGridConflictReason == null,
      disabledReason: autoGridConflictReason,
      keywords:
          'auto grid resolve all visible conflicts overlaps collisions free cells cleanup',
      onRun:
          () => layoutAutoGridActionService.resolveVisibleConflicts(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Compact visible Auto Grid',
      group: 'Layout',
      icon: Icons.view_module_outlined,
      shortcut: 'Alt+Shift+C',
      detail:
          autoGridMovableVisibleCount == 1
              ? '1 unlocked visible component'
              : '$autoGridMovableVisibleCount unlocked visible components',
      enabled: autoGridCompactReason == null,
      disabledReason: autoGridCompactReason,
      keywords:
          'auto grid compact pack visible holes gaps close layout locked cleanup',
      onRun:
          () => layoutAutoGridActionService.compactVisible(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Arrange visible components into Auto Grid',
      group: 'Layout',
      icon: Icons.dashboard_customize_outlined,
      detail:
          '$visibleComponentCount visible, ${layoutState.config.autoGridColumnCount} columns',
      enabled: autoGridVisibleReason == null,
      disabledReason: autoGridVisibleReason,
      keywords:
          'auto grid arrange pack visible all components wrap cards columns rows layout',
      onRun: layoutNotifier.arrangeVisibleIntoAutoGrid,
    ),
    ...autoGridColumnSpanOptions.map((span) {
      final isFullSpan = span == layoutState.config.autoGridColumnCount;

      return _EditorCommand(
        title:
            isFullSpan
                ? 'Set selection to full Auto Grid width'
                : 'Set selection to $span Auto Grid columns',
        group: 'Layout',
        icon: Icons.dashboard_customize_outlined,
        detail:
            isFullSpan
                ? '$span columns'
                : '$span of ${layoutState.config.autoGridColumnCount} columns',
        enabled: autoGridSelectionReason == null,
        disabledReason: autoGridSelectionReason,
        keywords: 'auto grid column span width size resize selection card rule',
        onRun: () => layoutNotifier.setSelectedAutoGridColumnSpan(span),
      );
    }),
    ...autoGridRowSpanOptions.map((span) {
      return _EditorCommand(
        title: 'Set selection to $span Auto Grid rows',
        group: 'Layout',
        icon: Icons.table_rows_outlined,
        detail:
            '${(span * safeAutoGridRowHeight + (span - 1) * layoutState.config.autoGridGap).round()} px',
        enabled: autoGridSelectionReason == null,
        disabledReason: autoGridSelectionReason,
        keywords: 'auto grid rows row span height size resize selection rule',
        onRun: () => layoutNotifier.setSelectedAutoGridRowSpan(span),
      );
    }),
    _EditorCommand(
      title: 'Nudge selection one Auto Grid column left',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Left',
      icon: Icons.west,
      detail: '${autoGridColumnStep.round()} px',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords:
          'auto grid columns nudge move left previous column selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByAutoGridColumns(-1),
    ),
    _EditorCommand(
      title: 'Nudge selection one Auto Grid column right',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Right',
      icon: Icons.east,
      detail: '${autoGridColumnStep.round()} px',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords: 'auto grid columns nudge move right next column selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByAutoGridColumns(1),
    ),
    _EditorCommand(
      title: 'Nudge selection one Auto Grid row up',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Up',
      icon: Icons.north,
      detail: '${autoGridRowStep.round()} px',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords: 'auto grid rows nudge move up previous row selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByAutoGridRows(-1),
    ),
    _EditorCommand(
      title: 'Nudge selection one Auto Grid row down',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Down',
      icon: Icons.south,
      detail: '${autoGridRowStep.round()} px',
      enabled: autoGridSelectionReason == null,
      disabledReason: autoGridSelectionReason,
      keywords: 'auto grid rows nudge move down next row selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByAutoGridRows(1),
    ),
    _EditorCommand(
      title: 'Use Tabular Columns layout rules',
      group: 'Layout',
      icon: Icons.view_column_outlined,
      detail: '${layoutState.config.tabularColumnCount} columns',
      enabled: layoutMechanismReason(LayoutMechanism.tabularColumns) == null,
      disabledReason: layoutMechanismReason(LayoutMechanism.tabularColumns),
      keywords: 'layout mechanism mode tabular columns table column rule snap',
      onRun:
          () => layoutNotifier.updateLayoutMechanism(
            LayoutMechanism.tabularColumns,
          ),
    ),
    _EditorCommand(
      title: 'Convert visible components to Tabular Columns',
      group: 'Layout',
      icon: Icons.auto_fix_high_outlined,
      detail:
          '$visibleComponentCount visible, ${layoutState.config.tabularColumnCount} columns',
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'convert migrate normalize visible components tabular columns layout snap position size',
      onRun:
          () => layoutNotifier.convertLayoutMechanism(
            LayoutMechanism.tabularColumns,
          ),
    ),
    ...tabularColumnSpanOptions.map((span) {
      final isFullSpan = span == layoutState.config.tabularColumnCount;

      return _EditorCommand(
        title:
            isFullSpan
                ? 'Set selection to full column span'
                : 'Set selection to $span-column span',
        group: 'Layout',
        icon: Icons.view_column_outlined,
        detail:
            isFullSpan
                ? '$span columns'
                : '$span of ${layoutState.config.tabularColumnCount} columns',
        enabled: tabularSelectionReason == null,
        disabledReason: tabularSelectionReason,
        keywords:
            'tabular columns column span width size resize selection table rule',
        onRun: () => layoutNotifier.setSelectedTabularColumnSpan(span),
      );
    }),
    ...tabularRowSpanOptions.map((span) {
      return _EditorCommand(
        title: 'Set selection to $span-row span',
        group: 'Layout',
        icon: Icons.table_rows_outlined,
        detail: '${(span * layoutState.config.tabularRowHeight).round()} px',
        enabled: tabularSelectionReason == null,
        disabledReason: tabularSelectionReason,
        keywords:
            'tabular rows row span height size resize selection table rule',
        onRun: () => layoutNotifier.setSelectedTabularRowSpan(span),
      );
    }),
    _EditorCommand(
      title: 'Nudge selection one tabular column left',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Left',
      icon: Icons.west,
      detail: '${tabularColumnStep.round()} px',
      enabled: tabularSelectionReason == null,
      disabledReason: tabularSelectionReason,
      keywords:
          'tabular columns nudge move left previous column selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByTabularColumns(-1),
    ),
    _EditorCommand(
      title: 'Nudge selection one tabular column right',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Right',
      icon: Icons.east,
      detail: '${tabularColumnStep.round()} px',
      enabled: tabularSelectionReason == null,
      disabledReason: tabularSelectionReason,
      keywords: 'tabular columns nudge move right next column selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByTabularColumns(1),
    ),
    _EditorCommand(
      title: 'Nudge selection one tabular row up',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Up',
      icon: Icons.north,
      detail: '${tabularRowStep.round()} px',
      enabled: tabularSelectionReason == null,
      disabledReason: tabularSelectionReason,
      keywords: 'tabular rows nudge move up previous row selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByTabularRows(-1),
    ),
    _EditorCommand(
      title: 'Nudge selection one tabular row down',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Alt+Down',
      icon: Icons.south,
      detail: '${tabularRowStep.round()} px',
      enabled: tabularSelectionReason == null,
      disabledReason: tabularSelectionReason,
      keywords: 'tabular rows nudge move down next row selection rule',
      onRun: () => layoutNotifier.nudgeSelectedByTabularRows(1),
    ),
    _EditorCommand(
      title: 'Keep selection inside canvas',
      group: 'Layout',
      shortcut: 'Alt+I',
      icon: Icons.fit_screen,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'bounds contain visible clamp',
      onRun:
          () => layoutCanvasContainmentActionService.moveSelectionInsideCanvas(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Fit selection into canvas',
      group: 'Layout',
      icon: Icons.zoom_out_map,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'fit scale shrink contain center canvas bounds',
      onRun:
          () => layoutCanvasContainmentActionService.fitSelectionInsideCanvas(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to canvas origin',
      group: 'Layout',
      icon: Icons.north_west,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'top left origin zero reset canvas position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToOrigin(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      commandId: 'layout.move-selection-to-clear-spot',
      title: clearSpotAction.menuActionLabel(prefix: 'Move selection to'),
      group: 'Layout',
      shortcut: 'Alt+M',
      icon: Icons.near_me_outlined,
      detail: clearSpotAction.detailLabel,
      enabled: clearSpotAction.isAvailable,
      disabledReason: clearSpotAction.disabledReason,
      keywords:
          'clear spot conflict collision overlap resolve avoid free space layout',
      onRun:
          () => layoutClearSpotActionService.moveSelectionToClearSpot(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Reset component position',
      group: 'Layout',
      icon: Icons.restart_alt,
      detail:
          selectedComponent == null
              ? null
              : '${selectedComponent.position.dx.round()}, ${selectedComponent.position.dy.round()}',
      enabled: resetPositionReason == null,
      disabledReason: resetPositionReason,
      keywords: 'origin zero reset selected component x y position',
      onRun: () {
        final component = selectedComponent;
        if (component == null) return;
        layoutNotifier.updateComponentPosition(component.id, Offset.zero);
      },
    ),
    _EditorCommand(
      title: 'Move selection to top-right corner',
      group: 'Layout',
      icon: Icons.north_east,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'top right corner canvas position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToCorner(
            launcherContext,
            actionRef,
            CanvasCorner.topRight,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to bottom-left corner',
      group: 'Layout',
      icon: Icons.south_west,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'bottom left corner canvas position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToCorner(
            launcherContext,
            actionRef,
            CanvasCorner.bottomLeft,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to bottom-right corner',
      group: 'Layout',
      icon: Icons.south_east,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'bottom right corner canvas position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToCorner(
            launcherContext,
            actionRef,
            CanvasCorner.bottomRight,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to top edge',
      group: 'Layout',
      icon: Icons.north,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'top edge canvas centered position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.top,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to right edge',
      group: 'Layout',
      icon: Icons.east,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'right edge canvas centered position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.right,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to bottom edge',
      group: 'Layout',
      icon: Icons.south,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'bottom edge canvas centered position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.bottom,
          ),
    ),
    _EditorCommand(
      title: 'Move selection to left edge',
      group: 'Layout',
      icon: Icons.west,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'left edge canvas centered position',
      onRun:
          () => layoutCanvasPlacementActionService.moveSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.left,
          ),
    ),
    _EditorCommand(
      title: 'Pin selection to top edge',
      group: 'Layout',
      icon: Icons.north,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'pin top edge canvas preserve x position',
      onRun:
          () => layoutCanvasPlacementActionService.pinSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.top,
          ),
    ),
    _EditorCommand(
      title: 'Pin selection to right edge',
      group: 'Layout',
      icon: Icons.east,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'pin right edge canvas preserve y position',
      onRun:
          () => layoutCanvasPlacementActionService.pinSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.right,
          ),
    ),
    _EditorCommand(
      title: 'Pin selection to bottom edge',
      group: 'Layout',
      icon: Icons.south,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'pin bottom edge canvas preserve x position',
      onRun:
          () => layoutCanvasPlacementActionService.pinSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.bottom,
          ),
    ),
    _EditorCommand(
      title: 'Pin selection to left edge',
      group: 'Layout',
      icon: Icons.west,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'pin left edge canvas preserve y position',
      onRun:
          () => layoutCanvasPlacementActionService.pinSelectionToEdge(
            launcherContext,
            actionRef,
            CanvasEdge.left,
          ),
    ),
    _EditorCommand(
      title: 'Snap selection to layout rules',
      group: 'Layout',
      icon: Icons.grid_4x4,
      detail: layoutMechanismLabel,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords:
          'round align grid tabular columns position coordinates snap tidy',
      onRun:
          () => layoutSelectionGeometryActionService.snapSelectionToLayoutRules(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Snap selection size to layout rules',
      group: 'Layout',
      icon: Icons.aspect_ratio,
      detail: layoutMechanismLabel,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'round align grid tabular columns size width height snap tidy',
      onRun:
          () => layoutSelectionGeometryActionService
              .snapSelectionSizeToLayoutRules(launcherContext, actionRef),
    ),
    _EditorCommand(
      title: 'Snap visible components to layout rules',
      group: 'Layout',
      icon: Icons.grid_on,
      detail: layoutMechanismLabel,
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'round align visible all grid tabular columns position coordinates snap tidy migrate normalize',
      onRun:
          () => layoutSelectionGeometryActionService
              .snapVisibleComponentsToLayoutRules(launcherContext, actionRef),
    ),
    _EditorCommand(
      title: 'Snap visible component sizes to layout rules',
      group: 'Layout',
      icon: Icons.dashboard_customize_outlined,
      detail: layoutMechanismLabel,
      enabled: hasVisibleComponents,
      disabledReason: visibleComponentReason,
      keywords:
          'round align visible all grid tabular columns size width height snap tidy migrate normalize',
      onRun:
          () => layoutSelectionGeometryActionService
              .snapVisibleComponentSizesToLayoutRules(
                launcherContext,
                actionRef,
              ),
    ),
    _EditorCommand(
      title: 'Reset component size',
      group: 'Layout',
      icon: Icons.aspect_ratio,
      detail:
          selectedComponent == null
              ? null
              : '${selectedComponent.size.width.round()} x ${selectedComponent.size.height.round()}',
      enabled: resetSizeReason == null,
      disabledReason: resetSizeReason,
      keywords: 'default reset selected component width height size',
      onRun: () {
        final component = selectedComponent;
        if (component == null) return;
        layoutNotifier.updateComponentSize(
          component.id,
          component.type.defaultSize,
        );
      },
    ),
    _EditorCommand(
      title: 'Reset selection to default sizes',
      group: 'Layout',
      icon: Icons.restart_alt,
      detail: '${layoutState.selectedComponents.length} selected',
      enabled: resetSelectionDefaultSizeReason == null,
      disabledReason: resetSelectionDefaultSizeReason,
      keywords: 'default reset selected components width height sizes',
      onRun: layoutNotifier.resetSelectedComponentsToDefaultSize,
    ),
    _EditorCommand(
      title: 'Increase selection width',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Right',
      icon: Icons.keyboard_arrow_right,
      detail: keyboardResizeDetail,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'resize wider width keyboard grow',
      onRun:
          () => layoutNotifier.resizeSelectedComponentsBy(
            Offset(keyboardResizeStep, 0),
          ),
    ),
    _EditorCommand(
      title: 'Decrease selection width',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Left',
      icon: Icons.keyboard_arrow_left,
      detail: keyboardResizeDetail,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'resize narrower width keyboard shrink',
      onRun:
          () => layoutNotifier.resizeSelectedComponentsBy(
            Offset(-keyboardResizeStep, 0),
          ),
    ),
    _EditorCommand(
      title: 'Increase selection height',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Down',
      icon: Icons.keyboard_arrow_down,
      detail: keyboardResizeDetail,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'resize taller height keyboard grow',
      onRun:
          () => layoutNotifier.resizeSelectedComponentsBy(
            Offset(0, keyboardResizeStep),
          ),
    ),
    _EditorCommand(
      title: 'Decrease selection height',
      group: 'Layout',
      shortcut: 'Ctrl/Cmd+Up',
      icon: Icons.keyboard_arrow_up,
      detail: keyboardResizeDetail,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'resize shorter height keyboard shrink',
      onRun:
          () => layoutNotifier.resizeSelectedComponentsBy(
            Offset(0, -keyboardResizeStep),
          ),
    ),
    _EditorCommand(
      title: 'Center selection on canvas',
      group: 'Layout',
      shortcut: 'Alt+C',
      icon: Icons.center_focus_weak,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'middle center both canvas',
      onRun:
          () => layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Center selection horizontally',
      group: 'Layout',
      shortcut: 'Alt+Shift+H',
      icon: Icons.horizontal_distribute,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'middle x axis canvas',
      onRun:
          () => layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            launcherContext,
            actionRef,
            vertical: false,
          ),
    ),
    _EditorCommand(
      title: 'Center selection vertically',
      group: 'Layout',
      shortcut: 'Alt+Shift+V',
      icon: Icons.vertical_distribute,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'middle y axis canvas',
      onRun:
          () => layoutCanvasPlacementActionService.centerSelectionOnCanvas(
            launcherContext,
            actionRef,
            horizontal: false,
          ),
    ),
    _EditorCommand(
      title: 'Align left',
      group: 'Layout',
      icon: Icons.format_align_left,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'edge horizontal x start',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.left,
          ),
    ),
    _EditorCommand(
      title: 'Align center',
      group: 'Layout',
      icon: Icons.align_horizontal_center,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'middle horizontal x',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.center,
          ),
    ),
    _EditorCommand(
      title: 'Align right',
      group: 'Layout',
      icon: Icons.format_align_right,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'edge horizontal x end',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.right,
          ),
    ),
    _EditorCommand(
      title: 'Align top',
      group: 'Layout',
      icon: Icons.vertical_align_top,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'edge vertical y start',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.top,
          ),
    ),
    _EditorCommand(
      title: 'Align middle',
      group: 'Layout',
      icon: Icons.vertical_align_center,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'center vertical y',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.middle,
          ),
    ),
    _EditorCommand(
      title: 'Align bottom',
      group: 'Layout',
      icon: Icons.vertical_align_bottom,
      enabled: hasSelection,
      disabledReason: selectionReason,
      keywords: 'edge vertical y end',
      onRun:
          () => layoutSelectionGeometryActionService.alignSelection(
            launcherContext,
            actionRef,
            ComponentAlignment.bottom,
          ),
    ),
    _EditorCommand(
      title: 'Match selection width',
      group: 'Layout',
      icon: Icons.swap_horiz,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'same width size dimension equal reference',
      onRun:
          () => layoutSelectionGeometryActionService.matchSelectionSize(
            launcherContext,
            actionRef,
            matchHeight: false,
          ),
    ),
    _EditorCommand(
      title: 'Match selection height',
      group: 'Layout',
      icon: Icons.swap_vert,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'same height size dimension equal reference',
      onRun:
          () => layoutSelectionGeometryActionService.matchSelectionSize(
            launcherContext,
            actionRef,
            matchWidth: false,
          ),
    ),
    _EditorCommand(
      title: 'Match selection size',
      group: 'Layout',
      icon: Icons.aspect_ratio,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'same width height size dimension equal reference',
      onRun:
          () => layoutSelectionGeometryActionService.matchSelectionSize(
            launcherContext,
            actionRef,
          ),
    ),
    _EditorCommand(
      title: 'Stack selection as row',
      group: 'Layout',
      icon: Icons.view_column,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'stack row horizontal grid gap tidy line up',
      onRun:
          () => layoutSelectionGeometryActionService.stackSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.horizontal,
          ),
    ),
    _EditorCommand(
      title: 'Stack selection as column',
      group: 'Layout',
      icon: Icons.view_stream,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'stack column vertical grid gap tidy line up',
      onRun:
          () => layoutSelectionGeometryActionService.stackSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.vertical,
          ),
    ),
    _EditorCommand(
      title: 'Space selection horizontally by grid',
      group: 'Layout',
      icon: Icons.more_horiz,
      detail: '${gridGap.round()} px',
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'gap spacing horizontal grid row exact',
      onRun:
          () => layoutSelectionGeometryActionService.spaceSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.horizontal,
            gridGap,
          ),
    ),
    _EditorCommand(
      title: 'Set custom horizontal spacing',
      group: 'Layout',
      icon: Icons.tune,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'gap spacing horizontal exact custom row',
      onRun: () {
        showSelectionSpacingDialog(
          launcherContext,
          actionRef,
          ComponentDistribution.horizontal,
        );
      },
    ),
    _EditorCommand(
      title: 'Space selection vertically by grid',
      group: 'Layout',
      icon: Icons.more_vert,
      detail: '${gridGap.round()} px',
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'gap spacing vertical grid column exact',
      onRun:
          () => layoutSelectionGeometryActionService.spaceSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.vertical,
            gridGap,
          ),
    ),
    _EditorCommand(
      title: 'Set custom vertical spacing',
      group: 'Layout',
      icon: Icons.tune,
      enabled: hasMultiSelection,
      disabledReason: multiSelectionReason,
      keywords: 'gap spacing vertical exact custom column',
      onRun: () {
        showSelectionSpacingDialog(
          launcherContext,
          actionRef,
          ComponentDistribution.vertical,
        );
      },
    ),
    _EditorCommand(
      title: 'Distribute horizontally',
      group: 'Layout',
      icon: Icons.more_horiz,
      enabled: canDistribute,
      disabledReason: distributeReason,
      keywords: 'space spacing even x row',
      onRun:
          () => layoutSelectionGeometryActionService.distributeSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.horizontal,
          ),
    ),
    _EditorCommand(
      title: 'Distribute vertically',
      group: 'Layout',
      icon: Icons.more_vert,
      enabled: canDistribute,
      disabledReason: distributeReason,
      keywords: 'space spacing even y column',
      onRun:
          () => layoutSelectionGeometryActionService.distributeSelection(
            launcherContext,
            actionRef,
            ComponentDistribution.vertical,
          ),
    ),
  ];
}

List<_EditorCommand> _commandsForGroup(
  String selectedGroup,
  List<_EditorCommand> matchingCommands,
) {
  if (selectedGroup == _EditorCommandPaletteDialogState._allCommandGroup) {
    return _prioritizedCommands(matchingCommands);
  }

  if (selectedGroup == _pinnedCommandGroup) {
    return _orderedCommandMatches(_pinnedEditorCommandIds, matchingCommands);
  }

  if (selectedGroup == _recentCommandGroup) {
    return _orderedCommandMatches(_recentEditorCommandIds, matchingCommands);
  }

  return matchingCommands
      .where((command) => command.group == selectedGroup)
      .toList(growable: false);
}

List<_EditorCommand> _prioritizedCommands(List<_EditorCommand> commands) {
  final ordered = <_EditorCommand>[];
  final includedIds = <String>{};

  void addById(String id) {
    for (final command in commands) {
      if (command.id == id && includedIds.add(id)) {
        ordered.add(command);
        return;
      }
    }
  }

  for (final id in _pinnedEditorCommandIds) {
    addById(id);
  }
  for (final id in _recentEditorCommandIds) {
    addById(id);
  }
  for (final command in commands) {
    if (includedIds.add(command.id)) {
      ordered.add(command);
    }
  }

  return ordered;
}

List<_EditorCommand> _orderedCommandMatches(
  Iterable<String> orderedIds,
  List<_EditorCommand> commands,
) {
  final matches = <_EditorCommand>[];
  for (final id in orderedIds) {
    for (final command in commands) {
      if (command.id == id) {
        matches.add(command);
        break;
      }
    }
  }

  return matches;
}

void _recordRecentCommand(_EditorCommand command) {
  _recentEditorCommandIds.remove(command.id);
  _recentEditorCommandIds.insert(0, command.id);
  if (_recentEditorCommandIds.length > _maxRecentCommandCount) {
    _recentEditorCommandIds.removeRange(
      _maxRecentCommandCount,
      _recentEditorCommandIds.length,
    );
  }
}

List<_CommandGroupFilter> _commandGroups(
  List<_EditorCommand> allCommands,
  List<_EditorCommand> matchingCommands,
) {
  final seen = <String>{};
  final counts = <String, int>{};
  for (final command in matchingCommands) {
    counts[command.group] = (counts[command.group] ?? 0) + 1;
  }

  return [
    _CommandGroupFilter(
      name: _EditorCommandPaletteDialogState._allCommandGroup,
      count: matchingCommands.length,
    ),
    if (_pinnedEditorCommandIds.isNotEmpty)
      _CommandGroupFilter(
        name: _pinnedCommandGroup,
        count:
            _orderedCommandMatches(
              _pinnedEditorCommandIds,
              matchingCommands,
            ).length,
      ),
    if (_recentEditorCommandIds.isNotEmpty)
      _CommandGroupFilter(
        name: _recentCommandGroup,
        count:
            _orderedCommandMatches(
              _recentEditorCommandIds,
              matchingCommands,
            ).length,
      ),
    for (final command in allCommands)
      if (seen.add(command.group))
        _CommandGroupFilter(
          name: command.group,
          count: counts[command.group] ?? 0,
        ),
  ];
}

class _CommandGroupFilter {
  final String name;
  final int count;

  const _CommandGroupFilter({required this.name, required this.count});
}

class _EditorCommand {
  final String? commandId;
  final String title;
  final String group;
  final IconData icon;
  final VoidCallback onRun;
  final String? shortcut;
  final bool enabled;
  final String? disabledReason;
  final String? detail;
  final String keywords;

  const _EditorCommand({
    this.commandId,
    required this.title,
    required this.group,
    required this.icon,
    required this.onRun,
    this.shortcut,
    this.enabled = true,
    this.disabledReason,
    this.detail,
    this.keywords = '',
  });

  String get id => commandId ?? _fallbackCommandId(group, title);

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final haystack =
        [
          title,
          group,
          shortcut ?? '',
          disabledReason ?? '',
          detail ?? '',
          keywords,
        ].join(' ').toLowerCase();
    return normalized
        .split(RegExp(r'\s+'))
        .every((term) => haystack.contains(term));
  }
}

String _fallbackCommandId(String group, String title) {
  final normalizedGroup = group.toLowerCase();
  final normalizedTitle = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '$normalizedGroup.$normalizedTitle';
}

void _copySharedBuilderSnapshot(BuildContext context, LayoutState layoutState) {
  final snapshot = layoutState.toSharedBuilderSnapshot();
  final snapshotJson = const JsonEncoder.withIndent(
    '  ',
  ).convert(snapshot.toJson());
  Clipboard.setData(ClipboardData(text: snapshotJson));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Copied shared builder snapshot (${snapshot.components.length} components)',
      ),
      duration: const Duration(milliseconds: 1200),
    ),
  );
}

bool _isSameCanvasSize(Size first, Size second) {
  return (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}

String? _resetPositionDisabledReason(ComponentData? component) {
  if (component == null) return 'Select one component first';
  if (component.isLocked) return 'Selected component is locked';
  if (component.position == Offset.zero) return 'Position is already 0, 0';
  return null;
}

String? _resetSizeDisabledReason(ComponentData? component) {
  if (component == null) return 'Select one component first';
  if (component.isLocked) return 'Selected component is locked';
  if (_isSameComponentSize(component.size, component.type.defaultSize)) {
    return 'Size is already the component default';
  }
  return null;
}

bool _isSameComponentSize(Size first, Size second) {
  return (first.width - second.width).abs() < 0.5 &&
      (first.height - second.height).abs() < 0.5;
}

IconData _canvasSizePresetIcon(LayoutCanvasSizePreset preset) {
  if (preset.size.height > preset.size.width) return Icons.phone_android;
  if (preset.size.width >= 1800) return Icons.tv;
  if (preset.size.width <= 1100) return Icons.tablet_mac;
  return Icons.desktop_windows;
}

IconData _copyBoundsFormatIcon(LayoutBoundsCopyFormat format) {
  return switch (format) {
    LayoutBoundsCopyFormat.text => Icons.notes,
    LayoutBoundsCopyFormat.json => Icons.data_object,
    LayoutBoundsCopyFormat.flutterRect => Icons.widgets_outlined,
    LayoutBoundsCopyFormat.css => Icons.style_outlined,
  };
}

String _zoomPercentLabel(double zoom) {
  return '${(zoom * 100).round()}%';
}
