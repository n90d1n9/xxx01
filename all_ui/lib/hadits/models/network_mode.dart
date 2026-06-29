// Network node for graph visualization
import 'package:flutter/material.dart';

class NetworkNode {
  final String id;
  final String type; // 'prophet', 'companion', 'hadith'
  final String label;
  final String arabicLabel;
  final String? grade;
  final List<String> connectedTo;
  Offset position;

  NetworkNode({
    required this.id,
    required this.type,
    required this.label,
    required this.arabicLabel,
    this.grade,
    required this.connectedTo,
    required this.position,
  });
}
