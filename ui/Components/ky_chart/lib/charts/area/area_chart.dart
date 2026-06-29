import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';
import 'dart:math' as math;

import 'area_chart_config.dart';

class AreaChartWidget extends StatefulWidget {
  final AreaChartConfig config;

  const AreaChartWidget({
    super.key,
    required this.config,
  });

  @override
  State<AreaChartWidget> createState() => _AreaChartWidgetState();
}

class _AreaChartWidgetState extends State<AreaChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  OverlayEntry? _tooltipOverlay;
  int? _hoveredPointIndex;
  int? _hoveredSeriesIndex;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hideTooltip();
    super.dispose();
  }

  void _hideTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  void _showTooltip(BuildContext context, Offset position, dynamic x,
      List<SeriesPoint> points) {
    _hideTooltip();

    _tooltipOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy - 80,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: point.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${point.seriesName}: ${point.y.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_tooltipOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final List<SeriesData> seriesDataList = _extractSeriesData(config);

    if (seriesDataList.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    // Determine all X values across all series
    final Set<dynamic> allXValues = {};
    for (var seriesData in seriesDataList) {
      allXValues.addAll(seriesData.points.map((p) => p.x));
    }

    final xValuesList = allXValues.toList()..sort();

    // Find min/max Y values for scaling
    double minY = double.infinity;
    double maxY = config.maxY;

    for (var seriesData in seriesDataList) {
      for (var point in seriesData.points) {
        if (point.y < minY) minY = point.y;
        if (point.y > maxY) maxY = point.y;
      }
    }

    // Ensure min is 0 for area charts to have a clear base
    minY = 0;

    // Add some padding to the top
    maxY = maxY * 1.1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        return Stack(
          children: [
            // Title if provided
            if (config.title != null)
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    config.title!.text ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: stringToColor(config.title!.textStyle!.color),
                    ),
                  ),
                ),
              ),

            // Main chart area
            Padding(
              padding: EdgeInsets.only(
                top: config.title != null ? 40 : 10,
                bottom: 30,
                left: 40,
                right: 10,
              ),
              child: GestureDetector(
                onTapUp: config.tooltip?.show != false
                    ? (details) {
                        final RenderBox box = _chartKey.currentContext!
                            .findRenderObject() as RenderBox;
                        final localPosition =
                            box.globalToLocal(details.globalPosition);

                        final chartWidth = availableWidth - 50;
                        final chartHeight =
                            availableHeight - (config.title != null ? 70 : 40);

                        if (localPosition.dx >= 0 &&
                            localPosition.dx <= chartWidth &&
                            localPosition.dy >= 0 &&
                            localPosition.dy <= chartHeight) {
                          // Calculate which x value was tapped
                          final segmentWidth =
                              chartWidth / (xValuesList.length - 1);
                          final xIndex =
                              (localPosition.dx / segmentWidth).round();

                          if (xIndex >= 0 && xIndex < xValuesList.length) {
                            final x = xValuesList[xIndex];

                            // Get all y values at this x from different series
                            final List<SeriesPoint> points = [];

                            for (var i = 0; i < seriesDataList.length; i++) {
                              final seriesData = seriesDataList[i];
                              final point = seriesData.points.firstWhere(
                                (p) => p.x == x,
                                orElse: () => SeriesPoint(
                                    x: x,
                                    y: 0,
                                    color: seriesData.color,
                                    seriesName: seriesData.name),
                              );

                              points.add(point);
                            }

                            _showTooltip(
                                context, details.globalPosition, x, points);
                          }
                        }
                      }
                    : null,
                onHorizontalDragUpdate: (details) {
                  // Handle dragging for interactive exploration
                  final RenderBox box =
                      _chartKey.currentContext!.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);

                  final chartWidth = availableWidth - 50;

                  if (localPosition.dx >= 0 && localPosition.dx <= chartWidth) {
                    // Calculate which x value was dragged over
                    final segmentWidth = chartWidth / (xValuesList.length - 1);
                    final xIndex = (localPosition.dx / segmentWidth).round();

                    if (xIndex >= 0 && xIndex < xValuesList.length) {
                      final x = xValuesList[xIndex];

                      // Get all y values at this x from different series
                      final List<SeriesPoint> points = [];

                      for (var i = 0; i < seriesDataList.length; i++) {
                        final seriesData = seriesDataList[i];
                        final point = seriesData.points.firstWhere(
                          (p) => p.x == x,
                          orElse: () => SeriesPoint(
                              x: x,
                              y: 0,
                              color: seriesData.color,
                              seriesName: seriesData.name),
                        );

                        points.add(point);
                      }

                      _showTooltip(context, details.globalPosition, x, points);
                    }
                  }
                },
                child: MouseRegion(
                  onHover: (event) {
                    final RenderBox box = _chartKey.currentContext!
                        .findRenderObject() as RenderBox;
                    final localPosition = box.globalToLocal(event.position);

                    final chartWidth = availableWidth - 50;
                    final chartHeight =
                        availableHeight - (config.title != null ? 70 : 40);

                    if (localPosition.dx >= 0 &&
                        localPosition.dx <= chartWidth &&
                        localPosition.dy >= 0 &&
                        localPosition.dy <= chartHeight) {
                      // Find closest data point
                      final segmentWidth =
                          chartWidth / (xValuesList.length - 1);
                      final xIndex = (localPosition.dx / segmentWidth).round();

                      if (xIndex >= 0 && xIndex < xValuesList.length) {
                        setState(() {
                          _hoveredPointIndex = xIndex;
                        });
                      }
                    }
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredPointIndex = null;
                      _hoveredSeriesIndex = null;
                      _hideTooltip();
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        key: _chartKey,
                        size: Size(
                          availableWidth - 50,
                          availableHeight - (config.title != null ? 70 : 40),
                        ),
                        painter: AreaChartPainter(
                          seriesDataList: seriesDataList,
                          xValues: xValuesList,
                          minY: minY,
                          maxY: maxY,
                          showGrid: config.grid?.show ?? true,
                          curveSmoothness: config.curveSmoothness,
                          showDots: config.showDots,
                          dotSize: config.dotSize,
                          hoveredPointIndex: _hoveredPointIndex,
                          hoveredSeriesIndex: _hoveredSeriesIndex,
                          animationValue: _animationController.value,
                          gradientArea: config.gradientArea,
                          areaOpacity: config.areaOpacity,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Legend if provided
            if (config.legend != null && config.legend!.show != false)
              Positioned(
                bottom: 0,
                left: 40,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: seriesDataList.map((series) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: series.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            series.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  List<SeriesData> _extractSeriesData(AreaChartConfig config) {
    final List<SeriesData> result = [];

    for (int i = 0; i < config.series.length; i++) {
      final series = config.series[i];
      final List<SeriesPoint> points = [];

      if (series.data != null) {
        for (final item in series.data!) {
          if (item is Map<String, dynamic> &&
              item.containsKey('x') &&
              item.containsKey('y')) {
            points.add(SeriesPoint(
              x: item['x'],
              y: (item['y'] as num).toDouble(),
              color: getRandomColor(),
              seriesName: series.name ?? 'Series ${i + 1}',
            ));
          } else if (item is List && item.length >= 2) {
            points.add(SeriesPoint(
              x: item[0],
              y: (item[1] as num).toDouble(),
              color: getRandomColor(),
              seriesName: series.name ?? 'Series ${i + 1}',
            ));
          }
        }
      }

      // Sort points by x value
      points.sort((a, b) {
        if (a.x is num && b.x is num) {
          return (a.x as num).compareTo(b.x as num);
        } else {
          return a.x.toString().compareTo(b.x.toString());
        }
      });

      result.add(SeriesData(
        name: series.name ?? 'Series ${i + 1}',
        points: points,
        color: getRandomColor(),
      ));
    }

    return result;
  }
}

class AreaChartPainter extends CustomPainter {
  final List<SeriesData> seriesDataList;
  final List<dynamic> xValues;
  final double minY;
  final double maxY;
  final bool showGrid;
  final double curveSmoothness;
  final bool showDots;
  final double dotSize;
  final int? hoveredPointIndex;
  final int? hoveredSeriesIndex;
  final double animationValue;
  final bool gradientArea;
  final double areaOpacity;

  AreaChartPainter({
    required this.seriesDataList,
    required this.xValues,
    required this.minY,
    required this.maxY,
    required this.showGrid,
    required this.curveSmoothness,
    required this.showDots,
    required this.dotSize,
    this.hoveredPointIndex,
    this.hoveredSeriesIndex,
    required this.animationValue,
    required this.gradientArea,
    required this.areaOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartWidth = size.width;
    final double chartHeight = size.height;
    final double horizontalPadding = 10;
    final double effectiveWidth = chartWidth - 2 * horizontalPadding;

    final segmentWidth = effectiveWidth / (xValues.length - 1);

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, size, xValues.length);
    }

    // Draw axes
    _drawAxes(canvas, size);

    // Draw X axis labels
    _drawXAxisLabels(canvas, size, xValues);

    // Draw Y axis labels
    _drawYAxisLabels(canvas, size);

    // Draw each series (from back to front)
    for (int i = seriesDataList.length - 1; i >= 0; i--) {
      final seriesData = seriesDataList[i];
      _drawSeries(canvas, size, seriesData, horizontalPadding, segmentWidth, i);
    }
  }

  void _drawGrid(Canvas canvas, Size size, int xCount) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw vertical grid lines
    for (int i = 0; i < xCount; i++) {
      final x = 10 + i * (size.width - 20) / (xCount - 1);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 20),
        gridPaint,
      );
    }

    // Draw horizontal grid lines
    final yCount = 5;
    for (int i = 0; i <= yCount; i++) {
      final y = i * (size.height - 20) / yCount;
      canvas.drawLine(
        Offset(10, y),
        Offset(size.width - 10, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // X axis
    canvas.drawLine(
      Offset(10, size.height - 20),
      Offset(size.width - 10, size.height - 20),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(10, 0),
      Offset(10, size.height - 20),
      axisPaint,
    );
  }

  void _drawXAxisLabels(Canvas canvas, Size size, List<dynamic> xValues) {
    final textStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 10,
    );

    final effectiveWidth = size.width - 20;

    // Only show a subset of labels to avoid overcrowding
    int stepSize = (xValues.length / 5).ceil();
    stepSize = math.max(1, stepSize);

    for (int i = 0; i < xValues.length; i += stepSize) {
      final x = 10 + i * effectiveWidth / (xValues.length - 1);
      final labelValue = xValues[i].toString();

      final textSpan = TextSpan(
        text: labelValue,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: 50,
      );

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }
  }

  void _drawYAxisLabels(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 10,
    );

    final yCount = 5;
    final yRange = maxY - minY;

    for (int i = 0; i <= yCount; i++) {
      final y = size.height - 20 - i * (size.height - 20) / yCount;
      final labelValue = (minY + i * yRange / yCount).toStringAsFixed(1);

      final textSpan = TextSpan(
        text: labelValue,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: 40,
      );

      textPainter.paint(
        canvas,
        Offset(5 - textPainter.width, y - textPainter.height / 2),
      );
    }
  }

  void _drawSeries(Canvas canvas, Size size, SeriesData seriesData,
      double padding, double segmentWidth, int seriesIndex) {
    if (seriesData.points.isEmpty) return;

    final linePaint = Paint()
      ..color = seriesData.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Create path for the line
    final path = Path();
    final areaPath = Path();

    // Get scaled points
    final scaledPoints = _getScaledPoints(seriesData.points, size, padding);

    if (scaledPoints.isEmpty) return;

    // Start from the first point
    path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    areaPath.moveTo(scaledPoints[0].dx, size.height - 20); // Start from base
    areaPath.lineTo(
        scaledPoints[0].dx, scaledPoints[0].dy); // Line up to first point

    if (curveSmoothness > 0 && scaledPoints.length > 1) {
      // Draw curved path
      for (int i = 0; i < scaledPoints.length - 1; i++) {
        final current = scaledPoints[i];
        final next = scaledPoints[i + 1];
        final distance = (next.dx - current.dx) * curveSmoothness;

        final cp1 = Offset(current.dx + distance, current.dy);
        final cp2 = Offset(next.dx - distance, next.dy);

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
        areaPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
      }
    } else {
      // Draw straight lines between points
      for (int i = 1; i < scaledPoints.length; i++) {
        path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
        areaPath.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
      }
    }

    // Complete the area path by drawing back to the axis
    areaPath.lineTo(scaledPoints.last.dx, size.height - 20);
    areaPath.lineTo(scaledPoints.first.dx, size.height - 20);
    areaPath.close();

    // Apply animation to reveal the path gradually
    final pathMetrics = path.computeMetrics().first;
    final animatedPath =
        pathMetrics.extractPath(0.0, pathMetrics.length * animationValue);

    // Draw area
    final areaPaint = Paint()..style = PaintingStyle.fill;

    if (gradientArea) {
      areaPaint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          seriesData.color.withOpacity(0.05),
          seriesData.color.withOpacity(areaOpacity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      areaPaint.color = seriesData.color.withOpacity(areaOpacity);
    }

    // Draw animated area
    final animatedAreaPath = Path()
      ..moveTo(scaledPoints.first.dx, size.height - 20)
      ..lineTo(scaledPoints.first.dx, scaledPoints.first.dy);

    for (int i = 0; i < animationValue * scaledPoints.length; i++) {
      if (i + 1 < scaledPoints.length) {
        final current = scaledPoints[i];
        final next = scaledPoints[i + 1];
        final distance = (next.dx - current.dx) * curveSmoothness;

        final cp1 = Offset(current.dx + distance, current.dy);
        final cp2 = Offset(next.dx - distance, next.dy);

        animatedAreaPath.cubicTo(
            cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
      }
    }

    if (animationValue < 1.0) {
      final lastIndex = (animationValue * scaledPoints.length).floor();
      if (lastIndex < scaledPoints.length - 1) {
        final current = scaledPoints[lastIndex];
        final next = scaledPoints[lastIndex + 1];
        final fraction = (animationValue * scaledPoints.length) - lastIndex;

        final lastPoint = Offset(
          current.dx + (next.dx - current.dx) * fraction,
          current.dy + (next.dy - current.dy) * fraction,
        );

        animatedAreaPath.lineTo(lastPoint.dx, lastPoint.dy);
        animatedAreaPath.lineTo(lastPoint.dx, size.height - 20);
      } else {
        animatedAreaPath.lineTo(scaledPoints.last.dx, scaledPoints.last.dy);
        animatedAreaPath.lineTo(scaledPoints.last.dx, size.height - 20);
      }
    } else {
      animatedAreaPath.lineTo(scaledPoints.last.dx, scaledPoints.last.dy);
      animatedAreaPath.lineTo(scaledPoints.last.dx, size.height - 20);
    }

    animatedAreaPath.close();

    canvas.drawPath(animatedAreaPath, areaPaint);
    canvas.drawPath(animatedPath, linePaint);

    // Draw dots if enabled
    if (showDots && animationValue > 0.3) {
      final dotPaint = Paint()
        ..color = seriesData.color
        ..style = PaintingStyle.fill;

      final outlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 0; i < scaledPoints.length * animationValue; i++) {
        // Determine if this point is hovered
        bool isHovered = hoveredPointIndex ==
                xValues.indexOf(seriesData.points[i].x) &&
            (hoveredSeriesIndex == null || hoveredSeriesIndex == seriesIndex);

        final dotRadius = isHovered ? dotSize * 1.5 : dotSize;

        canvas.drawCircle(scaledPoints[i], dotRadius, dotPaint);
        canvas.drawCircle(scaledPoints[i], dotRadius, outlinePaint);
      }
    }
  }

  List<Offset> _getScaledPoints(
      List<SeriesPoint> points, Size size, double padding) {
    final List<Offset> scaledPoints = [];
    final chartHeight = size.height - 20; // Account for bottom padding
    final effectiveWidth = size.width - 2 * padding;

    for (final point in points) {
      final x = padding +
          xValues.indexOf(point.x) * effectiveWidth / (xValues.length - 1);
      final y = chartHeight - (point.y - minY) * chartHeight / (maxY - minY);

      scaledPoints.add(Offset(x, y));
    }

    return scaledPoints;
  }

  @override
  bool shouldRepaint(covariant AreaChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.hoveredPointIndex != hoveredPointIndex ||
        oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex;
  }
}

class SeriesPoint {
  final dynamic x;
  final double y;
  final Color color;
  final String seriesName;

  SeriesPoint({
    required this.x,
    required this.y,
    required this.color,
    required this.seriesName,
  });
}

class SeriesData {
  final String name;
  final List<SeriesPoint> points;
  final Color color;

  SeriesData({
    required this.name,
    required this.points,
    required this.color,
  });
}
