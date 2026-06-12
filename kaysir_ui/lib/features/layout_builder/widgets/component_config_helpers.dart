import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';

/// Updates component attributes from focused inspector widgets.
void updateComponentAttribute(
  WidgetRef ref,
  ComponentData component,
  String key,
  Object? value,
) {
  final attributes = Map<String, dynamic>.from(component.properties.attributes);
  if (value == null) {
    attributes.remove(key);
  } else {
    attributes[key] = value;
  }

  ref
      .read(layoutStateProvider.notifier)
      .updateComponentProperties(
        component.id,
        component.properties.copyWith(attributes: attributes),
      );
}

/// Reads a non-empty string component config value.
String componentStringConfig(Object? value, {required String fallback}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

/// Reads a boolean component config value from typed or serialized attributes.
bool componentBoolConfig(Object? value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

/// Reads an integer component config value clamped to a supported range.
int componentIntConfig(
  Object? value, {
  required int fallback,
  required int min,
  required int max,
}) {
  final parsed =
      value is num ? value.round() : int.tryParse(value?.toString() ?? '');
  return (parsed ?? fallback).clamp(min, max);
}

/// Reads a double component config value clamped to a supported range.
double componentDoubleConfig(
  Object? value, {
  required double fallback,
  required double min,
  required double max,
}) {
  final parsed =
      value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '');
  final next = parsed ?? fallback;
  if (next < min) return min;
  if (next > max) return max;
  return next;
}

/// Reads a color component config value from ARGB integers or hex strings.
Color componentColorConfig(Object? value, {required Color fallback}) {
  if (value is int) return Color(value);
  if (value is String && value.trim().isNotEmpty) {
    final normalized = value.trim().replaceAll('#', '');
    final parsed = int.tryParse(
      normalized.length == 6 ? 'FF$normalized' : normalized,
      radix: 16,
    );
    if (parsed != null) return Color(parsed);
  }

  return fallback;
}

/// Reads a supported button visual style from component attributes.
String componentButtonStyleConfig(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  const allowedStyles = {'outlined', 'tonal', 'filled'};
  return allowedStyles.contains(normalized) ? normalized! : 'outlined';
}
