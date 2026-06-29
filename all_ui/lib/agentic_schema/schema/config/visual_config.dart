import '../workflow/workflow_node.dart';
import 'canvas_config.dart';
import '../node/custom_node_type.dart';
import '../palette/palette_config.dart';

class VisualConfig {
  final String? theme;
  final int? gridSize;
  final bool? snapToGrid;
  final bool? showGrid;
  final List<NodeCategory>? nodeCategories;
  final List<CustomNodeType>? customNodeTypes;
  final PaletteConfig? palette;
  final CanvasConfig? canvas;

  VisualConfig({
    this.theme = 'light',
    this.gridSize = 20,
    this.snapToGrid = true,
    this.showGrid = true,
    this.nodeCategories,
    this.customNodeTypes,
    this.palette,
    this.canvas,
  });

  factory VisualConfig.fromJson(Map<String, dynamic> json) {
    return VisualConfig(
      theme: json['theme'] as String?,
      gridSize: json['gridSize'] as int?,
      snapToGrid: json['snapToGrid'] as bool?,
      showGrid: json['showGrid'] as bool?,
      nodeCategories: json['nodeCategories'] != null
          ? (json['nodeCategories'] as List)
                .map((e) => _parseNodeCategory(e))
                .toList()
          : null,
      customNodeTypes: json['customNodeTypes'] != null
          ? (json['customNodeTypes'] as List)
                .map((e) => CustomNodeType.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      palette: json['palette'] != null
          ? PaletteConfig.fromJson(json['palette'] as Map<String, dynamic>)
          : null,
      canvas: json['canvas'] != null
          ? CanvasConfig.fromJson(json['canvas'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (theme != null) 'theme': theme,
      if (gridSize != null) 'gridSize': gridSize,
      if (snapToGrid != null) 'snapToGrid': snapToGrid,
      if (showGrid != null) 'showGrid': showGrid,
      if (nodeCategories != null)
        'nodeCategories': nodeCategories!.map((e) => e.name).toList(),
      if (customNodeTypes != null)
        'customNodeTypes': customNodeTypes!.map((e) => e.toJson()).toList(),
      if (palette != null) 'palette': palette!.toJson(),
      if (canvas != null) 'canvas': canvas!.toJson(),
    };
  }

  static NodeCategory _parseNodeCategory(dynamic value) {
    if (value is NodeCategory) return value;
    final stringValue = value.toString();
    return NodeCategory.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => NodeCategory.logic,
    );
  }
}
