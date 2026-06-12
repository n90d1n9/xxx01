import 'collaboration_state.dart';
import 'collaborator_state.dart';
import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';
import 'layout_version.dart';
import 'template_data.dart';

const Object _unset = Object();
const int _layoutExportSchemaVersion = 1;

class LayoutImportPreview {
  final bool isPackage;
  final String? schema;
  final int? schemaVersion;
  final DateTime? exportedAt;
  final String id;
  final String name;
  final LayoutMechanism layoutMechanism;
  final double canvasWidth;
  final double canvasHeight;
  final int componentCount;
  final int visibleCount;
  final int lockedCount;
  final int responsiveOverrideCount;
  final int constrainedCount;

  const LayoutImportPreview({
    required this.isPackage,
    required this.schema,
    required this.schemaVersion,
    required this.exportedAt,
    required this.id,
    required this.name,
    required this.layoutMechanism,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.componentCount,
    required this.visibleCount,
    required this.lockedCount,
    required this.responsiveOverrideCount,
    required this.constrainedCount,
  });

  String get formatLabel => isPackage ? 'Export package' : 'Raw layout';

  String get canvasLabel => '${canvasWidth.round()} x ${canvasHeight.round()}';

  String get componentLabel =>
      componentCount == 1 ? '1 component' : '$componentCount components';

  factory LayoutImportPreview.fromJson(Map<String, dynamic> json) {
    final imported = LayoutState.fromJson(json);
    final isPackage = json['layout'] is Map;
    final schemaVersion = json['schemaVersion'];
    final exportedAtValue = json['exportedAt'];
    final visibleCount =
        imported.components.where((component) => component.isVisible).length;
    final lockedCount =
        imported.components.where((component) => component.isLocked).length;
    final responsiveOverrideCount = imported.components.fold<int>(
      0,
      (count, component) => count + component.responsiveProperties.length,
    );
    final constrainedCount =
        imported.components
            .where((component) => component.constraints.hasCustomRules)
            .length;

    return LayoutImportPreview(
      isPackage: isPackage,
      schema: json['schema'] as String?,
      schemaVersion: schemaVersion is num ? schemaVersion.toInt() : null,
      exportedAt:
          exportedAtValue is String ? DateTime.tryParse(exportedAtValue) : null,
      id: imported.id,
      name: imported.name,
      layoutMechanism: imported.config.layoutMechanism,
      canvasWidth: imported.config.canvasWidth,
      canvasHeight: imported.config.canvasHeight,
      componentCount: imported.components.length,
      visibleCount: visibleCount,
      lockedCount: lockedCount,
      responsiveOverrideCount: responsiveOverrideCount,
      constrainedCount: constrainedCount,
    );
  }
}

class LayoutState {
  final List<ComponentData> components;
  final GridSettings gridSettings;
  final String? activeTemplate;
  final Map<String, TemplateData> savedTemplates;
  final String id;
  final String name;
  final List<LayoutVersion> versions;
  final int currentVersionIndex;
  final CollaborationState? collaborationState;
  final LayoutConfig config;
  final String? selectedComponentId;
  final Set<String> selectedComponentIds;
  final bool isEditMode;
  final int gridColumns;
  final int gridRows;
  final bool isGridVisible;
  final double gridOpacity;
  final Map<String, CollaboratorState> collaborators;
  final List<ComponentData> clipboard;
  final Map<String, bool>? visibilitySnapshot;

  const LayoutState({
    this.components = const [],
    this.versions = const [],
    required this.id,
    required this.name,
    required this.gridSettings,
    this.currentVersionIndex = 0,
    this.collaborationState,
    this.activeTemplate,
    this.savedTemplates = const {},
    this.config = const LayoutConfig(),
    this.selectedComponentId,
    this.selectedComponentIds = const <String>{},
    this.isEditMode = true,
    this.gridColumns = 12,
    this.gridRows = 12,
    this.isGridVisible = true,
    this.gridOpacity = 0.3,
    this.collaborators = const {},
    this.clipboard = const [],
    this.visibilitySnapshot,
  });

  factory LayoutState.initial() {
    const gridSettings = GridSettings();
    const config = LayoutConfig();
    final initialVersion = LayoutVersion.create(
      const [],
      gridSettings: gridSettings,
      config: config,
      name: 'Initial',
    );

    return LayoutState(
      id: 'layout-default',
      name: 'New Layout',
      gridSettings: gridSettings,
      versions: [initialVersion],
      gridColumns: 12,
      gridRows: 12,
      isGridVisible: gridSettings.enabled,
      gridOpacity: gridSettings.opacity,
    );
  }

  ComponentData? get selectedComponent {
    final selectedId =
        selectedComponentId ??
        (selectedComponentIds.isEmpty ? null : selectedComponentIds.first);
    if (selectedId == null) return null;

    for (final component in components) {
      if (component.id == selectedId) return component;
    }

    return null;
  }

  List<ComponentData> get selectedComponents {
    final selectedIds =
        selectedComponentIds.isEmpty && selectedComponentId != null
            ? <String>{selectedComponentId!}
            : selectedComponentIds;

    if (selectedIds.isEmpty) return const [];

    return [
      for (final component in components)
        if (selectedIds.contains(component.id)) component,
    ];
  }

  bool get hasSelection => selectedComponents.isNotEmpty;

  bool get hasMultiSelection => selectedComponents.length > 1;

  bool get canUndo => currentVersionIndex > 0;

  bool get canRedo => currentVersionIndex < versions.length - 1;

  LayoutVersion? get currentVersion {
    if (versions.isEmpty) return null;
    final index = currentVersionIndex.clamp(0, versions.length - 1);
    return versions[index];
  }

  Map<String, ComponentData> get componentsById {
    return {for (final component in components) component.id: component};
  }

  LayoutState addComponent(ComponentData component) {
    return copyWith(
      components: [...components, component],
      selectedComponentId: component.id,
      selectedComponentIds: {component.id},
    );
  }

  LayoutState copyWith({
    List<ComponentData>? components,
    GridSettings? gridSettings,
    String? activeTemplate,
    Map<String, TemplateData>? savedTemplates,
    LayoutConfig? config,
    Object? selectedComponentId = _unset,
    Object? selectedComponentIds = _unset,
    bool? isEditMode,
    String? id,
    String? name,
    int? currentVersionIndex,
    int? gridColumns,
    int? gridRows,
    bool? isGridVisible,
    double? gridOpacity,
    List<LayoutVersion>? versions,
    Map<String, CollaboratorState>? collaborators,
    CollaborationState? collaborationState,
    Object? clipboard = _unset,
    Object? visibilitySnapshot = _unset,
  }) {
    final nextGridSettings = gridSettings ?? this.gridSettings;
    final nextSelectedComponentId =
        identical(selectedComponentId, _unset)
            ? this.selectedComponentId
            : selectedComponentId as String?;
    final nextSelectedComponentIds =
        identical(selectedComponentIds, _unset)
            ? identical(selectedComponentId, _unset)
                ? this.selectedComponentIds
                : nextSelectedComponentId == null
                ? const <String>{}
                : <String>{nextSelectedComponentId}
            : Set<String>.unmodifiable(selectedComponentIds as Set<String>);

    return LayoutState(
      id: id ?? this.id,
      name: name ?? this.name,
      versions: versions ?? this.versions,
      currentVersionIndex: currentVersionIndex ?? this.currentVersionIndex,
      collaborationState: collaborationState ?? this.collaborationState,
      components: components ?? this.components,
      gridSettings: nextGridSettings,
      activeTemplate: activeTemplate ?? this.activeTemplate,
      savedTemplates: savedTemplates ?? this.savedTemplates,
      config: config ?? this.config,
      selectedComponentId: nextSelectedComponentId,
      selectedComponentIds: nextSelectedComponentIds,
      isEditMode: isEditMode ?? this.isEditMode,
      gridColumns: gridColumns ?? this.gridColumns,
      gridRows: gridRows ?? this.gridRows,
      isGridVisible: isGridVisible ?? nextGridSettings.enabled,
      gridOpacity: gridOpacity ?? nextGridSettings.opacity,
      collaborators: collaborators ?? this.collaborators,
      clipboard:
          identical(clipboard, _unset)
              ? this.clipboard
              : List<ComponentData>.unmodifiable(
                clipboard as List<ComponentData>,
              ),
      visibilitySnapshot:
          identical(visibilitySnapshot, _unset)
              ? this.visibilitySnapshot
              : visibilitySnapshot == null
              ? null
              : Map<String, bool>.unmodifiable(
                visibilitySnapshot as Map<String, bool>,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'components': components.map((component) => component.toJson()).toList(),
      'gridSettings': gridSettings.toJson(),
      'config': config.toJson(),
      'selectedComponentId': selectedComponentId,
      'selectedComponentIds': selectedComponentIds.toList(),
      'gridColumns': gridColumns,
      'gridRows': gridRows,
    };
  }

  Map<String, dynamic> toExportPackage({DateTime? exportedAt}) {
    final timestamp = exportedAt ?? DateTime.now().toUtc();
    final visibleCount =
        components.where((component) => component.isVisible).length;
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final responsiveOverrideCount = components.fold<int>(
      0,
      (count, component) => count + component.responsiveProperties.length,
    );
    final responsiveComponentCount =
        components
            .where((component) => component.responsiveProperties.isNotEmpty)
            .length;
    final constrainedCount =
        components
            .where((component) => component.constraints.hasCustomRules)
            .length;
    final boundComponentCount =
        components.where(_componentHasDataBinding).length;
    final eventComponentCount =
        components
            .where((component) => component.properties.events.isNotEmpty)
            .length;

    return {
      'schema': 'kaysir.layout.export',
      'schemaVersion': _layoutExportSchemaVersion,
      'exportedAt': timestamp.toIso8601String(),
      'summary': {
        'layoutId': id,
        'name': name,
        'layoutMechanism': config.layoutMechanism.key,
        'canvas': {'width': config.canvasWidth, 'height': config.canvasHeight},
        'components': {
          'total': components.length,
          'visible': visibleCount,
          'hidden': components.length - visibleCount,
          'locked': lockedCount,
          'unlocked': components.length - lockedCount,
          'withResponsiveOverrides': responsiveComponentCount,
          'responsiveOverrides': responsiveOverrideCount,
          'withConstraints': constrainedCount,
          'withDataBindings': boundComponentCount,
          'withEvents': eventComponentCount,
        },
        'layoutRules': _layoutRuleSummary(),
      },
      'layout': toJson(),
    };
  }

  factory LayoutState.fromJson(Map<String, dynamic> json) {
    final layoutJson = _layoutJsonFromImport(json);
    final gridSettings = GridSettings.fromJson(
      Map<String, dynamic>.from(layoutJson['gridSettings'] as Map? ?? const {}),
    );
    final config = LayoutConfig.fromJson(
      Map<String, dynamic>.from(layoutJson['config'] as Map? ?? const {}),
    ).copyWith(
      gridSize: gridSettings.gridSize,
      snapToGrid: gridSettings.snapToGrid,
      showGrid: gridSettings.enabled,
    );
    final components =
        (layoutJson['components'] as List? ?? const [])
            .map(
              (item) => ComponentData.fromJson(
                Map<String, dynamic>.from(item as Map? ?? const {}),
              ),
            )
            .toList();

    final selectedComponentId = layoutJson['selectedComponentId'] as String?;
    final selectedComponentIds =
        (layoutJson['selectedComponentIds'] as List?)
            ?.map((item) => '$item')
            .toSet() ??
        <String>{};
    if (selectedComponentId != null) {
      selectedComponentIds.add(selectedComponentId);
    }

    return LayoutState(
      id: layoutJson['id'] as String? ?? 'layout-imported',
      name: layoutJson['name'] as String? ?? 'Imported Layout',
      components: components,
      gridSettings: gridSettings,
      config: config,
      selectedComponentId: selectedComponentId,
      selectedComponentIds: selectedComponentIds,
      gridColumns: layoutJson['gridColumns'] as int? ?? 12,
      gridRows: layoutJson['gridRows'] as int? ?? 12,
      isGridVisible: gridSettings.enabled,
      gridOpacity: gridSettings.opacity,
      versions: [
        LayoutVersion.create(
          components,
          gridSettings: gridSettings,
          config: config,
          name: 'Imported',
        ),
      ],
    );
  }

  Map<String, dynamic> _layoutRuleSummary() {
    return switch (config.layoutMechanism) {
      LayoutMechanism.freeform => {'mechanism': config.layoutMechanism.key},
      LayoutMechanism.grid => {
        'mechanism': config.layoutMechanism.key,
        'gridSize': gridSettings.gridSize,
        'snapToGrid': gridSettings.snapToGrid,
      },
      LayoutMechanism.tabularColumns => {
        'mechanism': config.layoutMechanism.key,
        'columns': config.tabularColumnCount,
        'columnGap': config.tabularColumnGap,
        'rowHeight': config.tabularRowHeight,
      },
      LayoutMechanism.autoGrid => {
        'mechanism': config.layoutMechanism.key,
        'columns': config.autoGridColumnCount,
        'gap': config.autoGridGap,
        'rowHeight': config.autoGridRowHeight,
      },
    };
  }

  static Map<String, dynamic> _layoutJsonFromImport(Map<String, dynamic> json) {
    final layout = json['layout'];
    if (layout is Map) {
      return Map<String, dynamic>.from(layout);
    }

    return json;
  }

  static bool _componentHasDataBinding(ComponentData component) {
    bool containsBinding(Object? value) {
      if (value is String) return value.contains('{{') && value.contains('}}');
      if (value is Map) return value.values.any(containsBinding);
      if (value is Iterable) return value.any(containsBinding);
      return false;
    }

    return containsBinding(component.properties.attributes);
  }
}
