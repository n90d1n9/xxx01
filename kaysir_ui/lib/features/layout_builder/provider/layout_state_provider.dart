import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/component.dart';
import '../models/component_properties.dart';
import '../models/grid_setting.dart';
import '../models/layout_config.dart';
import '../models/layout_drag_preview.dart';
import '../models/layout_item.dart';
import '../models/layout_rules_conversion_preview.dart';
import '../models/layout_rules_version_name.dart';
import '../models/layout_state.dart';
import '../models/layout_version.dart';
import '../models/template.dart';

final layoutStateProvider =
    StateNotifierProvider<LayoutStateNotifier, LayoutState>((ref) {
      return LayoutStateNotifier();
    });

final selectedComponentProvider = StateProvider<String?>((ref) => null);

/// Describes a validated move that resolves a selected placement conflict.
class _ConflictResolutionPlan {
  final LayoutDragPreviewItem item;
  final List<ComponentData> components;
  final Set<String> componentIds;
  final String selectedComponentId;

  const _ConflictResolutionPlan({
    required this.item,
    required this.components,
    required this.componentIds,
    required this.selectedComponentId,
  });
}

/// Coordinates Layout Builder canvas state, history, and undoable mutations.
class LayoutStateNotifier extends StateNotifier<LayoutState> {
  LayoutStateNotifier() : super(LayoutState.initial());

  static const _smartGuideSnapThreshold = 6.0;

  List<ComponentData>? _interactionStartComponents;

  void beginInteractionTransaction() {
    _interactionStartComponents ??= state.components;
  }

  void endInteractionTransaction() {
    final startComponents = _interactionStartComponents;
    if (startComponents == null) return;

    _interactionStartComponents = null;
    if (!_hasComponentGeometryChanges(startComponents, state.components)) {
      return;
    }

    final version = LayoutVersion.create(
      state.components,
      gridSettings: state.gridSettings,
      config: state.config,
      name: 'Canvas interaction',
    );
    final history = state.versions.take(state.currentVersionIndex + 1).toList();

    state = state.copyWith(
      versions: [...history, version],
      currentVersionIndex: history.length,
    );
  }

  void loadTemplate(Template template) {
    state = LayoutState.fromJson(
      template.layout,
    ).copyWith(activeTemplate: template.id);
  }

  void importLayout(Map<String, dynamic> layout) {
    final imported = LayoutState.fromJson(layout);
    final history = state.versions.take(state.currentVersionIndex + 1).toList();
    final version = LayoutVersion.create(
      imported.components,
      gridSettings: imported.gridSettings,
      config: imported.config,
      name: 'Imported layout',
    );

    state = state.copyWith(
      id: imported.id,
      name: imported.name,
      components: imported.components,
      gridSettings: imported.gridSettings,
      config: imported.config,
      gridColumns: imported.gridColumns,
      gridRows: imported.gridRows,
      isGridVisible: imported.isGridVisible,
      gridOpacity: imported.gridOpacity,
      activeTemplate: null,
      selectedComponentId: null,
      selectedComponentIds: const <String>{},
      versions: [...history, version],
      currentVersionIndex: history.length,
    );
  }

  void saveLayout() {
    saveVersion('Manual save');
  }

  void saveVersion(String name) {
    final version = LayoutVersion.create(
      state.components,
      gridSettings: state.gridSettings,
      config: state.config,
      name: name,
    );

    state = state.copyWith(
      versions: [
        ...state.versions.take(state.currentVersionIndex + 1),
        version,
      ],
      currentVersionIndex: state.currentVersionIndex + 1,
    );
  }

  void renameVersion(String versionId, String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    var changed = false;
    final versions =
        state.versions.map((version) {
          if (version.id != versionId) return version;

          changed = true;
          return version.copyWith(name: trimmedName);
        }).toList();
    if (!changed) return;

    state = state.copyWith(versions: versions);
  }

  void duplicateVersion(String versionId) {
    final sourceIndex = state.versions.indexWhere(
      (version) => version.id == versionId,
    );
    if (sourceIndex < 0) return;

    final source = state.versions[sourceIndex];
    final sourceName = source.name?.trim();
    final duplicate = LayoutVersion.create(
      source.components,
      gridSettings: source.gridSettings,
      config: source.config,
      name:
          sourceName == null || sourceName.isEmpty
              ? 'Snapshot copy'
              : '$sourceName copy',
    );
    final versions = [...state.versions]..insert(sourceIndex + 1, duplicate);
    final nextVersionIndex =
        state.currentVersionIndex > sourceIndex
            ? state.currentVersionIndex + 1
            : state.currentVersionIndex;

    state = state.copyWith(
      versions: versions,
      currentVersionIndex: nextVersionIndex,
    );
  }

  void deleteVersion(String versionId) {
    if (state.versions.length <= 1) return;

    final removedIndex = state.versions.indexWhere(
      (version) => version.id == versionId,
    );
    if (removedIndex < 0) return;

    final versions = [...state.versions]..removeAt(removedIndex);
    var nextVersionIndex = state.currentVersionIndex;
    if (removedIndex < nextVersionIndex) {
      nextVersionIndex -= 1;
    } else if (removedIndex == nextVersionIndex) {
      nextVersionIndex = math.min(removedIndex, versions.length - 1);
    }

    final version = versions[nextVersionIndex];
    state = state.copyWith(
      components: version.components,
      gridSettings: version.gridSettings,
      config: version.config,
      selectedComponentId: null,
      selectedComponentIds: const <String>{},
      versions: versions,
      currentVersionIndex: nextVersionIndex,
    );
  }

  void restoreVersion(String versionId) {
    final version = state.versions.firstWhere((item) => item.id == versionId);
    state = state.copyWith(
      components: version.components,
      gridSettings: version.gridSettings,
      config: version.config,
      selectedComponentId: null,
      selectedComponentIds: const <String>{},
      currentVersionIndex: state.versions.indexOf(version),
    );
  }

  void undo() {
    if (!state.canUndo) return;
    final nextIndex = state.currentVersionIndex - 1;
    final version = state.versions[nextIndex];
    state = state.copyWith(
      components: version.components,
      gridSettings: version.gridSettings,
      config: version.config,
      selectedComponentId: null,
      selectedComponentIds: const <String>{},
      currentVersionIndex: nextIndex,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final nextIndex = state.currentVersionIndex + 1;
    final version = state.versions[nextIndex];
    state = state.copyWith(
      components: version.components,
      gridSettings: version.gridSettings,
      config: version.config,
      selectedComponentId: null,
      selectedComponentIds: const <String>{},
      currentVersionIndex: nextIndex,
    );
  }

  void updateGridSettings(GridSettings settings) {
    updateLayoutRules(
      gridSettings: settings,
      config: state.config.copyWith(
        gridSize: settings.gridSize,
        snapToGrid: settings.snapToGrid,
        showGrid: settings.enabled,
      ),
      versionName: 'Grid update',
    );
  }

  void updateLayoutRules({
    required GridSettings gridSettings,
    required LayoutConfig config,
    String? versionName,
  }) {
    applyLayoutRules(
      gridSettings: gridSettings,
      config: config,
      versionName: versionName,
    );
  }

  void applyLayoutRules({
    required GridSettings gridSettings,
    required LayoutConfig config,
    bool snapVisiblePositions = false,
    bool snapVisibleSizes = false,
    bool resolveAutoGridConflicts = false,
    String? versionName,
  }) {
    final syncedConfig = config.copyWith(
      gridSize: gridSettings.gridSize,
      snapToGrid: gridSettings.snapToGrid,
      showGrid: gridSettings.enabled,
    );
    final currentSize = state.config.canvasSize;
    final nextSize = syncedConfig.canvasSize;
    final shouldApplyConstraints =
        (nextSize.width - currentSize.width).abs() >= 0.01 ||
        (nextSize.height - currentSize.height).abs() >= 0.01;
    final nextComponents =
        shouldApplyConstraints
            ? _componentsConstrainedToCanvasResize(
              state.components,
              currentSize,
              nextSize,
            )
            : state.components;
    final convertedComponents = layoutRulesConvertedComponents(
      components: nextComponents,
      gridSettings: gridSettings,
      config: syncedConfig,
      snapPositions: snapVisiblePositions,
      snapSizes: snapVisibleSizes,
      resolveAutoGridConflicts: resolveAutoGridConflicts,
    );

    final hasRuleChanges =
        _hasGridSettingsChanges(state.gridSettings, gridSettings) ||
        _hasLayoutConfigChanges(state.config, syncedConfig);
    final hasComponentGeometryChanges = _hasComponentGeometryChanges(
      state.components,
      convertedComponents,
    );
    if (!hasRuleChanges && !hasComponentGeometryChanges) {
      return;
    }

    final nextState = state.copyWith(
      gridSettings: gridSettings,
      config: syncedConfig,
      components: convertedComponents,
      isGridVisible: gridSettings.enabled,
      gridOpacity: gridSettings.opacity,
    );

    _commitLayoutState(
      nextState,
      versionName:
          versionName ??
          layoutRulesVersionName(
            mechanism: syncedConfig.layoutMechanism,
            snapVisiblePositions: snapVisiblePositions,
            snapVisibleSizes: snapVisibleSizes,
            resolveAutoGridConflicts: resolveAutoGridConflicts,
            hasRuleChanges: hasRuleChanges,
          ),
    );
  }

  void updateGridSize(int columns, int rows) {
    state = state.copyWith(gridColumns: columns, gridRows: rows);
  }

  void updateCanvasSize(Size canvasSize, {bool applyConstraints = true}) {
    final normalizedSize = LayoutConfig.normalizeCanvasSize(canvasSize);
    final currentSize = state.config.canvasSize;
    if ((normalizedSize.width - currentSize.width).abs() < 0.01 &&
        (normalizedSize.height - currentSize.height).abs() < 0.01) {
      return;
    }

    final nextComponents =
        applyConstraints
            ? _componentsConstrainedToCanvasResize(
              state.components,
              currentSize,
              normalizedSize,
            )
            : state.components;

    _commitLayoutState(
      state.copyWith(
        config: state.config.copyWith(canvasSize: normalizedSize),
        components: nextComponents,
      ),
      versionName: 'Canvas size update',
    );
  }

  void updateLayoutMechanism(LayoutMechanism mechanism) {
    if (state.config.layoutMechanism == mechanism) return;

    _commitLayoutState(
      state.copyWith(config: state.config.copyWith(layoutMechanism: mechanism)),
      versionName: 'Layout mode update',
    );
  }

  void convertLayoutMechanism(LayoutMechanism mechanism) {
    final shouldConformGeometry = mechanism != LayoutMechanism.freeform;
    applyLayoutRules(
      gridSettings: state.gridSettings,
      config: state.config.copyWith(layoutMechanism: mechanism),
      snapVisiblePositions: shouldConformGeometry,
      snapVisibleSizes: shouldConformGeometry,
      resolveAutoGridConflicts: mechanism == LayoutMechanism.autoGrid,
      versionName: 'Layout rules: Convert to ${mechanism.label}',
    );
  }

  void updateLayoutConfig(LayoutConfig config) {
    final nextGridSettings = state.gridSettings.copyWith(
      gridSize: config.gridSize,
      snapToGrid: config.snapToGrid,
      enabled: config.showGrid,
    );
    final currentSize = state.config.canvasSize;
    final nextSize = config.canvasSize;
    final shouldApplyConstraints =
        (nextSize.width - currentSize.width).abs() >= 0.01 ||
        (nextSize.height - currentSize.height).abs() >= 0.01;
    final nextComponents =
        shouldApplyConstraints
            ? _componentsConstrainedToCanvasResize(
              state.components,
              currentSize,
              nextSize,
            )
            : state.components;

    if (!_hasGridSettingsChanges(state.gridSettings, nextGridSettings) &&
        !_hasLayoutConfigChanges(state.config, config) &&
        identical(nextComponents, state.components)) {
      return;
    }

    _commitLayoutState(
      state.copyWith(
        gridSettings: nextGridSettings,
        config: config,
        components: nextComponents,
        isGridVisible: nextGridSettings.enabled,
        gridOpacity: nextGridSettings.opacity,
      ),
      versionName: 'Layout rules: Update rules',
    );
  }

  void rotateCanvasSize() {
    final canvasSize = state.config.canvasSize;
    updateCanvasSize(Size(canvasSize.height, canvasSize.width));
  }

  void fitCanvasToContent({double padding = 24}) {
    final visibleComponents =
        state.components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return;

    final bounds = _componentsBounds(visibleComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    updateCanvasSize(
      Size(
        math.max(LayoutConfig.minCanvasWidth, bounds.right + safePadding),
        math.max(LayoutConfig.minCanvasHeight, bounds.bottom + safePadding),
      ),
      applyConstraints: false,
    );
  }

  void fitCanvasToSelection({double padding = 24}) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final visibleSelectedComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && component.isVisible,
            )
            .toList();
    if (visibleSelectedComponents.isEmpty) return;

    final bounds = _componentsBounds(visibleSelectedComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    updateCanvasSize(
      Size(
        math.max(LayoutConfig.minCanvasWidth, bounds.right + safePadding),
        math.max(LayoutConfig.minCanvasHeight, bounds.bottom + safePadding),
      ),
      applyConstraints: false,
    );
  }

  /// Shifts visible unlocked components back from negative canvas coordinates.
  void moveVisibleComponentsInsideCanvas({double padding = 0}) {
    final movableComponents =
        state.components
            .where((component) => component.isVisible && !component.isLocked)
            .toList();
    if (movableComponents.isEmpty) return;

    final bounds = _componentsBounds(movableComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final dx = bounds.left < safePadding ? safePadding - bounds.left : 0.0;
    final dy = bounds.top < safePadding ? safePadding - bounds.top : 0.0;
    if (dx.abs() < 0.01 && dy.abs() < 0.01) return;

    final delta = Offset(dx, dy);
    final movableIds =
        movableComponents.map((component) => component.id).toSet();
    final nextComponents =
        state.components
            .map(
              (component) =>
                  movableIds.contains(component.id)
                      ? component.copyWith(position: component.position + delta)
                      : component,
            )
            .toList();

    _commitLayoutState(
      state.copyWith(components: nextComponents),
      versionName: 'Layout health: Reposition inside canvas',
    );
  }

  void trimCanvasToContent({double padding = 24}) {
    final visibleComponents =
        state.components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return;

    final bounds = _componentsBounds(visibleComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final nextCanvasSize = Size(
      math.max(LayoutConfig.minCanvasWidth, bounds.width + safePadding * 2),
      math.max(LayoutConfig.minCanvasHeight, bounds.height + safePadding * 2),
    );
    final delta = Offset(safePadding - bounds.left, safePadding - bounds.top);

    if (delta.distance >= 0.01) {
      final selectedIds = _activeSelectedIds();
      _commitComponents(
        state.components
            .map(
              (component) =>
                  component.copyWith(position: component.position + delta),
            )
            .toList(),
        selectedComponentId: state.selectedComponentId,
        selectedComponentIds: selectedIds.isEmpty ? null : selectedIds,
      );
    }

    updateCanvasSize(nextCanvasSize, applyConstraints: false);
  }

  void toggleGridVisibility() {
    toggleGrid();
  }

  void toggleGrid() {
    updateGridSettings(
      state.gridSettings.copyWith(enabled: !state.gridSettings.enabled),
    );
  }

  void toggleSnapToGrid() {
    updateGridSettings(
      state.gridSettings.copyWith(
        snapToGrid: !state.gridSettings.snapToGrid,
        enabled: true,
      ),
    );
  }

  void addComponent(ComponentData component) {
    _commitComponents([
      ...state.components,
      _snapComponent(component),
    ], selectedComponentId: component.id);
  }

  void addComponentWithDropResolution(ComponentData component) {
    addComponentsWithDropResolution([component]);
  }

  void addComponents(List<ComponentData> components) {
    if (components.isEmpty) return;

    final snappedComponents = components.map(_snapComponent).toList();

    _commitComponents(
      [...state.components, ...snappedComponents],
      selectedComponentId: snappedComponents.last.id,
      selectedComponentIds:
          snappedComponents.map((component) => component.id).toSet(),
    );
  }

  void addComponentsWithDropResolution(List<ComponentData> components) {
    if (components.isEmpty) return;

    final placedComponents = _dropComponentsWithConflictResolution(components);

    _commitComponents(
      [...state.components, ...placedComponents],
      selectedComponentId: placedComponents.last.id,
      selectedComponentIds:
          placedComponents.map((component) => component.id).toSet(),
    );
  }

  void addComponentFromType(ComponentType type, Offset position) {
    addComponent(ComponentData.create(type: type, position: position));
  }

  void addComponentFromTypeWithDropResolution(
    ComponentType type,
    Offset position,
  ) {
    addComponentWithDropResolution(
      ComponentData.create(type: type, position: position),
    );
  }

  void addComponentFromPreset(ComponentData preset, Offset position) {
    addComponentsFromPreset([preset], position);
  }

  void addComponentsFromPreset(
    List<ComponentData> presetComponents,
    Offset position,
  ) {
    if (presetComponents.isEmpty) return;

    final components = _presetComponentsAtDropPosition(
      presetComponents,
      position,
    );

    _commitComponents(
      [...state.components, ...components],
      selectedComponentId: components.last.id,
      selectedComponentIds: components.map((component) => component.id).toSet(),
    );
  }

  void addComponentsFromPresetWithDropResolution(
    List<ComponentData> presetComponents,
    Offset position,
  ) {
    if (presetComponents.isEmpty) return;

    addComponentsWithDropResolution(
      _presetComponentsAtDropPosition(presetComponents, position),
    );
  }

  List<ComponentData> _presetComponentsAtDropPosition(
    List<ComponentData> presetComponents,
    Offset position,
  ) {
    final presetBounds = _componentsBounds(presetComponents);
    final positionDelta = position - presetBounds.topLeft;
    final groupIdMap = <String, String>{};

    return presetComponents.map((preset) {
      final parentId = preset.properties.parentId;
      final duplicated = preset.duplicate(offset: Offset.zero);
      final responsiveProperties = preset.responsiveProperties.map((
        key,
        value,
      ) {
        final responsivePosition = value.position;

        return MapEntry(
          key,
          value.copyWith(
            position:
                responsivePosition == null
                    ? null
                    : responsivePosition + positionDelta,
          ),
        );
      });
      final properties =
          parentId == null
              ? duplicated.properties.copyWith(parentId: null)
              : duplicated.properties.copyWith(
                parentId: groupIdMap.putIfAbsent(
                  parentId,
                  () => const Uuid().v4(),
                ),
              );

      return duplicated.copyWith(
        position: _snapOffset(preset.position + positionDelta),
        properties: properties,
        responsiveProperties: responsiveProperties,
        isLocked: false,
        isVisible: true,
      );
    }).toList();
  }

  void addComponentByKey(String type, Offset position) {
    addComponent(ComponentData.fromTypeKey(type: type, position: position));
  }

  void addItem(LayoutItem item) {
    addComponentByKey(item.type, Offset(item.x, item.y));
  }

  void updateItemPosition(String id, double x, double y) {
    updateComponentPosition(id, Offset(x, y));
  }

  void removeItem(String id) {
    removeComponent(id);
  }

  void selectComponent(String? id) {
    final selectedIds = id == null ? const <String>{} : _groupedIdsFor(id);

    state = state.copyWith(
      selectedComponentId: id != null && selectedIds.contains(id) ? id : null,
      selectedComponentIds: selectedIds,
    );
  }

  void selectAdjacentLayer({required bool towardFront}) {
    final components = state.components;
    if (components.isEmpty) return;

    final currentId =
        state.selectedComponentId ??
        (state.selectedComponentIds.isEmpty
            ? null
            : state.selectedComponentIds.first);
    if (currentId == null) {
      selectComponent(towardFront ? components.last.id : components.first.id);
      return;
    }

    final currentIndex = components.indexWhere(
      (component) => component.id == currentId,
    );
    if (currentIndex == -1) {
      selectComponent(towardFront ? components.last.id : components.first.id);
      return;
    }

    final delta = towardFront ? 1 : -1;
    final nextIndex = (currentIndex + delta) % components.length;
    selectComponent(
      components[nextIndex < 0 ? components.length - 1 : nextIndex].id,
    );
  }

  void toggleComponentSelection(String id) {
    final selectedIds = {...state.selectedComponentIds};
    final targetIds = _groupedIdsFor(id);
    if (targetIds.isEmpty) return;

    if (targetIds.every(selectedIds.contains)) {
      selectedIds.removeAll(targetIds);
    } else {
      selectedIds.addAll(targetIds);
    }

    final nextPrimary =
        selectedIds.isEmpty
            ? null
            : selectedIds.contains(state.selectedComponentId)
            ? state.selectedComponentId
            : selectedIds.contains(id)
            ? id
            : selectedIds.first;

    state = state.copyWith(
      selectedComponentId: nextPrimary,
      selectedComponentIds: selectedIds,
    );
  }

  void selectComponents(Set<String> ids, {bool addToExisting = false}) {
    final componentIds =
        state.components.map((component) => component.id).toSet();
    final requestedIds = {
      if (addToExisting) ...state.selectedComponentIds,
      ...ids.where(componentIds.contains),
    };
    final selectedIds = _expandGroupedIds(requestedIds);

    state = state.copyWith(
      selectedComponentId: selectedIds.isEmpty ? null : selectedIds.first,
      selectedComponentIds: selectedIds,
    );
  }

  void invertComponentsSelection(Set<String> ids) {
    if (ids.isEmpty) return;

    final componentIds =
        state.components.map((component) => component.id).toSet();
    final scopedIds = ids.where(componentIds.contains).toSet();
    if (scopedIds.isEmpty) return;

    final selectedIds = {...state.selectedComponentIds};
    for (final id in scopedIds) {
      if (!selectedIds.add(id)) {
        selectedIds.remove(id);
      }
    }

    final expandedSelectedIds = _expandGroupedIds(selectedIds);
    state = state.copyWith(
      selectedComponentId:
          expandedSelectedIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : expandedSelectedIds.isEmpty
              ? null
              : expandedSelectedIds.first,
      selectedComponentIds: expandedSelectedIds,
    );
  }

  void deselectComponents(Set<String> ids) {
    if (ids.isEmpty) return;

    final componentIds =
        state.components.map((component) => component.id).toSet();
    final scopedIds = ids.where(componentIds.contains).toSet();
    if (scopedIds.isEmpty) return;

    final selectedIds = _activeSelectedIds()..removeAll(scopedIds);
    final nextPrimary =
        selectedIds.contains(state.selectedComponentId)
            ? state.selectedComponentId
            : selectedIds.isEmpty
            ? null
            : selectedIds.first;

    state = state.copyWith(
      selectedComponentId: nextPrimary,
      selectedComponentIds: selectedIds,
    );
  }

  void selectComponentsByType(
    ComponentType type, {
    bool addToExisting = false,
  }) {
    _selectComponentsWhere(
      (component) => component.type == type,
      addToExisting: addToExisting,
    );
  }

  void selectComponentsByVisibility(bool isVisible) {
    _selectComponentsWhere((component) => component.isVisible == isVisible);
  }

  void selectComponentsByLockState(bool isLocked) {
    _selectComponentsWhere((component) => component.isLocked == isLocked);
  }

  void clearSelection() {
    selectComponent(null);
  }

  void selectAllComponents() {
    selectComponents(state.components.map((component) => component.id).toSet());
  }

  void invertSelection() {
    final allIds = state.components.map((component) => component.id).toSet();
    if (allIds.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    selectComponents(allIds.difference(selectedIds));
  }

  void _selectComponentsWhere(
    bool Function(ComponentData component) test, {
    bool addToExisting = false,
  }) {
    final matchingIds =
        state.components.where(test).map((component) => component.id).toSet();
    if (matchingIds.isEmpty) return;

    selectComponents(matchingIds, addToExisting: addToExisting);
  }

  void updateComponent(String id, ComponentData newComponent) {
    _commitComponents(
      state.components.map((component) {
        return component.id == id ? _snapComponent(newComponent) : component;
      }).toList(),
      selectedComponentId: id,
    );
  }

  void updateComponentPosition(String id, Offset newPosition) {
    final component = state.componentsById[id];
    if (component == null || component.isLocked) return;

    final selectedIds = _activeSelectedIds();
    final selectionIncludesComponent = selectedIds.contains(id);
    final nextPosition = _snappedPositionForComponent(
      component,
      newPosition,
      excludedIds: selectionIncludesComponent ? selectedIds : {id},
    );

    _commitComponents(
      state.components.map((component) {
        if (component.id != id) return component;
        return component.copyWith(position: nextPosition);
      }).toList(),
      selectedComponentId: id,
      selectedComponentIds: selectionIncludesComponent ? selectedIds : {id},
    );
  }

  void moveComponent(String id, Offset delta) {
    if (!state.isEditMode) return;
    final component = state.componentsById[id];
    if (component == null || component.isLocked) return;

    if (state.selectedComponentIds.length > 1 &&
        state.selectedComponentIds.contains(id)) {
      moveSelectedComponents(delta);
      return;
    }

    final nextPosition = _snappedPositionForComponent(
      component,
      component.position + delta,
      excludedIds: {id},
    );

    _commitComponents(
      state.components.map((component) {
        if (component.id != id) return component;
        return component.copyWith(position: nextPosition);
      }).toList(),
      selectedComponentId: id,
      selectedComponentIds: {id},
    );
  }

  void nudgeSelectedComponent(Offset delta) {
    moveSelectedComponents(delta);
  }

  void moveSelectedComponents(Offset delta) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;
    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;
    final desiredPositions = {
      for (final component in movableComponents)
        component.id: _snapOffset(component.position + delta),
    };
    final movedBounds = _componentsBoundsAt(
      movableComponents,
      desiredPositions,
    );
    final guideAdjustment = _smartGuideAdjustment(
      movedBounds,
      excludedIds: selectedIds,
    );

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          position: desiredPositions[component.id]! + guideAdjustment,
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  bool resolveActiveDragConflict(String activeComponentId) {
    if (!_shouldApplyDropLayoutRules) return false;

    return _resolveConflictPreview(
      _layoutDragPreviewForSelection(activeComponentId),
      activeComponentId,
    );
  }

  LayoutDragPreviewItem? selectedConflictResolutionPreview() {
    final activeComponentId = _selectedConflictResolutionComponentId();
    if (activeComponentId == null || !_hasLayoutRuleConflictResolution) {
      return null;
    }

    return _conflictResolutionPlanFor(
      _layoutDragPreviewForSelection(activeComponentId),
      activeComponentId,
    )?.item;
  }

  bool resolveSelectedConflict() {
    final activeComponentId = _selectedConflictResolutionComponentId();
    if (activeComponentId == null || !_hasLayoutRuleConflictResolution) {
      return false;
    }

    return _resolveConflictPreview(
      _layoutDragPreviewForSelection(activeComponentId),
      activeComponentId,
    );
  }

  bool _resolveConflictPreview(
    LayoutDragPreview? preview,
    String activeComponentId,
  ) {
    final plan = _conflictResolutionPlanFor(preview, activeComponentId);
    if (plan == null) return false;

    _commitComponents(
      plan.components,
      selectedComponentId: plan.selectedComponentId,
      selectedComponentIds: plan.componentIds,
    );

    return true;
  }

  void updateComponentSize(String id, Size newSize) {
    _updateComponent(
      id,
      (component) =>
          component.copyWith(size: _snapConstrainedSize(component, newSize)),
    );
  }

  void resizeSelectedComponents({double? width, double? height}) {
    if (width == null && height == null) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(
              width ?? component.size.width,
              height ?? component.size.height,
            ),
          );

          if ((nextSize.width - component.size.width).abs() >= 0.01 ||
              (nextSize.height - component.size.height).abs() >= 0.01) {
            changed = true;
          }

          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void resizeSelectedComponentsBy(Offset delta) {
    if (delta.distance < 0.01) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(
              component.size.width + delta.dx,
              component.size.height + delta.dy,
            ),
          );
          if ((nextSize.width - component.size.width).abs() >= 0.01 ||
              (nextSize.height - component.size.height).abs() >= 0.01) {
            changed = true;
          }

          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void setSelectedTabularColumnSpan(int span) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final normalizedSpan =
        span.clamp(1, state.config.tabularColumnCount).toInt();
    final targetWidth = _tabularColumnSpanWidth(normalizedSpan);
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(targetWidth, component.size.height),
          );
          if ((nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void setSelectedTabularRowSpan(int span) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final targetHeight = _tabularRowSpanHeight(span);
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(component.size.width, targetHeight),
          );
          if ((nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void nudgeSelectedByTabularColumns(int columns) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;
    if (columns == 0) return;

    _moveSelectedByLayoutRuleStep(
      Offset(_tabularColumnTrackWidth() * columns, 0),
    );
  }

  void nudgeSelectedByTabularRows(int rows) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;
    if (rows == 0) return;

    _moveSelectedByLayoutRuleStep(
      Offset(0, math.max(1.0, state.config.tabularRowHeight) * rows),
    );
  }

  void nudgeSelectedByAutoGridColumns(int columns) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;
    if (columns == 0) return;

    _moveSelectedByLayoutRuleStep(
      Offset(_autoGridColumnTrackWidth() * columns, 0),
    );
  }

  void nudgeSelectedByAutoGridRows(int rows) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;
    if (rows == 0) return;

    _moveSelectedByLayoutRuleStep(Offset(0, _autoGridRowTrackHeight() * rows));
  }

  void moveSelectedToTabularColumn(int column) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;

    _moveSelectedToTabularStart(column: column);
  }

  void moveSelectedToTabularRow(int row) {
    if (state.config.layoutMechanism != LayoutMechanism.tabularColumns) return;

    _moveSelectedToTabularStart(row: row);
  }

  void setSelectedAutoGridColumnSpan(int span) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final targetWidth = _autoGridColumnSpanWidth(span);
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(targetWidth, component.size.height),
          );
          if ((nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void setSelectedAutoGridRowSpan(int span) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final targetHeight = _autoGridRowSpanHeight(span);
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapConstrainedSize(
            component,
            Size(component.size.width, targetHeight),
          );
          if ((nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void moveSelectedToAutoGridColumn(int column) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    _moveSelectedToAutoGridStart(column: column);
  }

  void moveSelectedToAutoGridRow(int row) {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    _moveSelectedToAutoGridStart(row: row);
  }

  void arrangeSelectedIntoAutoGrid() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _arrangeComponentsIntoAutoGrid(selectedIds);
  }

  void moveSelectedToFreeAutoGridCells() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _moveComponentsToFreeAutoGridCells(selectedIds);
  }

  void selectAutoGridConflictPartnersForSelection() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final conflictIds = _autoGridConflictPartnerIdsForSelection(selectedIds);
    if (conflictIds.isEmpty) return;

    selectComponents(conflictIds);
  }

  Set<String> visibleAutoGridConflictComponentIds() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) {
      return const <String>{};
    }

    return _autoGridConflictComponentIds();
  }

  void selectVisibleAutoGridConflicts() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final conflictIds = _autoGridConflictComponentIds();
    if (conflictIds.isEmpty) return;

    selectComponents(conflictIds);
  }

  void resolveVisibleAutoGridConflicts() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final conflictIds = _autoGridConflictComponentIds();
    if (conflictIds.isEmpty) return;

    _moveComponentsToFreeAutoGridCells(conflictIds, expandGroups: false);
  }

  void compactVisibleAutoGrid() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final visibleIds =
        state.components
            .where((component) => component.isVisible && !component.isLocked)
            .map((component) => component.id)
            .toSet();
    if (visibleIds.isEmpty) return;

    _moveComponentsToFreeAutoGridCells(
      visibleIds,
      expandGroups: false,
      startAt: Offset.zero,
    );
  }

  void arrangeVisibleIntoAutoGrid() {
    if (state.config.layoutMechanism != LayoutMechanism.autoGrid) return;

    final visibleIds =
        state.components
            .where((component) => component.isVisible)
            .map((component) => component.id)
            .toSet();
    if (visibleIds.isEmpty) return;

    _arrangeComponentsIntoAutoGrid(visibleIds, expandGroups: false);
  }

  void resetSelectedComponentsToDefaultSize() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final defaultSize = _snapConstrainedSize(
            component,
            component.type.defaultSize,
          );
          if ((defaultSize.width - component.size.width).abs() < 0.01 &&
              (defaultSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: defaultSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void matchSelectedComponentSize({
    bool matchWidth = true,
    bool matchHeight = true,
  }) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.length < 2 || (!matchWidth && !matchHeight)) return;

    final selectedComponent = state.selectedComponent;
    final reference =
        selectedComponent != null && selectedIds.contains(selectedComponent.id)
            ? selectedComponent
            : state.components.firstWhere(
              (component) => selectedIds.contains(component.id),
            );

    resizeSelectedComponents(
      width: matchWidth ? reference.size.width : null,
      height: matchHeight ? reference.size.height : null,
    );
  }

  void snapSelectedToGrid() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _snapComponentsToLayoutRules(selectedIds);
  }

  void snapSelectedSizeToGrid() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _snapComponentSizesToLayoutRules(selectedIds);
  }

  void snapVisibleComponentsToLayoutRules() {
    final visibleIds =
        state.components
            .where((component) => component.isVisible)
            .map((component) => component.id)
            .toSet();
    if (visibleIds.isEmpty) return;

    _snapComponentsToLayoutRules(visibleIds, expandGroups: false);
  }

  void snapVisibleComponentSizesToLayoutRules() {
    final visibleIds =
        state.components
            .where((component) => component.isVisible)
            .map((component) => component.id)
            .toSet();
    if (visibleIds.isEmpty) return;

    _snapComponentSizesToLayoutRules(visibleIds, expandGroups: false);
  }

  void _snapComponentsToLayoutRules(
    Iterable<String> ids, {
    bool expandGroups = true,
  }) {
    final targetIds =
        expandGroups
            ? _expandGroupedIds(ids)
            : ids.where(state.componentsById.containsKey).toSet();
    if (targetIds.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!targetIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextPosition = _snapOffsetToLayoutRules(component.position);
          if ((nextPosition - component.position).distance < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void _snapComponentSizesToLayoutRules(
    Iterable<String> ids, {
    bool expandGroups = true,
  }) {
    final targetIds =
        expandGroups
            ? _expandGroupedIds(ids)
            : ids.where(state.componentsById.containsKey).toSet();
    if (targetIds.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!targetIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextSize = _snapSizeToLayoutRules(component.size);
          if ((nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void _moveSelectedByLayoutRuleStep(Offset delta) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextPosition = _snapOffsetToLayoutRules(
            component.position + delta,
          );
          if ((nextPosition - component.position).distance < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void _moveSelectedToTabularStart({int? column, int? row}) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final bounds = _componentsBounds(movableComponents);
    final targetLeft =
        column == null ? bounds.left : _tabularColumnStartOffset(column);
    final targetTop = row == null ? bounds.top : _tabularRowStartOffset(row);

    _moveSelectedByLayoutRuleStep(
      Offset(targetLeft - bounds.left, targetTop - bounds.top),
    );
  }

  void _moveSelectedToAutoGridStart({int? column, int? row}) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final bounds = _componentsBounds(movableComponents);
    final targetLeft =
        column == null ? bounds.left : _autoGridColumnStartOffset(column);
    final targetTop = row == null ? bounds.top : _autoGridRowStartOffset(row);

    _moveSelectedByLayoutRuleStep(
      Offset(targetLeft - bounds.left, targetTop - bounds.top),
    );
  }

  void _arrangeComponentsIntoAutoGrid(
    Iterable<String> ids, {
    bool expandGroups = true,
  }) {
    final targetIds =
        expandGroups
            ? _expandGroupedIds(ids)
            : ids.where(state.componentsById.containsKey).toSet();
    if (targetIds.isEmpty) return;

    final targetComponents =
        state.components
            .where(
              (component) =>
                  targetIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (targetComponents.isEmpty) return;

    final sortedComponents = [...targetComponents]..sort((a, b) {
      final verticalCompare = a.position.dy.compareTo(b.position.dy);
      if (verticalCompare != 0) return verticalCompare;
      return a.position.dx.compareTo(b.position.dx);
    });
    final start = _snapOffsetToAutoGrid(
      _componentsBounds(sortedComponents).topLeft,
    );

    _moveComponentsToFreeAutoGridCells(
      targetIds,
      expandGroups: false,
      startAt: start,
    );
  }

  void _moveComponentsToFreeAutoGridCells(
    Iterable<String> ids, {
    bool expandGroups = true,
    Offset? startAt,
  }) {
    final targetIds =
        expandGroups
            ? _expandGroupedIds(ids)
            : ids.where(state.componentsById.containsKey).toSet();
    if (targetIds.isEmpty) return;

    final targetComponents =
        state.components
            .where(
              (component) =>
                  targetIds.contains(component.id) &&
                  component.isVisible &&
                  !component.isLocked,
            )
            .toList();
    if (targetComponents.isEmpty) return;

    final sortedComponents = [...targetComponents]..sort((a, b) {
      final verticalCompare = a.position.dy.compareTo(b.position.dy);
      if (verticalCompare != 0) return verticalCompare;
      return a.position.dx.compareTo(b.position.dx);
    });
    final config = state.config;
    final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
    final trackWidth = _autoGridColumnTrackWidth();
    final rowTrackHeight = _autoGridRowTrackHeight();
    if (trackWidth <= 0 || rowTrackHeight <= 0) return;

    final movableIds =
        sortedComponents.map((component) => component.id).toSet();
    final occupiedCells = _autoGridOccupiedCells(
      excludedIds: movableIds,
      columnCount: columnCount,
      trackWidth: trackWidth,
      rowTrackHeight: rowTrackHeight,
    );
    final selectionStart = _snapOffsetToAutoGrid(
      startAt ?? _componentsBounds(sortedComponents).topLeft,
    );
    var searchIndex = _autoGridSearchIndexForPosition(
      selectionStart,
      columnCount,
      trackWidth,
      rowTrackHeight,
    );
    final nextPositions = <String, Offset>{};
    final nextSizes = <String, Size>{};

    for (final component in sortedComponents) {
      final nextSize = _snapSizeToAutoGrid(component.size);
      final columnSpan = _autoGridColumnSpanForWidth(nextSize.width);
      final rowSpan = _autoGridRowSpanForHeight(nextSize.height);
      final nextPlacement = _firstFreeAutoGridPlacement(
        occupiedCells: occupiedCells,
        columnCount: columnCount,
        columnSpan: columnSpan,
        rowSpan: rowSpan,
        startIndex: searchIndex,
      );
      if (nextPlacement == null) return;

      nextPositions[component.id] = Offset(
        nextPlacement.column * trackWidth,
        nextPlacement.row * rowTrackHeight,
      );
      nextSizes[component.id] = nextSize;
      _occupyAutoGridCells(occupiedCells, nextPlacement);
      searchIndex =
          nextPlacement.row * columnCount +
          nextPlacement.column +
          nextPlacement.columnSpan;
    }

    final selectedIds = _activeSelectedIds();
    var changed = false;
    final nextComponents =
        state.components.map((component) {
          final nextPosition = nextPositions[component.id];
          final nextSize = nextSizes[component.id];
          if (nextPosition == null || nextSize == null) return component;

          if ((nextPosition - component.position).distance < 0.01 &&
              (nextSize.width - component.size.width).abs() < 0.01 &&
              (nextSize.height - component.size.height).abs() < 0.01) {
            return component;
          }

          changed = true;
          return component.copyWith(position: nextPosition, size: nextSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void moveComponentInsideCanvas(String id, Size canvasSize) {
    final component = state.componentsById[id];
    if (component == null) return;

    final maxX = canvasSize.width - component.size.width;
    final maxY = canvasSize.height - component.size.height;
    final nextPosition = Offset(
      component.position.dx.clamp(0, maxX < 0 ? 0 : maxX).toDouble(),
      component.position.dy.clamp(0, maxY < 0 ? 0 : maxY).toDouble(),
    );

    _commitComponents(
      state.components.map((component) {
        if (component.id != id) return component;
        return component.copyWith(position: nextPosition);
      }).toList(),
      selectedComponentId: id,
      selectedComponentIds: {id},
    );
  }

  void moveSelectedInsideCanvas({Size? canvasSize}) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final maxLeft = resolvedCanvasSize.width - bounds.width;
    final maxTop = resolvedCanvasSize.height - bounds.height;
    final nextLeft =
        bounds.width > resolvedCanvasSize.width
            ? 0.0
            : bounds.left.clamp(0.0, maxLeft < 0 ? 0.0 : maxLeft).toDouble();
    final nextTop =
        bounds.height > resolvedCanvasSize.height
            ? 0.0
            : bounds.top.clamp(0.0, maxTop < 0 ? 0.0 : maxTop).toDouble();
    final delta = Offset(nextLeft - bounds.left, nextTop - bounds.top);

    if (delta.distance < 0.01) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(position: component.position + delta);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void moveSelectedToCanvasOrigin({double padding = 0}) {
    moveSelectedToCanvasCorner(CanvasCorner.topLeft, padding: padding);
  }

  void moveSelectedToCanvasCorner(
    CanvasCorner corner, {
    Size? canvasSize,
    double padding = 0,
  }) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final targetLeft = switch (corner) {
      CanvasCorner.topLeft || CanvasCorner.bottomLeft => safePadding,
      CanvasCorner.topRight || CanvasCorner.bottomRight => math.max(
        safePadding,
        resolvedCanvasSize.width - bounds.width - safePadding,
      ),
    };
    final targetTop = switch (corner) {
      CanvasCorner.topLeft || CanvasCorner.topRight => safePadding,
      CanvasCorner.bottomLeft || CanvasCorner.bottomRight => math.max(
        safePadding,
        resolvedCanvasSize.height - bounds.height - safePadding,
      ),
    };
    final delta = Offset(targetLeft - bounds.left, targetTop - bounds.top);
    if (delta.distance < 0.01) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          position: _snapOffset(component.position + delta),
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void moveSelectedToCanvasEdge(
    CanvasEdge edge, {
    Size? canvasSize,
    double padding = 0,
  }) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final centeredLeft = math.max(
      safePadding,
      (resolvedCanvasSize.width - bounds.width) / 2,
    );
    final centeredTop = math.max(
      safePadding,
      (resolvedCanvasSize.height - bounds.height) / 2,
    );
    final targetLeft = switch (edge) {
      CanvasEdge.left => safePadding,
      CanvasEdge.right => math.max(
        safePadding,
        resolvedCanvasSize.width - bounds.width - safePadding,
      ),
      CanvasEdge.top || CanvasEdge.bottom => centeredLeft,
    };
    final targetTop = switch (edge) {
      CanvasEdge.top => safePadding,
      CanvasEdge.bottom => math.max(
        safePadding,
        resolvedCanvasSize.height - bounds.height - safePadding,
      ),
      CanvasEdge.left || CanvasEdge.right => centeredTop,
    };
    final delta = Offset(targetLeft - bounds.left, targetTop - bounds.top);
    if (delta.distance < 0.01) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          position: _snapOffset(component.position + delta),
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void pinSelectedToCanvasEdge(
    CanvasEdge edge, {
    Size? canvasSize,
    double padding = 0,
  }) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final targetLeft = switch (edge) {
      CanvasEdge.left => safePadding,
      CanvasEdge.right => math.max(
        safePadding,
        resolvedCanvasSize.width - bounds.width - safePadding,
      ),
      CanvasEdge.top || CanvasEdge.bottom => bounds.left,
    };
    final targetTop = switch (edge) {
      CanvasEdge.top => safePadding,
      CanvasEdge.bottom => math.max(
        safePadding,
        resolvedCanvasSize.height - bounds.height - safePadding,
      ),
      CanvasEdge.left || CanvasEdge.right => bounds.top,
    };
    final delta = Offset(targetLeft - bounds.left, targetTop - bounds.top);
    if (delta.distance < 0.01) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          position: _snapOffset(component.position + delta),
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void fitSelectedInsideCanvas({Size? canvasSize, double padding = 24}) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final safePadding = padding.clamp(0.0, double.infinity).toDouble();
    final targetWidth = math.max(
      state.config.minComponentWidth,
      resolvedCanvasSize.width - safePadding * 2,
    );
    final targetHeight = math.max(
      state.config.minComponentHeight,
      resolvedCanvasSize.height - safePadding * 2,
    );
    final scale = math.min(
      1.0,
      math.min(targetWidth / bounds.width, targetHeight / bounds.height),
    );

    final scaledPositions = <String, Offset>{};
    final scaledSizes = <String, Size>{};
    for (final component in movableComponents) {
      final relativePosition = component.position - bounds.topLeft;
      scaledPositions[component.id] = relativePosition * scale;
      scaledSizes[component.id] = _snapConstrainedSize(
        component,
        Size(component.size.width * scale, component.size.height * scale),
      );
    }

    final fittedBounds = _componentsGeometryBounds(
      movableComponents,
      scaledPositions,
      scaledSizes,
    );
    final targetOrigin = Offset(
      (resolvedCanvasSize.width - fittedBounds.width) / 2,
      (resolvedCanvasSize.height - fittedBounds.height) / 2,
    );
    var changed = false;

    final nextComponents =
        state.components.map((component) {
          final relativePosition = scaledPositions[component.id];
          final scaledSize = scaledSizes[component.id];
          if (relativePosition == null ||
              scaledSize == null ||
              component.isLocked) {
            return component;
          }

          final nextPosition = _snapOffset(
            targetOrigin + relativePosition - fittedBounds.topLeft,
          );
          if ((nextPosition - component.position).distance >= 0.01 ||
              (scaledSize.width - component.size.width).abs() >= 0.01 ||
              (scaledSize.height - component.size.height).abs() >= 0.01) {
            changed = true;
          }

          return component.copyWith(position: nextPosition, size: scaledSize);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void resizeComponent(String id, Rect newBounds) {
    if (!state.isEditMode) return;
    _updateComponent(
      id,
      (component) => component.copyWith(
        position: _snapOffset(newBounds.topLeft),
        size: _snapConstrainedSize(component, newBounds.size),
      ),
    );
  }

  void updateComponentStyle(String id, ComponentStyle newStyle) {
    _updateComponent(id, (component) => component.copyWith(style: newStyle));
  }

  void updateComponentProperties(String id, ComponentProperties newProperties) {
    _updateComponent(
      id,
      (component) => component.copyWith(properties: newProperties),
    );
  }

  void updateComponentConstraints(String id, ComponentConstraints constraints) {
    _updateComponent(
      id,
      (component) => component.copyWith(constraints: constraints),
    );
  }

  void resetComponentConstraints(String id) {
    updateComponentConstraints(id, const ComponentConstraints());
  }

  void renameComponent(String id, String name) {
    _updateComponent(
      id,
      (component) => _componentWithLayerName(component, name),
    );
  }

  void renameComponents(Map<String, String> namesById) {
    if (namesById.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    final targetIds = namesById.keys.toSet();

    _commitComponents(
      state.components.map((component) {
        final name = namesById[component.id];
        if (name == null || component.isLocked) return component;
        return _componentWithLayerName(component, name);
      }).toList(),
      selectedComponentId:
          selectedIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : targetIds.first,
      selectedComponentIds: selectedIds.isEmpty ? targetIds : selectedIds,
    );
  }

  ComponentData _componentWithLayerName(ComponentData component, String name) {
    final attributes = Map<String, dynamic>.from(
      component.properties.attributes,
    );
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      attributes.remove('name');
    } else {
      attributes['name'] = trimmedName;
    }

    return component.copyWith(
      properties: component.properties.copyWith(attributes: attributes),
    );
  }

  void updateResponsiveProperties(
    String id,
    String deviceKey,
    ComponentResponsiveProperties properties,
  ) {
    _updateComponent(
      id,
      (component) => component.copyWith(
        responsiveProperties: {
          ...component.responsiveProperties,
          deviceKey: properties,
        },
      ),
    );
  }

  void setResponsivePropertiesFromBase(String id, String deviceKey) {
    setResponsivePropertiesFromBaseForDevices(id, [deviceKey]);
  }

  void setResponsivePropertiesFromBaseForDevices(
    String id,
    Iterable<String> deviceKeys,
  ) {
    final keys = deviceKeys.where((key) => key.isNotEmpty).toSet();
    if (keys.isEmpty) return;

    _updateComponent(id, (component) {
      final baseProperties = ComponentResponsiveProperties(
        position: component.position,
        size: component.size,
        isVisible: component.isVisible,
      );

      return component.copyWith(
        responsiveProperties: {
          ...component.responsiveProperties,
          for (final key in keys) key: baseProperties,
        },
      );
    });
  }

  void setSelectedResponsivePropertiesFromBase(String deviceKey) {
    setSelectedResponsivePropertiesFromBaseForDevices([deviceKey]);
  }

  void setSelectedResponsivePropertiesFromBaseForDevices(
    Iterable<String> deviceKeys,
  ) {
    final keys = deviceKeys.where((key) => key.isNotEmpty).toSet();
    if (keys.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        final baseProperties = ComponentResponsiveProperties(
          position: component.position,
          size: component.size,
          isVisible: component.isVisible,
        );

        return component.copyWith(
          responsiveProperties: {
            ...component.responsiveProperties,
            for (final key in keys) key: baseProperties,
          },
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void applyResponsiveConstraints(
    String id,
    String deviceKey,
    Size deviceSize,
  ) {
    applyResponsiveConstraintsForDevices(id, {deviceKey: deviceSize});
  }

  void applyResponsiveConstraintsForDevices(
    String id,
    Map<String, Size> deviceSizes,
  ) {
    final targets = _validResponsiveDeviceSizes(deviceSizes);
    if (targets.isEmpty) return;

    _updateComponent(
      id,
      (component) =>
          _componentWithResponsiveConstraintOverrides(component, targets),
    );
  }

  void applySelectedResponsiveConstraints(String deviceKey, Size deviceSize) {
    applySelectedResponsiveConstraintsForDevices({deviceKey: deviceSize});
  }

  void applySelectedResponsiveConstraintsForDevices(
    Map<String, Size> deviceSizes,
  ) {
    final targets = _validResponsiveDeviceSizes(deviceSizes);
    if (targets.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) ||
              component.isLocked ||
              !component.constraints.hasCustomRules) {
            return component;
          }

          final nextComponent = _componentWithResponsiveConstraintOverrides(
            component,
            targets,
          );
          if (nextComponent != component) changed = true;
          return nextComponent;
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void copyResponsivePropertiesToDevices(
    String id,
    String sourceDeviceKey,
    Iterable<String> targetDeviceKeys,
  ) {
    final keys =
        targetDeviceKeys
            .where((key) => key.isNotEmpty && key != sourceDeviceKey)
            .toSet();
    if (keys.isEmpty) return;

    _updateComponent(id, (component) {
      final sourceProperties = _effectiveResponsiveProperties(
        component,
        sourceDeviceKey,
      );

      return component.copyWith(
        responsiveProperties: {
          ...component.responsiveProperties,
          for (final key in keys) key: sourceProperties,
        },
      );
    });
  }

  void copySelectedResponsivePropertiesToDevices(
    String sourceDeviceKey,
    Iterable<String> targetDeviceKeys,
  ) {
    final keys =
        targetDeviceKeys
            .where((key) => key.isNotEmpty && key != sourceDeviceKey)
            .toSet();
    if (keys.isEmpty) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        final sourceProperties = _effectiveResponsiveProperties(
          component,
          sourceDeviceKey,
        );

        return component.copyWith(
          responsiveProperties: {
            ...component.responsiveProperties,
            for (final key in keys) key: sourceProperties,
          },
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void clearResponsiveProperties(String id, String deviceKey) {
    _updateComponent(id, (component) {
      final responsiveProperties = {...component.responsiveProperties}
        ..remove(deviceKey);
      return component.copyWith(responsiveProperties: responsiveProperties);
    });
  }

  void promoteResponsivePropertiesToBase(String id, String deviceKey) {
    _updateComponent(
      id,
      (component) => _promotedResponsiveComponent(component, deviceKey),
    );
  }

  void promoteSelectedResponsivePropertiesToBase(String deviceKey) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) ||
            component.isLocked ||
            !component.responsiveProperties.containsKey(deviceKey)) {
          return component;
        }

        return _snapComponent(
          _promotedResponsiveComponent(component, deviceKey),
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void clearSelectedResponsiveProperties(String deviceKey) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        final responsiveProperties = {...component.responsiveProperties}
          ..remove(deviceKey);
        return component.copyWith(responsiveProperties: responsiveProperties);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  ComponentResponsiveProperties _effectiveResponsiveProperties(
    ComponentData component,
    String deviceKey,
  ) {
    final override = component.responsiveProperties[deviceKey];

    return ComponentResponsiveProperties(
      position: override?.position ?? component.position,
      size: override?.size ?? component.size,
      isVisible: override?.isVisible ?? component.isVisible,
    );
  }

  Map<String, Size> _validResponsiveDeviceSizes(Map<String, Size> deviceSizes) {
    return {
      for (final entry in deviceSizes.entries)
        if (entry.key.isNotEmpty &&
            entry.value.width.isFinite &&
            entry.value.height.isFinite &&
            entry.value.width > 0 &&
            entry.value.height > 0)
          entry.key: LayoutConfig.normalizeCanvasSize(entry.value),
    };
  }

  ComponentData _componentWithResponsiveConstraintOverrides(
    ComponentData component,
    Map<String, Size> deviceSizes,
  ) {
    if (component.isLocked || !component.constraints.hasCustomRules) {
      return component;
    }

    var changed = false;
    final responsiveProperties = {...component.responsiveProperties};

    for (final entry in deviceSizes.entries) {
      final deviceKey = entry.key;
      final nextProperties = _responsiveConstraintPropertiesFor(
        component,
        deviceKey,
        entry.value,
      );
      final currentProperties = responsiveProperties[deviceKey];
      if (_responsivePropertiesEqual(currentProperties, nextProperties)) {
        continue;
      }

      responsiveProperties[deviceKey] = nextProperties;
      changed = true;
    }

    return changed
        ? component.copyWith(responsiveProperties: responsiveProperties)
        : component;
  }

  ComponentResponsiveProperties _responsiveConstraintPropertiesFor(
    ComponentData component,
    String deviceKey,
    Size deviceSize,
  ) {
    final constrained = _componentConstrainedToCanvasResize(
      component,
      state.config.canvasSize,
      deviceSize,
    );
    final current = component.responsiveProperties[deviceKey];

    return ComponentResponsiveProperties(
      position: constrained.position,
      size: constrained.size,
      isVisible: current?.isVisible ?? component.isVisible,
    );
  }

  bool _responsivePropertiesEqual(
    ComponentResponsiveProperties? first,
    ComponentResponsiveProperties second,
  ) {
    if (first == null) return false;

    return _nullableOffsetsEqual(first.position, second.position) &&
        _nullableSizesEqual(first.size, second.size) &&
        first.isVisible == second.isVisible;
  }

  bool _nullableOffsetsEqual(Offset? first, Offset? second) {
    if (first == null || second == null) return first == second;
    return (first - second).distance < 0.01;
  }

  bool _nullableSizesEqual(Size? first, Size? second) {
    if (first == null || second == null) return first == second;
    return (first.width - second.width).abs() < 0.01 &&
        (first.height - second.height).abs() < 0.01;
  }

  ComponentData _promotedResponsiveComponent(
    ComponentData component,
    String deviceKey,
  ) {
    final responsiveProperties = {...component.responsiveProperties};
    final override = responsiveProperties.remove(deviceKey);
    if (override == null) return component;

    return component.copyWith(
      position: override.position ?? component.position,
      size: override.size ?? component.size,
      isVisible: override.isVisible ?? component.isVisible,
      responsiveProperties: responsiveProperties,
    );
  }

  void clearAllResponsiveProperties(String id) {
    _updateComponent(
      id,
      (component) => component.copyWith(
        responsiveProperties: const <String, ComponentResponsiveProperties>{},
      ),
    );
  }

  void clearAllSelectedResponsiveProperties() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          responsiveProperties: const <String, ComponentResponsiveProperties>{},
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void removeComponent(String id) {
    final nextComponents =
        state.components.where((component) => component.id != id).toList();
    final selectedIds = {...state.selectedComponentIds}..remove(id);
    _commitComponents(
      nextComponents,
      selectedComponentId:
          state.selectedComponentId == id
              ? selectedIds.isEmpty
                  ? null
                  : selectedIds.first
              : state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void removeSelectedComponent() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    removeComponents(selectedIds);
  }

  void removeComponents(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final selectedIds = {...state.selectedComponentIds}
      ..removeWhere(targetIds.contains);
    _commitComponents(
      state.components
          .where((component) => !targetIds.contains(component.id))
          .toList(),
      selectedComponentId:
          targetIds.contains(state.selectedComponentId)
              ? selectedIds.isEmpty
                  ? null
                  : selectedIds.first
              : state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void copySelectedComponent() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    copyComponents(selectedIds);
  }

  void copyComponents(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final copiedComponents =
        state.components
            .where((component) => targetIds.contains(component.id))
            .toList();
    if (copiedComponents.isEmpty) return;

    state = state.copyWith(clipboard: copiedComponents);
  }

  void pasteComponent() {
    final clipboard = state.clipboard;
    if (clipboard.isEmpty) return;

    final groupIdMap = <String, String>{};
    final pastedComponents =
        clipboard.map((component) {
          final parentId = component.properties.parentId;
          final pasted = component.duplicate();

          if (parentId == null) {
            return pasted.copyWith(
              properties: pasted.properties.copyWith(parentId: null),
            );
          }

          final nextParentId = groupIdMap.putIfAbsent(
            parentId,
            () => const Uuid().v4(),
          );

          return pasted.copyWith(
            properties: pasted.properties.copyWith(parentId: nextParentId),
          );
        }).toList();
    final pastedIds = pastedComponents.map((component) => component.id).toSet();

    _commitComponents(
      [...state.components, ...pastedComponents],
      selectedComponentId: pastedComponents.last.id,
      selectedComponentIds: pastedIds,
      clipboard: clipboard,
    );
  }

  void pasteComponentAt(Offset position) {
    final clipboard = state.clipboard;
    if (clipboard.isEmpty) return;

    final clipboardBounds = _componentsBounds(clipboard);
    final targetPosition = _snapOffset(position);
    final positionDelta = targetPosition - clipboardBounds.topLeft;
    final groupIdMap = <String, String>{};
    final pastedComponents =
        clipboard.map((component) {
          final parentId = component.properties.parentId;
          final pasted = component.duplicate(offset: Offset.zero);
          final pastedProperties =
              parentId == null
                  ? pasted.properties.copyWith(parentId: null)
                  : pasted.properties.copyWith(
                    parentId: groupIdMap.putIfAbsent(
                      parentId,
                      () => const Uuid().v4(),
                    ),
                  );

          return pasted.copyWith(
            position: _snapOffset(component.position + positionDelta),
            properties: pastedProperties,
          );
        }).toList();
    final pastedIds = pastedComponents.map((component) => component.id).toSet();

    _commitComponents(
      [...state.components, ...pastedComponents],
      selectedComponentId: pastedComponents.last.id,
      selectedComponentIds: pastedIds,
      clipboard: clipboard,
    );
  }

  void duplicateSelectedComponent() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    duplicateComponents(selectedIds);
  }

  void duplicateComponents(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final targetComponents =
        state.components
            .where((component) => targetIds.contains(component.id))
            .toList();
    if (targetComponents.isEmpty) return;

    final groupIdMap = <String, String>{};
    final duplicatedComponents =
        targetComponents.map((component) {
          final parentId = component.properties.parentId;
          final duplicated = component.duplicate();

          if (parentId == null) return duplicated;

          final nextParentId = groupIdMap.putIfAbsent(
            parentId,
            () => const Uuid().v4(),
          );

          return duplicated.copyWith(
            properties: duplicated.properties.copyWith(parentId: nextParentId),
          );
        }).toList();
    final duplicatedIds =
        duplicatedComponents.map((component) => component.id).toSet();

    _commitComponents(
      [...state.components, ...duplicatedComponents],
      selectedComponentId: duplicatedComponents.last.id,
      selectedComponentIds: duplicatedIds,
    );
  }

  void groupSelectedComponents() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.length < 2) return;

    groupComponents(selectedIds);
  }

  void groupComponents(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.length < 2) return;

    final groupId = const Uuid().v4();

    _commitComponents(
      state.components.map((component) {
        if (!targetIds.contains(component.id)) return component;
        return component.copyWith(
          properties: component.properties.copyWith(parentId: groupId),
        );
      }).toList(),
      selectedComponentId:
          targetIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : targetIds.first,
      selectedComponentIds: targetIds,
    );
  }

  void ungroupSelectedComponents() {
    final selectedComponents = state.selectedComponents;
    if (selectedComponents.isEmpty) return;

    ungroupComponents(
      selectedComponents.map((component) => component.id).toSet(),
    );
  }

  void ungroupComponents(Set<String> ids) {
    if (ids.isEmpty) return;

    final groupIds =
        state.components
            .where((component) => ids.contains(component.id))
            .map((component) => component.properties.parentId)
            .whereType<String>()
            .toSet();
    if (groupIds.isEmpty) return;

    final nextSelectedIds = <String>{};

    _commitComponents(
      state.components.map((component) {
        if (!groupIds.contains(component.properties.parentId)) {
          return component;
        }

        nextSelectedIds.add(component.id);
        return component.copyWith(
          properties: component.properties.copyWith(parentId: null),
        );
      }).toList(),
      selectedComponentId:
          nextSelectedIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : nextSelectedIds.isEmpty
              ? null
              : nextSelectedIds.first,
      selectedComponentIds: nextSelectedIds,
    );
  }

  void toggleComponentLock(String id) {
    _commitComponents(
      state.components.map((component) {
        if (component.id != id) return component;
        return component.copyWith(isLocked: !component.isLocked);
      }).toList(),
      selectedComponentId: id,
    );
  }

  void toggleSelectedComponentLock() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;
    final selectedComponents =
        state.components
            .where((component) => selectedIds.contains(component.id))
            .toList();
    final shouldLock = selectedComponents.any(
      (component) => !component.isLocked,
    );

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id)) return component;
        return component.copyWith(isLocked: shouldLock);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void setComponentsLock(Set<String> ids, bool isLocked) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!targetIds.contains(component.id)) return component;
        return component.copyWith(isLocked: isLocked);
      }).toList(),
      selectedComponentId:
          targetIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : targetIds.first,
      selectedComponentIds: targetIds,
    );
  }

  void setAllComponentsLock(bool isLocked) {
    if (state.components.isEmpty ||
        state.components.every((component) => component.isLocked == isLocked)) {
      return;
    }

    final selectedIds = _activeSelectedIds();
    _commitComponents(
      state.components.map((component) {
        if (component.isLocked == isLocked) return component;
        return component.copyWith(isLocked: isLocked);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds.isEmpty ? null : selectedIds,
    );
  }

  void unlockAllComponents() {
    setAllComponentsLock(false);
  }

  void toggleComponentVisibility(String id) {
    _updateComponent(
      id,
      (component) => component.copyWith(isVisible: !component.isVisible),
    );
  }

  void toggleSelectedComponentVisibility() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;
    final selectedComponents =
        state.components
            .where((component) => selectedIds.contains(component.id))
            .toList();
    final shouldShow = selectedComponents.any(
      (component) => !component.isVisible,
    );

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id)) return component;
        return component.copyWith(isVisible: shouldShow);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void setComponentsVisibility(Set<String> ids, bool isVisible) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    _commitComponents(
      state.components.map((component) {
        if (!targetIds.contains(component.id)) return component;
        return component.copyWith(isVisible: isVisible);
      }).toList(),
      selectedComponentId:
          targetIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : targetIds.first,
      selectedComponentIds: targetIds,
    );
  }

  void setAllComponentsVisibility(bool isVisible) {
    if (state.components.isEmpty ||
        state.components.every(
          (component) => component.isVisible == isVisible,
        )) {
      return;
    }

    final selectedIds = _activeSelectedIds();
    _commitComponents(
      state.components.map((component) {
        if (component.isVisible == isVisible) return component;
        return component.copyWith(isVisible: isVisible);
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds.isEmpty ? null : selectedIds,
    );
  }

  void showAllComponents() {
    setAllComponentsVisibility(true);
  }

  void showOnlySelectedComponents() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    showOnlyComponents(selectedIds);
  }

  void showOnlyComponents(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final visibilitySnapshot =
        state.visibilitySnapshot ??
        {
          for (final component in state.components)
            component.id: component.isVisible,
        };
    final nextComponents =
        state.components.map((component) {
          final shouldShow = targetIds.contains(component.id);
          if (component.isVisible == shouldShow) return component;
          return component.copyWith(isVisible: shouldShow);
        }).toList();

    final hasChanges = state.components.asMap().entries.any((entry) {
      return entry.value.isVisible != nextComponents[entry.key].isVisible;
    });
    if (!hasChanges) return;

    _commitComponents(
      nextComponents,
      selectedComponentId:
          targetIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : targetIds.first,
      selectedComponentIds: targetIds,
    );
    state = state.copyWith(visibilitySnapshot: visibilitySnapshot);
  }

  void restoreVisibilitySnapshot() {
    final visibilitySnapshot = state.visibilitySnapshot;
    if (visibilitySnapshot == null || visibilitySnapshot.isEmpty) return;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          final isVisible = visibilitySnapshot[component.id];
          if (isVisible == null || component.isVisible == isVisible) {
            return component;
          }

          changed = true;
          return component.copyWith(isVisible: isVisible);
        }).toList();

    if (!changed) {
      state = state.copyWith(visibilitySnapshot: null);
      return;
    }

    final selectedIds = _activeSelectedIds();
    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds.isEmpty ? null : selectedIds,
    );
    state = state.copyWith(visibilitySnapshot: null);
  }

  void bringForward(String id) {
    final index = state.components.indexWhere(
      (component) => component.id == id,
    );
    if (index == -1 || index == state.components.length - 1) return;
    final components = [...state.components];
    final component = components.removeAt(index);
    components.insert(index + 1, component);
    _commitComponents(components, selectedComponentId: id);
  }

  void bringToFront(String id) {
    final index = state.components.indexWhere(
      (component) => component.id == id,
    );
    if (index == -1 || index == state.components.length - 1) return;
    final components = [...state.components];
    final component = components.removeAt(index);
    components.add(component);
    _commitComponents(components, selectedComponentId: id);
  }

  void sendBackward(String id) {
    final index = state.components.indexWhere(
      (component) => component.id == id,
    );
    if (index <= 0) return;
    final components = [...state.components];
    final component = components.removeAt(index);
    components.insert(index - 1, component);
    _commitComponents(components, selectedComponentId: id);
  }

  void sendToBack(String id) {
    final index = state.components.indexWhere(
      (component) => component.id == id,
    );
    if (index <= 0) return;
    final components = [...state.components];
    final component = components.removeAt(index);
    components.insert(0, component);
    _commitComponents(components, selectedComponentId: id);
  }

  void bringSelectedForward() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final components = [...state.components];
    var changed = false;

    for (var index = components.length - 2; index >= 0; index--) {
      final current = components[index];
      final next = components[index + 1];
      if (!selectedIds.contains(current.id) || selectedIds.contains(next.id)) {
        continue;
      }

      components[index] = next;
      components[index + 1] = current;
      changed = true;
    }

    if (!changed) return;
    _commitSelectedArrangement(components, selectedIds);
  }

  void bringSelectedToFront() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    bringComponentsToFront(selectedIds);
  }

  void bringComponentsToFront(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final selected = <ComponentData>[];
    final unselected = <ComponentData>[];

    for (final component in state.components) {
      if (targetIds.contains(component.id)) {
        selected.add(component);
      } else {
        unselected.add(component);
      }
    }

    if (selected.isEmpty || unselected.isEmpty) return;
    _commitSelectedArrangement([...unselected, ...selected], targetIds);
  }

  void sendSelectedBackward() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final components = [...state.components];
    var changed = false;

    for (var index = 1; index < components.length; index++) {
      final previous = components[index - 1];
      final current = components[index];
      if (!selectedIds.contains(current.id) ||
          selectedIds.contains(previous.id)) {
        continue;
      }

      components[index - 1] = current;
      components[index] = previous;
      changed = true;
    }

    if (!changed) return;
    _commitSelectedArrangement(components, selectedIds);
  }

  void sendSelectedToBack() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    sendComponentsToBack(selectedIds);
  }

  void sendComponentsToBack(Set<String> ids) {
    final targetIds = _expandGroupedIds(ids);
    if (targetIds.isEmpty) return;

    final selected = <ComponentData>[];
    final unselected = <ComponentData>[];

    for (final component in state.components) {
      if (targetIds.contains(component.id)) {
        selected.add(component);
      } else {
        unselected.add(component);
      }
    }

    if (selected.isEmpty || unselected.isEmpty) return;
    _commitSelectedArrangement([...selected, ...unselected], targetIds);
  }

  void reorderComponents(List<String> orderedIds) {
    if (orderedIds.length != state.components.length) return;

    final componentsById = state.componentsById;
    final nextComponents = <ComponentData>[];

    for (final id in orderedIds) {
      final component = componentsById[id];
      if (component == null) return;
      nextComponents.add(component);
    }

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
    );
  }

  void _commitSelectedArrangement(
    List<ComponentData> components,
    Set<String> selectedIds,
  ) {
    _commitComponents(
      components,
      selectedComponentId:
          selectedIds.contains(state.selectedComponentId)
              ? state.selectedComponentId
              : selectedIds.first,
      selectedComponentIds: selectedIds,
    );
  }

  void alignSelected(ComponentAlignment alignment) {
    final selectedComponents = state.selectedComponents;
    if (selectedComponents.isEmpty) return;

    final canvasSize = state.config.canvasSize;
    final selectedIds =
        selectedComponents.map((component) => component.id).toSet();
    final selectionBounds =
        selectedComponents.length > 1
            ? _componentsBounds(selectedComponents)
            : null;

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          if (!selectedIds.contains(component.id) || component.isLocked) {
            return component;
          }

          final nextPosition = _alignedPosition(
            component,
            alignment,
            canvasSize,
            selectionBounds,
          );

          if ((nextPosition - component.position).distance >= 0.01) {
            changed = true;
          }

          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void centerSelectedOnCanvas({
    bool horizontal = true,
    bool vertical = true,
    Size? canvasSize,
  }) {
    if (!horizontal && !vertical) return;

    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.isEmpty) return;

    final resolvedCanvasSize = canvasSize ?? state.config.canvasSize;
    final bounds = _componentsBounds(movableComponents);
    final targetLeft = (resolvedCanvasSize.width - bounds.width) / 2;
    final targetTop = (resolvedCanvasSize.height - bounds.height) / 2;
    final delta = Offset(
      horizontal ? targetLeft - bounds.left : 0,
      vertical ? targetTop - bounds.top : 0,
    );
    if (delta.distance < 0.01) return;

    _commitComponents(
      state.components.map((component) {
        if (!selectedIds.contains(component.id) || component.isLocked) {
          return component;
        }

        return component.copyWith(
          position: _snapOffset(component.position + delta),
        );
      }).toList(),
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  Offset _alignedPosition(
    ComponentData component,
    ComponentAlignment alignment,
    Size canvasSize,
    Rect? selectionBounds,
  ) {
    final targetBounds = selectionBounds ?? Offset.zero & canvasSize;

    switch (alignment) {
      case ComponentAlignment.left:
        return Offset(targetBounds.left, component.position.dy);
      case ComponentAlignment.center:
        return Offset(
          targetBounds.center.dx - component.size.width / 2,
          component.position.dy,
        );
      case ComponentAlignment.right:
        return Offset(
          targetBounds.right - component.size.width,
          component.position.dy,
        );
      case ComponentAlignment.top:
        return Offset(component.position.dx, targetBounds.top);
      case ComponentAlignment.middle:
        return Offset(
          component.position.dx,
          targetBounds.center.dy - component.size.height / 2,
        );
      case ComponentAlignment.bottom:
        return Offset(
          component.position.dx,
          targetBounds.bottom - component.size.height,
        );
    }
  }

  void distributeSelected(ComponentDistribution distribution) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.length < 3) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.length < 3) return;

    final sortedComponents = [...movableComponents]..sort((a, b) {
      final aValue =
          distribution == ComponentDistribution.horizontal
              ? a.position.dx
              : a.position.dy;
      final bValue =
          distribution == ComponentDistribution.horizontal
              ? b.position.dx
              : b.position.dy;
      return aValue.compareTo(bValue);
    });
    final bounds = _componentsBounds(sortedComponents);
    final totalSize = sortedComponents.fold<double>(
      0,
      (sum, component) =>
          sum +
          (distribution == ComponentDistribution.horizontal
              ? component.size.width
              : component.size.height),
    );
    final availableSpace =
        (distribution == ComponentDistribution.horizontal
            ? bounds.width
            : bounds.height) -
        totalSize;
    final gap = availableSpace / (sortedComponents.length - 1);
    var cursor =
        distribution == ComponentDistribution.horizontal
            ? bounds.left
            : bounds.top;
    final nextPositions = <String, Offset>{};

    for (final component in sortedComponents) {
      nextPositions[component.id] =
          distribution == ComponentDistribution.horizontal
              ? Offset(cursor, component.position.dy)
              : Offset(component.position.dx, cursor);
      cursor +=
          (distribution == ComponentDistribution.horizontal
              ? component.size.width
              : component.size.height) +
          gap;
    }

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          final position = nextPositions[component.id];
          if (position == null) return component;

          final nextPosition = _snapOffset(position);
          if ((nextPosition - component.position).distance >= 0.01) {
            changed = true;
          }

          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void stackSelectedComponents(ComponentDistribution direction) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.length < 2) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.length < 2) return;

    final sortedComponents = [...movableComponents]..sort((a, b) {
      final aValue =
          direction == ComponentDistribution.horizontal
              ? a.position.dx
              : a.position.dy;
      final bValue =
          direction == ComponentDistribution.horizontal
              ? b.position.dx
              : b.position.dy;
      return aValue.compareTo(bValue);
    });
    final bounds = _componentsBounds(sortedComponents);
    final gap =
        state.gridSettings.snapToGrid
            ? state.gridSettings.gridSize
            : state.config.gridSize;
    var cursor =
        direction == ComponentDistribution.horizontal
            ? bounds.left
            : bounds.top;
    final nextPositions = <String, Offset>{};

    for (final component in sortedComponents) {
      nextPositions[component.id] =
          direction == ComponentDistribution.horizontal
              ? Offset(cursor, bounds.top)
              : Offset(bounds.left, cursor);
      cursor +=
          (direction == ComponentDistribution.horizontal
              ? component.size.width
              : component.size.height) +
          gap;
    }

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          final position = nextPositions[component.id];
          if (position == null) return component;

          final nextPosition = _snapOffset(position);
          if ((nextPosition - component.position).distance >= 0.01) {
            changed = true;
          }

          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void spaceSelectedComponents(ComponentDistribution direction, double gap) {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.length < 2) return;

    final movableComponents =
        state.components
            .where(
              (component) =>
                  selectedIds.contains(component.id) && !component.isLocked,
            )
            .toList();
    if (movableComponents.length < 2) return;

    final sortedComponents = [...movableComponents]..sort((a, b) {
      final aValue =
          direction == ComponentDistribution.horizontal
              ? a.position.dx
              : a.position.dy;
      final bValue =
          direction == ComponentDistribution.horizontal
              ? b.position.dx
              : b.position.dy;
      return aValue.compareTo(bValue);
    });
    final normalizedGap = gap < 0 ? 0.0 : gap;
    var cursor =
        direction == ComponentDistribution.horizontal
            ? sortedComponents.first.position.dx
            : sortedComponents.first.position.dy;
    final nextPositions = <String, Offset>{};

    for (final component in sortedComponents) {
      nextPositions[component.id] =
          direction == ComponentDistribution.horizontal
              ? Offset(cursor, component.position.dy)
              : Offset(component.position.dx, cursor);
      cursor +=
          (direction == ComponentDistribution.horizontal
              ? component.size.width
              : component.size.height) +
          normalizedGap;
    }

    var changed = false;
    final nextComponents =
        state.components.map((component) {
          final position = nextPositions[component.id];
          if (position == null) return component;

          final nextPosition = _snapOffset(position);
          if ((nextPosition - component.position).distance >= 0.01) {
            changed = true;
          }

          return component.copyWith(position: nextPosition);
        }).toList();

    if (!changed) return;

    _commitComponents(
      nextComponents,
      selectedComponentId: state.selectedComponentId,
      selectedComponentIds: selectedIds,
    );
  }

  void _updateComponent(
    String id,
    ComponentData Function(ComponentData component) update,
  ) {
    _commitComponents(
      state.components.map((component) {
        if (component.id != id || component.isLocked) return component;
        return _snapComponent(update(component));
      }).toList(),
      selectedComponentId: id,
    );
  }

  void _commitComponents(
    List<ComponentData> components, {
    String? selectedComponentId,
    Set<String>? selectedComponentIds,
    List<ComponentData>? clipboard,
  }) {
    final componentIds = components.map((component) => component.id).toSet();
    final componentsById = {
      for (final component in components) component.id: component,
    };
    final requestedSelectedIds =
        selectedComponentIds ??
        (selectedComponentId == null
            ? const <String>{}
            : <String>{selectedComponentId});
    final expandedSelectedIds = <String>{};

    for (final id in requestedSelectedIds.where(componentIds.contains)) {
      final component = componentsById[id];
      final parentId = component?.properties.parentId;
      if (parentId == null) {
        expandedSelectedIds.add(id);
        continue;
      }

      expandedSelectedIds.addAll(
        components
            .where((component) => component.properties.parentId == parentId)
            .map((component) => component.id),
      );
    }

    final normalizedSelectedIds =
        expandedSelectedIds.where(componentIds.contains).toSet();
    final normalizedSelectedComponentId =
        selectedComponentId != null &&
                normalizedSelectedIds.contains(selectedComponentId)
            ? selectedComponentId
            : normalizedSelectedIds.isEmpty
            ? null
            : normalizedSelectedIds.first;

    if (_interactionStartComponents != null) {
      state = state.copyWith(
        components: components,
        selectedComponentId: normalizedSelectedComponentId,
        selectedComponentIds: normalizedSelectedIds,
        clipboard: clipboard ?? state.clipboard,
      );
      return;
    }

    final version = LayoutVersion.create(
      components,
      gridSettings: state.gridSettings,
      config: state.config,
    );
    final history = state.versions.take(state.currentVersionIndex + 1).toList();

    state = state.copyWith(
      components: components,
      selectedComponentId: normalizedSelectedComponentId,
      selectedComponentIds: normalizedSelectedIds,
      versions: [...history, version],
      currentVersionIndex: history.length,
      clipboard: clipboard ?? state.clipboard,
    );
  }

  void _commitLayoutState(LayoutState nextState, {String? versionName}) {
    if (_interactionStartComponents != null) {
      state = nextState;
      return;
    }

    final version = LayoutVersion.create(
      nextState.components,
      gridSettings: nextState.gridSettings,
      config: nextState.config,
      name: versionName,
    );
    final history = state.versions.take(state.currentVersionIndex + 1).toList();

    state = nextState.copyWith(
      versions: [...history, version],
      currentVersionIndex: history.length,
    );
  }

  bool _hasComponentGeometryChanges(
    List<ComponentData> before,
    List<ComponentData> after,
  ) {
    if (before.length != after.length) return true;

    for (var index = 0; index < before.length; index++) {
      final previous = before[index];
      final next = after[index];
      if (previous.id != next.id) return true;
      if ((previous.position - next.position).distance >= 0.01) return true;
      if ((previous.size.width - next.size.width).abs() >= 0.01) return true;
      if ((previous.size.height - next.size.height).abs() >= 0.01) return true;
    }

    return false;
  }

  bool _hasGridSettingsChanges(GridSettings before, GridSettings after) {
    return _hasDoubleChange(before.gridSize, after.gridSize) ||
        _hasDoubleChange(before.opacity, after.opacity) ||
        before.enabled != after.enabled ||
        before.snapToGrid != after.snapToGrid ||
        before.gridColor != after.gridColor ||
        before.showSubgrid != after.showSubgrid;
  }

  bool _hasLayoutConfigChanges(LayoutConfig before, LayoutConfig after) {
    return _hasDoubleChange(before.gridSize, after.gridSize) ||
        _hasDoubleChange(before.canvasWidth, after.canvasWidth) ||
        _hasDoubleChange(before.canvasHeight, after.canvasHeight) ||
        _hasDoubleChange(before.minComponentWidth, after.minComponentWidth) ||
        _hasDoubleChange(before.minComponentHeight, after.minComponentHeight) ||
        before.snapToGrid != after.snapToGrid ||
        before.showGrid != after.showGrid ||
        before.layoutMechanism != after.layoutMechanism ||
        before.tabularColumnCount != after.tabularColumnCount ||
        _hasDoubleChange(before.tabularColumnGap, after.tabularColumnGap) ||
        _hasDoubleChange(before.tabularRowHeight, after.tabularRowHeight) ||
        before.autoGridColumnCount != after.autoGridColumnCount ||
        _hasDoubleChange(before.autoGridGap, after.autoGridGap) ||
        _hasDoubleChange(before.autoGridRowHeight, after.autoGridRowHeight);
  }

  bool _hasDoubleChange(double before, double after) {
    return (before - after).abs() >= 0.01;
  }

  bool get _shouldApplyDropLayoutRules {
    return state.gridSettings.snapToGrid &&
        state.config.layoutMechanism != LayoutMechanism.freeform;
  }

  bool get _hasLayoutRuleConflictResolution {
    return state.config.layoutMechanism != LayoutMechanism.freeform;
  }

  String? _selectedConflictResolutionComponentId() {
    final selectedIds = _activeSelectedIds();
    if (selectedIds.isEmpty) return null;

    final selectedId = state.selectedComponentId;
    if (selectedId != null && selectedIds.contains(selectedId)) {
      return selectedId;
    }

    return selectedIds.first;
  }

  LayoutDragPreview? _layoutDragPreviewForSelection(String activeComponentId) {
    return layoutDragPreviewFor(
      components: state.components,
      selectedComponentIds: _activeSelectedIds(),
      activeComponentId: activeComponentId,
      config: state.config,
      gridSettings: state.gridSettings,
    );
  }

  _ConflictResolutionPlan? _conflictResolutionPlanFor(
    LayoutDragPreview? preview,
    String activeComponentId,
  ) {
    final movingIds = preview?.componentIds ?? const <String>{};
    if (preview == null || movingIds.isEmpty) return null;

    final item = _conflictResolutionItemFor(preview, activeComponentId);
    final resolvedBounds = item?.conflictResolvedBounds;
    if (item == null || resolvedBounds == null) return null;

    final delta = resolvedBounds.topLeft - item.currentBounds.topLeft;
    if (delta.distance < 0.01) return null;

    final nextComponents = _componentsMovedByResolutionDelta(
      components: state.components,
      componentIds: movingIds,
      delta: delta,
    );
    final validationPreview = layoutDragPreviewFor(
      components: nextComponents,
      selectedComponentIds: movingIds,
      activeComponentId: activeComponentId,
      config: state.config,
      gridSettings: state.gridSettings,
    );
    if (!_isClearLayoutDragPreview(validationPreview)) return null;

    return _ConflictResolutionPlan(
      item: item,
      components: nextComponents,
      componentIds: movingIds,
      selectedComponentId:
          movingIds.contains(activeComponentId)
              ? activeComponentId
              : movingIds.first,
    );
  }

  List<ComponentData> _dropComponentsWithConflictResolution(
    List<ComponentData> components,
  ) {
    final snappedComponents = components.map(_snapComponent).toList();
    if (snappedComponents.isEmpty || !_shouldApplyDropLayoutRules) {
      return snappedComponents;
    }

    final dropIds = snappedComponents.map((component) => component.id).toSet();
    final activeComponentId = snappedComponents.first.id;
    final preview = layoutDragPreviewFor(
      components: [...state.components, ...snappedComponents],
      selectedComponentIds: dropIds,
      activeComponentId: activeComponentId,
      config: state.config,
      gridSettings: state.gridSettings,
    );
    final item = _conflictResolutionItemFor(preview, activeComponentId);
    final resolvedBounds = item?.conflictResolvedBounds;
    final delta =
        item == null || resolvedBounds == null
            ? null
            : resolvedBounds.topLeft - item.currentBounds.topLeft;
    if (delta == null || delta.distance < 0.01) return snappedComponents;

    final resolvedComponents = _componentsMovedByResolutionDelta(
      components: snappedComponents,
      componentIds: dropIds,
      delta: delta,
    );
    final validationPreview = layoutDragPreviewFor(
      components: [...state.components, ...resolvedComponents],
      selectedComponentIds: dropIds,
      activeComponentId: activeComponentId,
      config: state.config,
      gridSettings: state.gridSettings,
    );
    if (!_isClearLayoutDragPreview(validationPreview)) return snappedComponents;

    return resolvedComponents;
  }

  LayoutDragPreviewItem? _conflictResolutionItemFor(
    LayoutDragPreview? preview,
    String activeComponentId,
  ) {
    if (preview == null) return null;

    for (final item in preview.items) {
      if (item.componentId == activeComponentId && item.hasConflictResolution) {
        return item;
      }
    }

    for (final item in preview.items) {
      if (item.hasConflictResolution) return item;
    }

    return null;
  }

  List<ComponentData> _componentsMovedByResolutionDelta({
    required List<ComponentData> components,
    required Set<String> componentIds,
    required Offset delta,
  }) {
    return [
      for (final component in components)
        componentIds.contains(component.id) && !component.isLocked
            ? component.copyWith(
              position: _snapOffset(component.position + delta),
            )
            : component,
    ];
  }

  bool _isClearLayoutDragPreview(LayoutDragPreview? preview) {
    if (preview == null || preview.items.isEmpty) return true;

    return preview.items.every(
      (item) => !item.hasConflict && !item.isOutsideCanvas,
    );
  }

  Set<String> _activeSelectedIds() {
    if (state.selectedComponentIds.isNotEmpty) {
      return _expandGroupedIds(state.selectedComponentIds);
    }

    final selectedId = state.selectedComponentId;
    return selectedId == null ? <String>{} : _groupedIdsFor(selectedId);
  }

  Set<String> _groupedIdsFor(String id) {
    final component = state.componentsById[id];
    if (component == null) return <String>{};

    final parentId = component.properties.parentId;
    if (parentId == null) return <String>{id};

    return {
      for (final item in state.components)
        if (item.properties.parentId == parentId) item.id,
    };
  }

  Set<String> _expandGroupedIds(Iterable<String> ids) {
    final expandedIds = <String>{};
    for (final id in ids) {
      expandedIds.addAll(_groupedIdsFor(id));
    }

    return expandedIds;
  }

  Rect _componentsBounds(List<ComponentData> components) {
    final first = components.first;
    var left = first.position.dx;
    var top = first.position.dy;
    var right = first.position.dx + first.size.width;
    var bottom = first.position.dy + first.size.height;

    for (final component in components.skip(1)) {
      final componentRight = component.position.dx + component.size.width;
      final componentBottom = component.position.dy + component.size.height;
      if (component.position.dx < left) left = component.position.dx;
      if (component.position.dy < top) top = component.position.dy;
      if (componentRight > right) right = componentRight;
      if (componentBottom > bottom) bottom = componentBottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _componentsBoundsAt(
    List<ComponentData> components,
    Map<String, Offset> positions,
  ) {
    final first = components.first;
    final firstPosition = positions[first.id] ?? first.position;
    var left = firstPosition.dx;
    var top = firstPosition.dy;
    var right = firstPosition.dx + first.size.width;
    var bottom = firstPosition.dy + first.size.height;

    for (final component in components.skip(1)) {
      final position = positions[component.id] ?? component.position;
      final componentRight = position.dx + component.size.width;
      final componentBottom = position.dy + component.size.height;
      if (position.dx < left) left = position.dx;
      if (position.dy < top) top = position.dy;
      if (componentRight > right) right = componentRight;
      if (componentBottom > bottom) bottom = componentBottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _componentsGeometryBounds(
    List<ComponentData> components,
    Map<String, Offset> positions,
    Map<String, Size> sizes,
  ) {
    final first = components.first;
    final firstPosition = positions[first.id] ?? first.position;
    final firstSize = sizes[first.id] ?? first.size;
    var left = firstPosition.dx;
    var top = firstPosition.dy;
    var right = firstPosition.dx + firstSize.width;
    var bottom = firstPosition.dy + firstSize.height;

    for (final component in components.skip(1)) {
      final position = positions[component.id] ?? component.position;
      final size = sizes[component.id] ?? component.size;
      final componentRight = position.dx + size.width;
      final componentBottom = position.dy + size.height;
      if (position.dx < left) left = position.dx;
      if (position.dy < top) top = position.dy;
      if (componentRight > right) right = componentRight;
      if (componentBottom > bottom) bottom = componentBottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Offset _snappedPositionForComponent(
    ComponentData component,
    Offset position, {
    required Set<String> excludedIds,
  }) {
    final snappedPosition = _snapOffset(position);
    final bounds = Rect.fromLTWH(
      snappedPosition.dx,
      snappedPosition.dy,
      component.size.width,
      component.size.height,
    );

    return snappedPosition +
        _smartGuideAdjustment(bounds, excludedIds: excludedIds);
  }

  Offset _smartGuideAdjustment(
    Rect targetBounds, {
    required Set<String> excludedIds,
  }) {
    double? xAdjustment;
    double? yAdjustment;
    var xDistance = _smartGuideSnapThreshold + 1;
    var yDistance = _smartGuideSnapThreshold + 1;
    final targetXAnchors = [
      targetBounds.left,
      targetBounds.center.dx,
      targetBounds.right,
    ];
    final targetYAnchors = [
      targetBounds.top,
      targetBounds.center.dy,
      targetBounds.bottom,
    ];

    for (final component in state.components) {
      if (!component.isVisible || excludedIds.contains(component.id)) continue;

      final bounds = Rect.fromLTWH(
        component.position.dx,
        component.position.dy,
        component.size.width,
        component.size.height,
      );
      final xAnchors = [bounds.left, bounds.center.dx, bounds.right];
      final yAnchors = [bounds.top, bounds.center.dy, bounds.bottom];

      for (final targetAnchor in targetXAnchors) {
        for (final anchor in xAnchors) {
          final distance = anchor - targetAnchor;
          final absoluteDistance = distance.abs();
          if (absoluteDistance <= _smartGuideSnapThreshold &&
              absoluteDistance < xDistance) {
            xAdjustment = distance;
            xDistance = absoluteDistance;
          }
        }
      }

      for (final targetAnchor in targetYAnchors) {
        for (final anchor in yAnchors) {
          final distance = anchor - targetAnchor;
          final absoluteDistance = distance.abs();
          if (absoluteDistance <= _smartGuideSnapThreshold &&
              absoluteDistance < yDistance) {
            yAdjustment = distance;
            yDistance = absoluteDistance;
          }
        }
      }
    }

    return Offset(xAdjustment ?? 0, yAdjustment ?? 0);
  }

  Set<_AutoGridCellKey> _autoGridOccupiedCells({
    required Set<String> excludedIds,
    required int columnCount,
    required double trackWidth,
    required double rowTrackHeight,
  }) {
    final occupiedCells = <_AutoGridCellKey>{};
    for (final component in state.components) {
      if (!component.isVisible || excludedIds.contains(component.id)) continue;

      final placement = _autoGridPlacementForGeometry(
        component.position,
        component.size,
        columnCount,
        trackWidth,
        rowTrackHeight,
      );
      _occupyAutoGridCells(occupiedCells, placement);
    }

    return occupiedCells;
  }

  Set<String> _autoGridConflictPartnerIdsForSelection(Set<String> selectedIds) {
    final config = state.config;
    final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
    final trackWidth = _autoGridColumnTrackWidth();
    final rowTrackHeight = _autoGridRowTrackHeight();
    if (trackWidth <= 0 || rowTrackHeight <= 0) return const <String>{};

    final groupsByCell = <_AutoGridCellKey, Set<String>>{};
    final selectedGroupsByCell = <_AutoGridCellKey, Set<String>>{};
    final componentIdsByGroup = <String, Set<String>>{};

    for (final component in state.components) {
      if (!component.isVisible) continue;

      final groupKey = component.properties.parentId ?? component.id;
      componentIdsByGroup
          .putIfAbsent(groupKey, () => <String>{})
          .add(component.id);

      final placement = _autoGridPlacementForGeometry(
        component.position,
        component.size,
        columnCount,
        trackWidth,
        rowTrackHeight,
      );
      final isSelected = selectedIds.contains(component.id);

      for (
        var row = placement.row;
        row < placement.row + placement.rowSpan;
        row++
      ) {
        if (row < 0 || row * rowTrackHeight >= config.canvasHeight) continue;

        for (
          var column = placement.column;
          column < placement.column + placement.columnSpan;
          column++
        ) {
          if (column < 0 || column >= columnCount) continue;

          final key = _AutoGridCellKey(column, row);
          groupsByCell.putIfAbsent(key, () => <String>{}).add(groupKey);
          if (isSelected) {
            selectedGroupsByCell
                .putIfAbsent(key, () => <String>{})
                .add(groupKey);
          }
        }
      }
    }

    final conflictGroupKeys = <String>{};
    for (final entry in selectedGroupsByCell.entries) {
      final groups = groupsByCell[entry.key] ?? const <String>{};
      if (entry.value.isNotEmpty && groups.length > 1) {
        conflictGroupKeys.addAll(groups);
      }
    }

    return {
      for (final groupKey in conflictGroupKeys)
        ...?componentIdsByGroup[groupKey],
    };
  }

  Set<String> _autoGridConflictComponentIds() {
    final config = state.config;
    final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
    final trackWidth = _autoGridColumnTrackWidth();
    final rowTrackHeight = _autoGridRowTrackHeight();
    if (trackWidth <= 0 || rowTrackHeight <= 0) return const <String>{};

    final groupsByCell = <_AutoGridCellKey, Set<String>>{};
    final componentIdsByGroup = <String, Set<String>>{};

    for (final component in state.components) {
      if (!component.isVisible) continue;

      final groupKey = component.properties.parentId ?? component.id;
      componentIdsByGroup
          .putIfAbsent(groupKey, () => <String>{})
          .add(component.id);

      final placement = _autoGridPlacementForGeometry(
        component.position,
        component.size,
        columnCount,
        trackWidth,
        rowTrackHeight,
      );

      for (
        var row = placement.row;
        row < placement.row + placement.rowSpan;
        row++
      ) {
        if (row < 0 || row * rowTrackHeight >= config.canvasHeight) continue;

        for (
          var column = placement.column;
          column < placement.column + placement.columnSpan;
          column++
        ) {
          if (column < 0 || column >= columnCount) continue;

          groupsByCell
              .putIfAbsent(_AutoGridCellKey(column, row), () => <String>{})
              .add(groupKey);
        }
      }
    }

    final conflictGroupKeys = <String>{};
    for (final groups in groupsByCell.values) {
      if (groups.length > 1) conflictGroupKeys.addAll(groups);
    }

    return {
      for (final groupKey in conflictGroupKeys)
        ...?componentIdsByGroup[groupKey],
    };
  }

  _AutoGridPlacement _autoGridPlacementForGeometry(
    Offset position,
    Size size,
    int columnCount,
    double trackWidth,
    double rowTrackHeight,
  ) {
    final config = state.config;
    final column =
        trackWidth <= 0
            ? 0
            : (position.dx / trackWidth)
                .round()
                .clamp(0, columnCount - 1)
                .toInt();
    final row =
        rowTrackHeight <= 0
            ? 0
            : math.max(0, (position.dy / rowTrackHeight).round());
    final columnSpan =
        trackWidth <= 0
            ? 1
            : ((size.width + config.autoGridGap) / trackWidth)
                .round()
                .clamp(1, columnCount)
                .toInt();
    final rowSpan =
        rowTrackHeight <= 0
            ? 1
            : math.max(
              1,
              ((size.height + config.autoGridGap) / rowTrackHeight).round(),
            );

    return _AutoGridPlacement(
      column: column,
      row: row,
      columnSpan: math.min(columnSpan, columnCount - column),
      rowSpan: rowSpan,
    );
  }

  _AutoGridPlacement? _firstFreeAutoGridPlacement({
    required Set<_AutoGridCellKey> occupiedCells,
    required int columnCount,
    required int columnSpan,
    required int rowSpan,
    required int startIndex,
  }) {
    if (columnCount <= 0) return null;

    final normalizedColumnSpan = columnSpan.clamp(1, columnCount).toInt();
    final normalizedRowSpan = math.max(1, rowSpan);
    final normalizedStartIndex = math.max(0, startIndex);
    const maxSearchSlots = 10000;

    for (var offset = 0; offset < maxSearchSlots; offset++) {
      final index = normalizedStartIndex + offset;
      final row = index ~/ columnCount;
      final column = index % columnCount;
      if (column + normalizedColumnSpan > columnCount) continue;

      final placement = _AutoGridPlacement(
        column: column,
        row: row,
        columnSpan: normalizedColumnSpan,
        rowSpan: normalizedRowSpan,
      );
      if (_canPlaceAutoGridPlacement(occupiedCells, placement)) {
        return placement;
      }
    }

    return null;
  }

  bool _canPlaceAutoGridPlacement(
    Set<_AutoGridCellKey> occupiedCells,
    _AutoGridPlacement placement,
  ) {
    for (
      var row = placement.row;
      row < placement.row + placement.rowSpan;
      row++
    ) {
      for (
        var column = placement.column;
        column < placement.column + placement.columnSpan;
        column++
      ) {
        if (occupiedCells.contains(_AutoGridCellKey(column, row))) {
          return false;
        }
      }
    }

    return true;
  }

  void _occupyAutoGridCells(
    Set<_AutoGridCellKey> occupiedCells,
    _AutoGridPlacement placement,
  ) {
    for (
      var row = placement.row;
      row < placement.row + placement.rowSpan;
      row++
    ) {
      for (
        var column = placement.column;
        column < placement.column + placement.columnSpan;
        column++
      ) {
        occupiedCells.add(_AutoGridCellKey(column, row));
      }
    }
  }

  int _autoGridSearchIndexForPosition(
    Offset position,
    int columnCount,
    double trackWidth,
    double rowTrackHeight,
  ) {
    if (columnCount <= 0) return 0;

    final column =
        trackWidth <= 0
            ? 0
            : (position.dx / trackWidth)
                .round()
                .clamp(0, columnCount - 1)
                .toInt();
    final row =
        rowTrackHeight <= 0
            ? 0
            : math.max(0, (position.dy / rowTrackHeight).round());

    return row * columnCount + column;
  }

  List<ComponentData> _componentsConstrainedToCanvasResize(
    List<ComponentData> components,
    Size previousCanvasSize,
    Size nextCanvasSize,
  ) {
    if (previousCanvasSize.width <= 0 ||
        previousCanvasSize.height <= 0 ||
        nextCanvasSize.width <= 0 ||
        nextCanvasSize.height <= 0) {
      return components;
    }

    var changed = false;
    final nextComponents =
        components.map((component) {
          final constrained = _componentConstrainedToCanvasResize(
            component,
            previousCanvasSize,
            nextCanvasSize,
          );
          if ((constrained.position - component.position).distance >= 0.01 ||
              (constrained.size.width - component.size.width).abs() >= 0.01 ||
              (constrained.size.height - component.size.height).abs() >= 0.01) {
            changed = true;
          }

          return constrained;
        }).toList();

    return changed ? nextComponents : components;
  }

  ComponentData _componentConstrainedToCanvasResize(
    ComponentData component,
    Size previousCanvasSize,
    Size nextCanvasSize,
  ) {
    final constraints = component.constraints;
    if (component.isLocked || !constraints.hasCustomRules) return component;

    final previousPosition = component.position;
    final previousSize = component.size;
    final rightInset =
        previousCanvasSize.width - previousPosition.dx - previousSize.width;
    final bottomInset =
        previousCanvasSize.height - previousPosition.dy - previousSize.height;
    final centerDeltaX =
        previousPosition.dx +
        previousSize.width / 2 -
        previousCanvasSize.width / 2;
    final centerDeltaY =
        previousPosition.dy +
        previousSize.height / 2 -
        previousCanvasSize.height / 2;

    var left = previousPosition.dx;
    var top = previousPosition.dy;
    var width = previousSize.width;
    var height = previousSize.height;

    switch (constraints.horizontalAnchor) {
      case ComponentAnchorMode.free:
      case ComponentAnchorMode.start:
        break;
      case ComponentAnchorMode.center:
        left = nextCanvasSize.width / 2 + centerDeltaX - width / 2;
        break;
      case ComponentAnchorMode.end:
        left = nextCanvasSize.width - rightInset - width;
        break;
      case ComponentAnchorMode.stretch:
        width = nextCanvasSize.width - rightInset - left;
        break;
    }

    switch (constraints.verticalAnchor) {
      case ComponentAnchorMode.free:
      case ComponentAnchorMode.start:
        break;
      case ComponentAnchorMode.center:
        top = nextCanvasSize.height / 2 + centerDeltaY - height / 2;
        break;
      case ComponentAnchorMode.end:
        top = nextCanvasSize.height - bottomInset - height;
        break;
      case ComponentAnchorMode.stretch:
        height = nextCanvasSize.height - bottomInset - top;
        break;
    }

    final nextSize = _snapConstrainedSize(
      component,
      Size(
        _finitePositiveOrFallback(width, previousSize.width),
        _finitePositiveOrFallback(height, previousSize.height),
      ),
    );

    switch (constraints.horizontalAnchor) {
      case ComponentAnchorMode.center:
        left = nextCanvasSize.width / 2 + centerDeltaX - nextSize.width / 2;
        break;
      case ComponentAnchorMode.end:
        left = nextCanvasSize.width - rightInset - nextSize.width;
        break;
      case ComponentAnchorMode.free:
      case ComponentAnchorMode.start:
      case ComponentAnchorMode.stretch:
        break;
    }

    switch (constraints.verticalAnchor) {
      case ComponentAnchorMode.center:
        top = nextCanvasSize.height / 2 + centerDeltaY - nextSize.height / 2;
        break;
      case ComponentAnchorMode.end:
        top = nextCanvasSize.height - bottomInset - nextSize.height;
        break;
      case ComponentAnchorMode.free:
      case ComponentAnchorMode.start:
      case ComponentAnchorMode.stretch:
        break;
    }

    return component.copyWith(
      position: _snapOffset(
        Offset(
          _finiteOrFallback(left, previousPosition.dx),
          _finiteOrFallback(top, previousPosition.dy),
        ),
      ),
      size: nextSize,
    );
  }

  ComponentData _snapComponent(ComponentData component) {
    return component.copyWith(
      position: _snapOffset(component.position),
      size: _snapConstrainedSize(component, component.size),
    );
  }

  Size _snapConstrainedSize(ComponentData component, Size size) {
    final constrained = _constrainSizeToComponentRules(component, size);
    final snapped = _snapSize(constrained);

    return _constrainSizeToComponentRules(component, snapped);
  }

  Size _constrainSizeToComponentRules(ComponentData component, Size size) {
    final constraints = component.constraints;
    final minWidth = math.max(
      state.config.minComponentWidth,
      constraints.minWidth ?? 0,
    );
    final minHeight = math.max(
      state.config.minComponentHeight,
      constraints.minHeight ?? 0,
    );
    final maxWidth = math.max(
      minWidth,
      constraints.maxWidth ?? double.infinity,
    );
    final maxHeight = math.max(
      minHeight,
      constraints.maxHeight ?? double.infinity,
    );
    var width = _finitePositiveOrFallback(size.width, component.size.width);
    var height = _finitePositiveOrFallback(size.height, component.size.height);

    if (constraints.maintainAspectRatio && component.size.height > 0) {
      final ratio = component.size.width / component.size.height;
      final widthDelta = (width - component.size.width).abs();
      final heightDelta = (height - component.size.height).abs();
      if (widthDelta >= heightDelta) {
        height = width / ratio;
      } else {
        width = height * ratio;
      }
    }

    width = width.clamp(minWidth, maxWidth).toDouble();
    height = height.clamp(minHeight, maxHeight).toDouble();

    if (constraints.maintainAspectRatio && component.size.height > 0) {
      final ratio = component.size.width / component.size.height;
      final widthDelta = (width - component.size.width).abs();
      final heightDelta = (height - component.size.height).abs();
      if (widthDelta >= heightDelta) {
        height = (width / ratio).clamp(minHeight, maxHeight).toDouble();
        width = (height * ratio).clamp(minWidth, maxWidth).toDouble();
      } else {
        width = (height * ratio).clamp(minWidth, maxWidth).toDouble();
        height = (width / ratio).clamp(minHeight, maxHeight).toDouble();
      }
    }

    return Size(width, height);
  }

  double _finitePositiveOrFallback(double value, double fallback) {
    if (value.isFinite && value > 0) return value;
    return _finiteOrFallback(fallback, 1);
  }

  double _finiteOrFallback(double value, double fallback) {
    return value.isFinite ? value : fallback;
  }

  Offset _snapOffset(Offset offset) {
    if (!state.gridSettings.snapToGrid) return offset;

    return _snapOffsetToLayoutRules(offset);
  }

  Offset _snapOffsetToLayoutRules(Offset offset) {
    switch (state.config.layoutMechanism) {
      case LayoutMechanism.freeform:
        return offset;
      case LayoutMechanism.grid:
        return _snapOffsetToGrid(offset, state.gridSettings.gridSize);
      case LayoutMechanism.tabularColumns:
        return _snapOffsetToTabularColumns(offset);
      case LayoutMechanism.autoGrid:
        return _snapOffsetToAutoGrid(offset);
    }
  }

  Offset _snapOffsetToGrid(Offset offset, double gridSize) {
    if (gridSize <= 0) return offset;
    return Offset(
      (offset.dx / gridSize).round() * gridSize,
      (offset.dy / gridSize).round() * gridSize,
    );
  }

  Size _snapSize(Size size) {
    final constrained = Size(
      size.width
          .clamp(state.config.minComponentWidth, double.infinity)
          .toDouble(),
      size.height
          .clamp(state.config.minComponentHeight, double.infinity)
          .toDouble(),
    );

    if (!state.gridSettings.snapToGrid) return constrained;

    return _snapSizeToLayoutRules(constrained);
  }

  Size _snapSizeToLayoutRules(Size size) {
    final constrained = Size(
      size.width
          .clamp(state.config.minComponentWidth, double.infinity)
          .toDouble(),
      size.height
          .clamp(state.config.minComponentHeight, double.infinity)
          .toDouble(),
    );

    switch (state.config.layoutMechanism) {
      case LayoutMechanism.freeform:
        return constrained;
      case LayoutMechanism.grid:
        return _snapSizeToGrid(constrained, state.gridSettings.gridSize);
      case LayoutMechanism.tabularColumns:
        return _snapSizeToTabularColumns(constrained);
      case LayoutMechanism.autoGrid:
        return _snapSizeToAutoGrid(constrained);
    }
  }

  Size _snapSizeToGrid(Size size, double gridSize) {
    final constrained = Size(
      size.width
          .clamp(state.config.minComponentWidth, double.infinity)
          .toDouble(),
      size.height
          .clamp(state.config.minComponentHeight, double.infinity)
          .toDouble(),
    );

    if (gridSize <= 0) return constrained;
    return Size(
      (constrained.width / gridSize).round() * gridSize,
      (constrained.height / gridSize).round() * gridSize,
    );
  }

  Offset _snapOffsetToTabularColumns(Offset offset) {
    final config = state.config;
    final columnWidth = config.tabularColumnWidth;
    final trackWidth = columnWidth + config.tabularColumnGap;
    final column =
        trackWidth <= 0
            ? 0
            : (offset.dx / trackWidth)
                .round()
                .clamp(0, config.tabularColumnCount - 1)
                .toInt();
    final rowHeight = math.max(1.0, config.tabularRowHeight);
    final row = (offset.dy / rowHeight).round();

    return Offset(column * trackWidth, row * rowHeight);
  }

  Size _snapSizeToTabularColumns(Size size) {
    final config = state.config;
    final constrained = Size(
      size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
      size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
    );
    final columnWidth = config.tabularColumnWidth;
    final trackWidth = columnWidth + config.tabularColumnGap;
    if (trackWidth <= 0) return constrained;

    final span =
        ((constrained.width + config.tabularColumnGap) / trackWidth)
            .round()
            .clamp(1, config.tabularColumnCount)
            .toInt();
    final rowHeight = math.max(1.0, config.tabularRowHeight);
    final rowSpan = math.max(1, (constrained.height / rowHeight).round());

    return Size(_tabularColumnSpanWidth(span), _tabularRowSpanHeight(rowSpan));
  }

  Offset _snapOffsetToAutoGrid(Offset offset) {
    final config = state.config;
    final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
    final column =
        trackWidth <= 0
            ? 0
            : (offset.dx / trackWidth)
                .round()
                .clamp(0, config.autoGridColumnCount - 1)
                .toInt();
    final rowTrackHeight =
        math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
    final row = rowTrackHeight <= 0 ? 0 : (offset.dy / rowTrackHeight).round();

    return Offset(column * trackWidth, row * rowTrackHeight);
  }

  Size _snapSizeToAutoGrid(Size size) {
    final config = state.config;
    final constrained = Size(
      size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
      size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
    );
    final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
    if (trackWidth <= 0) return constrained;

    final columnSpan = _autoGridColumnSpanForWidth(constrained.width);
    final rowSpan = _autoGridRowSpanForHeight(constrained.height);

    return Size(
      _autoGridColumnSpanWidth(columnSpan),
      _autoGridRowSpanHeight(rowSpan),
    );
  }

  double _tabularColumnSpanWidth(int span) {
    final config = state.config;
    final normalizedSpan = span.clamp(1, config.tabularColumnCount).toInt();

    return normalizedSpan * config.tabularColumnWidth +
        math.max(0, normalizedSpan - 1) * config.tabularColumnGap;
  }

  double _tabularColumnTrackWidth() {
    return state.config.tabularColumnWidth + state.config.tabularColumnGap;
  }

  double _autoGridColumnSpanWidth(int span) {
    final config = state.config;
    final normalizedSpan = span.clamp(1, config.autoGridColumnCount).toInt();

    return normalizedSpan * config.autoGridColumnWidth +
        math.max(0, normalizedSpan - 1) * config.autoGridGap;
  }

  double _autoGridColumnTrackWidth() {
    return state.config.autoGridColumnWidth + state.config.autoGridGap;
  }

  double _autoGridColumnStartOffset(int column) {
    final normalizedColumn =
        column.clamp(1, state.config.autoGridColumnCount).toInt();

    return (normalizedColumn - 1) * _autoGridColumnTrackWidth();
  }

  int _autoGridColumnSpanForWidth(double width) {
    final config = state.config;
    final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
    if (trackWidth <= 0) return 1;

    return ((width + config.autoGridGap) / trackWidth)
        .round()
        .clamp(1, config.autoGridColumnCount)
        .toInt();
  }

  double _autoGridRowSpanHeight(int span) {
    return math.max(1, span) * math.max(24.0, state.config.autoGridRowHeight) +
        math.max(0, span - 1) * state.config.autoGridGap;
  }

  double _autoGridRowTrackHeight() {
    return math.max(24.0, state.config.autoGridRowHeight) +
        state.config.autoGridGap;
  }

  double _autoGridRowStartOffset(int row) {
    final normalizedRow = math.max(1, row);

    return (normalizedRow - 1) * _autoGridRowTrackHeight();
  }

  int _autoGridRowSpanForHeight(double height) {
    final config = state.config;
    final rowTrackHeight =
        math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
    if (rowTrackHeight <= 0) return 1;

    return math.max(
      1,
      ((height + config.autoGridGap) / rowTrackHeight).round(),
    );
  }

  double _tabularColumnStartOffset(int column) {
    final normalizedColumn =
        column.clamp(1, state.config.tabularColumnCount).toInt();

    return (normalizedColumn - 1) * _tabularColumnTrackWidth();
  }

  double _tabularRowStartOffset(int row) {
    final normalizedRow = math.max(1, row);

    return (normalizedRow - 1) * math.max(1.0, state.config.tabularRowHeight);
  }

  double _tabularRowSpanHeight(int span) {
    return math.max(1, span) * math.max(1.0, state.config.tabularRowHeight);
  }
}

enum ComponentAlignment { left, center, right, top, middle, bottom }

enum ComponentDistribution { horizontal, vertical }

enum CanvasCorner { topLeft, topRight, bottomLeft, bottomRight }

enum CanvasEdge { top, right, bottom, left }

class _AutoGridCellKey {
  final int column;
  final int row;

  const _AutoGridCellKey(this.column, this.row);

  @override
  bool operator ==(Object other) {
    return other is _AutoGridCellKey &&
        other.column == column &&
        other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);
}

class _AutoGridPlacement {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;

  const _AutoGridPlacement({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
  });
}
