import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ky_chart/model/bar_series.dart';
import 'package:ky_chart/model/line_series.dart';

import '../model/chart_model.dart';

/// Base class for creating custom charts using CustomPainter
abstract class BaseChartPainter extends CustomPainter {
  // Chart configuration properties
  final ChartConfig config;
  
  // Painting properties
  final Paint gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint axisPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  // Padding and margins
  final double horizontalPadding;
  final double verticalPadding;

  // Calculated chart dimensions
  late Rect chartArea;
  late double chartWidth;
  late double chartHeight;

  BaseChartPainter({
    required this.config,
    this.horizontalPadding = 40.0,
    this.verticalPadding = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate chart area
    chartWidth = size.width - (2 * horizontalPadding);
    chartHeight = size.height - (2 * verticalPadding);
    chartArea = Rect.fromLTWH(
      horizontalPadding, 
      verticalPadding, 
      chartWidth, 
      chartHeight
    );

    // Draw background if configured
    _drawBackground(canvas, size);

    // Draw grid if configured
    _drawGrid(canvas);

    // Draw axes
    _drawAxes(canvas);

    // Draw title if configured
    _drawTitle(canvas, size);

    // Draw chart-specific content (to be implemented by subclasses)
    drawChartContent(canvas);
  }

  /// Draw chart-specific content (abstract method to be implemented by subclasses)
  void drawChartContent(Canvas canvas);

  /// Draw chart background
  void _drawBackground(Canvas canvas, Size size) {
    if (config.grid?.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = _parseColor(config.grid!.backgroundColor!)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), 
        backgroundPaint
      );
    }
  }

  /// Draw grid lines
  void _drawGrid(Canvas canvas) {
    if (config.grid?.show ?? true) {
      // Vertical grid lines
      for (int i = 1; i < 10; i++) {
        final x = chartArea.left + (i / 10) * chartWidth;
        canvas.drawLine(
          Offset(x, chartArea.top), 
          Offset(x, chartArea.bottom), 
          gridPaint
        );
      }

      // Horizontal grid lines
      for (int i = 1; i < 10; i++) {
        final y = chartArea.bottom - (i / 10) * chartHeight;
        canvas.drawLine(
          Offset(chartArea.left, y), 
          Offset(chartArea.right, y), 
          gridPaint
        );
      }
    }
  }

  /// Draw x and y axes
  void _drawAxes(Canvas canvas) {
    // X-axis
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom), 
      Offset(chartArea.right, chartArea.bottom), 
      axisPaint
    );

    // Y-axis
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top), 
      Offset(chartArea.left, chartArea.bottom), 
      axisPaint
    );
  }

  /// Draw chart title
  void _drawTitle(Canvas canvas, Size size) {
    if (config.title?.text != null) {
      final textStyle = TextStyle(
        color: _parseColor(config.title?.textStyle?.color ?? Colors.black.toString()),
        fontSize: config.title?.textStyle?.fontSize ?? 16,
        fontWeight: _parseFontWeight(config.title?.textStyle?.fontWeight),
      );

      final textPainter = TextPainter(
        text: TextSpan(text: config.title!.text, style: textStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: size.width);

      // Position the title at the top center
      final titleX = (size.width - textPainter.width) / 2;
      final titleY = 10; // Small padding from the top

      textPainter.paint(canvas, Offset(titleX, titleY as double));
    }
  }

  /// Utility method to parse color from string
  Color _parseColor(String colorStr) {
    try {
      // Remove 'Color(' prefix and ')' suffix if present
      colorStr = colorStr.replaceAll('Color(', '').replaceAll(')', '');
      
      // Parse hex color
      if (colorStr.startsWith('0x') || colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      }
      
      // Handle named colors
      return _getColorFromName(colorStr);
    } catch (e) {
      return Colors.black; // Fallback color
    }
  }

  /// Map color names to Color objects
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      default: return Colors.black;
    }
  }

  /// Parse font weight from string
  FontWeight _parseFontWeight(String? weightStr) {
    if (weightStr == null) return FontWeight.normal;
    
    switch (weightStr.toLowerCase()) {
      case 'bold': return FontWeight.bold;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default: return FontWeight.normal;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Implement more sophisticated change detection if needed
  }

  /// Helper method to scale values to chart dimensions
  double scaleValueToChartHeight(double value, double maxValue) {
    return chartHeight * (value / maxValue);
  }

  /// Helper method to scale values to chart width
  double scaleValueToChartWidth(double value, double maxValue) {
    return chartWidth * (value / maxValue);
  }
}

/// Widget to render the custom chart
class CustomChart extends StatelessWidget {
  final ChartConfig config;
  final CustomPainter chartPainter;

  const CustomChart({
    Key? key, 
    required this.config, 
    required this.chartPainter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: chartPainter,
      child: Container(
        width: double.infinity,
        height: 300, // Default height, can be customized
      ),
    );
  }
}

// Example usage for extending the base chart
class KBarChart2 extends BaseChartPainter {
  KBarChart2({
    required super.config,
    super.horizontalPadding,
    super.verticalPadding,
  });

  @override
  void drawChartContent(Canvas canvas) {
    if (config.series.isEmpty) return;

    final barSeries = config.series.first as BarSeries;
    final data = barSeries.data ?? [];
    
    // Find max value for scaling
    final maxValue = 1000;//data.reduce(max);

    // Paint for bars
    final barPaint = Paint()
      ..color = barSeries.itemStyle?.color ?? Colors.blue
      ..style = PaintingStyle.fill;

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final barWidth = chartWidth / (data.length * 1.5);
      final barHeight = scaleValueToChartHeight(data[i], maxValue as double);
      
      final left = chartArea.left + i * barWidth * 1.5;
      final top = chartArea.bottom - barHeight;

      final barRect = Rect.fromLTWH(left, top, barWidth, barHeight);
      canvas.drawRect(barRect, barPaint);
    }
  }
}

// Example of extending base chart for a line chart
class LineChartPainter extends BaseChartPainter {
  LineChartPainter({
    required super.config,
    super.horizontalPadding,
    super.verticalPadding,
  });

  @override
  void drawChartContent(Canvas canvas) {
    if (config.series.isEmpty) return;

    final lineSeries = config.series.first as LineSeries;
    final data = lineSeries.data ?? [];
    
    // Find max value for scaling
    final maxValue = 1000;//data.reduce(max);

    // Line paint
    final linePaint = Paint()
      ..color = lineSeries.itemStyle?.color ?? Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Create path for line
    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = chartArea.left + (i / (data.length - 1)) * chartWidth;
      final y = chartArea.bottom - scaleValueToChartHeight(data[i], maxValue as double);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }
}