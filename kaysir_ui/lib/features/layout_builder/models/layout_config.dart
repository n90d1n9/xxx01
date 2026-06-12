import 'dart:ui';

enum LayoutMechanism { freeform, grid, tabularColumns, autoGrid }

extension LayoutMechanismX on LayoutMechanism {
  String get key {
    switch (this) {
      case LayoutMechanism.freeform:
        return 'freeform';
      case LayoutMechanism.grid:
        return 'grid';
      case LayoutMechanism.tabularColumns:
        return 'tabular_columns';
      case LayoutMechanism.autoGrid:
        return 'auto_grid';
    }
  }

  String get label {
    switch (this) {
      case LayoutMechanism.freeform:
        return 'Freeform';
      case LayoutMechanism.grid:
        return 'Grid';
      case LayoutMechanism.tabularColumns:
        return 'Tabular Columns';
      case LayoutMechanism.autoGrid:
        return 'Auto Grid';
    }
  }

  static LayoutMechanism fromKey(String? key) {
    return LayoutMechanism.values.firstWhere(
      (mechanism) => mechanism.key == key || mechanism.name == key,
      orElse: () => LayoutMechanism.grid,
    );
  }
}

class LayoutConfig {
  static const defaultCanvasWidth = 1200.0;
  static const defaultCanvasHeight = 760.0;
  static const minCanvasWidth = 320.0;
  static const minCanvasHeight = 320.0;

  final double gridSize;
  final double canvasWidth;
  final double canvasHeight;
  final double minComponentWidth;
  final double minComponentHeight;
  final bool snapToGrid;
  final bool showGrid;
  final LayoutMechanism layoutMechanism;
  final int tabularColumnCount;
  final double tabularColumnGap;
  final double tabularRowHeight;
  final int autoGridColumnCount;
  final double autoGridGap;
  final double autoGridRowHeight;

  const LayoutConfig({
    this.gridSize = 20.0,
    this.canvasWidth = defaultCanvasWidth,
    this.canvasHeight = defaultCanvasHeight,
    this.minComponentWidth = 100.0,
    this.minComponentHeight = 80.0,
    this.snapToGrid = true,
    this.showGrid = true,
    this.layoutMechanism = LayoutMechanism.grid,
    this.tabularColumnCount = 12,
    this.tabularColumnGap = 12,
    this.tabularRowHeight = 64,
    this.autoGridColumnCount = 4,
    this.autoGridGap = 16,
    this.autoGridRowHeight = 140,
  });

  Size get canvasSize => Size(canvasWidth, canvasHeight);

  double get tabularColumnWidth {
    final safeColumns = tabularColumnCount.clamp(1, 48);
    final totalGap = (safeColumns - 1) * tabularColumnGap;
    return ((canvasWidth - totalGap) / safeColumns).clamp(1.0, double.infinity);
  }

  double get autoGridColumnWidth {
    final safeColumns = autoGridColumnCount.clamp(1, 24);
    final totalGap = (safeColumns - 1) * autoGridGap;
    return ((canvasWidth - totalGap) / safeColumns).clamp(1.0, double.infinity);
  }

  static Size normalizeCanvasSize(Size size) {
    return Size(
      size.width.clamp(minCanvasWidth, double.infinity).toDouble(),
      size.height.clamp(minCanvasHeight, double.infinity).toDouble(),
    );
  }

  LayoutConfig copyWith({
    double? gridSize,
    double? canvasWidth,
    double? canvasHeight,
    Size? canvasSize,
    double? minComponentWidth,
    double? minComponentHeight,
    bool? snapToGrid,
    bool? showGrid,
    LayoutMechanism? layoutMechanism,
    int? tabularColumnCount,
    double? tabularColumnGap,
    double? tabularRowHeight,
    int? autoGridColumnCount,
    double? autoGridGap,
    double? autoGridRowHeight,
  }) {
    return LayoutConfig(
      gridSize: gridSize ?? this.gridSize,
      canvasWidth:
          canvasSize?.width.clamp(minCanvasWidth, double.infinity).toDouble() ??
          canvasWidth?.clamp(minCanvasWidth, double.infinity).toDouble() ??
          this.canvasWidth,
      canvasHeight:
          canvasSize?.height
              .clamp(minCanvasHeight, double.infinity)
              .toDouble() ??
          canvasHeight?.clamp(minCanvasHeight, double.infinity).toDouble() ??
          this.canvasHeight,
      minComponentWidth: minComponentWidth ?? this.minComponentWidth,
      minComponentHeight: minComponentHeight ?? this.minComponentHeight,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      showGrid: showGrid ?? this.showGrid,
      layoutMechanism: layoutMechanism ?? this.layoutMechanism,
      tabularColumnCount:
          tabularColumnCount?.clamp(1, 48).toInt() ?? this.tabularColumnCount,
      tabularColumnGap:
          tabularColumnGap?.clamp(0.0, double.infinity).toDouble() ??
          this.tabularColumnGap,
      tabularRowHeight:
          tabularRowHeight?.clamp(1.0, double.infinity).toDouble() ??
          this.tabularRowHeight,
      autoGridColumnCount:
          autoGridColumnCount?.clamp(1, 24).toInt() ?? this.autoGridColumnCount,
      autoGridGap:
          autoGridGap?.clamp(0.0, double.infinity).toDouble() ??
          this.autoGridGap,
      autoGridRowHeight:
          autoGridRowHeight?.clamp(24.0, double.infinity).toDouble() ??
          this.autoGridRowHeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gridSize': gridSize,
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
      'minComponentWidth': minComponentWidth,
      'minComponentHeight': minComponentHeight,
      'snapToGrid': snapToGrid,
      'showGrid': showGrid,
      'layoutMechanism': layoutMechanism.key,
      'tabularColumnCount': tabularColumnCount,
      'tabularColumnGap': tabularColumnGap,
      'tabularRowHeight': tabularRowHeight,
      'autoGridColumnCount': autoGridColumnCount,
      'autoGridGap': autoGridGap,
      'autoGridRowHeight': autoGridRowHeight,
    };
  }

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    double readDouble(String key, double fallback) {
      final value = json[key];
      return switch (value) {
        num() => value.toDouble(),
        String() => double.tryParse(value) ?? fallback,
        _ => fallback,
      };
    }

    return LayoutConfig(
      gridSize: readDouble('gridSize', 20.0),
      canvasWidth:
          readDouble(
            'canvasWidth',
            defaultCanvasWidth,
          ).clamp(minCanvasWidth, double.infinity).toDouble(),
      canvasHeight:
          readDouble(
            'canvasHeight',
            defaultCanvasHeight,
          ).clamp(minCanvasHeight, double.infinity).toDouble(),
      minComponentWidth: readDouble('minComponentWidth', 100.0),
      minComponentHeight: readDouble('minComponentHeight', 80.0),
      snapToGrid: json['snapToGrid'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      layoutMechanism: LayoutMechanismX.fromKey(
        json['layoutMechanism'] as String?,
      ),
      tabularColumnCount:
          (json['tabularColumnCount'] as num?)?.toInt().clamp(1, 48) ?? 12,
      tabularColumnGap: readDouble('tabularColumnGap', 12.0),
      tabularRowHeight: readDouble('tabularRowHeight', 64.0),
      autoGridColumnCount:
          (json['autoGridColumnCount'] as num?)?.toInt().clamp(1, 24) ?? 4,
      autoGridGap: readDouble('autoGridGap', 16.0),
      autoGridRowHeight: readDouble('autoGridRowHeight', 140.0),
    );
  }
}

class LayoutCanvasSizePreset {
  final String id;
  final String label;
  final Size size;

  const LayoutCanvasSizePreset({
    required this.id,
    required this.label,
    required this.size,
  });

  String get dimensionLabel => '${size.width.round()} x ${size.height.round()}';
}

const layoutCanvasSizePresets = <LayoutCanvasSizePreset>[
  LayoutCanvasSizePreset(
    id: 'default',
    label: 'Default',
    size: Size(
      LayoutConfig.defaultCanvasWidth,
      LayoutConfig.defaultCanvasHeight,
    ),
  ),
  LayoutCanvasSizePreset(
    id: 'desktop',
    label: 'Desktop',
    size: Size(1440, 900),
  ),
  LayoutCanvasSizePreset(
    id: 'full-hd',
    label: 'Full HD',
    size: Size(1920, 1080),
  ),
  LayoutCanvasSizePreset(id: 'tablet', label: 'Tablet', size: Size(1024, 768)),
  LayoutCanvasSizePreset(id: 'mobile', label: 'Mobile', size: Size(390, 844)),
];
