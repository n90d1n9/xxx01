import 'package:flutter/material.dart';

import 'chart_type.dart';

class ChartData {
  final String id;
  final ChartType type;
  final String title;
  final List<String> labels;
  final List<double> values;
  final Color color;
  ChartData({
    required this.id,
    required this.type,
    required this.title,
    required this.labels,
    required this.values,
    this.color = Colors.blue,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'labels': labels,
    'values': values,
    'color': color.value,
  };
  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
    id: json['id'],
    type: ChartType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => ChartType.bar,
    ),
    title: json['title'],
    labels: List<String>.from(json['labels']),
    values: List<double>.from(json['values']),
    color: Color(json['color']),
  );
}
