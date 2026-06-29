import 'package:flutter/material.dart';

import 'enums.dart';

class InteractiveElement {
  final String id;
  final InteractiveType type;
  final String? label;
  final List<String>? options;
  final int? duration;
  final String? link;
  final VoidCallback? onTap;

  InteractiveElement({
    required this.id,
    required this.type,
    this.label,
    this.options,
    this.duration,
    this.link,
    this.onTap,
  });
}
