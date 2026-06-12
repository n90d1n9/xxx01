import 'dart:math' as math;
import 'dart:ui';

import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';

class LayoutRulesConversionPreview {
  final int editableCount;
  final int moveCount;
  final int resizeCount;
  final int changedCount;
  final int unchangedCount;
  final int autoGridConflictCount;
  final double maxMoveDistance;
  final double maxResizeDelta;
  final List<String> moveComponentIds;
  final List<String> resizeComponentIds;
  final List<String> autoGridConflictComponentIds;

  const LayoutRulesConversionPreview({
    required this.editableCount,
    required this.moveCount,
    required this.resizeCount,
    required this.changedCount,
    required this.unchangedCount,
    this.autoGridConflictCount = 0,
    this.maxMoveDistance = 0,
    this.maxResizeDelta = 0,
    this.moveComponentIds = const <String>[],
    this.resizeComponentIds = const <String>[],
    this.autoGridConflictComponentIds = const <String>[],
  });

  bool get hasGeometryChanges => moveCount > 0 || resizeCount > 0;
}

LayoutRulesConversionPreview layoutRulesConversionPreviewFor({
  required List<ComponentData> components,
  required GridSettings gridSettings,
  required LayoutConfig config,
  required bool snapPositions,
  required bool snapSizes,
  bool resolveAutoGridConflicts = false,
}) {
  final editableIds = _editableComponentIds(components);
  final snappedComponents = layoutRulesConvertedComponents(
    components: components,
    gridSettings: gridSettings,
    config: config,
    snapPositions: snapPositions,
    snapSizes: snapSizes,
  );
  final autoGridConflictIds =
      resolveAutoGridConflicts &&
              config.layoutMechanism == LayoutMechanism.autoGrid
          ? _autoGridConflictComponentIds(snappedComponents, config)
          : const <String>{};
  final nextComponents =
      autoGridConflictIds.isEmpty
          ? snappedComponents
          : _moveComponentsToFreeAutoGridCells(
            snappedComponents,
            autoGridConflictIds,
            config,
          );

  final nextComponentsById = {
    for (final component in nextComponents) component.id: component,
  };
  var moveCount = 0;
  var resizeCount = 0;
  var changedCount = 0;
  var maxMoveDistance = 0.0;
  var maxResizeDelta = 0.0;
  final moveComponentIds = <String>[];
  final resizeComponentIds = <String>[];

  for (final component in components) {
    if (!editableIds.contains(component.id)) continue;

    final nextComponent = nextComponentsById[component.id] ?? component;
    final moveDistance = (nextComponent.position - component.position).distance;
    final widthDelta = (nextComponent.size.width - component.size.width).abs();
    final heightDelta =
        (nextComponent.size.height - component.size.height).abs();
    final resizeDelta = math.max(widthDelta, heightDelta);
    final didMove = moveDistance >= 0.01;
    final didResize = resizeDelta >= 0.01;

    if (didMove) {
      moveCount++;
      moveComponentIds.add(component.id);
      maxMoveDistance = math.max(maxMoveDistance, moveDistance);
    }
    if (didResize) {
      resizeCount++;
      resizeComponentIds.add(component.id);
      maxResizeDelta = math.max(maxResizeDelta, resizeDelta);
    }
    if (didMove || didResize) changedCount++;
  }

  return LayoutRulesConversionPreview(
    editableCount: editableIds.length,
    moveCount: moveCount,
    resizeCount: resizeCount,
    changedCount: changedCount,
    unchangedCount: editableIds.length - changedCount,
    autoGridConflictCount: autoGridConflictIds.length,
    maxMoveDistance: maxMoveDistance,
    maxResizeDelta: maxResizeDelta,
    moveComponentIds: moveComponentIds,
    resizeComponentIds: resizeComponentIds,
    autoGridConflictComponentIds: [
      for (final component in components)
        if (autoGridConflictIds.contains(component.id)) component.id,
    ],
  );
}

List<ComponentData> layoutRulesConvertedComponents({
  required List<ComponentData> components,
  required GridSettings gridSettings,
  required LayoutConfig config,
  required bool snapPositions,
  required bool snapSizes,
  bool resolveAutoGridConflicts = false,
}) {
  final editableIds = _editableComponentIds(components);
  final snappedComponents =
      components.map((component) {
        if (!editableIds.contains(component.id)) return component;

        return component.copyWith(
          position:
              snapPositions
                  ? _snapPositionForRules(
                    component.position,
                    config,
                    gridSettings.gridSize,
                  )
                  : component.position,
          size:
              snapSizes
                  ? _snapSizeForRules(
                    component.size,
                    config,
                    gridSettings.gridSize,
                  )
                  : component.size,
        );
      }).toList();

  if (!resolveAutoGridConflicts ||
      config.layoutMechanism != LayoutMechanism.autoGrid) {
    return snappedComponents;
  }

  final autoGridConflictIds = _autoGridConflictComponentIds(
    snappedComponents,
    config,
  );
  if (autoGridConflictIds.isEmpty) return snappedComponents;

  return _moveComponentsToFreeAutoGridCells(
    snappedComponents,
    autoGridConflictIds,
    config,
  );
}

Set<String> _editableComponentIds(List<ComponentData> components) {
  return components
      .where((component) => component.isVisible && !component.isLocked)
      .map((component) => component.id)
      .toSet();
}

Offset _snapPositionForRules(
  Offset position,
  LayoutConfig config,
  double gridSize,
) {
  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return position;
    case LayoutMechanism.grid:
      if (gridSize <= 0) return position;

      return Offset(
        (position.dx / gridSize).round() * gridSize,
        (position.dy / gridSize).round() * gridSize,
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
      return _snapPositionToAutoGrid(position, config);
  }
}

Size _snapSizeForRules(Size size, LayoutConfig config, double gridSize) {
  final constrained = Size(
    size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
    size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
  );

  switch (config.layoutMechanism) {
    case LayoutMechanism.freeform:
      return constrained;
    case LayoutMechanism.grid:
      if (gridSize <= 0) return constrained;

      return Size(
        (constrained.width / gridSize).round() * gridSize,
        (constrained.height / gridSize).round() * gridSize,
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
      return _snapSizeToAutoGrid(constrained, config);
  }
}

List<ComponentData> _moveComponentsToFreeAutoGridCells(
  List<ComponentData> components,
  Set<String> targetIds,
  LayoutConfig config,
) {
  final targetComponents =
      components
          .where(
            (component) =>
                targetIds.contains(component.id) &&
                component.isVisible &&
                !component.isLocked,
          )
          .toList();
  if (targetComponents.isEmpty) return components;

  final sortedComponents = [...targetComponents]..sort((a, b) {
    final verticalCompare = a.position.dy.compareTo(b.position.dy);
    if (verticalCompare != 0) return verticalCompare;
    return a.position.dx.compareTo(b.position.dx);
  });
  final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
  final trackWidth = _autoGridColumnTrackWidth(config);
  final rowTrackHeight = _autoGridRowTrackHeight(config);
  if (trackWidth <= 0 || rowTrackHeight <= 0) return components;

  final movableIds = sortedComponents.map((component) => component.id).toSet();
  final occupiedCells = _autoGridOccupiedCells(
    components,
    excludedIds: movableIds,
    columnCount: columnCount,
    trackWidth: trackWidth,
    rowTrackHeight: rowTrackHeight,
    config: config,
  );
  final selectionStart = _snapPositionToAutoGrid(
    _componentsBounds(sortedComponents).topLeft,
    config,
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
    final nextSize = _snapSizeToAutoGrid(component.size, config);
    final columnSpan = _autoGridColumnSpanForWidth(nextSize.width, config);
    final rowSpan = _autoGridRowSpanForHeight(nextSize.height, config);
    final nextPlacement = _firstFreeAutoGridPlacement(
      occupiedCells: occupiedCells,
      columnCount: columnCount,
      columnSpan: columnSpan,
      rowSpan: rowSpan,
      startIndex: searchIndex,
    );
    if (nextPlacement == null) return components;

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

  return components.map((component) {
    final nextPosition = nextPositions[component.id];
    final nextSize = nextSizes[component.id];
    if (nextPosition == null || nextSize == null) return component;

    return component.copyWith(position: nextPosition, size: nextSize);
  }).toList();
}

Set<String> _autoGridConflictComponentIds(
  List<ComponentData> components,
  LayoutConfig config,
) {
  final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
  final trackWidth = _autoGridColumnTrackWidth(config);
  final rowTrackHeight = _autoGridRowTrackHeight(config);
  if (trackWidth <= 0 || rowTrackHeight <= 0) return const <String>{};

  final groupsByCell = <_AutoGridCellKey, Set<String>>{};
  final componentIdsByGroup = <String, Set<String>>{};

  for (final component in components) {
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
      config,
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
    for (final groupKey in conflictGroupKeys) ...?componentIdsByGroup[groupKey],
  };
}

Set<_AutoGridCellKey> _autoGridOccupiedCells(
  List<ComponentData> components, {
  required Set<String> excludedIds,
  required int columnCount,
  required double trackWidth,
  required double rowTrackHeight,
  required LayoutConfig config,
}) {
  final occupiedCells = <_AutoGridCellKey>{};
  for (final component in components) {
    if (!component.isVisible || excludedIds.contains(component.id)) continue;

    final placement = _autoGridPlacementForGeometry(
      component.position,
      component.size,
      columnCount,
      trackWidth,
      rowTrackHeight,
      config,
    );
    _occupyAutoGridCells(occupiedCells, placement);
  }

  return occupiedCells;
}

_AutoGridPlacement _autoGridPlacementForGeometry(
  Offset position,
  Size size,
  int columnCount,
  double trackWidth,
  double rowTrackHeight,
  LayoutConfig config,
) {
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

Offset _snapPositionToAutoGrid(Offset position, LayoutConfig config) {
  final trackWidth = _autoGridColumnTrackWidth(config);
  final column =
      trackWidth <= 0
          ? 0
          : (position.dx / trackWidth)
              .round()
              .clamp(0, config.autoGridColumnCount - 1)
              .toInt();
  final rowTrackHeight = _autoGridRowTrackHeight(config);
  final row = rowTrackHeight <= 0 ? 0 : (position.dy / rowTrackHeight).round();

  return Offset(column * trackWidth, row * rowTrackHeight);
}

Size _snapSizeToAutoGrid(Size size, LayoutConfig config) {
  final constrained = Size(
    size.width.clamp(config.minComponentWidth, double.infinity).toDouble(),
    size.height.clamp(config.minComponentHeight, double.infinity).toDouble(),
  );
  final columnSpan = _autoGridColumnSpanForWidth(constrained.width, config);
  final rowSpan = _autoGridRowSpanForHeight(constrained.height, config);

  return Size(
    _autoGridColumnSpanWidth(columnSpan, config),
    _autoGridRowSpanHeight(rowSpan, config),
  );
}

int _autoGridColumnSpanForWidth(double width, LayoutConfig config) {
  final trackWidth = _autoGridColumnTrackWidth(config);
  if (trackWidth <= 0) return 1;

  return ((width + config.autoGridGap) / trackWidth)
      .round()
      .clamp(1, config.autoGridColumnCount)
      .toInt();
}

int _autoGridRowSpanForHeight(double height, LayoutConfig config) {
  final rowTrackHeight = _autoGridRowTrackHeight(config);
  if (rowTrackHeight <= 0) return 1;

  return math.max(1, ((height + config.autoGridGap) / rowTrackHeight).round());
}

double _autoGridColumnSpanWidth(int span, LayoutConfig config) {
  final normalizedSpan = span.clamp(1, config.autoGridColumnCount).toInt();

  return normalizedSpan * config.autoGridColumnWidth +
      math.max(0, normalizedSpan - 1) * config.autoGridGap;
}

double _autoGridRowSpanHeight(int span, LayoutConfig config) {
  return math.max(1, span) * math.max(24.0, config.autoGridRowHeight) +
      math.max(0, span - 1) * config.autoGridGap;
}

double _autoGridColumnTrackWidth(LayoutConfig config) {
  return config.autoGridColumnWidth + config.autoGridGap;
}

double _autoGridRowTrackHeight(LayoutConfig config) {
  return math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
}

Rect _componentsBounds(List<ComponentData> components) {
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
