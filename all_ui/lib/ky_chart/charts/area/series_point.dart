import 'dart:ui';

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

  SeriesData({required this.name, required this.points, required this.color});
}
