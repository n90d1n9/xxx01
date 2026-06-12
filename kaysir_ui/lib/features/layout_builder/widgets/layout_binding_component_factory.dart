import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/component.dart';
import '../provider/layout_data_binding_provider.dart';

ComponentData createBoundTextLabelFromBinding(
  LayoutBindingPreview binding,
  Offset position,
) {
  final component = ComponentData.create(
    type: ComponentType.textLabel,
    position: position,
    size: boundTextLabelSizeForBinding(binding),
  );

  return component.copyWith(
    properties: component.properties.copyWith(
      attributes: {'name': binding.key, 'text': binding.token},
    ),
  );
}

Size boundTextLabelSizeForBinding(LayoutBindingPreview binding) {
  final value = binding.value.trim().isEmpty ? binding.token : binding.value;
  final longestLine = value
      .split(RegExp(r'\s+'))
      .fold<int>(0, (length, word) => math.max(length, word.length));
  final width = (math.max(value.length, longestLine) * 7.5 + 48).clamp(
    160,
    340,
  );
  final height = value.length > 32 ? 64.0 : 48.0;

  return Size(width.toDouble(), height);
}
