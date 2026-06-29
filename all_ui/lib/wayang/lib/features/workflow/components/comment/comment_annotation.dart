import 'package:flutter/material.dart';

class CommentAnnotation {
  final String id;
  final Offset position;
  final String text;
  final Color color;
  final double width;

  CommentAnnotation({
    required this.id,
    required this.position,
    required this.text,
    required this.color,
    this.width = 200,
  });
}
