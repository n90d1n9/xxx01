import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import 'grid_painter.dart';
import 'scatter_chart_painter.dart';
import 'scatter_config.dart';

class ScatterBarChartWidget extends StatefulWidget {
  final ScatterChartConfig config;
  final double height;
  final double width;
  final bool isResponsive;

  const ScatterBarChartWidget({
    super.key,
    required this.config,
    this.height = 400,
    this.width = double.infinity,
    this.isResponsive = true,
  });

  @override
  State<ScatterBarChartWidget> createState() => _ScatterBarChartWidgetState();
}

class _ScatterBarChartWidgetState extends State<ScatterBarChartWidget> {
  late int selectedPointIndex;
  late Offset? tooltipPosition;
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedPointIndex = -1;
    tooltipPosition = null;
  }

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.config.title != null) ...[
                  Text(
                    widget.config.title!.text!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.config.legend != null) _buildLegend(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 16, bottom: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  print(widget.config.series[0].data);

                  return Stack(
                    children: [
                      // Grid background
                      _buildGridLines(constraints),

                      // Scatter plot
                      GestureDetector(
                        onTapUp: (details) {
                          _handleTapUp(details, constraints);
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            tooltipPosition = null;
                            selectedPointIndex = -1;
                          });
                        },
                        child: CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: ScatterChartPainter(
                            config: widget.config,
                            selectedPointIndex: selectedPointIndex,
                          ),
                        ),
                      ),

                      // Y Axis
                      Positioned(
                        left: -40,
                        top: 0,
                        bottom: 0,
                        width: 40,
                        child: _buildYAxis(constraints),
                      ),

                      // X Axis
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -40,
                        height: 40,
                        child: _buildXAxis(constraints),
                      ),

                      // Tooltip
                      if (tooltipPosition != null && selectedPointIndex >= 0)
                        _buildTooltip(tooltipPosition!, selectedPointIndex),
                    ],
                  );
                },
              ),
            ),
          ),

          // Toolbar if available
          if (widget.config.toolbox != null) _buildToolbox(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.config.series.map((series) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: stringToColor(series.itemStyle!.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              series.name ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGridLines(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: GridPainter(
        config: widget.config,
      ),
    );
  }

  Widget _buildYAxis(BoxConstraints constraints) {
    final yRange = widget.config.maxY - widget.config.minY;
    final interval = _calculateAxisInterval(yRange, 5);
    final values = <double>[];

    for (double y = widget.config.minY;
        y <= widget.config.maxY;
        y += interval) {
      values.add(y);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.reversed.map((value) {
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildXAxis(BoxConstraints constraints) {
    final xRange = widget.config.maxX - widget.config.minX;
    final interval = _calculateAxisInterval(xRange, 5);
    final values = <double>[];

    for (double x = widget.config.minX;
        x <= widget.config.maxX;
        x += interval) {
      values.add(x);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTooltip(Offset position, int pointIndex) {
    final seriesIndex = _getSeriesIndexFromPointIndex(pointIndex);
    final dataIndex = _getDataIndexFromPointIndex(pointIndex, seriesIndex);

    if (seriesIndex < 0 || dataIndex < 0) return const SizedBox.shrink();

    final series = widget.config.series[seriesIndex];
    final data = (series.data as List<Map<String, dynamic>>)[dataIndex];

    return Positioned(
      left: position.dx < 100 ? position.dx : position.dx - 100,
      top: position.dy < 70 ? position.dy + 10 : position.dy - 70,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        constraints: const BoxConstraints(
          maxWidth: 150,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              series.name ?? 'Series ${seriesIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'X: ${data['x'].toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Y: ${data['y'].toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            if (data['value'] != null)
              Text(
                'Value: ${data['value'].toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbox() {
    // Implement your toolbox here
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 20),
            onPressed: () {
              // Implement zoom in functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 20),
            onPressed: () {
              // Implement zoom out functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              setState(() {
                selectedPointIndex = -1;
                tooltipPosition = null;
              });
            },
          ),
        ],
      ),
    );
  }

  void _handleTapUp(TapUpDetails details, BoxConstraints constraints) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.globalToLocal(details.globalPosition);

    // Find the closest point
    int closestPointIndex = -1;
    double minDistance = double.infinity;

    int pointIndex = 0;
    for (int seriesIndex = 0;
        seriesIndex < widget.config.series.length;
        seriesIndex++) {
      final series = widget.config.series[seriesIndex];
      if (series.data != null && series.data is List<Map<String, dynamic>>) {
        final data = series.data as List<Map<String, dynamic>>;

        for (int dataIndex = 0; dataIndex < data.length; dataIndex++) {
          final point = data[dataIndex];
          final x = point['x'].toDouble();
          final y = point['y'].toDouble();

          final pixelX = _mapXToPixel(x, constraints.maxWidth);
          final pixelY = _mapYToPixel(y, constraints.maxHeight);

          final dx = offset.dx - pixelX;
          final dy = offset.dy - 40 - pixelY; // Adjust for top padding
          final distance = math.sqrt(dx * dx + dy * dy);

          if (distance < minDistance && distance < 20) {
            // 20 pixels tolerance
            minDistance = distance;
            closestPointIndex = pointIndex;
          }
          pointIndex++;
        }
      }
    }

    setState(() {
      selectedPointIndex = closestPointIndex;
      if (closestPointIndex >= 0) {
        tooltipPosition = offset;
      } else {
        tooltipPosition = null;
      }
    });
  }

  double _mapXToPixel(double x, double width) {
    return (x - widget.config.minX) /
        (widget.config.maxX - widget.config.minX) *
        width;
  }

  double _mapYToPixel(double y, double height) {
    return height -
        (y - widget.config.minY) /
            (widget.config.maxY - widget.config.minY) *
            height;
  }

  int _getSeriesIndexFromPointIndex(int pointIndex) {
    if (pointIndex < 0) return -1;

    int currentIndex = 0;
    for (int i = 0; i < widget.config.series.length; i++) {
      final series = widget.config.series[i];
      if (series.data != null && series.data is List<Map<String, dynamic>>) {
        final dataLength = (series.data as List<Map<String, dynamic>>).length;
        if (pointIndex < currentIndex + dataLength) {
          return i;
        }
        currentIndex += dataLength;
      }
    }
    return -1;
  }

  int _getDataIndexFromPointIndex(int pointIndex, int seriesIndex) {
    if (pointIndex < 0 || seriesIndex < 0) return -1;

    int currentIndex = 0;
    for (int i = 0; i < seriesIndex; i++) {
      final series = widget.config.series[i];
      if (series.data != null && series.data is List<Map<String, dynamic>>) {
        currentIndex += (series.data as List<Map<String, dynamic>>).length;
      }
    }

    return pointIndex - currentIndex;
  }

  double _calculateAxisInterval(double range, int desiredDivisions) {
    // Calculate a nice interval value
    final rawInterval = range / desiredDivisions;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor());
    final normalized = rawInterval / magnitude;

    double niceInterval;
    if (normalized < 1.5) {
      niceInterval = 1;
    } else if (normalized < 3) {
      niceInterval = 2;
    } else if (normalized < 7) {
      niceInterval = 5;
    } else {
      niceInterval = 10;
    }

    return niceInterval * magnitude;
  }
}
