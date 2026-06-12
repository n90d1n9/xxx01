// Services
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component_style.dart';
import '../models/component_type.dart';
import '../models/design_component.dart';
import '../models/designer_state.dart';
import '../models/enums.dart';
import '../models/project.dart';
import '../services/cloud_storage_service.dart';
import '../services/collaborator_service.dart';

final cloudStorageServiceProvider = Provider((ref) => CloudStorageService());
final collaborationServiceProvider = Provider((ref) => CollaborationService());

// Main Designer State
class DesignerNotifier extends StateNotifier<DesignerState> {
  DesignerNotifier(this.ref) : super(const DesignerState()) {
    _idCounter = 0;
    _groupCounter = 0;
    _addToHistory();
  }

  final Ref ref;
  int _idCounter = 0;
  int _groupCounter = 0;
  final List<List<DesignComponent>> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 100;

  String _generateId() =>
      'comp_${_idCounter++}_${DateTime.now().millisecondsSinceEpoch}';
  String _generateGroupId() => 'group_${_groupCounter++}';

  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(List.from(state.components));
    _historyIndex++;
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(List.from(state.components));
    _historyIndex++;
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  // Component Operations
  void addComponent(ComponentType type) {
    final newComponent = DesignComponent(
      id: _generateId(),
      type: type,
      position: const Offset(100, 100),
      size: _getDefaultSize(type),
      properties: _getDefaultProperties(type),
      zIndex: state.components.length,
      lastModified: DateTime.now(),
      modifiedBy: 'current_user',
    );

    state = state.copyWith(
      components: [...state.components, newComponent],
      selectedComponentIds: [newComponent.id],
    );
    _addToHistory();
    _notifyCollaborators('component_added', newComponent.id);
  }

  void updateComponent(String id, DesignComponent updated) {
    final index = state.components.indexWhere((c) => c.id == id);
    if (index != -1) {
      final newComponents = List<DesignComponent>.from(state.components);
      newComponents[index] = updated.copyWith(
        lastModified: DateTime.now(),
        modifiedBy: 'current_user',
      );
      state = state.copyWith(components: newComponents);
      _addToHistory();
      _notifyCollaborators('component_updated', id);
    }
  }

  void updateComponentProperty(String id, String key, dynamic value) {
    final component = state.components.firstWhere((c) => c.id == id);
    final newProperties = Map<String, dynamic>.from(component.properties);
    newProperties[key] = value;
    updateComponent(id, component.copyWith(properties: newProperties));
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

  void duplicateComponents() {
    if (state.selectedComponentIds.isEmpty) return;

    final duplicates = <DesignComponent>[];
    for (var id in state.selectedComponentIds) {
      final component = state.components.firstWhere((c) => c.id == id);
      final duplicate = component.copyWith(
        id: _generateId(),
        position: Offset(
          component.position.dx + 20,
          component.position.dy + 20,
        ),
        lastModified: DateTime.now(),
      );
      duplicates.add(duplicate);
    }

    state = state.copyWith(
      components: [...state.components, ...duplicates],
      selectedComponentIds: duplicates.map((c) => c.id).toList(),
    );
    _addToHistory();
  }

  void copyComponents() {
    if (state.selectedComponentIds.isEmpty) return;

    final copied =
        state.components
            .where((c) => state.selectedComponentIds.contains(c.id))
            .map((c) => c.copyWith())
            .toList();

    state = state.copyWith(clipboard: copied);
  }

  void pasteComponents() {
    if (state.clipboard.isEmpty) return;

    final pasted = <DesignComponent>[];
    for (var component in state.clipboard) {
      final paste = component.copyWith(
        id: _generateId(),
        position: Offset(
          component.position.dx + 20,
          component.position.dy + 20,
        ),
        lastModified: DateTime.now(),
      );
      pasted.add(paste);
    }

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

  void clearSelection() {
    state = state.copyWith(selectedComponentIds: []);
  }

  // Grouping
  void groupSelected() {
    if (state.selectedComponentIds.length <= 1) return;

    final groupId = _generateGroupId();
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
  void alignLeft() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final leftMost = selected.map((c) => c.position.dx).reduce(math.min);
    _alignComponents((c) => Offset(leftMost, c.position.dy));
  }

  void alignCenter() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final avg =
        selected
            .map((c) => c.position.dx + c.size.width / 2)
            .reduce((a, b) => a + b) /
        selected.length;
    _alignComponents((c) => Offset(avg - c.size.width / 2, c.position.dy));
  }

  void alignRight() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final rightMost = selected
        .map((c) => c.position.dx + c.size.width)
        .reduce(math.max);
    _alignComponents((c) => Offset(rightMost - c.size.width, c.position.dy));
  }

  void _alignComponents(Offset Function(DesignComponent) getPosition) {
    final newComponents =
        state.components.map((c) {
          if (state.selectedComponentIds.contains(c.id)) {
            return c.copyWith(position: getPosition(c));
          }
          return c;
        }).toList();
    state = state.copyWith(components: newComponents);
    _addToHistory();
  }

  // Z-Index
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

  // History
  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      state = state.copyWith(
        components: List.from(_history[_historyIndex]),
        selectedComponentIds: [],
      );
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      state = state.copyWith(
        components: List.from(_history[_historyIndex]),
        selectedComponentIds: [],
      );
    }
  }

  bool canUndo() => _historyIndex > 0;
  bool canRedo() => _historyIndex < _history.length - 1;

  // View Operations
  void toggleGrid() => state = state.copyWith(showGrid: !state.showGrid);
  void toggleSnapToGrid() =>
      state = state.copyWith(snapToGrid: !state.snapToGrid);
  void toggleComponentTree() =>
      state = state.copyWith(showComponentTree: !state.showComponentTree);
  void toggleAnimationPanel() =>
      state = state.copyWith(showAnimationPanel: !state.showAnimationPanel);
  void toggleDarkMode() =>
      state = state.copyWith(isDarkMode: !state.isDarkMode);
  void setZoom(double zoom) =>
      state = state.copyWith(canvasZoom: zoom.clamp(0.5, 2.0));
  void setBreakpoint(ResponsiveBreakpoint bp) =>
      state = state.copyWith(currentBreakpoint: bp);
  void setFramework(String fw) => state = state.copyWith(selectedFramework: fw);

  // Cloud Operations
  Future<void> saveToCloud(String projectName) async {
    state = state.copyWith(projectStatus: ProjectStatus.saving);

    try {
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

      final cloudService = ref.read(cloudStorageServiceProvider);
      await cloudService.saveProject(project);

      state = state.copyWith(
        currentProjectId: project.id,
        projectStatus: ProjectStatus.idle,
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
        projectStatus: ProjectStatus.idle,
        selectedComponentIds: [],
      );

      _history.clear();
      _historyIndex = -1;
      _addToHistory();
    } catch (e) {
      state = state.copyWith(projectStatus: ProjectStatus.error);
      rethrow;
    }
  }

  // Collaboration
  Future<void> startCollaboration(String projectId) async {
    state = state.copyWith(collaborationStatus: CollaborationStatus.connecting);

    try {
      final collabService = ref.read(collaborationServiceProvider);
      await collabService.connect(projectId, 'current_user');

      state = state.copyWith(
        collaborationStatus: CollaborationStatus.connected,
      );

      // Listen to updates
      collabService.messages.listen((message) {
        _handleCollaborationMessage(message);
      });
    } catch (e) {
      state = state.copyWith(
        collaborationStatus: CollaborationStatus.disconnected,
      );
    }
  }

  void _handleCollaborationMessage(Map<String, dynamic> message) {
    final type = message['type'];

    switch (type) {
      case 'component_update':
        // Handle remote component update
        final componentId = message['componentId'];
        final changes = message['changes'];
        // Apply changes without adding to history
        break;
      case 'cursor_move':
        // Update collaborator cursor position
        final userId = message['userId'];
        final position = message['position'];
        final newCollaborators = Map<String, dynamic>.from(state.collaborators);
        newCollaborators[userId] = position;
        state = state.copyWith(collaborators: newCollaborators);
        break;
    }
  }

  void _notifyCollaborators(String action, String componentId) {
    if (state.collaborationStatus != CollaborationStatus.connected) return;

    final collabService = ref.read(collaborationServiceProvider);
    collabService.sendUpdate(componentId, {'action': action});
  }

  // Helper Methods
  Size _getDefaultSize(ComponentType type) {
    switch (type) {
      case ComponentType.container:
        return const Size(200, 150);
      case ComponentType.text:
        return const Size(150, 40);
      case ComponentType.button:
        return const Size(120, 45);
      case ComponentType.image:
        return const Size(200, 200);
      case ComponentType.input:
        return const Size(250, 50);
      case ComponentType.icon:
        return const Size(50, 50);
      default:
        return const Size(200, 150);
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.container:
        return {
          'backgroundColor': Colors.blue.shade100.value,
          'borderRadius': 8.0,
          'borderWidth': 1.0,
          'borderColor': Colors.blue.value,
          'padding': 16.0,
          'shadow': false,
        };
      case ComponentType.text:
        return {
          'text': 'Text Component',
          'fontSize': 16.0,
          'color': Colors.black.value,
          'fontWeight': 'normal',
          'textAlign': 'left',
        };
      case ComponentType.button:
        return {
          'text': 'Button',
          'backgroundColor': Colors.blue.value,
          'textColor': Colors.white.value,
          'borderRadius': 8.0,
        };
      case ComponentType.icon:
        return {'icon': 'star', 'color': Colors.blue.value, 'size': 24.0};
      default:
        return {};
    }
  }

  //////

  // ========== COMPONENT OPERATIONS ==========

  void addComponent(ComponentType type) {
    final newComponent = DesignComponent(
      id: _generateId(),
      type: type,
      name: '${type.name}_${_idCounter}',
      position: Offset(100 + (components.length * 20).toDouble(), 100),
      size: _getDefaultSize(type),
      properties: _getDefaultProperties(type),
      style: _getDefaultStyle(type),
      animation: const ComponentAnimation(),
      zIndex: state.components.length,
    );

    state = state.copyWith(
      components: [...state.components, newComponent],
      selectedComponentIds: [newComponent.id],
      hasUnsavedChanges: true,
    );
    _addToHistory();
  }

  List<DesignComponent> get components => state.components;

  void updateComponent(String id, DesignComponent updated) {
    final index = state.components.indexWhere((c) => c.id == id);
    if (index != -1) {
      final newComponents = List<DesignComponent>.from(state.components);
      newComponents[index] = updated;
      state = state.copyWith(
        components: newComponents,
        hasUnsavedChanges: true,
      );
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

  void updateComponentAnimation(String id, ComponentAnimation animation) {
    final component = state.components.firstWhere((c) => c.id == id);
    updateComponent(id, component.copyWith(animation: animation));
  }

  void deleteSelectedComponents() {
    if (state.selectedComponentIds.isEmpty) return;
    final newComponents =
        state.components
            .where((c) => !state.selectedComponentIds.contains(c.id))
            .toList();
    state = state.copyWith(
      components: newComponents,
      selectedComponentIds: [],
      hasUnsavedChanges: true,
    );
    _addToHistory();
  }

  void duplicateComponents() {
    if (state.selectedComponentIds.isEmpty) return;
    final duplicates = <DesignComponent>[];
    for (var id in state.selectedComponentIds) {
      final component = state.components.firstWhere((c) => c.id == id);
      final duplicate = component.copyWith(
        id: _generateId(),
        position: Offset(
          component.position.dx + 20,
          component.position.dy + 20,
        ),
      );
      duplicates.add(duplicate);
    }
    state = state.copyWith(
      components: [...state.components, ...duplicates],
      selectedComponentIds: duplicates.map((c) => c.id).toList(),
      hasUnsavedChanges: true,
    );
    _addToHistory();
  }

  void copyComponents() {
    if (state.selectedComponentIds.isEmpty) return;
    final copied =
        state.components
            .where((c) => state.selectedComponentIds.contains(c.id))
            .map((c) => c.copyWith())
            .toList();
    state = state.copyWith(clipboard: copied);
  }

  void pasteComponents() {
    if (state.clipboard.isEmpty) return;
    final pasted =
        state.clipboard
            .map(
              (c) => c.copyWith(
                id: _generateId(),
                position: Offset(c.position.dx + 20, c.position.dy + 20),
              ),
            )
            .toList();
    state = state.copyWith(
      components: [...state.components, ...pasted],
      selectedComponentIds: pasted.map((c) => c.id).toList(),
      hasUnsavedChanges: true,
    );
    _addToHistory();
  }

  // ========== SELECTION & GROUPING ==========

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

  void groupSelected() {
    if (state.selectedComponentIds.length <= 1) return;
    final groupId = _generateGroupId();
    final newComponents =
        state.components.map((c) {
          if (state.selectedComponentIds.contains(c.id)) {
            return c.copyWith(groupId: groupId);
          }
          return c;
        }).toList();
    final newGroups = Map<String, List<String>>.from(state.groups);
    newGroups[groupId] = List.from(state.selectedComponentIds);
    state = state.copyWith(
      components: newComponents,
      groups: newGroups,
      hasUnsavedChanges: true,
    );
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
    state = state.copyWith(
      components: newComponents,
      groups: newGroups,
      hasUnsavedChanges: true,
    );
    _addToHistory();
  }

  // ========== ALIGNMENT & DISTRIBUTION ==========

  void alignLeft() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final leftMost = selected.map((c) => c.position.dx).reduce(math.min);
    _alignComponents((c) => Offset(leftMost, c.position.dy));
  }

  void alignCenter() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final avg =
        selected
            .map((c) => c.position.dx + c.size.width / 2)
            .reduce((a, b) => a + b) /
        selected.length;
    _alignComponents((c) => Offset(avg - c.size.width / 2, c.position.dy));
  }

  void alignRight() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final rightMost = selected
        .map((c) => c.position.dx + c.size.width)
        .reduce(math.max);
    _alignComponents((c) => Offset(rightMost - c.size.width, c.position.dy));
  }

  void alignTop() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final topMost = selected.map((c) => c.position.dy).reduce(math.min);
    _alignComponents((c) => Offset(c.position.dx, topMost));
  }

  void alignBottom() {
    if (state.selectedComponentIds.length <= 1) return;
    final selected = state.selectedComponents;
    final bottomMost = selected
        .map((c) => c.position.dy + c.size.height)
        .reduce(math.max);
    _alignComponents((c) => Offset(c.position.dx, bottomMost - c.size.height));
  }

  void distributeHorizontally() {
    if (state.selectedComponentIds.length <= 2) return;
    final selected = List<DesignComponent>.from(state.selectedComponents)
      ..sort((a, b) => a.position.dx.compareTo(b.position.dx));
    final leftMost = selected.first.position.dx;
    final rightMost = selected.last.position.dx + selected.last.size.width;
    final totalWidth = selected
        .map((c) => c.size.width)
        .reduce((a, b) => a + b);
    final spacing = (rightMost - leftMost - totalWidth) / (selected.length - 1);
    var currentX = leftMost;
    final newComponents =
        state.components.map((c) {
          final index = selected.indexWhere((s) => s.id == c.id);
          if (index != -1) {
            final updated = c.copyWith(
              position: Offset(currentX, c.position.dy),
            );
            currentX += c.size.width + spacing;
            return updated;
          }
          return c;
        }).toList();
    state = state.copyWith(components: newComponents, hasUnsavedChanges: true);
    _addToHistory();
  }

  void distributeVertically() {
    if (state.selectedComponentIds.length <= 2) return;
    final selected = List<DesignComponent>.from(state.selectedComponents)
      ..sort((a, b) => a.position.dy.compareTo(b.position.dy));
    final topMost = selected.first.position.dy;
    final bottomMost = selected.last.position.dy + selected.last.size.height;
    final totalHeight = selected
        .map((c) => c.size.height)
        .reduce((a, b) => a + b);
    final spacing =
        (bottomMost - topMost - totalHeight) / (selected.length - 1);
    var currentY = topMost;
    final newComponents =
        state.components.map((c) {
          final index = selected.indexWhere((s) => s.id == c.id);
          if (index != -1) {
            final updated = c.copyWith(
              position: Offset(c.position.dx, currentY),
            );
            currentY += c.size.height + spacing;
            return updated;
          }
          return c;
        }).toList();
    state = state.copyWith(components: newComponents, hasUnsavedChanges: true);
    _addToHistory();
  }

  void _alignComponents(Offset Function(DesignComponent) getPosition) {
    final newComponents =
        state.components.map((c) {
          if (state.selectedComponentIds.contains(c.id)) {
            return c.copyWith(position: getPosition(c));
          }
          return c;
        }).toList();
    state = state.copyWith(components: newComponents, hasUnsavedChanges: true);
    _addToHistory();
  }

  // ========== Z-INDEX MANAGEMENT ==========

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

  // ========== HISTORY ==========

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      state = state.copyWith(
        components: List.from(_history[_historyIndex]),
        selectedComponentIds: [],
      );
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      state = state.copyWith(
        components: List.from(_history[_historyIndex]),
        selectedComponentIds: [],
      );
    }
  }

  bool canUndo() => _historyIndex > 0;
  bool canRedo() => _historyIndex < _history.length - 1;

  // ========== TOGGLE & VIEW OPERATIONS ==========

  void toggleGrid() => state = state.copyWith(showGrid: !state.showGrid);
  void toggleSnapToGrid() =>
      state = state.copyWith(snapToGrid: !state.snapToGrid);
  void toggleComponentTree() =>
      state = state.copyWith(showComponentTree: !state.showComponentTree);
  void togglePropertiesPanel() =>
      state = state.copyWith(showPropertiesPanel: !state.showPropertiesPanel);
  void toggleLayersPanel() =>
      state = state.copyWith(showLayersPanel: !state.showLayersPanel);
  void toggleCodePanel() =>
      state = state.copyWith(showCodePanel: !state.showCodePanel);
  void toggleAIAssist() =>
      state = state.copyWith(aiAssistEnabled: !state.aiAssistEnabled);
  void toggleDarkMode() {
    state = state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

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

  // ========== PROJECT MANAGEMENT ==========

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
    state = state.copyWith(hasUnsavedChanges: false);
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  void loadProject(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString);
      final loadedComponents =
          (jsonData['components'] as List)
              .map((c) => DesignComponent.fromJson(c))
              .toList();

      /////

      state = state.copyWith(
        components: loadedComponents,
        currentProjectName: jsonData['name'] ?? 'Loaded Project',
        selectedComponentIds: [],
        hasUnsavedChanges: false,
      );
      _history.clear();
      _historyIndex = -1;
      _addToHistory();
    } catch (e) {
      print('Error loading project: $e');
    }
  }

  void newProject() {
    state = const DesignerState(currentProjectName: 'New Project');
    _history.clear();
    _historyIndex = -1;
    _addToHistory();
  }

  // ========== AI FEATURES ==========

  Future<void> generateUIFromPrompt(String prompt) async {
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
      addComponent(ComponentType.card);
      addComponent(ComponentType.card);
    }
  }

  // ========== HELPER METHODS ==========

  Size _getDefaultSize(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return const Size(400, 300);
      case ComponentType.card:
        return const Size(280, 200);
      case ComponentType.productCard:
        return const Size(250, 350);
      case ComponentType.button:
        return const Size(120, 45);
      case ComponentType.text:
        return const Size(150, 40);
      case ComponentType.input:
        return const Size(250, 50);
      case ComponentType.image:
        return const Size(200, 200);
      case ComponentType.icon:
        return const Size(50, 50);
      case ComponentType.chip:
        return const Size(100, 32);
      case ComponentType.badge:
        return const Size(24, 24);
      case ComponentType.avatar:
        return const Size(48, 48);
      case ComponentType.imageCarousel:
        return const Size(400, 250);
      case ComponentType.chart:
        return const Size(400, 300);
      case ComponentType.dataTable:
        return const Size(600, 400);
      case ComponentType.glassmorphism:
        return const Size(300, 200);
      case ComponentType.neumorphism:
        return const Size(200, 200);
      case ComponentType.shimmer:
        return const Size(200, 100);
      case ComponentType.progressBar:
        return const Size(300, 8);
      case ComponentType.rating:
        return const Size(150, 30);
      default:
        return const Size(200, 150);
    }
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return {
          'title': 'Hero Section',
          'subtitle': 'Amazing tagline here',
          'ctaText': 'Get Started',
        };
      case ComponentType.text:
        return {'text': 'Text Component', 'editable': true};
      case ComponentType.button:
        return {'text': 'Button', 'variant': 'filled'};
      case ComponentType.productCard:
        return {
          'title': 'Product Name',
          'price': '\$99.99',
          'rating': 4.5,
          'imageUrl': '',
        };
      case ComponentType.rating:
        return {'value': 4.5, 'max': 5, 'allowHalf': true};
      case ComponentType.progressBar:
        return {'value': 0.7, 'showLabel': true};
      case ComponentType.chart:
        return {'type': 'bar', 'data': []};
      default:
        return {};
    }
  }

  ComponentStyle _getDefaultStyle(ComponentType type) {
    switch (type) {
      case ComponentType.hero:
        return ComponentStyle(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
        );
      case ComponentType.glassmorphism:
        return ComponentStyle(
          backgroundColor: Colors.white.withOpacity(0.1),
          borderRadius: 16.0,
          blur: 10.0,
          opacity: 0.7,
        );
      case ComponentType.neumorphism:
        return const ComponentStyle(
          backgroundColor: Color(0xFFE0E0E0),
          borderRadius: 20.0,
        );
      case ComponentType.button:
        return const ComponentStyle(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          borderRadius: 8.0,
          fontSize: 14.0,
        );
      case ComponentType.card:
        return const ComponentStyle(
          backgroundColor: Colors.white,
          borderRadius: 12.0,
        );
      default:
        return const ComponentStyle(
          backgroundColor: Colors.white,
          borderRadius: 8.0,
        );
    }
  }
}

// Main Provider
final designerProvider = StateNotifierProvider<DesignerNotifier, DesignerState>(
  (ref) => DesignerNotifier(ref),
);
