// Services
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component_style.dart';
import '../models/component_type.dart';
import '../models/design_component.dart';
import '../models/designer_state.dart';
import '../models/enums.dart';
import '../models/project.dart';

import '../states/component_provider.dart';
import 'history_service.dart';
import '../states/provider.dart';

class DesignerNotifier extends StateNotifier<DesignerState> {
  DesignerNotifier(this.ref) : super(const DesignerState()) {
    _addToHistory();
  }

  final Ref ref;
  final HistoryService _history = HistoryService();

  void _addToHistory() {
    _history.addToHistory(state.components);
  }

  // Component Operations
  void addComponent(ComponentType type, {Offset? position}) {
    final componentService = ref.read(componentServiceProvider);
    final newComponent = componentService.createComponent(
      type,
      position: position,
    );

    state = state.copyWith(
      components: [...state.components, newComponent],
      selectedComponentIds: [newComponent.id],
    );
    _addToHistory();
  }

  void updateComponent(String id, DesignComponent updated) {
    final index = state.components.indexWhere((c) => c.id == id);
    if (index != -1) {
      final newComponents = List<DesignComponent>.from(state.components);
      newComponents[index] = updated.copyWith(lastModified: DateTime.now());
      state = state.copyWith(components: newComponents);
      _addToHistory();
    }
  }

  void updateComponentProperty(String id, String key, dynamic value) {
    final component = state.components.firstWhere((c) => c.id == id);
    final newProperties = Map<String, dynamic>.from(component.properties);
    newProperties[key] = value;
    updateComponent(id, component.copyWith(properties: newProperties));
  }

  void updateComponentStyle(String id, ComponentStyle style) {
    final component = state.components.firstWhere((c) => c.id == id);
    updateComponent(id, component.copyWith(style: style));
  }

  void deleteSelectedComponents() {
    if (state.selectedComponentIds.isEmpty) return;

    final newComponents =
        state.components
            .where((c) => !state.selectedComponentIds.contains(c.id))
            .toList();

    state = state.copyWith(components: newComponents, selectedComponentIds: []);
    _addToHistory();
  }

  void duplicateSelected() {
    if (state.selectedComponentIds.isEmpty) return;

    final componentService = ref.read(componentServiceProvider);
    final selected = state.selectedComponents;
    final duplicates = componentService.duplicateComponents(selected);

    state = state.copyWith(
      components: [...state.components, ...duplicates],
      selectedComponentIds: duplicates.map((c) => c.id).toList(),
    );
    _addToHistory();
  }

  void copySelected() {
    if (state.selectedComponentIds.isEmpty) return;

    final componentService = ref.read(componentServiceProvider);
    final selected = state.selectedComponents;
    final copied = componentService.copyComponents(selected);

    state = state.copyWith(clipboard: copied);
    _addToHistory();
  }

  void pasteComponents() {
    if (state.clipboard.isEmpty) return;

    final componentService = ref.read(componentServiceProvider);
    final pasted = componentService.duplicateComponents(state.clipboard);

    state = state.copyWith(
      components: [...state.components, ...pasted],
      selectedComponentIds: pasted.map((c) => c.id).toList(),
    );
    _addToHistory();
  }

  // Selection
  void selectComponent(String id, {bool multiSelect = false}) {
    if (multiSelect) {
      final selected = List<String>.from(state.selectedComponentIds);
      if (selected.contains(id)) {
        selected.remove(id);
      } else {
        selected.add(id);
      }
      state = state.copyWith(selectedComponentIds: selected);
    } else {
      state = state.copyWith(selectedComponentIds: [id]);
    }
  }

  void selectAll() {
    state = state.copyWith(
      selectedComponentIds: state.components.map((c) => c.id).toList(),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedComponentIds: []);
  }

  // Grouping
  void groupSelected() {
    if (state.selectedComponentIds.length <= 1) return;

    final componentService = ref.read(componentServiceProvider);
    final groupId = componentService.generateGroupId();

    final newComponents =
        state.components.map((c) {
          if (state.selectedComponentIds.contains(c.id)) {
            return c.copyWith(groupId: groupId);
          }
          return c;
        }).toList();

    final newGroups = Map<String, List<String>>.from(state.groups);
    newGroups[groupId] = List.from(state.selectedComponentIds);

    state = state.copyWith(components: newComponents, groups: newGroups);
    _addToHistory();
  }

  void ungroupSelected() {
    final component = state.selectedComponent;
    if (component?.groupId == null) return;

    final groupId = component!.groupId!;
    final newComponents =
        state.components.map((c) {
          if (c.groupId == groupId) return c.copyWith(groupId: null);
          return c;
        }).toList();

    final newGroups = Map<String, List<String>>.from(state.groups);
    newGroups.remove(groupId);

    state = state.copyWith(components: newComponents, groups: newGroups);
    _addToHistory();
  }

  // Alignment
  // In DesignerNotifier class - update the alignment methods
  void alignSelected(AlignType alignType) {
    if (state.selectedComponentIds.length <= 1) return;

    final alignmentService = ref.read(alignmentServiceProvider);
    List<DesignComponent> updatedComponents;

    switch (alignType) {
      case AlignType.left:
        updatedComponents = alignmentService.alignLeft(
          state.components,
          state.selectedComponentIds,
        );
        break;
      case AlignType.center:
        updatedComponents = alignmentService.alignCenter(
          state.components,
          state.selectedComponentIds,
        );
        break;
      case AlignType.right:
        updatedComponents = alignmentService.alignRight(
          state.components,
          state.selectedComponentIds,
        );
        break;
      case AlignType.top:
        updatedComponents = alignmentService.alignTop(
          state.components,
          state.selectedComponentIds,
        );
        break;
      case AlignType.bottom:
        updatedComponents = alignmentService.alignBottom(
          state.components,
          state.selectedComponentIds,
        );
        break;
      case AlignType.spaceBetween:
        updatedComponents = alignmentService.distributeHorizontally(
          state.components,
          state.selectedComponentIds,
        );
        break;
      default:
        return;
    }

    state = state.copyWith(components: updatedComponents);
    _addToHistory();
  }

  // Individual alignment methods for convenience
  void alignLeft() => alignSelected(AlignType.left);
  void alignCenter() => alignSelected(AlignType.center);
  void alignRight() => alignSelected(AlignType.right);
  void alignTop() => alignSelected(AlignType.top);
  void alignBottom() => alignSelected(AlignType.bottom);
  void distributeHorizontally() => alignSelected(AlignType.spaceBetween);

  // Z-Index Management
  void bringToFront() {
    final component = state.selectedComponent;
    if (component == null) return;

    final maxZ = state.components.map((c) => c.zIndex).reduce(math.max);
    updateComponent(component.id, component.copyWith(zIndex: maxZ + 1));
  }

  void sendToBack() {
    final component = state.selectedComponent;
    if (component == null) return;

    final minZ = state.components.map((c) => c.zIndex).reduce(math.min);
    updateComponent(component.id, component.copyWith(zIndex: minZ - 1));
  }

  // In DesignerNotifier class - add this method
  void distributeVertically() {
    if (state.selectedComponentIds.length <= 2) return;

    final alignmentService = ref.read(alignmentServiceProvider);
    final updatedComponents = alignmentService.distributeVertically(
      state.components,
      state.selectedComponentIds,
    );

    state = state.copyWith(components: updatedComponents);
    _addToHistory();
  }

  // In DesignerNotifier class - add these methods
  void bringForward() {
    final component = state.selectedComponent;
    if (component == null) return;

    updateComponent(
      component.id,
      component.copyWith(zIndex: component.zIndex + 1),
    );
  }

  void sendBackward() {
    final component = state.selectedComponent;
    if (component == null) return;

    updateComponent(
      component.id,
      component.copyWith(zIndex: component.zIndex - 1),
    );
  }

  // In DesignerNotifier class - add this method
  void toggleAIAssist() =>
      state = state.copyWith(aiAssistEnabled: !state.aiAssistEnabled);
  // View Operations
  // In DesignerNotifier class - ensure all these toggle methods exist
  void toggleGrid() => state = state.copyWith(showGrid: !state.showGrid);
  void toggleSnapToGrid() =>
      state = state.copyWith(snapToGrid: !state.snapToGrid);
  void toggleComponentTree() =>
      state = state.copyWith(showComponentTree: !state.showComponentTree);
  void toggleAnimationPanel() =>
      state = state.copyWith(showAnimationPanel: !state.showAnimationPanel);
  void togglePropertiesPanel() =>
      state = state.copyWith(showPropertiesPanel: !state.showPropertiesPanel);
  void toggleLayersPanel() =>
      state = state.copyWith(showLayersPanel: !state.showLayersPanel);
  void toggleCodePanel() =>
      state = state.copyWith(showCodePanel: !state.showCodePanel);

  void toggleDarkMode() =>
      state = state.copyWith(
        themeMode:
            state.themeMode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light,
      );
  amework(String fw) => state = state.copyWith(selectedFramework: fw);

  void copyComponents() {
    if (state.selectedComponentIds.isEmpty) return;

    final copied =
        state.components
            .where((c) => state.selectedComponentIds.contains(c.id))
            .map((c) => c.copyWith())
            .toList();

    state = state.copyWith(clipboard: copied);
  }

  // In DesignerNotifier class - replace the duplicateComponents method
  void duplicateComponents() {
    if (state.selectedComponentIds.isEmpty) return;

    final componentService = ref.read(componentServiceProvider);
    final selected = state.selectedComponents;
    final duplicates = componentService.duplicateComponents(selected);

    state = state.copyWith(
      components: [...state.components, ...duplicates],
      selectedComponentIds: duplicates.map((c) => c.id).toList(),
    );
    _addToHistory();
  }

  // History
  void undo() {
    final components = _history.undo();
    if (components != null) {
      state = state.copyWith(components: components, selectedComponentIds: []);
    }
  }

  void redo() {
    final components = _history.redo();
    if (components != null) {
      state = state.copyWith(components: components, selectedComponentIds: []);
    }
  }

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  void setZoom(double zoom) =>
      state = state.copyWith(canvasZoom: zoom.clamp(0.1, 5.0));
  void setGridSize(double size) =>
      state = state.copyWith(gridSize: size.clamp(10, 100));
  void setBreakpoint(ResponsiveBreakpoint bp) =>
      state = state.copyWith(currentBreakpoint: bp);
  void setLayoutMode(LayoutMode mode) =>
      state = state.copyWith(layoutMode: mode);
  void setSelectedTool(String? tool) =>
      state = state.copyWith(selectedTool: tool);

  // Project Management
  String saveProject() {
    final jsonData = {
      'name': state.currentProjectName,
      'components': state.components.map((c) => c.toJson()).toList(),
      'groups': state.groups,
      'designTokens': state.designTokens,
      'breakpoint': state.currentBreakpoint.name,
      'version': '2.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  void loadProject(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString);
      final loadedComponents =
          (jsonData['components'] as List)
              .map((c) => DesignComponent.fromJson(c))
              .toList();

      state = state.copyWith(
        components: loadedComponents,
        currentProjectName: jsonData['name'] ?? 'Loaded Project',
        selectedComponentIds: [],
      );

      _history.clear();
      _addToHistory();
    } catch (e) {
      print('Error loading project: $e');
    }
  }

  void newProject() {
    state = const DesignerState(currentProjectName: 'New Project');
    _history.clear();
    _addToHistory();
  }

  // Cloud Operations
  Future<void> saveToCloud(String projectName) async {
    state = state.copyWith(projectStatus: ProjectStatus.saving);

    try {
      final cloudService = ref.read(cloudStorageServiceProvider);
      final project = Project(
        id:
            state.currentProjectId ??
            'project_${DateTime.now().millisecondsSinceEpoch}',
        name: projectName,
        components: state.components,
        groups: state.groups,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await cloudService.saveProject(project);
      state = state.copyWith(
        currentProjectId: project.id,
        projectStatus: ProjectStatus.idle,
        currentProjectName: projectName,
      );
    } catch (e) {
      state = state.copyWith(projectStatus: ProjectStatus.error);
      rethrow;
    }
  }

  Future<void> loadFromCloud(String projectId) async {
    state = state.copyWith(projectStatus: ProjectStatus.loading);

    try {
      final cloudService = ref.read(cloudStorageServiceProvider);
      final project = await cloudService.loadProject(projectId);

      state = state.copyWith(
        components: project.components,
        groups: project.groups,
        currentProjectId: project.id,
        currentProjectName: project.name,
        projectStatus: ProjectStatus.idle,
        selectedComponentIds: [],
      );

      _history.clear();
      _addToHistory();
    } catch (e) {
      state = state.copyWith(projectStatus: ProjectStatus.error);
      rethrow;
    }
  }

  // AI Features
  Future<void> generateUIFromPrompt(String prompt) async {
    state = state.copyWith(aiAssistEnabled: true);

    await Future.delayed(const Duration(seconds: 1));

    // Simulate AI generation
    if (prompt.toLowerCase().contains('hero')) {
      addComponent(ComponentType.hero);
    }
    if (prompt.toLowerCase().contains('button')) {
      addComponent(ComponentType.button);
    }
    if (prompt.toLowerCase().contains('card')) {
      addComponent(ComponentType.card);
    }

    state = state.copyWith(aiAssistEnabled: false);
  }
}
