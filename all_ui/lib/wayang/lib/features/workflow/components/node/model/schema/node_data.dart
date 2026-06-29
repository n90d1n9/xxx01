import 'package:flutter/material.dart';

class NodeData {
  final String id;
  final String type;
  final String label;
  final Offset position;
  final Map<String, dynamic> config;
  final bool disabled;
  NodeData({
    required this.id,
    required this.type,
    required this.label,
    required this.position,
    required this.config,
    this.disabled = false,
  });
}
