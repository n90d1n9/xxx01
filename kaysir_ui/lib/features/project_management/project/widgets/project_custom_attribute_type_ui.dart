import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';

extension ProjectCustomAttributeTypeUi on ProjectCustomAttributeType {
  IconData get icon {
    switch (this) {
      case ProjectCustomAttributeType.text:
        return Icons.short_text_outlined;
      case ProjectCustomAttributeType.number:
        return Icons.pin_outlined;
      case ProjectCustomAttributeType.date:
        return Icons.event_outlined;
      case ProjectCustomAttributeType.url:
        return Icons.link_outlined;
      case ProjectCustomAttributeType.choice:
        return Icons.tune_outlined;
      case ProjectCustomAttributeType.boolean:
        return Icons.toggle_on_outlined;
    }
  }

  Color accentColor(ColorScheme colorScheme) {
    switch (this) {
      case ProjectCustomAttributeType.text:
        return colorScheme.primary;
      case ProjectCustomAttributeType.number:
        return colorScheme.secondary;
      case ProjectCustomAttributeType.date:
        return colorScheme.tertiary;
      case ProjectCustomAttributeType.url:
        return Colors.blue.shade700;
      case ProjectCustomAttributeType.choice:
        return Colors.indigo.shade600;
      case ProjectCustomAttributeType.boolean:
        return Colors.teal.shade700;
    }
  }

  TextInputType get keyboardType {
    switch (this) {
      case ProjectCustomAttributeType.number:
        return const TextInputType.numberWithOptions(decimal: true);
      case ProjectCustomAttributeType.date:
        return TextInputType.datetime;
      case ProjectCustomAttributeType.url:
        return TextInputType.url;
      case ProjectCustomAttributeType.text:
      case ProjectCustomAttributeType.choice:
      case ProjectCustomAttributeType.boolean:
        return TextInputType.text;
    }
  }

  String? get valueHint {
    switch (this) {
      case ProjectCustomAttributeType.date:
        return 'YYYY-MM-DD';
      case ProjectCustomAttributeType.text:
      case ProjectCustomAttributeType.number:
      case ProjectCustomAttributeType.url:
      case ProjectCustomAttributeType.choice:
      case ProjectCustomAttributeType.boolean:
        return null;
    }
  }
}
