import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/services/layout_rule_geometry_service.dart';

void main() {
  test('calculates grid geometry metrics from component bounds', () {
    final component = ComponentData.create(
      id: 'grid-button',
      type: ComponentType.customButton,
      position: const Offset(40, 60),
      size: const Size(80, 40),
    );

    final metrics = layoutRuleGeometryService.gridGeometryFor(
      component,
      const LayoutConfig(canvasWidth: 200, canvasHeight: 120),
      20,
    );

    expect(metrics.column, 3);
    expect(metrics.row, 4);
    expect(metrics.columnSpan, 4);
    expect(metrics.rowSpan, 2);
    expect(metrics.pixelWidth, 80);
    expect(metrics.pixelHeight, 40);
  });

  test('calculates grid selection range metrics from visible bounds', () {
    final first = ComponentData.create(
      id: 'grid-first',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(40, 40),
    );
    final second = ComponentData.create(
      id: 'grid-second',
      type: ComponentType.customButton,
      position: const Offset(60, 20),
      size: const Size(40, 40),
    );

    final metrics = layoutRuleGeometryService.gridSelectionMetricsFor(
      [first, second],
      const LayoutConfig(canvasWidth: 200, canvasHeight: 160),
      20,
    );

    expect(metrics?.startColumn, 2);
    expect(metrics?.startRow, 2);
    expect(metrics?.endColumn, 5);
    expect(metrics?.endRow, 3);
    expect(metrics?.columnSpan, 4);
    expect(metrics?.rowSpan, 2);
    expect(layoutRuleGeometryService.cellRangeLabel(metrics!), 'C2-5 R2-3');
  });

  test('calculates tabular geometry metrics from component bounds', () {
    final component = ComponentData.create(
      id: 'tabular-button',
      type: ComponentType.customButton,
      position: const Offset(110, 80),
      size: const Size(100, 80),
    );

    final metrics = layoutRuleGeometryService.tabularGeometryFor(
      component,
      const LayoutConfig(
        canvasWidth: 430,
        tabularColumnCount: 4,
        tabularColumnGap: 10,
        tabularRowHeight: 40,
      ),
    );

    expect(metrics.column, 2);
    expect(metrics.row, 3);
    expect(metrics.columnSpan, 1);
    expect(metrics.rowSpan, 2);
    expect(metrics.pixelWidth, 100);
    expect(metrics.pixelHeight, 80);
  });

  test('calculates tabular selection range metrics from visible bounds', () {
    final first = ComponentData.create(
      id: 'tabular-first',
      type: ComponentType.customButton,
      position: const Offset(110, 40),
      size: const Size(100, 40),
    );
    final second = ComponentData.create(
      id: 'tabular-second',
      type: ComponentType.customButton,
      position: const Offset(220, 40),
      size: const Size(100, 40),
    );

    final metrics = layoutRuleGeometryService.tabularSelectionMetricsFor(
      [first, second],
      const LayoutConfig(
        canvasWidth: 430,
        tabularColumnCount: 4,
        tabularColumnGap: 10,
        tabularRowHeight: 40,
      ),
    );

    expect(metrics?.startColumn, 2);
    expect(metrics?.startRow, 2);
    expect(metrics?.endColumn, 3);
    expect(metrics?.endRow, 2);
    expect(metrics?.columnSpan, 2);
    expect(metrics?.rowSpan, 1);
    expect(layoutRuleGeometryService.cellRangeLabel(metrics!), 'C2-3 R2');
  });

  test('calculates auto-grid geometry metrics from component bounds', () {
    final component = ComponentData.create(
      id: 'auto-grid-button',
      type: ComponentType.customButton,
      position: const Offset(110, 110),
      size: const Size(210, 100),
    );

    final metrics = layoutRuleGeometryService.autoGridGeometryFor(
      component,
      const LayoutConfig(
        canvasWidth: 430,
        autoGridColumnCount: 4,
        autoGridGap: 10,
        autoGridRowHeight: 100,
      ),
    );

    expect(metrics.column, 2);
    expect(metrics.row, 2);
    expect(metrics.columnSpan, 2);
    expect(metrics.rowSpan, 1);
    expect(metrics.pixelWidth, 210);
    expect(metrics.pixelHeight, 100);
  });

  test('calculates auto-grid selection range metrics from visible bounds', () {
    final first = ComponentData.create(
      id: 'auto-grid-first',
      type: ComponentType.customButton,
      position: const Offset(110, 110),
      size: const Size(100, 100),
    );
    final second = ComponentData.create(
      id: 'auto-grid-second',
      type: ComponentType.customButton,
      position: const Offset(220, 110),
      size: const Size(100, 100),
    );

    final metrics = layoutRuleGeometryService.autoGridSelectionMetricsFor(
      [first, second],
      const LayoutConfig(
        canvasWidth: 430,
        autoGridColumnCount: 4,
        autoGridGap: 10,
        autoGridRowHeight: 100,
      ),
    );

    expect(metrics?.startColumn, 2);
    expect(metrics?.startRow, 2);
    expect(metrics?.endColumn, 3);
    expect(metrics?.endRow, 2);
    expect(metrics?.columnSpan, 2);
    expect(metrics?.rowSpan, 1);
    expect(layoutRuleGeometryService.cellRangeLabel(metrics!), 'C2-3 R2');
  });

  test('reports snap status for unsnapped visible components', () {
    final component = ComponentData.create(
      id: 'unsnapped-button',
      type: ComponentType.customButton,
      position: const Offset(41, 60),
      size: const Size(83, 40),
    );

    final status = layoutRuleGeometryService.snapStatusFor(
      [component],
      const LayoutConfig(layoutMechanism: LayoutMechanism.grid),
      20,
    );

    expect(status.positionCount, 1);
    expect(status.sizeCount, 1);
    expect(status.isAligned, isFalse);
  });

  test('formats non-finite pixel values defensively', () {
    expect(layoutRuleGeometryService.formatPixels(double.infinity), '0px');
    expect(layoutRuleGeometryService.formatPixels(19.6), '20px');
  });
}
