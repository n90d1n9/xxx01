import 'dart:math' as math;
import 'dart:ui';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_rule_geometry.dart';
import '../provider/layout_state_provider.dart';

/// Calculates grid and rule-based geometry for layout builder inspectors.
class LayoutRuleGeometryService {
  const LayoutRuleGeometryService();

  LayoutRuleGridGeometryMetrics gridGeometryFor(
    ComponentData component,
    LayoutConfig config,
    double gridSize,
  ) {
    final trackSize = gridTrackSize(gridSize);
    final columnCount = gridColumnCountFor(config, gridSize);
    final rowCount = gridRowCountFor(config, gridSize);
    final column =
        ((component.position.dx / trackSize).round() + 1)
            .clamp(1, columnCount)
            .toInt();
    final row =
        ((component.position.dy / trackSize).round() + 1)
            .clamp(1, rowCount)
            .toInt();
    final columnSpan =
        (component.size.width / trackSize)
            .round()
            .clamp(1, columnCount)
            .toInt();
    final rowSpan =
        (component.size.height / trackSize).round().clamp(1, rowCount).toInt();

    return LayoutRuleGridGeometryMetrics(
      column: column,
      row: row,
      columnSpan: columnSpan,
      rowSpan: rowSpan,
      pixelWidth: gridSpanPixels(columnSpan, gridSize),
      pixelHeight: gridSpanPixels(rowSpan, gridSize),
    );
  }

  LayoutRuleTabularGeometryMetrics tabularGeometryFor(
    ComponentData component,
    LayoutConfig config,
  ) {
    final rowHeight = config.tabularRowHeight.clamp(1.0, double.infinity);
    final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
    final column =
        trackWidth <= 0
            ? 1
            : ((component.position.dx / trackWidth).round() + 1)
                .clamp(1, config.tabularColumnCount)
                .toInt();
    final row = math.max(1, (component.position.dy / rowHeight).round() + 1);
    final columnSpan =
        trackWidth <= 0
            ? 1
            : ((component.size.width + config.tabularColumnGap) / trackWidth)
                .round()
                .clamp(1, config.tabularColumnCount)
                .toInt();
    final rowSpan = math.max(1, (component.size.height / rowHeight).round());
    final pixelWidth =
        config.tabularColumnWidth * columnSpan +
        config.tabularColumnGap * math.max(0, columnSpan - 1);
    final pixelHeight = rowHeight * rowSpan;

    return LayoutRuleTabularGeometryMetrics(
      column: column,
      row: row,
      columnSpan: columnSpan,
      rowSpan: rowSpan,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
    );
  }

  LayoutRuleAutoGridGeometryMetrics autoGridGeometryFor(
    ComponentData component,
    LayoutConfig config,
  ) {
    final rowHeight = math.max(24.0, config.autoGridRowHeight);
    final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
    final rowTrackHeight = rowHeight + config.autoGridGap;
    final column =
        trackWidth <= 0
            ? 1
            : ((component.position.dx / trackWidth).round() + 1)
                .clamp(1, config.autoGridColumnCount)
                .toInt();
    final row =
        rowTrackHeight <= 0
            ? 1
            : math.max(1, (component.position.dy / rowTrackHeight).round() + 1);
    final columnSpan =
        trackWidth <= 0
            ? 1
            : ((component.size.width + config.autoGridGap) / trackWidth)
                .round()
                .clamp(1, config.autoGridColumnCount)
                .toInt();
    final rowSpan =
        rowTrackHeight <= 0
            ? 1
            : math.max(
              1,
              ((component.size.height + config.autoGridGap) / rowTrackHeight)
                  .round(),
            );
    final pixelWidth =
        config.autoGridColumnWidth * columnSpan +
        config.autoGridGap * math.max(0, columnSpan - 1);
    final pixelHeight =
        rowHeight * rowSpan + config.autoGridGap * math.max(0, rowSpan - 1);

    return LayoutRuleAutoGridGeometryMetrics(
      column: column,
      row: row,
      columnSpan: columnSpan,
      rowSpan: rowSpan,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
    );
  }

  LayoutRuleSelectionMetrics? gridSelectionMetricsFor(
    Iterable<ComponentData> components,
    LayoutConfig config,
    double gridSize,
  ) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return null;

    var startColumn = gridColumnCountFor(config, gridSize);
    var startRow = gridRowCountFor(config, gridSize);
    var endColumn = 1;
    var endRow = 1;

    for (final component in visibleComponents) {
      final metrics = gridGeometryFor(component, config, gridSize);
      startColumn = math.min(startColumn, metrics.column);
      startRow = math.min(startRow, metrics.row);
      endColumn = math.max(endColumn, metrics.column + metrics.columnSpan - 1);
      endRow = math.max(endRow, metrics.row + metrics.rowSpan - 1);
    }

    return LayoutRuleSelectionMetrics(
      startColumn: startColumn,
      startRow: startRow,
      endColumn: endColumn,
      endRow: endRow,
    );
  }

  LayoutRuleSelectionMetrics? tabularSelectionMetricsFor(
    Iterable<ComponentData> components,
    LayoutConfig config,
  ) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return null;

    var startColumn = config.tabularColumnCount;
    var startRow = 1 << 30;
    var endColumn = 1;
    var endRow = 1;

    for (final component in visibleComponents) {
      final metrics = tabularGeometryFor(component, config);
      startColumn = math.min(startColumn, metrics.column);
      startRow = math.min(startRow, metrics.row);
      endColumn = math.max(endColumn, metrics.column + metrics.columnSpan - 1);
      endRow = math.max(endRow, metrics.row + metrics.rowSpan - 1);
    }

    return LayoutRuleSelectionMetrics(
      startColumn: startColumn,
      startRow: startRow,
      endColumn: endColumn,
      endRow: endRow,
    );
  }

  LayoutRuleSelectionMetrics? autoGridSelectionMetricsFor(
    Iterable<ComponentData> components,
    LayoutConfig config,
  ) {
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    if (visibleComponents.isEmpty) return null;

    var startColumn = config.autoGridColumnCount;
    var startRow = 1 << 30;
    var endColumn = 1;
    var endRow = 1;

    for (final component in visibleComponents) {
      final metrics = autoGridGeometryFor(component, config);
      startColumn = math.min(startColumn, metrics.column);
      startRow = math.min(startRow, metrics.row);
      endColumn = math.max(endColumn, metrics.column + metrics.columnSpan - 1);
      endRow = math.max(endRow, metrics.row + metrics.rowSpan - 1);
    }

    return LayoutRuleSelectionMetrics(
      startColumn: startColumn,
      startRow: startRow,
      endColumn: endColumn,
      endRow: endRow,
    );
  }

  String cellRangeLabel(LayoutRuleSelectionMetrics metrics) {
    final columnRange =
        metrics.startColumn == metrics.endColumn
            ? 'C${metrics.startColumn}'
            : 'C${metrics.startColumn}-${metrics.endColumn}';
    final rowRange =
        metrics.startRow == metrics.endRow
            ? 'R${metrics.startRow}'
            : 'R${metrics.startRow}-${metrics.endRow}';
    return '$columnRange $rowRange';
  }

  LayoutRuleSnapStatus snapStatusFor(
    Iterable<ComponentData> components,
    LayoutConfig config,
    double gridSize, {
    bool includeHidden = false,
  }) {
    var positionCount = 0;
    var sizeCount = 0;

    for (final component in components) {
      if ((!includeHidden && !component.isVisible) || component.isLocked) {
        continue;
      }

      if (needsPositionSnap(component, config, gridSize)) {
        positionCount++;
      }
      if (needsSizeSnap(component, config, gridSize)) {
        sizeCount++;
      }
    }

    return LayoutRuleSnapStatus(
      positionCount: positionCount,
      sizeCount: sizeCount,
    );
  }

  bool needsPositionSnap(
    ComponentData component,
    LayoutConfig config,
    double gridSize,
  ) {
    final snappedPosition = snapPositionForLayoutRules(
      component.position,
      config,
      gridSize,
    );

    return (snappedPosition - component.position).distance >= 0.01;
  }

  bool needsSizeSnap(
    ComponentData component,
    LayoutConfig config,
    double gridSize,
  ) {
    final snappedSize = snapSizeForLayoutRules(
      component.size,
      config,
      gridSize,
    );

    return (snappedSize.width - component.size.width).abs() >= 0.01 ||
        (snappedSize.height - component.size.height).abs() >= 0.01;
  }

  Offset snapPositionForLayoutRules(
    Offset position,
    LayoutConfig config,
    double gridSize,
  ) {
    switch (config.layoutMechanism) {
      case LayoutMechanism.freeform:
        return position;
      case LayoutMechanism.grid:
        final safeGridSize = gridTrackSize(gridSize);

        return Offset(
          (position.dx / safeGridSize).round() * safeGridSize,
          (position.dy / safeGridSize).round() * safeGridSize,
        );
      case LayoutMechanism.tabularColumns:
        final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
        final column =
            trackWidth <= 0
                ? 0
                : (position.dx / trackWidth)
                    .round()
                    .clamp(0, config.tabularColumnCount - 1)
                    .toInt();
        final rowHeight = math.max(1.0, config.tabularRowHeight);
        final row = (position.dy / rowHeight).round();

        return Offset(column * trackWidth, row * rowHeight);
      case LayoutMechanism.autoGrid:
        final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
        final column =
            trackWidth <= 0
                ? 0
                : (position.dx / trackWidth)
                    .round()
                    .clamp(0, config.autoGridColumnCount - 1)
                    .toInt();
        final rowTrackHeight =
            math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
        final row =
            rowTrackHeight <= 0 ? 0 : (position.dy / rowTrackHeight).round();

        return Offset(column * trackWidth, row * rowTrackHeight);
    }
  }

  Size snapSizeForLayoutRules(Size size, LayoutConfig config, double gridSize) {
    final constrained = Size(
      size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
      size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
    );

    switch (config.layoutMechanism) {
      case LayoutMechanism.freeform:
        return constrained;
      case LayoutMechanism.grid:
        final safeGridSize = gridTrackSize(gridSize);

        return Size(
          (constrained.width / safeGridSize).round() * safeGridSize,
          (constrained.height / safeGridSize).round() * safeGridSize,
        );
      case LayoutMechanism.tabularColumns:
        final trackWidth = config.tabularColumnWidth + config.tabularColumnGap;
        if (trackWidth <= 0) return constrained;

        final columnSpan =
            ((constrained.width + config.tabularColumnGap) / trackWidth)
                .round()
                .clamp(1, config.tabularColumnCount)
                .toInt();
        final rowHeight = math.max(1.0, config.tabularRowHeight);
        final rowSpan = math.max(1, (constrained.height / rowHeight).round());

        return Size(
          columnSpan * config.tabularColumnWidth +
              math.max(0, columnSpan - 1) * config.tabularColumnGap,
          rowSpan * rowHeight,
        );
      case LayoutMechanism.autoGrid:
        final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
        if (trackWidth <= 0) return constrained;

        final columnSpan =
            ((constrained.width + config.autoGridGap) / trackWidth)
                .round()
                .clamp(1, config.autoGridColumnCount)
                .toInt();
        final rowTrackHeight =
            math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
        final rowSpan = math.max(
          1,
          ((constrained.height + config.autoGridGap) / rowTrackHeight).round(),
        );

        return Size(
          columnSpan * config.autoGridColumnWidth +
              math.max(0, columnSpan - 1) * config.autoGridGap,
          rowSpan * math.max(24.0, config.autoGridRowHeight) +
              math.max(0, rowSpan - 1) * config.autoGridGap,
        );
    }
  }

  void moveSelectionToGridColumn(
    LayoutStateNotifier notifier,
    Iterable<ComponentData> components,
    double gridSize,
    int column,
  ) {
    final movableComponents =
        components.where((component) => !component.isLocked).toList();
    if (movableComponents.isEmpty) return;

    final bounds = _selectionBounds(movableComponents);
    final targetLeft = gridStartOffset(column, gridSize);
    notifier.moveSelectedComponents(Offset(targetLeft - bounds.left, 0));
  }

  void moveSelectionToGridRow(
    LayoutStateNotifier notifier,
    Iterable<ComponentData> components,
    double gridSize,
    int row,
  ) {
    final movableComponents =
        components.where((component) => !component.isLocked).toList();
    if (movableComponents.isEmpty) return;

    final bounds = _selectionBounds(movableComponents);
    final targetTop = gridStartOffset(row, gridSize);
    notifier.moveSelectedComponents(Offset(0, targetTop - bounds.top));
  }

  double gridTrackSize(double gridSize) =>
      gridSize.clamp(1.0, double.infinity).toDouble();

  double gridStartOffset(int index, double gridSize) {
    final normalizedIndex = math.max(1, index);
    return (normalizedIndex - 1) * gridTrackSize(gridSize);
  }

  double gridSpanPixels(int span, double gridSize) {
    return math.max(1, span) * gridTrackSize(gridSize);
  }

  int gridColumnCountFor(LayoutConfig config, double gridSize) {
    return math.max(1, (config.canvasWidth / gridTrackSize(gridSize)).ceil());
  }

  int gridRowCountFor(LayoutConfig config, double gridSize) {
    return math.max(1, (config.canvasHeight / gridTrackSize(gridSize)).ceil());
  }

  String formatPixels(double value) {
    if (!value.isFinite) return '0px';
    return '${value.round()}px';
  }

  Rect _selectionBounds(List<ComponentData> components) {
    final first = components.first;
    var left = first.position.dx;
    var top = first.position.dy;
    var right = first.position.dx + first.size.width;
    var bottom = first.position.dy + first.size.height;

    for (final component in components.skip(1)) {
      left = math.min(left, component.position.dx);
      top = math.min(top, component.position.dy);
      right = math.max(right, component.position.dx + component.size.width);
      bottom = math.max(bottom, component.position.dy + component.size.height);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
}

/// Shared instance for stateless layout-rule geometry calculations.
const layoutRuleGeometryService = LayoutRuleGeometryService();
