import 'dart:math' as math;

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Size cellSize;
  final Color color;
  final bool showSubgrid;

  const GridPainter({
    required this.cellSize,
    required this.color,
    required this.showSubgrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += cellSize.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    if (showSubgrid) {
      final subPaint =
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 0.5;

      for (double x = 0; x <= size.width; x += cellSize.width / 2) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), subPaint);
      }

      for (double y = 0; y <= size.height; y += cellSize.height / 2) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), subPaint);
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize ||
        oldDelegate.color != color ||
        oldDelegate.showSubgrid != showSubgrid;
  }
}

class TabularGridPainter extends CustomPainter {
  final int columnCount;
  final double columnGap;
  final double rowHeight;
  final Color color;
  final bool showLabels;

  const TabularGridPainter({
    required this.columnCount,
    required this.columnGap,
    required this.rowHeight,
    required this.color,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final safeColumnCount = columnCount.clamp(1, 48).toInt();
    final safeGap = columnGap.clamp(0.0, double.infinity).toDouble();
    final safeRowHeight = rowHeight.clamp(1.0, double.infinity).toDouble();
    final totalGap = (safeColumnCount - 1) * safeGap;
    final columnWidth =
        ((size.width - totalGap) / safeColumnCount)
            .clamp(1.0, double.infinity)
            .toDouble();
    final columnPaint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    final columnEdgePaint =
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..strokeWidth = 0.5;
    final rowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..strokeWidth = 0.5;

    var x = 0.0;
    for (var index = 0; index < safeColumnCount; index++) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), columnPaint);
      canvas.drawLine(
        Offset(x + columnWidth, 0),
        Offset(x + columnWidth, size.height),
        columnEdgePaint,
      );
      x += columnWidth + safeGap;
    }

    for (double y = 0; y <= size.height; y += safeRowHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rowPaint);
    }

    if (showLabels) {
      _paintLabels(
        canvas,
        size,
        columnCount: safeColumnCount,
        columnWidth: columnWidth,
        columnGap: safeGap,
        rowHeight: safeRowHeight,
      );
    }
  }

  @override
  bool shouldRepaint(TabularGridPainter oldDelegate) {
    return oldDelegate.columnCount != columnCount ||
        oldDelegate.columnGap != columnGap ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.color != color ||
        oldDelegate.showLabels != showLabels;
  }

  void _paintLabels(
    Canvas canvas,
    Size size, {
    required int columnCount,
    required double columnWidth,
    required double columnGap,
    required double rowHeight,
  }) {
    if (size.width <= 0 || size.height <= 0) return;

    final labelStyle = TextStyle(
      color: color.withValues(alpha: 0.72),
      fontSize: columnWidth < 48 ? 9 : 10,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final painter = TextPainter(
      maxLines: 1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (columnWidth >= 24) {
      var x = 0.0;
      for (var index = 0; index < columnCount; index++) {
        _paintText(
          canvas,
          painter,
          'C${index + 1}',
          labelStyle,
          Offset(x + columnWidth / 2, 4),
          centered: true,
        );
        x += columnWidth + columnGap;
      }
    }

    final rowLabelInterval = math.max(1, (28 / rowHeight).ceil());
    var rowIndex = 0;
    for (double y = 0; y < size.height; y += rowHeight) {
      if (rowIndex % rowLabelInterval == 0) {
        _paintText(
          canvas,
          painter,
          'R${rowIndex + 1}',
          labelStyle,
          Offset(4, y + rowHeight / 2),
          centeredVertically: true,
        );
      }
      rowIndex++;
    }
  }

  void _paintText(
    Canvas canvas,
    TextPainter painter,
    String text,
    TextStyle style,
    Offset offset, {
    bool centered = false,
    bool centeredVertically = false,
  }) {
    painter
      ..text = TextSpan(text: text, style: style)
      ..layout();

    final dx = centered ? offset.dx - painter.width / 2 : offset.dx;
    final dy = centeredVertically ? offset.dy - painter.height / 2 : offset.dy;
    painter.paint(canvas, Offset(dx, dy));
  }
}

class AutoGridPainter extends CustomPainter {
  final int columnCount;
  final double gap;
  final double rowHeight;
  final Color color;
  final bool showLabels;

  const AutoGridPainter({
    required this.columnCount,
    required this.gap,
    required this.rowHeight,
    required this.color,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final safeColumnCount = columnCount.clamp(1, 24).toInt();
    final safeGap = gap.clamp(0.0, double.infinity).toDouble();
    final safeRowHeight = rowHeight.clamp(24.0, double.infinity).toDouble();
    final totalGap = (safeColumnCount - 1) * safeGap;
    final columnWidth =
        ((size.width - totalGap) / safeColumnCount)
            .clamp(1.0, double.infinity)
            .toDouble();
    final trackHeight = safeRowHeight + safeGap;
    final cellPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final gapPaint =
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += trackHeight) {
      if (safeGap > 0 && y + safeRowHeight < size.height) {
        canvas.drawRect(
          Rect.fromLTWH(
            0,
            y + safeRowHeight,
            size.width,
            math.min(safeGap, size.height - y - safeRowHeight),
          ),
          gapPaint,
        );
      }

      var x = 0.0;
      for (var index = 0; index < safeColumnCount; index++) {
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            y,
            columnWidth,
            math.min(safeRowHeight, size.height - y),
          ),
          cellPaint,
        );
        x += columnWidth + safeGap;
      }
    }

    if (showLabels) {
      _paintLabels(
        canvas,
        size,
        columnCount: safeColumnCount,
        columnWidth: columnWidth,
        gap: safeGap,
        rowHeight: safeRowHeight,
        trackHeight: trackHeight,
      );
    }
  }

  @override
  bool shouldRepaint(AutoGridPainter oldDelegate) {
    return oldDelegate.columnCount != columnCount ||
        oldDelegate.gap != gap ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.color != color ||
        oldDelegate.showLabels != showLabels;
  }

  void _paintLabels(
    Canvas canvas,
    Size size, {
    required int columnCount,
    required double columnWidth,
    required double gap,
    required double rowHeight,
    required double trackHeight,
  }) {
    if (size.width <= 0 || size.height <= 0) return;

    final labelStyle = TextStyle(
      color: color.withValues(alpha: 0.72),
      fontSize: columnWidth < 56 ? 9 : 10,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final painter = TextPainter(
      maxLines: 1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (columnWidth >= 28) {
      var x = 0.0;
      for (var index = 0; index < columnCount; index++) {
        _paintText(
          canvas,
          painter,
          'G${index + 1}',
          labelStyle,
          Offset(x + columnWidth / 2, 4),
          centered: true,
        );
        x += columnWidth + gap;
      }
    }

    var rowIndex = 0;
    for (double y = 0; y < size.height; y += trackHeight) {
      _paintText(
        canvas,
        painter,
        'R${rowIndex + 1}',
        labelStyle,
        Offset(4, y + rowHeight / 2),
        centeredVertically: true,
      );
      rowIndex++;
    }
  }

  void _paintText(
    Canvas canvas,
    TextPainter painter,
    String text,
    TextStyle style,
    Offset offset, {
    bool centered = false,
    bool centeredVertically = false,
  }) {
    painter
      ..text = TextSpan(text: text, style: style)
      ..layout();

    final dx = centered ? offset.dx - painter.width / 2 : offset.dx;
    final dy = centeredVertically ? offset.dy - painter.height / 2 : offset.dy;
    painter.paint(canvas, Offset(dx, dy));
  }
}
