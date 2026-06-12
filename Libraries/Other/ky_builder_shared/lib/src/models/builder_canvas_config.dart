import 'dart:math' as math;
import 'dart:ui';

import 'builder_layout_mechanism.dart';

class BuilderCanvasConfig {
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
  final BuilderLayoutMechanism layoutMechanism;
  final int tabularColumnCount;
  final double tabularColumnGap;
  final double tabularRowHeight;
  final int autoGridColumnCount;
  final double autoGridGap;
  final double autoGridRowHeight;

  const BuilderCanvasConfig({
    this.gridSize = 20.0,
    this.canvasWidth = defaultCanvasWidth,
    this.canvasHeight = defaultCanvasHeight,
    this.minComponentWidth = 100.0,
    this.minComponentHeight = 80.0,
    this.snapToGrid = true,
    this.showGrid = true,
    this.layoutMechanism = BuilderLayoutMechanism.grid,
    this.tabularColumnCount = 12,
    this.tabularColumnGap = 12.0,
    this.tabularRowHeight = 64.0,
    this.autoGridColumnCount = 4,
    this.autoGridGap = 16.0,
    this.autoGridRowHeight = 140.0,
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

  BuilderCanvasConfig copyWith({
    double? gridSize,
    double? canvasWidth,
    double? canvasHeight,
    Size? canvasSize,
    double? minComponentWidth,
    double? minComponentHeight,
    bool? snapToGrid,
    bool? showGrid,
    BuilderLayoutMechanism? layoutMechanism,
    int? tabularColumnCount,
    double? tabularColumnGap,
    double? tabularRowHeight,
    int? autoGridColumnCount,
    double? autoGridGap,
    double? autoGridRowHeight,
  }) {
    return BuilderCanvasConfig(
      gridSize: _positiveDouble(gridSize, this.gridSize),
      canvasWidth: _normalizeWidth(
        canvasSize?.width ?? canvasWidth ?? this.canvasWidth,
      ),
      canvasHeight: _normalizeHeight(
        canvasSize?.height ?? canvasHeight ?? this.canvasHeight,
      ),
      minComponentWidth: _positiveDouble(
        minComponentWidth,
        this.minComponentWidth,
      ),
      minComponentHeight: _positiveDouble(
        minComponentHeight,
        this.minComponentHeight,
      ),
      snapToGrid: snapToGrid ?? this.snapToGrid,
      showGrid: showGrid ?? this.showGrid,
      layoutMechanism: layoutMechanism ?? this.layoutMechanism,
      tabularColumnCount:
          tabularColumnCount?.clamp(1, 48).toInt() ?? this.tabularColumnCount,
      tabularColumnGap: _nonNegativeDouble(
        tabularColumnGap,
        this.tabularColumnGap,
      ),
      tabularRowHeight: _positiveDouble(
        tabularRowHeight,
        this.tabularRowHeight,
      ),
      autoGridColumnCount:
          autoGridColumnCount?.clamp(1, 24).toInt() ?? this.autoGridColumnCount,
      autoGridGap: _nonNegativeDouble(autoGridGap, this.autoGridGap),
      autoGridRowHeight: _positiveDouble(
        autoGridRowHeight,
        this.autoGridRowHeight,
      ),
    );
  }

  Offset snapOffset(Offset offset) {
    final constrained = constrainOffset(offset);
    if (!snapToGrid) return constrained;

    return switch (layoutMechanism) {
      BuilderLayoutMechanism.tabularColumns => _snapToTabular(constrained),
      BuilderLayoutMechanism.autoGrid => _snapToAutoGrid(constrained),
      _ => _snapToRegularGrid(constrained),
    };
  }

  Size snapSize(Size size) {
    final constrained = constrainSize(size);
    if (!snapToGrid) return constrained;

    return switch (layoutMechanism) {
      BuilderLayoutMechanism.tabularColumns => _snapSizeToTabular(constrained),
      BuilderLayoutMechanism.autoGrid => _snapSizeToAutoGrid(constrained),
      _ => _snapSizeToRegularGrid(constrained),
    };
  }

  Offset constrainOffset(Offset offset) {
    final maxX = math.max(0.0, canvasWidth - minComponentWidth);
    final maxY = math.max(0.0, canvasHeight - minComponentHeight);
    return Offset(offset.dx.clamp(0.0, maxX), offset.dy.clamp(0.0, maxY));
  }

  Size constrainSize(Size size) {
    return Size(
      size.width.clamp(minComponentWidth, canvasWidth),
      size.height.clamp(minComponentHeight, canvasHeight),
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

  factory BuilderCanvasConfig.fromJson(Map<String, dynamic> json) {
    return BuilderCanvasConfig(
      gridSize: _readDouble(json, 'gridSize', 20.0),
      canvasWidth: _normalizeWidth(
        _readDouble(json, 'canvasWidth', defaultCanvasWidth),
      ),
      canvasHeight: _normalizeHeight(
        _readDouble(json, 'canvasHeight', defaultCanvasHeight),
      ),
      minComponentWidth: _readDouble(json, 'minComponentWidth', 100.0),
      minComponentHeight: _readDouble(json, 'minComponentHeight', 80.0),
      snapToGrid: _readBool(json, 'snapToGrid', true),
      showGrid: _readBool(json, 'showGrid', true),
      layoutMechanism: BuilderLayoutMechanism.fromKey(
        json['layoutMechanism'] as String?,
      ),
      tabularColumnCount:
          (json['tabularColumnCount'] as num?)?.toInt().clamp(1, 48) ?? 12,
      tabularColumnGap: _readDouble(json, 'tabularColumnGap', 12.0),
      tabularRowHeight: _readDouble(json, 'tabularRowHeight', 64.0),
      autoGridColumnCount:
          (json['autoGridColumnCount'] as num?)?.toInt().clamp(1, 24) ?? 4,
      autoGridGap: _readDouble(json, 'autoGridGap', 16.0),
      autoGridRowHeight: _readDouble(json, 'autoGridRowHeight', 140.0),
    );
  }

  Offset _snapToRegularGrid(Offset offset) {
    final cellSize = math.max(1.0, gridSize);
    return Offset(
      (offset.dx / cellSize).round() * cellSize,
      (offset.dy / cellSize).round() * cellSize,
    );
  }

  Offset _snapToTabular(Offset offset) {
    final stride = tabularColumnWidth + tabularColumnGap;
    return Offset(
      (offset.dx / stride).round() * stride,
      (offset.dy / tabularRowHeight).round() * tabularRowHeight,
    );
  }

  Offset _snapToAutoGrid(Offset offset) {
    final stride = autoGridColumnWidth + autoGridGap;
    return Offset(
      (offset.dx / stride).round() * stride,
      (offset.dy / autoGridRowHeight).round() * autoGridRowHeight,
    );
  }

  Size _snapSizeToRegularGrid(Size size) {
    final cellSize = math.max(1.0, gridSize);
    return constrainSize(
      Size(
        (size.width / cellSize).round() * cellSize,
        (size.height / cellSize).round() * cellSize,
      ),
    );
  }

  Size _snapSizeToTabular(Size size) {
    final stride = tabularColumnWidth + tabularColumnGap;
    final columns = math.max(1, (size.width / stride).round());
    return constrainSize(
      Size(
        (columns * tabularColumnWidth) + ((columns - 1) * tabularColumnGap),
        (size.height / tabularRowHeight).round() * tabularRowHeight,
      ),
    );
  }

  Size _snapSizeToAutoGrid(Size size) {
    final stride = autoGridColumnWidth + autoGridGap;
    final columns = math.max(1, (size.width / stride).round());
    return constrainSize(
      Size(
        (columns * autoGridColumnWidth) + ((columns - 1) * autoGridGap),
        (size.height / autoGridRowHeight).round() * autoGridRowHeight,
      ),
    );
  }

  static double _readDouble(
    Map<String, dynamic> json,
    String key,
    double fallback,
  ) {
    final value = json[key];
    return switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  static bool _readBool(Map<String, dynamic> json, String key, bool fallback) {
    final value = json[key];
    return switch (value) {
      bool() => value,
      String() => value.toLowerCase() == 'true',
      _ => fallback,
    };
  }

  static double _positiveDouble(double? value, double fallback) {
    if (value == null || value <= 0 || !value.isFinite) return fallback;
    return value;
  }

  static double _nonNegativeDouble(double? value, double fallback) {
    if (value == null || value < 0 || !value.isFinite) return fallback;
    return value;
  }

  static double _normalizeWidth(double width) {
    return width.clamp(minCanvasWidth, double.infinity).toDouble();
  }

  static double _normalizeHeight(double height) {
    return height.clamp(minCanvasHeight, double.infinity).toDouble();
  }
}
