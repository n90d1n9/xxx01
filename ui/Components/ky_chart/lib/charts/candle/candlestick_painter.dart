import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/chart_type.dart';
import '../../model/series.dart';
import '../../model/xyaxis.dart';
import 'candlestick_data.dart';

class CandlestickPainter extends CustomPainter {
  final List<Series> series;
  final BoxConstraints constraints;
  final Color bullColor;
  final Color bearColor;
  final double barWidth;
  final XYAxis? xAxis;
  final XYAxis? yAxis;

  CandlestickPainter({
    required this.series,
    required this.constraints,
    required this.bullColor,
    required this.bearColor,
    required this.barWidth,
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

    for (int i = 0; i < seriesData.length; i++) {
      final data = seriesData[i] as CandlestickData;
      final x = (i / (seriesData.length - 1)) * size.width;

      // Normalize values to the canvas height
      final open = size.height - ((data.open - minY) / range) * size.height;
      final close = size.height - ((data.close - minY) / range) * size.height;
      final high = size.height - ((data.high - minY) / range) * size.height;
      final low = size.height - ((data.low - minY) / range) * size.height;

      final isBullish = data.close > data.open;
      final paint = Paint()
        ..color = isBullish ? bullColor : bearColor
        ..strokeWidth = 2
        ..style = PaintingStyle.fill;

      // Draw the wick (vertical line)
      canvas.drawLine(
        Offset(x, high),
        Offset(x, low),
        paint..style = PaintingStyle.stroke,
      );

      // Draw the body (rectangle)
      final bodyTop = isBullish ? close : open;
      final bodyBottom = isBullish ? open : close;
      canvas.drawRect(
        Rect.fromPoints(
          Offset(x - barWidth / 2, bodyTop),
          Offset(x + barWidth / 2, bodyBottom),
        ),
        paint..style = PaintingStyle.fill,
      );
    }
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
