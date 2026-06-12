// services/alignment_service.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/design_component.dart';

// services/alignment_service.dart
class AlignmentService {
  List<DesignComponent> alignLeft(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 1) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final leftMost = selected.map((c) => c.position.dx).reduce(math.min);

    return _updateComponentsPosition(
      components,
      selectedIds,
      (c) => Offset(leftMost, c.position.dy),
    );
  }

  List<DesignComponent> alignCenter(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 1) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final avg =
        selected
            .map((c) => c.position.dx + c.size.width / 2)
            .reduce((a, b) => a + b) /
        selected.length;

    return _updateComponentsPosition(
      components,
      selectedIds,
      (c) => Offset(avg - c.size.width / 2, c.position.dy),
    );
  }

  List<DesignComponent> alignRight(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 1) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final rightMost = selected
        .map((c) => c.position.dx + c.size.width)
        .reduce(math.max);

    return _updateComponentsPosition(
      components,
      selectedIds,
      (c) => Offset(rightMost - c.size.width, c.position.dy),
    );
  }

  List<DesignComponent> alignTop(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 1) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final topMost = selected.map((c) => c.position.dy).reduce(math.min);

    return _updateComponentsPosition(
      components,
      selectedIds,
      (c) => Offset(c.position.dx, topMost),
    );
  }

  List<DesignComponent> alignBottom(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 1) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final bottomMost = selected
        .map((c) => c.position.dy + c.size.height)
        .reduce(math.max);

    return _updateComponentsPosition(
      components,
      selectedIds,
      (c) => Offset(c.position.dx, bottomMost - c.size.height),
    );
  }

  List<DesignComponent> distributeHorizontally(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 2) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final sorted = List<DesignComponent>.from(selected)
      ..sort((a, b) => a.position.dx.compareTo(b.position.dx));

    final leftMost = sorted.first.position.dx;
    final rightMost = sorted.last.position.dx + sorted.last.size.width;
    final totalWidth = sorted.map((c) => c.size.width).reduce((a, b) => a + b);
    final spacing = (rightMost - leftMost - totalWidth) / (sorted.length - 1);

    var currentX = leftMost;
    final updatedComponents = List<DesignComponent>.from(components);

    for (final component in sorted) {
      final index = updatedComponents.indexWhere((c) => c.id == component.id);
      if (index != -1) {
        updatedComponents[index] = component.copyWith(
          position: Offset(currentX, component.position.dy),
        );
        currentX += component.size.width + spacing;
      }
    }

    return updatedComponents;
  }

  List<DesignComponent> _updateComponentsPosition(
    List<DesignComponent> components,
    List<String> selectedIds,
    Offset Function(DesignComponent) getPosition,
  ) {
    return components.map((component) {
      if (selectedIds.contains(component.id)) {
        return component.copyWith(position: getPosition(component));
      }
      return component;
    }).toList();
  }

  // In AlignmentService class - add this method
  List<DesignComponent> distributeVertically(
    List<DesignComponent> components,
    List<String> selectedIds,
  ) {
    if (selectedIds.length <= 2) return components;

    final selected =
        components.where((c) => selectedIds.contains(c.id)).toList();
    final sorted = List<DesignComponent>.from(selected)
      ..sort((a, b) => a.position.dy.compareTo(b.position.dy));

    final topMost = sorted.first.position.dy;
    final bottomMost = sorted.last.position.dy + sorted.last.size.height;
    final totalHeight = sorted
        .map((c) => c.size.height)
        .reduce((a, b) => a + b);
    final spacing = (bottomMost - topMost - totalHeight) / (sorted.length - 1);

    var currentY = topMost;
    final updatedComponents = List<DesignComponent>.from(components);

    for (final component in sorted) {
      final index = updatedComponents.indexWhere((c) => c.id == component.id);
      if (index != -1) {
        updatedComponents[index] = component.copyWith(
          position: Offset(component.position.dx, currentY),
        );
        currentY += component.size.height + spacing;
      }
    }

    return updatedComponents;
  }
}
