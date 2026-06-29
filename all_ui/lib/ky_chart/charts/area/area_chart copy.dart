import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';
import 'dart:math' as math;

import 'area_chart_config.dart';
import 'area_chart_painter.dart';
import 'series_point.dart';

class AreaChartWidget extends StatefulWidget {
  final AreaChartConfig config;

  const AreaChartWidget({super.key, required this.config});

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
  final LayerLink _tooltipLayerLink = LayerLink();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )
      ..forward().then((_) {
        // Animation completed
        _animationController.stop();
      });
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
    if (mounted) {
      setState(() {
        _hoveredPointIndex = null;
        _hoveredSeriesIndex = null;
      });
    }
  }

  void _showTooltip(
    BuildContext context,
    Offset position,
    dynamic x,
    List<SeriesPoint> points,
    int pointIndex,
  ) {
    _hideTooltip();

    // Only show tooltip if there are valid points with non-zero values
    final validPoints = points.where((point) => point.y > 0).toList();
    if (validPoints.isEmpty) return;

    _tooltipOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 60, // Center the tooltip
          top: position.dy - 100, // Position above the point
          child: CompositedTransformFollower(
            link: _tooltipLayerLink,
            offset: Offset(-60, -100),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.85),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    ...validPoints.map((point) {
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
          ),
        );
      },
    );

    Overlay.of(context).insert(_tooltipOverlay!);

    if (mounted) {
      setState(() {
        _hoveredPointIndex = pointIndex;
      });
    }
  }

  int _findClosestPointIndex(
    Offset localPosition,
    double chartWidth,
    int totalPoints,
  ) {
    final segmentWidth = chartWidth / (totalPoints - 1);
    final xIndex = (localPosition.dx / segmentWidth).round();
    return xIndex.clamp(0, totalPoints - 1);
  }

  void _handleInteraction(
    Offset localPosition,
    Size chartSize,
    GlobalKey chartKey,
  ) {
    final chartWidth = chartSize.width;
    final chartHeight = chartSize.height;

    if (localPosition.dx >= 0 &&
        localPosition.dx <= chartWidth &&
        localPosition.dy >= 0 &&
        localPosition.dy <= chartHeight) {
      final xValues = _extractAllXValues(widget.config);
      if (xValues.isEmpty) return; // Safety check

      final closestIndex = _findClosestPointIndex(
        localPosition,
        chartWidth,
        xValues.length,
      );
      final x = xValues[closestIndex];

      // Get all y values at this x from different series
      final List<SeriesPoint> points = [];
      final seriesDataList = _extractSeriesData(widget.config);

      for (var i = 0; i < seriesDataList.length; i++) {
        final seriesData = seriesDataList[i];

        // Find the point with matching x value, or create a zero point if not found
        SeriesPoint point;
        try {
          point = seriesData.points.firstWhere(
            (p) => p.x == x,
            orElse:
                () => SeriesPoint(
                  x: x,
                  y: 0,
                  color: seriesData.color,
                  seriesName: seriesData.name,
                ),
          );
        } catch (e) {
          // Fallback if firstWhere fails
          point = SeriesPoint(
            x: x,
            y: 0,
            color: seriesData.color,
            seriesName: seriesData.name,
          );
        }
        points.add(point);
      }

      final RenderBox box =
          chartKey.currentContext!.findRenderObject() as RenderBox;
      final globalPosition = box.localToGlobal(localPosition);

      _showTooltip(context, globalPosition, x, points, closestIndex);
    }
  }

  List<dynamic> _extractAllXValues(AreaChartConfig config) {
    final Set<dynamic> allXValues = {};
    final seriesDataList = _extractSeriesData(config);

    for (var seriesData in seriesDataList) {
      allXValues.addAll(seriesData.points.map((p) => p.x));
    }

    return allXValues.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final seriesDataList = _extractSeriesData(config);
    final xValues = _extractAllXValues(config);

    if (seriesDataList.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

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
              child: CompositedTransformTarget(
                link: _tooltipLayerLink,
                child: GestureDetector(
                  onTapDown:
                      config.tooltip?.show != false
                          ? (details) {
                            final RenderBox box =
                                _chartKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final localPosition = box.globalToLocal(
                              details.globalPosition,
                            );
                            _handleInteraction(
                              localPosition,
                              Size(
                                availableWidth - 50,
                                availableHeight -
                                    (config.title != null ? 70 : 40),
                              ),
                              _chartKey,
                            );
                          }
                          : null,
                  onTapCancel: () {
                    if (!_isDragging) {
                      _hideTooltip();
                    }
                  },
                  onHorizontalDragStart: (details) {
                    _isDragging = true;
                  },
                  onHorizontalDragUpdate:
                      config.tooltip?.show != false
                          ? (details) {
                            final RenderBox box =
                                _chartKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final localPosition = box.globalToLocal(
                              details.globalPosition,
                            );
                            _handleInteraction(
                              localPosition,
                              Size(
                                availableWidth - 50,
                                availableHeight -
                                    (config.title != null ? 70 : 40),
                              ),
                              _chartKey,
                            );
                          }
                          : null,
                  onHorizontalDragEnd: (details) {
                    _isDragging = false;
                    // Keep tooltip visible after drag for better UX
                  },
                  onPanEnd: (details) {
                    _isDragging = false;
                  },
                  child: MouseRegion(
                    onHover:
                        config.tooltip?.show != false
                            ? (event) {
                              final RenderBox box =
                                  _chartKey.currentContext!.findRenderObject()
                                      as RenderBox;
                              final localPosition = box.globalToLocal(
                                event.position,
                              );
                              _handleInteraction(
                                localPosition,
                                Size(
                                  availableWidth - 50,
                                  availableHeight -
                                      (config.title != null ? 70 : 40),
                                ),
                                _chartKey,
                              );
                            }
                            : null,
                    onExit: (_) {
                      if (!_isDragging) {
                        _hideTooltip();
                      }
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
                            xValues: xValues,
                            minY: 0,
                            maxY:
                                config.maxY > 0
                                    ? config.maxY
                                    : widget.config.getMaxSeriesValue() * 1.1,
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
            ),

            // Legend if provided
            if (config.legend != null && config.legend!.show != false)
              Positioned(
                bottom: 0,
                left: 40,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      seriesDataList.map((series) {
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

    // Use predefined colors that are definitely visible
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green];

    for (int i = 0; i < config.series.length; i++) {
      final series = config.series[i];
      final List<SeriesPoint> points = [];

      print('Processing series ${i + 1}: ${series.name}');

      if (series.data != null) {
        for (final item in series.data!) {
          if (item is Map<String, dynamic> &&
              item.containsKey('x') &&
              item.containsKey('y')) {
            final x = item['x'];
            final y = (item['y'] as num).toDouble();

            points.add(
              SeriesPoint(
                x: x,
                y: y,
                color: colors[i % colors.length],
                seriesName: series.name ?? 'Series ${i + 1}',
              ),
            );

            print('Added point: $x, $y');
          }
        }
      }

      // Sort points by x value
      points.sort((a, b) => a.x.toString().compareTo(b.x.toString()));

      result.add(
        SeriesData(
          name: series.name ?? 'Series ${i + 1}',
          points: points,
          color: colors[i % colors.length],
        ),
      );

      print('Series ${i + 1} has ${points.length} points');
    }

    print('Total series extracted: ${result.length}');
    return result;
  }
}
