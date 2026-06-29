import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';
import 'dart:math' as math;

import 'heatmap_config.dart';

class HeatmapChartWidget extends StatefulWidget {
  final HeatmapChartConfig config;

  const HeatmapChartWidget({
    super.key,
    required this.config,
  });

  @override
  State<HeatmapChartWidget> createState() => _HeatmapChartWidgetState();
}

class _HeatmapChartWidgetState extends State<HeatmapChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  OverlayEntry? _tooltipOverlay;
  int? _hoveredDataIndex;
  final GlobalKey _heatmapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  void _showTooltip(
      BuildContext context, Offset position, HeatmapDataPoint dataPoint) {
    _hideTooltip();

    _tooltipOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy - 60,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.black87,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${dataPoint.x}, ${dataPoint.y}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Value: ${dataPoint.value.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
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
    final List<HeatmapDataPoint> data = _extractHeatmapData(config);

    if (data.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    // Determine min and max values if not provided
    final double minValue =
        config.minValue ?? data.map((e) => e.value).reduce(math.min);
    final double maxValue =
        config.maxValue ?? data.map((e) => e.value).reduce(math.max);

    // Get unique X and Y values to determine grid size
    final List<dynamic> xValues = data.map((e) => e.x).toSet().toList();
    final List<dynamic> yValues = data.map((e) => e.y).toSet().toList();

    xValues.sort();
    yValues.sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final cellWidth = availableWidth / xValues.length;
        final cellHeight = availableHeight / yValues.length;

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

            // Main heatmap grid
            Padding(
              padding: EdgeInsets.only(
                top: config.title != null ? 40 : 10,
                bottom: 30,
                left: 40,
                right: 10,
              ),
              child: MouseRegion(
                onExit: (_) {
                  setState(() {
                    _hoveredDataIndex = null;
                    _hideTooltip();
                  });
                },
                child: GestureDetector(
                  onTapUp: config.enableTooltip
                      ? (details) {
                          final RenderBox box = _heatmapKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final localPosition =
                              box.globalToLocal(details.globalPosition);

                          // Calculate which cell was tapped
                          final int xIndex =
                              (localPosition.dx / cellWidth).floor();
                          final int yIndex =
                              (localPosition.dy / cellHeight).floor();

                          if (xIndex >= 0 &&
                              xIndex < xValues.length &&
                              yIndex >= 0 &&
                              yIndex < yValues.length) {
                            final dynamic xVal = xValues[xIndex];
                            final dynamic yVal = yValues[
                                yValues.length - 1 - yIndex]; // Invert Y axis

                            // Find the corresponding data point
                            final dataPoint = data.firstWhere(
                              (d) => d.x == xVal && d.y == yVal,
                              orElse: () =>
                                  HeatmapDataPoint(x: xVal, y: yVal, value: 0),
                            );

                            _showTooltip(
                                context, details.globalPosition, dataPoint);
                          }
                        }
                      : null,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        key: _heatmapKey,
                        size: Size(
                          availableWidth - 50,
                          availableHeight - (config.title != null ? 70 : 40),
                        ),
                        painter: HeatmapPainter(
                          data: data,
                          xValues: xValues,
                          yValues: yValues,
                          minValue: minValue,
                          maxValue: maxValue,
                          minColor: config.minColor ?? Colors.blue.shade100,
                          maxColor: config.maxColor ?? Colors.red,
                          showLabels: config.showLabels,
                          hoveredDataIndex: _hoveredDataIndex,
                          animationValue: _animationController.value,
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
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            config.minColor ?? Colors.blue.shade100,
                            config.maxColor ?? Colors.red,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '${minValue.toStringAsFixed(1)} - ${maxValue.toStringAsFixed(1)}'),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  List<HeatmapDataPoint> _extractHeatmapData(HeatmapChartConfig config) {
    final List<HeatmapDataPoint> result = [];

    for (final series in config.series) {
      if (series.data != null) {
        for (final item in series.data!) {
          if (item is Map<String, dynamic> &&
              item.containsKey('x') &&
              item.containsKey('y') &&
              item.containsKey('value')) {
            result.add(HeatmapDataPoint(
              x: item['x'],
              y: item['y'],
              value: (item['value'] as num).toDouble(),
            ));
          } else if (item is List && item.length >= 3) {
            result.add(HeatmapDataPoint(
              x: item[0],
              y: item[1],
              value: (item[2] as num).toDouble(),
            ));
          }
        }
      }
    }

    return result;
  }
}

class HeatmapPainter extends CustomPainter {
  final List<HeatmapDataPoint> data;
  final List<dynamic> xValues;
  final List<dynamic> yValues;
  final double minValue;
  final double maxValue;
  final Color minColor;
  final Color maxColor;
  final bool showLabels;
  final int? hoveredDataIndex;
  final double animationValue;

  HeatmapPainter({
    required this.data,
    required this.xValues,
    required this.yValues,
    required this.minValue,
    required this.maxValue,
    required this.minColor,
    required this.maxColor,
    required this.showLabels,
    this.hoveredDataIndex,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / xValues.length;
    final cellHeight = size.height / yValues.length;

    // Draw axis lines
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw vertical grid lines
    for (int i = 0; i <= xValues.length; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        axisPaint,
      );
    }

    // Draw horizontal grid lines
    for (int i = 0; i <= yValues.length; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        axisPaint,
      );
    }

    // Draw X axis labels
    if (showLabels) {
      final textStyle = TextStyle(
        color: Colors.black87,
        fontSize: 10,
      );

      for (int i = 0; i < xValues.length; i++) {
        final textSpan = TextSpan(
          text: xValues[i].toString(),
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(
          minWidth: 0,
          maxWidth: cellWidth,
        );

        final x = i * cellWidth + (cellWidth - textPainter.width) / 2;
        final y = size.height + 5;

        textPainter.paint(canvas, Offset(x, y));
      }

      // Draw Y axis labels
      for (int i = 0; i < yValues.length; i++) {
        final textSpan = TextSpan(
          text: yValues[i].toString(),
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

        final x = -textPainter.width - 5;
        final y = i * cellHeight + (cellHeight - textPainter.height) / 2;

        textPainter.paint(canvas, Offset(x, y));
      }
    }

    // Calculate color for each cell
    for (int x = 0; x < xValues.length; x++) {
      for (int y = 0; y < yValues.length; y++) {
        final xVal = xValues[x];
        final yVal = yValues[yValues.length - 1 - y]; // Invert Y axis

        // Find data point for this cell
        final dataPoint = data.firstWhere(
          (d) => d.x == xVal && d.y == yVal,
          orElse: () => HeatmapDataPoint(x: xVal, y: yVal, value: 0),
        );

        // Calculate color based on value
        final double normalizedValue =
            (dataPoint.value - minValue) / (maxValue - minValue);
        final color = Color.lerp(
          minColor,
          maxColor,
          normalizedValue.clamp(0.0, 1.0),
        )!
            .withOpacity(animationValue);

        final cellRect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        // Draw cell
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        // Add rounded corners for a modern look
        final rrect = RRect.fromRectAndRadius(
          cellRect.deflate(1), // Small gap between cells
          Radius.circular(2),
        );

        canvas.drawRRect(rrect, paint);

        // Draw value text if showLabels is true
        if (showLabels) {
          final textValue = dataPoint.value.toStringAsFixed(1);
          final valueTextSpan = TextSpan(
            text: textValue,
            style: TextStyle(
              color: _getContrastColor(color),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          );

          final textPainter = TextPainter(
            text: valueTextSpan,
            textDirection: TextDirection.ltr,
          );

          textPainter.layout(
            minWidth: 0,
            maxWidth: cellWidth,
          );

          final textX = x * cellWidth + (cellWidth - textPainter.width) / 2;
          final textY = y * cellHeight + (cellHeight - textPainter.height) / 2;

          textPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use black or white text
    final double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.hoveredDataIndex != hoveredDataIndex;
  }
}

class HeatmapDataPoint {
  final dynamic x;
  final dynamic y;
  final double value;

  HeatmapDataPoint({
    required this.x,
    required this.y,
    required this.value,
  });
}

// Example of how to use the heatmap chart
