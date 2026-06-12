import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_presets.dart';
import 'website_builder_component_properties.dart';
import 'website_builder_content_preset_library.dart';
import 'website_builder_html_exporter.dart';
import 'website_builder_snapshot_import_preview.dart';

typedef WebsiteBuilderIdFactory = String Function();

const _maxWebsiteBuilderHistoryDepth = 80;
const _componentInsertGap = 24.0;
const _componentCollisionGap = 8.0;

class WebsiteBuilderController extends ChangeNotifier {
  WebsiteBuilderController({
    BuilderComponentCatalog? catalog,
    BuilderCanvasConfig? canvasConfig,
    BuilderBreakpoint currentBreakpoint = BuilderBreakpoint.desktop,
    String projectId = 'website-builder-project',
    String projectName = 'Untitled Website',
    List<BuilderComponentGeometry> components = const [],
    List<WebsiteBuilderComponentPreset> customContentPresets = const [],
    WebsiteBuilderIdFactory? idFactory,
  }) : catalog = catalog ?? websiteBuilderCatalog,
       _canvasConfig = canvasConfig ?? const BuilderCanvasConfig(),
       _currentBreakpoint = currentBreakpoint,
       _projectId = projectId,
       _projectName = projectName,
       _components = [
         for (final component in components)
           websiteBuilderComponentWithDefaultProperties(component),
       ],
       _customContentPresets = [
         for (final preset in customContentPresets)
           if (preset.id.trim().isNotEmpty && preset.kindKey.trim().isNotEmpty)
             preset.copyWith(isCustom: true),
       ],
       _idFactory = idFactory {
    _components.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  final BuilderComponentCatalog catalog;
  final WebsiteBuilderIdFactory? _idFactory;
  final List<BuilderComponentGeometry> _components;
  final List<WebsiteBuilderComponentPreset> _customContentPresets;
  final List<_WebsiteBuilderHistorySnapshot> _undoStack = [];
  final List<_WebsiteBuilderHistorySnapshot> _redoStack = [];

  BuilderCanvasConfig _canvasConfig;
  BuilderBreakpoint _currentBreakpoint;
  String _projectId;
  String _projectName;
  String? _selectedComponentId;
  int _nextId = 1;

  BuilderCanvasConfig get canvasConfig => _canvasConfig;
  BuilderBreakpoint get currentBreakpoint => _currentBreakpoint;
  String get projectId => _projectId;
  String get projectName => _projectName;
  String? get selectedComponentId => _selectedComponentId;
  List<BuilderComponentGeometry> get components =>
      List.unmodifiable(_components);
  List<WebsiteBuilderComponentPreset> get customContentPresets =>
      List.unmodifiable(_customContentPresets);

  int get componentCount => _components.length;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get contentIssueCount {
    var count = 0;
    for (final component in _components) {
      count += websiteBuilderContentIssuesFor(component).length;
    }
    return count;
  }

  bool get hasContentIssueComponents {
    for (final component in _components) {
      if (websiteBuilderContentIssuesFor(component).isNotEmpty) return true;
    }
    return false;
  }

  bool get hasFixableContentIssues {
    for (final component in _components) {
      if (component.isLocked) continue;
      if (websiteBuilderContentIssuesFor(
        component,
      ).any((issue) => issue.hasFix)) {
        return true;
      }
    }
    return false;
  }

  BuilderComponentGeometry? get selectedComponent {
    final id = _selectedComponentId;
    if (id == null) return null;
    return _findComponent(id);
  }

  BuilderComponentKind? get selectedComponentKind {
    final component = selectedComponent;
    if (component == null) return null;
    return catalog.byKey(component.kindKey);
  }

  List<WebsiteBuilderComponentPreset> presetsFor(String kindKey) {
    return [
      for (final preset in _customContentPresets)
        if (preset.kindKey == kindKey) preset,
      ...websiteBuilderPresetsFor(kindKey),
    ];
  }

  List<WebsiteBuilderComponentPreset> customContentPresetsFor(String kindKey) {
    return [
      for (final preset in _customContentPresets)
        if (preset.kindKey == kindKey) preset,
    ];
  }

  List<WebsiteBuilderComponentPreset> presetsMatching(
    String kindKey,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final presets = presetsFor(kindKey);
    if (normalizedQuery.isEmpty) return presets;
    return [
      for (final preset in presets)
        if (websiteBuilderPresetMatchesQuery(preset, normalizedQuery)) preset,
    ];
  }

  bool kindHasPresetMatch(String kindKey, String query) {
    return presetsMatching(kindKey, query).isNotEmpty;
  }

  void renameProject(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _projectName) return;
    final before = _captureHistory();
    _projectName = trimmed;
    _commitHistory(before);
  }

  bool updateProjectDetails({
    required String projectId,
    required String projectName,
  }) {
    final trimmedId = projectId.trim();
    final trimmedName = projectName.trim();
    if (trimmedId.isEmpty || trimmedName.isEmpty) return false;
    if (trimmedId == _projectId && trimmedName == _projectName) return false;

    final before = _captureHistory();
    _projectId = trimmedId;
    _projectName = trimmedName;
    return _commitHistory(before);
  }

  void updateCanvasConfig(
    BuilderCanvasConfig config, {
    bool snapExisting = false,
  }) {
    final before = _captureHistory();
    _canvasConfig = config;
    if (snapExisting) {
      for (var index = 0; index < _components.length; index += 1) {
        _components[index] = _components[index].snapped(config);
      }
    }
    _commitHistory(before);
  }

  void setBreakpoint(BuilderBreakpoint breakpoint) {
    if (_currentBreakpoint == breakpoint) return;
    final before = _captureHistory();
    _currentBreakpoint = breakpoint;
    _commitHistory(before);
  }

  void setLayoutMechanism(BuilderLayoutMechanism mechanism) {
    updateCanvasConfig(
      _canvasConfig.copyWith(layoutMechanism: mechanism),
      snapExisting: true,
    );
  }

  void setShowGrid(bool showGrid) {
    updateCanvasConfig(_canvasConfig.copyWith(showGrid: showGrid));
  }

  void setSnapToGrid(bool snapToGrid) {
    updateCanvasConfig(
      _canvasConfig.copyWith(snapToGrid: snapToGrid),
      snapExisting: snapToGrid,
    );
  }

  String addComponent(
    BuilderComponentKind kind, {
    Offset? position,
    WebsiteBuilderComponentPreset? contentPreset,
  }) {
    final before = _captureHistory();
    final id = _createId(kind.key);
    final size = _canvasConfig.snapSize(kind.defaultSize);
    var component = BuilderComponentGeometry(
      id: id,
      kindKey: kind.key,
      position:
          position == null
              ? _nextComponentPosition(size)
              : _snapAndConstrainOffsetForSize(position, size),
      size: size,
      properties: websiteBuilderDefaultPropertiesFor(kind.key),
      zIndex: _nextZIndex(),
    );
    if (contentPreset != null) {
      component = websiteBuilderComponentWithPreset(component, contentPreset);
    }
    _components.add(component);
    _selectedComponentId = id;
    _commitHistory(before);
    return id;
  }

  void selectComponent(String? id) {
    if (id != null && _findComponent(id) == null) return;
    if (_selectedComponentId == id) return;
    _selectedComponentId = id;
    notifyListeners();
  }

  void moveComponent(String id, Offset position) {
    _updateComponent(id, (component) {
      return component.copyWith(position: _canvasConfig.snapOffset(position));
    });
  }

  void resizeComponent(String id, Size size) {
    _updateComponent(id, (component) {
      return component.copyWith(size: _canvasConfig.snapSize(size));
    });
  }

  void updateSelectedComponentProperty(String key, String value) {
    final component = selectedComponent;
    if (component == null) return;
    updateComponentProperty(component.id, key, value);
  }

  void updateComponentProperty(String id, String key, String value) {
    if (key.trim().isEmpty) return;
    _updateComponent(id, (component) {
      final nextProperties = {...component.properties};
      nextProperties[key] = value;
      return component.copyWith(properties: nextProperties);
    });
  }

  void resetSelectedComponentProperties() {
    final component = selectedComponent;
    if (component == null) return;
    resetComponentProperties(component.id);
  }

  void resetComponentProperties(String id) {
    _updateComponent(id, websiteBuilderComponentWithResetContentProperties);
  }

  WebsiteBuilderComponentPreset? saveSelectedComponentContentPreset({
    String? label,
  }) {
    final component = selectedComponent;
    if (component == null) return null;
    return saveComponentContentPreset(component.id, label: label);
  }

  bool updateCustomContentPresetFromSelectedComponent(String presetId) {
    final component = selectedComponent;
    if (component == null) return false;
    return updateCustomContentPresetFromComponent(presetId, component.id);
  }

  WebsiteBuilderComponentPreset? saveComponentContentPreset(
    String id, {
    String? label,
  }) {
    final component = _findComponent(id);
    if (component == null) return null;
    final properties = _contentPresetPropertiesFor(component);
    if (properties.isEmpty) return null;

    final effectiveLabel = _customPresetLabelFor(component, label);
    final preset = WebsiteBuilderComponentPreset(
      id: _uniqueCustomPresetId(component.kindKey, effectiveLabel),
      kindKey: component.kindKey,
      label: effectiveLabel,
      description:
          'Saved from ${catalog.byKey(component.kindKey)?.label ?? component.kindKey} content.',
      properties: properties,
      isCustom: true,
    );

    final before = _captureHistory();
    _customContentPresets.add(preset);
    _commitHistory(before);
    return preset;
  }

  bool updateCustomContentPresetFromComponent(
    String presetId,
    String componentId,
  ) {
    final component = _findComponent(componentId);
    if (component == null) return false;

    final presetIndex = _customContentPresets.indexWhere(
      (preset) => preset.id == presetId,
    );
    if (presetIndex < 0) return false;

    final preset = _customContentPresets[presetIndex];
    if (preset.kindKey != component.kindKey) return false;

    final properties = _contentPresetPropertiesFor(component);
    if (properties.isEmpty || mapEquals(preset.properties, properties)) {
      return false;
    }

    final before = _captureHistory();
    _customContentPresets[presetIndex] = preset.copyWith(
      properties: properties,
      isCustom: true,
    );
    return _commitHistory(before);
  }

  WebsiteBuilderContentPresetLibraryImportResult
  previewCustomContentPresetLibrary(
    WebsiteBuilderContentPresetLibrary library, {
    required String kindKey,
  }) {
    return _planCustomContentPresetLibraryImport(
      library,
      kindKey: kindKey,
    ).result;
  }

  WebsiteBuilderContentPresetLibraryImportResult
  importCustomContentPresetLibrary(
    WebsiteBuilderContentPresetLibrary library, {
    required String kindKey,
  }) {
    final plan = _planCustomContentPresetLibraryImport(
      library,
      kindKey: kindKey,
    );
    if (!plan.result.didChange) return plan.result;

    final before = _captureHistory();
    for (final entry in plan.updates.entries) {
      _customContentPresets[entry.key] = entry.value;
    }
    _customContentPresets.addAll(plan.additions);
    _commitHistory(before);

    return plan.result;
  }

  _WebsiteBuilderContentPresetLibraryImportPlan
  _planCustomContentPresetLibraryImport(
    WebsiteBuilderContentPresetLibrary library, {
    required String kindKey,
  }) {
    final targetKindKey = kindKey.trim();
    final libraryKindKey = library.kindKey.trim();
    if (targetKindKey.isEmpty || libraryKindKey != targetKindKey) {
      return _WebsiteBuilderContentPresetLibraryImportPlan(
        result: WebsiteBuilderContentPresetLibraryImportResult(
          targetKindKey: targetKindKey,
          libraryKindKey: libraryKindKey,
          skippedCount: library.presetCount,
          kindMismatch: true,
        ),
      );
    }

    var addedCount = 0;
    var updatedCount = 0;
    var skippedCount = 0;
    final additions = <WebsiteBuilderComponentPreset>[];
    final updates = <int, WebsiteBuilderComponentPreset>{};
    final reservedIds = {
      for (final preset in _customContentPresets) preset.id,
      for (final preset in websiteBuilderPresetsFor(targetKindKey)) preset.id,
    };

    for (final preset in library.presets) {
      final presetKindKey = preset.kindKey.trim();
      if (presetKindKey != targetKindKey || preset.properties.isEmpty) {
        skippedCount += 1;
        continue;
      }

      final label =
          preset.label.trim().isEmpty
              ? '${catalog.byKey(targetKindKey)?.label ?? targetKindKey} preset'
              : preset.label.trim();
      final description =
          preset.description.trim().isEmpty
              ? 'Imported from ${catalog.byKey(targetKindKey)?.label ?? targetKindKey} content.'
              : preset.description.trim();
      final preferredId = preset.id.trim();
      final nextPreset = preset.copyWith(
        id: preferredId,
        kindKey: targetKindKey,
        label: label,
        description: description,
        isCustom: true,
      );

      final existingIndex = _customContentPresets.indexWhere(
        (item) => item.id == preferredId && item.kindKey == targetKindKey,
      );
      if (preferredId.isNotEmpty && existingIndex >= 0) {
        if (_contentPresetMatches(
          _customContentPresets[existingIndex],
          nextPreset,
        )) {
          skippedCount += 1;
          continue;
        }
        updates[existingIndex] = nextPreset;
        updatedCount += 1;
        continue;
      }

      final hasReservedId =
          preferredId.isEmpty || reservedIds.contains(preferredId);
      final nextId =
          hasReservedId
              ? _uniqueCustomPresetIdForReserved(
                targetKindKey,
                label,
                reservedIds,
              )
              : preferredId;
      reservedIds.add(nextId);
      additions.add(nextPreset.copyWith(id: nextId));
      addedCount += 1;
    }

    return _WebsiteBuilderContentPresetLibraryImportPlan(
      additions: additions,
      updates: updates,
      result: WebsiteBuilderContentPresetLibraryImportResult(
        targetKindKey: targetKindKey,
        libraryKindKey: libraryKindKey,
        addedCount: addedCount,
        updatedCount: updatedCount,
        skippedCount: skippedCount,
      ),
    );
  }

  bool deleteCustomContentPreset(String id) {
    final index = _customContentPresets.indexWhere((preset) => preset.id == id);
    if (index < 0) return false;

    final before = _captureHistory();
    _customContentPresets.removeAt(index);
    return _commitHistory(before);
  }

  bool renameCustomContentPreset(String id, String label) {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) return false;
    final index = _customContentPresets.indexWhere((preset) => preset.id == id);
    if (index < 0 || _customContentPresets[index].label == trimmedLabel) {
      return false;
    }

    final before = _captureHistory();
    _customContentPresets[index] = _customContentPresets[index].copyWith(
      label: trimmedLabel,
    );
    return _commitHistory(before);
  }

  void applySelectedComponentPreset(WebsiteBuilderComponentPreset preset) {
    final component = selectedComponent;
    if (component == null) return;
    applyComponentPreset(component.id, preset);
  }

  void applyComponentPreset(String id, WebsiteBuilderComponentPreset preset) {
    _updateComponent(
      id,
      (component) => websiteBuilderComponentWithPreset(component, preset),
    );
  }

  void applySelectedContentIssueFix(WebsiteBuilderComponentContentIssue issue) {
    final component = selectedComponent;
    if (component == null) return;
    applyContentIssueFix(component.id, issue);
  }

  void applyContentIssueFix(
    String id,
    WebsiteBuilderComponentContentIssue issue,
  ) {
    final suggestedValue = issue.suggestedValue;
    if (suggestedValue == null) return;
    updateComponentProperty(id, issue.key, suggestedValue);
  }

  void applySelectedContentIssueFixes() {
    final component = selectedComponent;
    if (component == null) return;
    applyContentIssueFixes(component.id);
  }

  void applyContentIssueFixes(String id) {
    _updateComponent(id, websiteBuilderComponentWithContentIssueFixes);
  }

  String? selectNextComponentWithContentIssues() {
    return _selectComponentWithContentIssues(direction: 1);
  }

  String? selectPreviousComponentWithContentIssues() {
    return _selectComponentWithContentIssues(direction: -1);
  }

  int applyAllContentIssueFixes() {
    final before = _captureHistory();
    var changedCount = 0;

    for (var index = 0; index < _components.length; index += 1) {
      final component = _components[index];
      if (component.isLocked) continue;
      final updated = websiteBuilderComponentWithContentIssueFixes(component);
      if (jsonEncode(component.toJson()) == jsonEncode(updated.toJson())) {
        continue;
      }
      _components[index] = updated;
      changedCount += 1;
    }

    if (changedCount == 0) return 0;
    _commitHistory(before);
    return changedCount;
  }

  void toggleComponentVisibility(String id) {
    final component = _findComponent(id);
    if (component == null) return;
    _updateComponent(
      id,
      (component) => component.copyWith(isVisible: !component.isVisible),
      respectLock: false,
    );
  }

  void toggleComponentLock(String id) {
    final component = _findComponent(id);
    if (component == null) return;
    _updateComponent(
      id,
      (component) => component.copyWith(isLocked: !component.isLocked),
      respectLock: false,
    );
  }

  void bringSelectedForward() {
    _moveSelectedLayerBy(1);
  }

  void sendSelectedBackward() {
    _moveSelectedLayerBy(-1);
  }

  void bringSelectedToFront() {
    _moveSelectedLayerTo(_components.length - 1);
  }

  void sendSelectedToBack() {
    _moveSelectedLayerTo(0);
  }

  void nudgeSelected(Offset delta) {
    final component = selectedComponent;
    if (component == null || component.isLocked) return;
    moveComponent(component.id, component.position + delta);
  }

  String? duplicateSelected() {
    final component = selectedComponent;
    if (component == null || component.isLocked) return null;
    final before = _captureHistory();
    final size = _canvasConfig.snapSize(component.size);
    final duplicate = component
        .duplicate(id: _createId(component.kindKey), offset: Offset.zero)
        .copyWith(
          position: _nextComponentPosition(size, anchor: component),
          size: size,
          zIndex: _nextZIndex(),
        );
    _components.add(duplicate);
    _selectedComponentId = duplicate.id;
    _commitHistory(before);
    return duplicate.id;
  }

  void removeSelected() {
    final id = _selectedComponentId;
    if (id == null) return;
    if (_findComponent(id)?.isLocked ?? false) return;
    final before = _captureHistory();
    _components.removeWhere((component) => component.id == id);
    _selectedComponentId = null;
    _commitHistory(before);
  }

  void clear() {
    if (_components.isEmpty && _selectedComponentId == null) return;
    final before = _captureHistory();
    _components.clear();
    _selectedComponentId = null;
    _commitHistory(before);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final current = _captureHistory();
    final previous = _undoStack.removeLast();
    _redoStack.add(current);
    _restoreHistory(previous);
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final current = _captureHistory();
    final next = _redoStack.removeLast();
    _undoStack.add(current);
    _restoreHistory(next);
    notifyListeners();
  }

  void loadSharedSnapshot(
    BuilderSharedSnapshot snapshot, {
    bool includeUnknownComponents = true,
    WebsiteBuilderSnapshotImportMode mode =
        WebsiteBuilderSnapshotImportMode.replace,
  }) {
    final before = _captureHistory();
    final preview = previewSharedSnapshot(snapshot);
    final normalizedComponents =
        preview
            .normalizedComponents(
              includeUnknownComponents: includeUnknownComponents,
            )
            .toList()
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    switch (mode) {
      case WebsiteBuilderSnapshotImportMode.replace:
        _projectId = snapshot.id.trim().isEmpty ? _projectId : snapshot.id;
        _projectName =
            snapshot.name.trim().isEmpty ? _projectName : snapshot.name;
        _canvasConfig = snapshot.canvasConfig;
        _components
          ..clear()
          ..addAll(
            normalizedComponents.map(
              (component) => websiteBuilderComponentWithDefaultProperties(
                component.snapped(_canvasConfig),
              ),
            ),
          )
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
        _selectedComponentId =
            _findComponent(snapshot.selectedComponentId ?? '') == null
                ? null
                : snapshot.selectedComponentId;
      case WebsiteBuilderSnapshotImportMode.append:
        _appendSharedSnapshotComponents(snapshot, normalizedComponents);
    }

    _syncNextIdAfterImport();
    _commitHistory(before);
  }

  WebsiteBuilderSnapshotImportPreview previewSharedSnapshot(
    BuilderSharedSnapshot snapshot,
  ) {
    return WebsiteBuilderSnapshotImportPreview.fromSnapshot(
      snapshot,
      catalog: catalog,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _projectId,
      'name': _projectName,
      'canvasConfig': _canvasConfig.toJson(),
      'currentBreakpoint': _currentBreakpoint.key,
      'selectedComponentId': _selectedComponentId,
      'components': _components.map((component) => component.toJson()).toList(),
      'customContentPresets':
          _customContentPresets.map((preset) => preset.toJson()).toList(),
      'version': '1.0',
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  WebsiteBuilderContentPresetLibrary customContentPresetLibraryFor(
    String kindKey, {
    String? kindLabel,
  }) {
    final normalizedKindKey = kindKey.trim();
    final normalizedKindLabel = kindLabel?.trim();
    return WebsiteBuilderContentPresetLibrary(
      kindKey: normalizedKindKey,
      kindLabel:
          normalizedKindLabel == null || normalizedKindLabel.isEmpty
              ? catalog.byKey(normalizedKindKey)?.label ?? normalizedKindKey
              : normalizedKindLabel,
      presets: customContentPresetsFor(normalizedKindKey),
    );
  }

  String toPrettyCustomContentPresetLibraryJson(
    String kindKey, {
    String? kindLabel,
  }) {
    return customContentPresetLibraryFor(
      kindKey,
      kindLabel: kindLabel,
    ).toPrettyJson();
  }

  BuilderSharedSnapshot toSharedSnapshot() {
    return BuilderSharedSnapshot(
      id: _projectId,
      name: _projectName,
      canvasConfig: _canvasConfig,
      selectedComponentId: _selectedComponentId,
      components: List.unmodifiable(_components),
    );
  }

  String toPrettySharedSnapshotJson() {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(toSharedSnapshot().toJson());
  }

  String toHtml({
    WebsiteBuilderHtmlExportOptions options =
        const WebsiteBuilderHtmlExportOptions(),
  }) {
    return WebsiteBuilderHtmlExporter(catalog: catalog).exportDocument(
      projectName: _projectName,
      canvasConfig: _canvasConfig,
      components: _components,
      options: options,
    );
  }

  WebsiteBuilderHtmlExportReadiness inspectHtmlExport({
    WebsiteBuilderHtmlExportOptions options =
        const WebsiteBuilderHtmlExportOptions(),
  }) {
    return WebsiteBuilderHtmlExporter(
      catalog: catalog,
    ).inspect(components: _components, options: options);
  }

  factory WebsiteBuilderController.fromJson(
    Map<String, dynamic> json, {
    BuilderComponentCatalog? catalog,
    WebsiteBuilderIdFactory? idFactory,
  }) {
    final controller = WebsiteBuilderController(
      catalog: catalog,
      idFactory: idFactory,
      projectId: json['id'] as String? ?? 'loaded-website',
      projectName: json['name'] as String? ?? 'Loaded Website',
      currentBreakpoint: BuilderBreakpoint.fromKey(
        json['currentBreakpoint'] as String?,
      ),
      canvasConfig: BuilderCanvasConfig.fromJson(
        Map<String, dynamic>.from(json['canvasConfig'] as Map? ?? const {}),
      ),
      components: [
        for (final item in json['components'] as List? ?? const [])
          BuilderComponentGeometry.fromJson(
            Map<String, dynamic>.from(item as Map? ?? const {}),
          ),
      ],
      customContentPresets: [
        for (final item in json['customContentPresets'] as List? ?? const [])
          WebsiteBuilderComponentPreset.fromJson(
            Map<String, dynamic>.from(item as Map? ?? const {}),
          ),
      ],
    );
    controller._selectedComponentId = json['selectedComponentId'] as String?;
    return controller;
  }

  factory WebsiteBuilderController.fromSharedSnapshot(
    BuilderSharedSnapshot snapshot, {
    BuilderComponentCatalog? catalog,
    WebsiteBuilderIdFactory? idFactory,
  }) {
    final controller = WebsiteBuilderController(
      catalog: catalog,
      idFactory: idFactory,
    );
    controller.loadSharedSnapshot(snapshot);
    controller._clearHistory();
    return controller;
  }

  void _updateComponent(
    String id,
    BuilderComponentGeometry Function(BuilderComponentGeometry component)
    update, {
    bool respectLock = true,
  }) {
    final index = _components.indexWhere((component) => component.id == id);
    if (index < 0 || (respectLock && _components[index].isLocked)) return;
    final current = _components[index];
    final updated = update(current);
    if (jsonEncode(current.toJson()) == jsonEncode(updated.toJson())) return;

    final before = _captureHistory();
    _components[index] = updated;
    _commitHistory(before);
  }

  BuilderComponentGeometry? _findComponent(String id) {
    for (final component in _components) {
      if (component.id == id) return component;
    }
    return null;
  }

  Offset _nextComponentPosition(
    Size targetSize, {
    BuilderComponentGeometry? anchor,
  }) {
    final primaryAnchor = anchor ?? selectedComponent ?? _topComponent;
    final candidates = <Offset>[];
    final candidateAnchors = <BuilderComponentGeometry>[];
    final seenAnchorIds = <String>{};

    void addAnchor(BuilderComponentGeometry? component) {
      if (component == null || !seenAnchorIds.add(component.id)) return;
      candidateAnchors.add(component);
    }

    addAnchor(primaryAnchor);
    for (final component in _componentsByLayer().reversed) {
      addAnchor(component);
    }

    for (final component in candidateAnchors) {
      candidates.addAll(_placementCandidatesAround(component));
    }

    final index = _components.length;
    final offset = 24.0 + ((index % 8) * 28.0);
    candidates.add(Offset(offset, offset));

    for (final candidate in candidates) {
      final position = _snapAndConstrainOffsetForSize(candidate, targetSize);
      if (_canPlaceComponentAt(position, targetSize)) return position;
    }

    return _firstOpenCanvasPosition(targetSize) ??
        _snapAndConstrainOffsetForSize(Offset(offset, offset), targetSize);
  }

  BuilderComponentGeometry? get _topComponent {
    if (_components.isEmpty) return null;
    return _componentsByLayer().last;
  }

  List<Offset> _placementCandidatesAround(BuilderComponentGeometry component) {
    return [
      Offset(
        component.position.dx,
        component.position.dy + component.size.height + _componentInsertGap,
      ),
      Offset(
        component.position.dx + component.size.width + _componentInsertGap,
        component.position.dy,
      ),
    ];
  }

  bool _canPlaceComponentAt(Offset offset, Size size) {
    if (!_fitsWithinCanvas(offset, size)) return false;
    final candidateRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      size.height,
    );
    for (final component in _components) {
      if (candidateRect.overlaps(
        component.rect.inflate(_componentCollisionGap),
      )) {
        return false;
      }
    }
    return true;
  }

  Offset? _firstOpenCanvasPosition(Size targetSize) {
    final step = _canvasConfig.gridSize < 20.0 ? 20.0 : _canvasConfig.gridSize;
    final maxX = (_canvasConfig.canvasWidth - targetSize.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_canvasConfig.canvasHeight - targetSize.height).clamp(
      0.0,
      double.infinity,
    );

    for (var y = 0.0; y <= maxY; y += step) {
      for (var x = 0.0; x <= maxX; x += step) {
        final position = _snapAndConstrainOffsetForSize(
          Offset(x, y),
          targetSize,
        );
        if (_canPlaceComponentAt(position, targetSize)) return position;
      }
    }
    return null;
  }

  bool _fitsWithinCanvas(Offset offset, Size size) {
    return offset.dx >= 0 &&
        offset.dy >= 0 &&
        offset.dx + size.width <= _canvasConfig.canvasWidth &&
        offset.dy + size.height <= _canvasConfig.canvasHeight;
  }

  Offset _snapAndConstrainOffsetForSize(Offset offset, Size size) {
    final constrained = _constrainOffsetForSize(offset, size);
    final snapped = _canvasConfig.snapOffset(constrained);
    return _constrainOffsetForSize(snapped, size);
  }

  Offset _constrainOffsetForSize(Offset offset, Size size) {
    final maxX = (_canvasConfig.canvasWidth - size.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (_canvasConfig.canvasHeight - size.height).clamp(
      0.0,
      double.infinity,
    );
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  int _nextZIndex() {
    if (_components.isEmpty) return 0;
    return _components
            .map((component) => component.zIndex)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  void _appendSharedSnapshotComponents(
    BuilderSharedSnapshot snapshot,
    List<BuilderComponentGeometry> components,
  ) {
    final reservedIds = <String>{};
    final idMap = <String, String>{};
    final nextZIndex = _nextZIndex();
    final imported = <BuilderComponentGeometry>[];

    for (var index = 0; index < components.length; index += 1) {
      final component = components[index];
      final id = _uniqueImportedId(component.id, reservedIds);
      idMap[component.id] = id;
      imported.add(
        websiteBuilderComponentWithDefaultProperties(
          component
              .copyWith(id: id, zIndex: nextZIndex + index)
              .snapped(_canvasConfig),
        ),
      );
    }

    _components.addAll(imported);
    _components.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final selectedId = snapshot.selectedComponentId;
    final remappedSelectedId = selectedId == null ? null : idMap[selectedId];
    if (remappedSelectedId != null) {
      _selectedComponentId = remappedSelectedId;
    }
  }

  void _moveSelectedLayerBy(int delta) {
    final selectedId = _selectedComponentId;
    if (selectedId == null) return;
    final sorted = _componentsByLayer();
    final currentIndex = sorted.indexWhere(
      (component) => component.id == selectedId,
    );
    if (currentIndex < 0) return;
    _moveSelectedLayerTo(currentIndex + delta);
  }

  void _moveSelectedLayerTo(int targetIndex) {
    final selectedId = _selectedComponentId;
    final selected = selectedComponent;
    if (selectedId == null || selected == null || selected.isLocked) return;
    final sorted = _componentsByLayer();
    final currentIndex = sorted.indexWhere(
      (component) => component.id == selectedId,
    );
    if (currentIndex < 0) return;

    final boundedTarget = targetIndex.clamp(0, sorted.length - 1);
    if (boundedTarget == currentIndex) return;

    final moving = sorted.removeAt(currentIndex);
    sorted.insert(boundedTarget, moving);
    _applyLayerOrder(sorted);
  }

  List<BuilderComponentGeometry> _componentsByLayer() {
    return [..._components]..sort((a, b) {
      final zCompare = a.zIndex.compareTo(b.zIndex);
      if (zCompare != 0) return zCompare;
      return a.id.compareTo(b.id);
    });
  }

  void _applyLayerOrder(List<BuilderComponentGeometry> orderedComponents) {
    final before = _captureHistory();
    for (var layer = 0; layer < orderedComponents.length; layer += 1) {
      final component = orderedComponents[layer];
      final index = _components.indexWhere((item) => item.id == component.id);
      if (index >= 0) {
        _components[index] = _components[index].copyWith(zIndex: layer);
      }
    }
    _components.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    _commitHistory(before);
  }

  String? _selectComponentWithContentIssues({required int direction}) {
    final issueComponents = _componentsWithIssuesByLayer();
    if (issueComponents.isEmpty) return null;

    final currentIndex = issueComponents.indexWhere(
      (component) => component.id == _selectedComponentId,
    );
    final nextIndex =
        currentIndex < 0
            ? direction >= 0
                ? 0
                : issueComponents.length - 1
            : (currentIndex + direction) % issueComponents.length;
    final normalizedIndex =
        nextIndex < 0 ? issueComponents.length + nextIndex : nextIndex;
    final nextId = issueComponents[normalizedIndex].id;
    selectComponent(nextId);
    return nextId;
  }

  List<BuilderComponentGeometry> _componentsWithIssuesByLayer() {
    return [
      for (final component in [..._components]
        ..sort((a, b) => b.zIndex.compareTo(a.zIndex)))
        if (websiteBuilderContentIssuesFor(component).isNotEmpty) component,
    ];
  }

  _WebsiteBuilderHistorySnapshot _captureHistory() {
    return _WebsiteBuilderHistorySnapshot(
      canvasConfig: _canvasConfig,
      currentBreakpoint: _currentBreakpoint,
      projectId: _projectId,
      projectName: _projectName,
      selectedComponentId: _selectedComponentId,
      components: _components,
      customContentPresets: _customContentPresets,
      nextId: _nextId,
    );
  }

  bool _commitHistory(_WebsiteBuilderHistorySnapshot before) {
    final after = _captureHistory();
    if (before.fingerprint == after.fingerprint) return false;

    _undoStack.add(before);
    if (_undoStack.length > _maxWebsiteBuilderHistoryDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    notifyListeners();
    return true;
  }

  void _restoreHistory(_WebsiteBuilderHistorySnapshot snapshot) {
    _canvasConfig = snapshot.canvasConfig;
    _currentBreakpoint = snapshot.currentBreakpoint;
    _projectId = snapshot.projectId;
    _projectName = snapshot.projectName;
    _selectedComponentId = snapshot.selectedComponentId;
    _components
      ..clear()
      ..addAll(snapshot.components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    _customContentPresets
      ..clear()
      ..addAll(snapshot.customContentPresets);
    _nextId = snapshot.nextId;
  }

  void _clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }

  Map<String, String> _contentPresetPropertiesFor(
    BuilderComponentGeometry component,
  ) {
    final properties = <String, String>{};
    for (final spec in websiteBuilderPropertySpecsFor(component.kindKey)) {
      properties[spec.key] =
          component.properties[spec.key] ?? spec.defaultValue;
    }
    return properties;
  }

  String _customPresetLabelFor(
    BuilderComponentGeometry component,
    String? label,
  ) {
    final trimmedLabel = label?.trim();
    if (trimmedLabel != null && trimmedLabel.isNotEmpty) {
      return trimmedLabel;
    }
    final primary = websiteBuilderPrimaryPropertyValue(component);
    if (primary != null && primary.trim().isNotEmpty) return primary.trim();
    return '${catalog.byKey(component.kindKey)?.label ?? component.kindKey} preset';
  }

  String _uniqueCustomPresetId(String kindKey, String label) {
    final slug = _slugForPresetId(label);
    final base = 'custom_${kindKey}_$slug';
    final reservedIds = {
      for (final preset in _customContentPresets) preset.id,
      for (final preset in websiteBuilderPresetsFor(kindKey)) preset.id,
    };
    var candidate = base;
    var suffix = 2;
    while (reservedIds.contains(candidate)) {
      candidate = '${base}_$suffix';
      suffix += 1;
    }
    return candidate;
  }

  String _uniqueCustomPresetIdForReserved(
    String kindKey,
    String label,
    Set<String> reservedIds,
  ) {
    final slug = _slugForPresetId(label);
    final base = 'custom_${kindKey}_$slug';
    var candidate = base;
    var suffix = 2;
    while (reservedIds.contains(candidate)) {
      candidate = '${base}_$suffix';
      suffix += 1;
    }
    return candidate;
  }

  String _slugForPresetId(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'preset' : slug;
  }

  bool _contentPresetMatches(
    WebsiteBuilderComponentPreset left,
    WebsiteBuilderComponentPreset right,
  ) {
    return left.id == right.id &&
        left.kindKey == right.kindKey &&
        left.label == right.label &&
        left.description == right.description &&
        left.isCustom == right.isCustom &&
        mapEquals(left.properties, right.properties);
  }

  String _createId(String prefix) {
    final next = _idFactory?.call();
    if (next != null &&
        next.trim().isNotEmpty &&
        _findComponent(next) == null) {
      return next;
    }
    final normalizedPrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    var candidate = '${normalizedPrefix}_${_nextId++}';
    while (_findComponent(candidate) != null) {
      candidate = '${normalizedPrefix}_${_nextId++}';
    }
    return candidate;
  }

  String _uniqueImportedId(String preferredId, Set<String> reservedIds) {
    final fallback =
        preferredId.trim().isEmpty ? 'imported_component' : preferredId;
    final base = fallback.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    var candidate = base;
    var suffix = 2;
    while (_findComponent(candidate) != null ||
        reservedIds.contains(candidate)) {
      candidate = '${base}_$suffix';
      suffix += 1;
    }
    reservedIds.add(candidate);
    return candidate;
  }

  void _syncNextIdAfterImport() {
    var highestSuffix = 0;
    for (final component in _components) {
      final match = RegExp(r'_(\d+)$').firstMatch(component.id);
      if (match == null) continue;
      final suffix = int.tryParse(match.group(1) ?? '');
      if (suffix != null && suffix > highestSuffix) {
        highestSuffix = suffix;
      }
    }
    _nextId = highestSuffix + 1;
  }
}

class _WebsiteBuilderContentPresetLibraryImportPlan {
  final WebsiteBuilderContentPresetLibraryImportResult result;
  final List<WebsiteBuilderComponentPreset> additions;
  final Map<int, WebsiteBuilderComponentPreset> updates;

  _WebsiteBuilderContentPresetLibraryImportPlan({
    required this.result,
    this.additions = const [],
    this.updates = const {},
  });
}

class _WebsiteBuilderHistorySnapshot {
  final BuilderCanvasConfig canvasConfig;
  final BuilderBreakpoint currentBreakpoint;
  final String projectId;
  final String projectName;
  final String? selectedComponentId;
  final List<BuilderComponentGeometry> components;
  final List<WebsiteBuilderComponentPreset> customContentPresets;
  final int nextId;

  _WebsiteBuilderHistorySnapshot({
    required this.canvasConfig,
    required this.currentBreakpoint,
    required this.projectId,
    required this.projectName,
    required this.selectedComponentId,
    required List<BuilderComponentGeometry> components,
    required List<WebsiteBuilderComponentPreset> customContentPresets,
    required this.nextId,
  }) : components = List.unmodifiable(components),
       customContentPresets = List.unmodifiable(customContentPresets);

  String get fingerprint => jsonEncode({
    'canvasConfig': canvasConfig.toJson(),
    'currentBreakpoint': currentBreakpoint.key,
    'projectId': projectId,
    'projectName': projectName,
    'selectedComponentId': selectedComponentId,
    'components': components.map((component) => component.toJson()).toList(),
    'customContentPresets':
        customContentPresets.map((preset) => preset.toJson()).toList(),
    'nextId': nextId,
  });
}
