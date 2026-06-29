import 'package:flutter/material.dart';

import 'design_component.dart';
import 'enums.dart';

class DesignerState {
  final List<DesignComponent> components;
  final List<String> selectedComponentIds;
  final List<DesignComponent> clipboard;
  final Map<String, List<String>> groups;
  final bool showGrid;
  final bool snapToGrid;
  final double canvasZoom;

  final bool showComponentTree;
  final bool showAnimationPanel;
  final ResponsiveBreakpoint currentBreakpoint;
  final String selectedFramework;
  final String? currentProjectId;
  final ProjectStatus projectStatus;
  final CollaborationStatus collaborationStatus;
  final Map<String, dynamic> collaborators;
  final double gridSize;
  final ThemeMode themeMode;
  final bool showPropertiesPanel;
  final bool showLayersPanel;
  final bool showCodePanel;
  final LayoutMode layoutMode;
  final bool aiAssistEnabled;
  final String currentProjectName;

  final List<String> recentColors;
  final Map<String, dynamic> designTokens;
  final String? selectedTool;

  const DesignerState({
    this.components = const [],
    this.selectedComponentIds = const [],
    this.clipboard = const [],
    this.groups = const {},
    this.showGrid = true,
    this.snapToGrid = true,
    this.canvasZoom = 1.0,

    this.showComponentTree = false,
    this.showAnimationPanel = false,
    this.currentBreakpoint = ResponsiveBreakpoint.desktop,
    this.selectedFramework = 'Flutter',
    this.currentProjectId,
    this.projectStatus = ProjectStatus.idle,
    this.collaborationStatus = CollaborationStatus.disconnected,
    this.collaborators = const {},

    this.gridSize = 20.0,

    this.themeMode = ThemeMode.light,

    this.showPropertiesPanel = true,
    this.showLayersPanel = false,
    this.showCodePanel = false,

    this.layoutMode = LayoutMode.freeform,
    this.aiAssistEnabled = false,

    this.currentProjectName = 'Untitled Project',

    this.recentColors = const [],
    this.designTokens = const {},
    this.selectedTool,
  });

  DesignerState copyWith({
    List<DesignComponent>? components,
    List<String>? selectedComponentIds,
    List<DesignComponent>? clipboard,
    Map<String, List<String>>? groups,
    bool? showGrid,
    bool? snapToGrid,
    double? canvasZoom,

    bool? showComponentTree,
    bool? showAnimationPanel,
    ResponsiveBreakpoint? currentBreakpoint,
    String? selectedFramework,
    String? currentProjectId,
    ProjectStatus? projectStatus,
    CollaborationStatus? collaborationStatus,
    Map<String, dynamic>? collaborators,

    double? gridSize,

    ThemeMode? themeMode,

    bool? showPropertiesPanel,
    bool? showLayersPanel,
    bool? showCodePanel,

    LayoutMode? layoutMode,
    bool? aiAssistEnabled,
    String? currentProjectName,

    List<String>? recentColors,
    Map<String, dynamic>? designTokens,
    String? selectedTool,
  }) {
    return DesignerState(
      components: components ?? this.components,
      selectedComponentIds: selectedComponentIds ?? this.selectedComponentIds,
      clipboard: clipboard ?? this.clipboard,
      groups: groups ?? this.groups,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      canvasZoom: canvasZoom ?? this.canvasZoom,

      showComponentTree: showComponentTree ?? this.showComponentTree,
      showAnimationPanel: showAnimationPanel ?? this.showAnimationPanel,
      currentBreakpoint: currentBreakpoint ?? this.currentBreakpoint,
      selectedFramework: selectedFramework ?? this.selectedFramework,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      projectStatus: projectStatus ?? this.projectStatus,
      collaborationStatus: collaborationStatus ?? this.collaborationStatus,
      collaborators: collaborators ?? this.collaborators,

      gridSize: gridSize ?? this.gridSize,

      themeMode: themeMode ?? this.themeMode,

      showPropertiesPanel: showPropertiesPanel ?? this.showPropertiesPanel,
      showLayersPanel: showLayersPanel ?? this.showLayersPanel,
      showCodePanel: showCodePanel ?? this.showCodePanel,

      layoutMode: layoutMode ?? this.layoutMode,
      aiAssistEnabled: aiAssistEnabled ?? this.aiAssistEnabled,

      currentProjectName: currentProjectName ?? this.currentProjectName,

      recentColors: recentColors ?? this.recentColors,
      designTokens: designTokens ?? this.designTokens,
      selectedTool: selectedTool ?? this.selectedTool,
    );
  }

  List<DesignComponent> get selectedComponents {
    return components
        .where((c) => selectedComponentIds.contains(c.id))
        .toList();
  }

  DesignComponent? get selectedComponent {
    return selectedComponents.isNotEmpty ? selectedComponents.first : null;
  }

  bool get hasUnsavedChanges =>
      projectStatus == ProjectStatus.idle && currentProjectId != null;

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
