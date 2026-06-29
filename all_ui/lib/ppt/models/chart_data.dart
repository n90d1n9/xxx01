import 'dart:ui';

import 'enums.dart';

class ChartData {
  final ChartType type;
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;

  ChartData({
    required this.type,
    required this.values,
    required this.labels,
    required this.colors,
  });
}
