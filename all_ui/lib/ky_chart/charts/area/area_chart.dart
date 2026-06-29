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
      if (xValues.isEmpty) return;

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

        // Find the point with matching x value
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

  int _findClosestPointIndex(
    Offset localPosition,
    double chartWidth,
    int totalPoints,
  ) {
    final segmentWidth = chartWidth / (totalPoints - 1);
    final xIndex = (localPosition.dx / segmentWidth).round();
    return xIndex.clamp(0, totalPoints - 1);
  }

  void _showTooltip(
    BuildContext context,
    Offset position,
    dynamic x,
    List<SeriesPoint> points,
    int pointIndex,
  ) {
    _hideTooltip();

    // Only show tooltip if there are valid points
    final validPoints = points.where((point) => point.y > 0).toList();
    if (validPoints.isEmpty) return;

    _tooltipOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 60,
          top: position.dy - 100,
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
                            '${point.seriesName}: ${point.y.toStringAsFixed(0)}',
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

    if (mounted) {
      setState(() {
        _hoveredPointIndex = pointIndex;
      });
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

    // Calculate proper minY and maxY
    double minY = 0.0;
    double maxY = 0.0;

    if (seriesDataList.isNotEmpty) {
      for (var series in seriesDataList) {
        for (var point in series.points) {
          if (point.y > maxY) maxY = point.y;
        }
      }
      minY = 0.0;
      maxY = maxY * 1.1;
    } else {
      minY = 0.0;
      maxY = 100.0;
    }

    return Container(
      height: 400,
      width: double.infinity,
      color: Colors.white, // Change to white background
      child: GestureDetector(
        onTapDown: (details) {
          _handleInteraction(details.localPosition, Size(1096, 400), _chartKey);
        },
        onHorizontalDragUpdate: (details) {
          _handleInteraction(details.localPosition, Size(1096, 400), _chartKey);
        },
        child: MouseRegion(
          onHover: (event) {
            _handleInteraction(event.localPosition, Size(1096, 400), _chartKey);
          },
          onExit: (_) {
            _hideTooltip();
          },
          child: CustomPaint(
            key: _chartKey,
            painter: AreaChartPainter(
              seriesDataList: seriesDataList,
              xValues: xValues,
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
          ),
        ),
      ),
    );
  }

  List<SeriesData> _extractSeriesData(AreaChartConfig config) {
    final List<SeriesData> result = [];

    final List<Color> colors = [Colors.blue, Colors.red, Colors.green];

    // Define month order for proper sorting
    final monthOrder = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    // First, extract all X values to maintain consistent order
    final allXValues = <String>{};
    for (final series in config.series) {
      if (series.data != null) {
        for (final item in series.data!) {
          if (item is Map<String, dynamic> && item.containsKey('x')) {
            allXValues.add(item['x'].toString());
          }
        }
      }
    }

    // Sort X values by month order
    final sortedXValues =
        allXValues.toList()..sort((a, b) {
          final aOrder = monthOrder[a] ?? 0;
          final bOrder = monthOrder[b] ?? 0;
          return aOrder.compareTo(bOrder);
        });

    print('Sorted X values: $sortedXValues');

    for (int i = 0; i < config.series.length; i++) {
      final series = config.series[i];
      final List<SeriesPoint> points = [];

      print('Processing series ${i + 1}: ${series.name}');

      if (series.data != null) {
        // Create a map for quick lookup
        final dataMap = <String, double>{};
        for (final item in series.data!) {
          if (item is Map<String, dynamic> &&
              item.containsKey('x') &&
              item.containsKey('y')) {
            dataMap[item['x'].toString()] = (item['y'] as num).toDouble();
          }
        }

        // Create points in sorted X order
        for (final xValue in sortedXValues) {
          final y = dataMap[xValue] ?? 0.0;
          points.add(
            SeriesPoint(
              x: xValue,
              y: y,
              color: colors[i % colors.length],
              seriesName: series.name ?? 'Series ${i + 1}',
            ),
          );
        }
      }

      result.add(
        SeriesData(
          name: series.name ?? 'Series ${i + 1}',
          points: points,
          color: colors[i % colors.length],
        ),
      );

      print('Series ${i + 1} has ${points.length} points');
    }

    return result;
  }
}
