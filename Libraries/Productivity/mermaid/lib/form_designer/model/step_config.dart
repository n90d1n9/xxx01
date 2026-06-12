import 'package:flutter/material.dart';

import 'field_config.dart';

class StepConfig {
  final String id;
  final String title;
  final String? subtitle;
  final List<FieldConfig> fields;
  final bool optional;
  final StepState state;

  StepConfig({
    required this.id,
    required this.title,
    this.subtitle,
    required this.fields,
    this.optional = false,
    this.state = StepState.indexed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'fields': fields.map((f) => f.toJson()).toList(),
      'optional': optional,
      'state': state.toString(),
    };
  }
}
