import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_version.dart';
import 'package:kaysir/features/layout_builder/models/layout_version_change.dart';

void main() {
  group('describeLayoutVersionChanges', () {
    test('marks the first version as baseline', () {
      final changes = describeLayoutVersionChanges(_version(), null);

      expect(changes.map((change) => change.label), ['Baseline']);
    });

    test('summarizes component geometry and layout rule changes', () {
      final previous = _version(
        components: [
          _component('a', position: Offset.zero, size: const Size(100, 80)),
        ],
      );
      final next = _version(
        components: [
          _component(
            'a',
            position: const Offset(20, 0),
            size: const Size(120, 90),
          ),
          _component('b', position: Offset.zero, size: const Size(80, 80)),
        ],
        gridSettings: const GridSettings(gridSize: 28, snapToGrid: false),
        config: const LayoutConfig(
          gridSize: 28,
          canvasWidth: 700,
          canvasHeight: 500,
          snapToGrid: false,
          layoutMechanism: LayoutMechanism.autoGrid,
          autoGridColumnCount: 6,
        ),
      );

      final labels = describeLayoutVersionChanges(
        next,
        previous,
      ).map((change) => change.label);

      expect(
        labels,
        containsAll([
          '+1 component',
          '1 component moved',
          '1 component resized',
          'Mode Auto Grid',
          'Canvas 700 x 500',
          '6 auto cols',
        ]),
      );
    });
  });
}

LayoutVersion _version({
  List<ComponentData> components = const [],
  GridSettings gridSettings = const GridSettings(),
  LayoutConfig config = const LayoutConfig(),
}) {
  return LayoutVersion(
    id: 'version-${components.length}-${config.layoutMechanism.name}',
    timestamp: DateTime(2026, 6, 3),
    components: components,
    gridSettings: gridSettings,
    config: config,
  );
}

ComponentData _component(
  String id, {
  required Offset position,
  required Size size,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: size,
  );
}
