import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'line_sample_3_models.dart';
import 'line_sample_3_painter.dart';

// Main chart widget
class ModernLineChart extends StatefulWidget {
  final List<ChartSeries> series;
  final String? title;
  final String? xAxisLabel;
  final String? yAxisLabel;
  final bool showGrid;
  final bool showAxes;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color gridColor;
  final Color axisColor;
  final TextStyle? titleStyle;
  final TextStyle? axisLabelStyle;
  final Function(String x, String y)? tooltipFormatter;

  const ModernLineChart({
    super.key,
    required this.series,
    this.title,
    this.xAxisLabel,
    this.yAxisLabel,
    this.showGrid = true,
    this.showAxes = true,
    this.padding = const EdgeInsets.all(40),
    this.backgroundColor = Colors.white,
    this.gridColor = const Color(0xFFE5E7EB),
    this.axisColor = const Color(0xFF6B7280),
    this.titleStyle,
    this.axisLabelStyle,
    this.tooltipFormatter,
  });

  @override
  State<ModernLineChart> createState() => _ModernLineChartState();
}

class _ModernLineChartState extends State<ModernLineChart>
    with TickerProviderStateMixin {
  TooltipData? _tooltipData;
  Offset? _hoverPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title!,
                style:
                    widget.titleStyle ??
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                MouseRegion(
                  onHover: _onHover,
                  onExit: (_) => _clearTooltip(),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LineChartPainter(
                          series: widget.series,
                          showGrid: widget.showGrid,
                          showAxes: widget.showAxes,
                          padding: widget.padding,
                          gridColor: widget.gridColor,
                          axisColor: widget.axisColor,
                          hoverPosition: _hoverPosition,
                          animationValue: _animation.value,
                          titleHeight: 20,
                          legendHeight: 60,
                        ),
                        child: Container(),
                      );
                    },
                  ),
                ),
                if (_tooltipData != null) _buildTooltip(),
              ],
            ),
          ),
          if (widget.series.length > 1) _buildLegend(),
        ],
      ),
    );
  }

  void _onHover(PointerHoverEvent event) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);

    setState(() {
      _hoverPosition = localPosition;
      _tooltipData = _findNearestPoint(localPosition);
    });
  }

  void _clearTooltip() {
    setState(() {
      _tooltipData = null;
      _hoverPosition = null;
    });
  }

  TooltipData? _findNearestPoint(Offset position) {
    if (widget.series.isEmpty || context.size == null) return null;

    // Calculate chart area (same as in painter)
    final titleHeight = widget.title != null ? 60.0 : 0.0;
    final legendHeight = widget.series.length > 1 ? 60.0 : 0.0;

    final chartRect = Rect.fromLTWH(
      widget.padding.left,
      widget.padding.top + titleHeight,
      context.size!.width - widget.padding.horizontal,
      context.size!.height -
          widget.padding.vertical -
          titleHeight -
          legendHeight,
    );

    if (!chartRect.contains(position)) return null;

    // Find data bounds (same calculation as painter)
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (final series in widget.series) {
      for (final point in series.points) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
      }
    }

    // Add same padding as painter
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.05;
    maxX += xRange * 0.05;
    minY -= yRange * 0.05;
    maxY += yRange * 0.05;

    ChartSeries? nearestSeries;
    ChartPoint? nearestPoint;
    double minDistance = double.infinity;
    Offset? nearestScreenPosition;

    for (final series in widget.series) {
      for (final point in series.points) {
        // Use exact same coordinate calculation as painter
        final x =
            chartRect.left + (point.x - minX) / (maxX - minX) * chartRect.width;
        final y =
            chartRect.bottom -
            (point.y - minY) / (maxY - minY) * chartRect.height;

        final screenPoint = Offset(x, y);
        final distance = (position - screenPoint).distance;

        if (distance < minDistance && distance < 30) {
          minDistance = distance;
          nearestSeries = series;
          nearestPoint = point;
          nearestScreenPosition = screenPoint;
        }
      }
    }

    if (nearestPoint != null &&
        nearestSeries != null &&
        nearestScreenPosition != null) {
      return TooltipData(
        position: nearestScreenPosition,
        point: nearestPoint,
        series: nearestSeries,
        formattedX: nearestPoint.x.toStringAsFixed(1),
        formattedY: nearestPoint.y.toStringAsFixed(2),
      );
    }

    return null;
  }

  Widget _buildTooltip() {
    final screenSize = MediaQuery.of(context).size;
    double left = _tooltipData!.position.dx + 15;
    double top = _tooltipData!.position.dy - 80;

    // Keep tooltip within screen bounds
    if (left + 120 > screenSize.width) {
      left = _tooltipData!.position.dx - 135;
    }
    if (top < 0) {
      top = _tooltipData!.position.dy + 15;
    }

    return Positioned(
      left: left,
      top: top,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _tooltipData!.series.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _tooltipData!.series.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'X: ${_tooltipData!.formattedX}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              'Y: ${_tooltipData!.formattedY}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 20,
        children: widget.series.map((series) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: series.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                series.name,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
