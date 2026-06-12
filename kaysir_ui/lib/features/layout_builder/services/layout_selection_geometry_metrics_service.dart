import 'dart:ui';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';

/// Describes the resolved geometry values for a multi-component selection.
class LayoutSelectionGeometryMetrics {
  final Rect bounds;
  final bool canMoveToOrigin;
  final double? sharedWidth;
  final double? sharedHeight;
  final bool canResetDefaultSizes;
  final double horizontalGap;
  final double verticalGap;

  const LayoutSelectionGeometryMetrics({
    required this.bounds,
    required this.canMoveToOrigin,
    required this.sharedWidth,
    required this.sharedHeight,
    required this.canResetDefaultSizes,
    required this.horizontalGap,
    required this.verticalGap,
  });
}

/// Calculates reusable geometry metrics for selected layout components.
class LayoutSelectionGeometryMetricsService {
  const LayoutSelectionGeometryMetricsService();

  LayoutSelectionGeometryMetrics? geometryFor(
    Iterable<ComponentData> components,
  ) {
    final selectedComponents = components.toList();
    if (selectedComponents.isEmpty) return null;

    return LayoutSelectionGeometryMetrics(
      bounds: selectionBounds(selectedComponents),
      canMoveToOrigin: canMoveSelectionToOrigin(selectedComponents),
      sharedWidth: sharedDimension(
        selectedComponents.map((component) => component.size.width),
      ),
      sharedHeight: sharedDimension(
        selectedComponents.map((component) => component.size.height),
      ),
      canResetDefaultSizes: selectedComponents.any(
        (component) =>
            !component.isLocked &&
            !_isSameSize(component.size, component.type.defaultSize),
      ),
      horizontalGap: selectionGap(
        selectedComponents,
        ComponentDistribution.horizontal,
      ),
      verticalGap: selectionGap(
        selectedComponents,
        ComponentDistribution.vertical,
      ),
    );
  }

  Rect selectionBounds(Iterable<ComponentData> components) {
    final iterator = components.iterator;
    if (!iterator.moveNext()) return Rect.zero;

    final first = iterator.current;
    var left = first.position.dx;
    var top = first.position.dy;
    var right = first.position.dx + first.size.width;
    var bottom = first.position.dy + first.size.height;

    while (iterator.moveNext()) {
      final component = iterator.current;
      left = left < component.position.dx ? left : component.position.dx;
      top = top < component.position.dy ? top : component.position.dy;
      right =
          right > component.position.dx + component.size.width
              ? right
              : component.position.dx + component.size.width;
      bottom =
          bottom > component.position.dy + component.size.height
              ? bottom
              : component.position.dy + component.size.height;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  bool canMoveSelectionToOrigin(Iterable<ComponentData> components) {
    final movableComponents =
        components.where((component) => !component.isLocked).toList();
    if (movableComponents.isEmpty) return false;

    return selectionBounds(movableComponents).topLeft.distance >= 0.01;
  }

  double? sharedDimension(Iterable<double> values) {
    final iterator = values.iterator;
    if (!iterator.moveNext()) return null;

    final first = iterator.current;
    while (iterator.moveNext()) {
      if ((iterator.current - first).abs() > 0.01) return null;
    }

    return first;
  }

  double selectionGap(
    Iterable<ComponentData> components,
    ComponentDistribution direction,
  ) {
    final sortedComponents = components.toList();
    if (sortedComponents.length < 2) return 0;

    sortedComponents.sort((a, b) {
      final aValue =
          direction == ComponentDistribution.horizontal
              ? a.position.dx
              : a.position.dy;
      final bValue =
          direction == ComponentDistribution.horizontal
              ? b.position.dx
              : b.position.dy;
      return aValue.compareTo(bValue);
    });
    var totalGap = 0.0;

    for (var index = 0; index < sortedComponents.length - 1; index++) {
      final current = sortedComponents[index];
      final next = sortedComponents[index + 1];
      final currentEnd =
          direction == ComponentDistribution.horizontal
              ? current.position.dx + current.size.width
              : current.position.dy + current.size.height;
      final nextStart =
          direction == ComponentDistribution.horizontal
              ? next.position.dx
              : next.position.dy;
      totalGap += nextStart - currentEnd;
    }

    return (totalGap / (sortedComponents.length - 1))
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  bool _isSameSize(Size first, Size second) {
    return (first.width - second.width).abs() < 0.5 &&
        (first.height - second.height).abs() < 0.5;
  }
}

const layoutSelectionGeometryMetricsService =
    LayoutSelectionGeometryMetricsService();
