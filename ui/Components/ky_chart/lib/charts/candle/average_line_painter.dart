import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/chart_type.dart';
import '../../model/series.dart';
import '../../model/xyaxis.dart';
import 'candlestick_data.dart';

class AverageLinePainter extends CustomPainter {
  final List<Series> series;
  final BoxConstraints constraints;
  final XYAxis? xAxis;
  final XYAxis? yAxis;

  AverageLinePainter({
    required this.series,
    required this.constraints,
    this.xAxis,
    this.yAxis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    // Find candlestick series data
    final candlestickSeries =
        series.where((s) => s.type == ChartType.candlestick).toList();
    if (candlestickSeries.isEmpty) return;

    final seriesData = candlestickSeries.first.data;
    final maxY = _getMaxValue(seriesData!);
    final minY = _getMinValue(seriesData);
    final range = maxY - minY;

    // Calculate average close price
    final averageClose = _calculateAverageClose(seriesData);
    final y = size.height - ((averageClose - minY) / range) * size.height;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal average line
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );

    // Add label
    final textSpan = TextSpan(
      text: 'Avg: ${averageClose.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.blue,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas,
        Offset(size.width - textPainter.width - 4, y - textPainter.height - 2));
  }

  double _calculateAverageClose(List<dynamic> data) {
    final sum = data.fold<double>(0, (sum, item) {
      final candleData = item as CandlestickData;
      return sum + candleData.close;
    });
    return sum / data.length;
  }

  double _getMaxValue(List<dynamic> data) {
    return data.fold<double>(double.negativeInfinity, (max, item) {
      final candleData = item as CandlestickData;
      return math.max(max, candleData.high);
    });
  }

  double _getMinValue(List<dynamic> data) {
    return data.fold<double>(double.infinity, (min, item) {
      final candleData = item as CandlestickData;
      return math.min(min, candleData.low);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
