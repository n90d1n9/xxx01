import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/services/layout_selection_geometry_metrics_service.dart';

void main() {
  test('calculates reusable geometry metrics for a multi-selection', () {
    final first = ComponentData.create(
      id: 'selection-first',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(40, 40),
    );
    final second = ComponentData.create(
      id: 'selection-second',
      type: ComponentType.customButton,
      position: const Offset(80, 20),
      size: const Size(40, 40),
    );

    final metrics = layoutSelectionGeometryMetricsService.geometryFor([
      first,
      second,
    ]);

    expect(metrics?.bounds, const Rect.fromLTWH(20, 20, 100, 40));
    expect(metrics?.canMoveToOrigin, isTrue);
    expect(metrics?.sharedWidth, 40);
    expect(metrics?.sharedHeight, 40);
    expect(metrics?.canResetDefaultSizes, isTrue);
    expect(metrics?.horizontalGap, 20);
    expect(metrics?.verticalGap, 0);
  });

  test('does not allow moving a locked-only selection to origin', () {
    final locked = ComponentData.create(
      id: 'selection-locked',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(160, 56),
    ).copyWith(isLocked: true);

    final metrics = layoutSelectionGeometryMetricsService.geometryFor([locked]);

    expect(metrics?.canMoveToOrigin, isFalse);
    expect(metrics?.canResetDefaultSizes, isFalse);
  });
}
