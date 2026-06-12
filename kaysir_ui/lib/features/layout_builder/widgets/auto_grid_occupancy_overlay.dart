import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/canvas_viewport_provider.dart';

class AutoGridOccupancyOverlay extends StatelessWidget {
  final List<ComponentData> components;
  final LayoutConfig config;
  final Set<String> selectedComponentIds;
  final AutoGridPreview? preview;

  const AutoGridOccupancyOverlay({
    super.key,
    required this.components,
    required this.config,
    required this.selectedComponentIds,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    if (config.layoutMechanism != LayoutMechanism.autoGrid) {
      return const SizedBox.shrink();
    }

    final previewComponentIds = preview?.componentIds ?? const <String>{};
    final cells = _buildOccupancyCells(
      components,
      config,
      selectedComponentIds,
      excludedComponentIds: previewComponentIds,
    );
    final previewCells = _buildPreviewCells(preview, config, cells);
    if (cells.isEmpty && previewCells.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _AutoGridOccupancyPainter(
          cells: cells,
          previewCells: previewCells,
          config: config,
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

List<_AutoGridOccupancyCell> _buildOccupancyCells(
  List<ComponentData> components,
  LayoutConfig config,
  Set<String> selectedComponentIds, {
  Set<String> excludedComponentIds = const <String>{},
}) {
  final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  if (trackWidth <= 0 || rowTrackHeight <= 0) {
    return const <_AutoGridOccupancyCell>[];
  }

  final drafts = <_AutoGridCellKey, _AutoGridCellDraft>{};
  for (final component in components) {
    if (!component.isVisible) continue;
    if (excludedComponentIds.contains(component.id)) continue;

    final placement = _autoGridPlacementFor(
      component,
      config,
      columnCount,
      trackWidth,
      rowTrackHeight,
    );
    final groupKey = component.properties.parentId ?? component.id;

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

        final key = _AutoGridCellKey(column: column, row: row);
        final draft = drafts.putIfAbsent(key, () => _AutoGridCellDraft(key));
        draft.componentCount += 1;
        draft.groupKeys.add(groupKey);
        draft.hasSelectedComponent |= selectedComponentIds.contains(
          component.id,
        );
        draft.hasLockedComponent |= component.isLocked;
      }
    }
  }

  final cells =
      drafts.values.map((draft) => draft.toCell()).toList()..sort((a, b) {
        final rowCompare = a.key.row.compareTo(b.key.row);
        if (rowCompare != 0) return rowCompare;
        return a.key.column.compareTo(b.key.column);
      });

  return cells;
}

List<_AutoGridPreviewCell> _buildPreviewCells(
  AutoGridPreview? preview,
  LayoutConfig config,
  List<_AutoGridOccupancyCell> occupancyCells,
) {
  if (preview == null || preview.isEmpty) return const <_AutoGridPreviewCell>[];

  final columnCount = config.autoGridColumnCount.clamp(1, 24).toInt();
  final trackWidth = config.autoGridColumnWidth + config.autoGridGap;
  final rowTrackHeight =
      math.max(24.0, config.autoGridRowHeight) + config.autoGridGap;
  if (trackWidth <= 0 || rowTrackHeight <= 0) {
    return const <_AutoGridPreviewCell>[];
  }

  final occupiedKeys = {for (final cell in occupancyCells) cell.key: cell};
  final drafts = <_AutoGridCellKey, _AutoGridPreviewCellDraft>{};

  for (final item in preview.items) {
    final placement = _autoGridPlacementForBounds(
      item.bounds,
      config,
      columnCount,
      trackWidth,
      rowTrackHeight,
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

        final key = _AutoGridCellKey(column: column, row: row);
        final draft = drafts.putIfAbsent(
          key,
          () => _AutoGridPreviewCellDraft(key),
        );
        draft.componentIds.add(item.componentId);
        draft.hasConflict |= occupiedKeys.containsKey(key);
      }
    }
  }

  return drafts.values.map((draft) => draft.toCell()).toList()..sort((a, b) {
    final rowCompare = a.key.row.compareTo(b.key.row);
    if (rowCompare != 0) return rowCompare;
    return a.key.column.compareTo(b.key.column);
  });
}

_AutoGridPlacement _autoGridPlacementFor(
  ComponentData component,
  LayoutConfig config,
  int columnCount,
  double trackWidth,
  double rowTrackHeight,
) {
  return _autoGridPlacementForBounds(
    Rect.fromLTWH(
      component.position.dx,
      component.position.dy,
      component.size.width,
      component.size.height,
    ),
    config,
    columnCount,
    trackWidth,
    rowTrackHeight,
  );
}

_AutoGridPlacement _autoGridPlacementForBounds(
  Rect bounds,
  LayoutConfig config,
  int columnCount,
  double trackWidth,
  double rowTrackHeight,
) {
  final column =
      (bounds.left / trackWidth).round().clamp(0, columnCount - 1).toInt();
  final row = math.max(0, (bounds.top / rowTrackHeight).round());
  final columnSpan =
      ((bounds.width + config.autoGridGap) / trackWidth)
          .round()
          .clamp(1, columnCount)
          .toInt();
  final rowSpan = math.max(
    1,
    ((bounds.height + config.autoGridGap) / rowTrackHeight).round(),
  );

  return _AutoGridPlacement(
    column: column,
    row: row,
    columnSpan: math.min(columnSpan, columnCount - column),
    rowSpan: rowSpan,
  );
}

class _AutoGridOccupancyPainter extends CustomPainter {
  final List<_AutoGridOccupancyCell> cells;
  final List<_AutoGridPreviewCell> previewCells;
  final LayoutConfig config;
  final ColorScheme colorScheme;

  const _AutoGridOccupancyPainter({
    required this.cells,
    required this.previewCells,
    required this.config,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final columnWidth = config.autoGridColumnWidth;
    final rowHeight = math.max(24.0, config.autoGridRowHeight);
    final trackWidth = columnWidth + config.autoGridGap;
    final rowTrackHeight = rowHeight + config.autoGridGap;
    if (columnWidth <= 0 || rowHeight <= 0) return;

    for (final cell in cells) {
      final rect = Rect.fromLTWH(
        cell.key.column * trackWidth,
        cell.key.row * rowTrackHeight,
        columnWidth,
        rowHeight,
      ).intersect(Offset.zero & size);
      if (rect.isEmpty) continue;

      final fillColor =
          cell.hasConflict
              ? colorScheme.error.withValues(alpha: 0.18)
              : cell.hasSelectedComponent
              ? colorScheme.primary.withValues(alpha: 0.16)
              : colorScheme.tertiary.withValues(alpha: 0.09);
      final borderColor =
          cell.hasConflict
              ? colorScheme.error.withValues(alpha: 0.66)
              : cell.hasSelectedComponent
              ? colorScheme.primary.withValues(alpha: 0.62)
              : colorScheme.tertiary.withValues(alpha: 0.26);
      final radius = Radius.circular(math.min(6.0, rect.shortestSide / 4));
      final roundedRect = RRect.fromRectAndRadius(rect.deflate(3), radius);

      canvas.drawRRect(
        roundedRect,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        roundedRect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell.hasConflict || cell.componentCount > 1 ? 1.4 : 1,
      );

      if (cell.hasLockedComponent) {
        _drawLockedStripe(canvas, roundedRect.outerRect);
      }
    }

    for (final cell in previewCells) {
      final rect = Rect.fromLTWH(
        cell.key.column * trackWidth,
        cell.key.row * rowTrackHeight,
        columnWidth,
        rowHeight,
      ).intersect(Offset.zero & size);
      if (rect.isEmpty) continue;

      final borderColor =
          cell.hasConflict
              ? colorScheme.error.withValues(alpha: 0.86)
              : colorScheme.primary.withValues(alpha: 0.86);
      final fillColor =
          cell.hasConflict
              ? colorScheme.error.withValues(alpha: 0.22)
              : colorScheme.primary.withValues(alpha: 0.2);
      final radius = Radius.circular(math.min(7.0, rect.shortestSide / 4));
      final roundedRect = RRect.fromRectAndRadius(rect.deflate(2), radius);

      canvas.drawRRect(
        roundedRect,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        roundedRect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );

      if (cell.hasConflict) {
        _drawConflictSlash(canvas, roundedRect.outerRect);
      } else {
        _drawPreviewCorner(canvas, roundedRect.outerRect);
      }
    }
  }

  void _drawLockedStripe(Canvas canvas, Rect rect) {
    final paint =
        Paint()
          ..color = colorScheme.onSurfaceVariant.withValues(alpha: 0.24)
          ..strokeWidth = 1;
    final start = Offset(rect.right - 18, rect.top + 4);
    final end = Offset(rect.right - 4, rect.top + 18);

    canvas.drawLine(start, end, paint);
  }

  void _drawConflictSlash(Canvas canvas, Rect rect) {
    final paint =
        Paint()
          ..color = colorScheme.error.withValues(alpha: 0.72)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(rect.left + 7, rect.top + 7),
      Offset(rect.right - 7, rect.bottom - 7),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + 7, rect.bottom - 7),
      Offset(rect.right - 7, rect.top + 7),
      paint,
    );
  }

  void _drawPreviewCorner(Canvas canvas, Rect rect) {
    final paint =
        Paint()
          ..color = colorScheme.primary.withValues(alpha: 0.72)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    const cornerLength = 12.0;
    final left = rect.left + 7;
    final top = rect.top + 7;

    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), paint);
  }

  @override
  bool shouldRepaint(_AutoGridOccupancyPainter oldDelegate) {
    return oldDelegate.cells != cells ||
        oldDelegate.previewCells != previewCells ||
        oldDelegate.config != config ||
        oldDelegate.colorScheme != colorScheme;
  }
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

class _AutoGridCellKey {
  final int column;
  final int row;

  const _AutoGridCellKey({required this.column, required this.row});

  @override
  bool operator ==(Object other) {
    return other is _AutoGridCellKey &&
        other.column == column &&
        other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);
}

class _AutoGridCellDraft {
  final _AutoGridCellKey key;
  final groupKeys = <String>{};
  var componentCount = 0;
  var hasSelectedComponent = false;
  var hasLockedComponent = false;

  _AutoGridCellDraft(this.key);

  _AutoGridOccupancyCell toCell() {
    return _AutoGridOccupancyCell(
      key: key,
      componentCount: componentCount,
      hasConflict: groupKeys.length > 1,
      hasSelectedComponent: hasSelectedComponent,
      hasLockedComponent: hasLockedComponent,
    );
  }
}

class _AutoGridPreviewCellDraft {
  final _AutoGridCellKey key;
  final componentIds = <String>{};
  var hasConflict = false;

  _AutoGridPreviewCellDraft(this.key);

  _AutoGridPreviewCell toCell() {
    return _AutoGridPreviewCell(
      key: key,
      hasConflict: hasConflict || componentIds.length > 1,
    );
  }
}

class _AutoGridOccupancyCell {
  final _AutoGridCellKey key;
  final int componentCount;
  final bool hasConflict;
  final bool hasSelectedComponent;
  final bool hasLockedComponent;

  const _AutoGridOccupancyCell({
    required this.key,
    required this.componentCount,
    required this.hasConflict,
    required this.hasSelectedComponent,
    required this.hasLockedComponent,
  });
}

class _AutoGridPreviewCell {
  final _AutoGridCellKey key;
  final bool hasConflict;

  const _AutoGridPreviewCell({required this.key, required this.hasConflict});
}
