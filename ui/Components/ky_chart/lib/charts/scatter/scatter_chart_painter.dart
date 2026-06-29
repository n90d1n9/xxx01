// Custom painter for the scatter chart
import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import 'scatter_config.dart';

class ScatterChartPainter extends CustomPainter {
  final ScatterChartConfig config;
  final int selectedPointIndex;

  ScatterChartPainter({
    required this.config,
    required this.selectedPointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    int pointIndex = 0;

    for (int seriesIndex = 0;
        seriesIndex < config.series.length;
        seriesIndex++) {
      final series = config.series[seriesIndex];
      if (series.data != null && series.data is List<Map<String, dynamic>>) {
        final data = series.data as List<Map<String, dynamic>>;

        for (int dataIndex = 0; dataIndex < data.length; dataIndex++) {
          final point = data[dataIndex];
          final x = point['x'].toDouble();
          final y = point['y'].toDouble();

          // Map data coordinates to pixel coordinates
          final pixelX =
              (x - config.minX) / (config.maxX - config.minX) * size.width;
          final pixelY = size.height -
              (y - config.minY) / (config.maxY - config.minY) * size.height;

          // Draw point
          final color = series.itemStyle != null
              ? stringToColor(series.itemStyle!.color)
              : getDefaultSeriesColor(seriesIndex);
          final Paint paint = Paint()
            ..color = pointIndex == selectedPointIndex ? Colors.white : color
            ..style = PaintingStyle.fill;

          final Paint borderPaint = Paint()
            ..color = pointIndex == selectedPointIndex
                ? color
                : color.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = pointIndex == selectedPointIndex ? 2 : 1;

          final radius = pointIndex == selectedPointIndex
              ? config.dotSize * 1.5
              : config.dotSize;

          canvas.drawCircle(Offset(pixelX, pixelY), radius, paint);
          canvas.drawCircle(Offset(pixelX, pixelY), radius, borderPaint);

          pointIndex++;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
