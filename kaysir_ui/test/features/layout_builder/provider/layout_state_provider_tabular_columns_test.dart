import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier Tabular Columns placement', () {
    test('moves selected bounds to requested column and row', () {
      final notifier = _tabularNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: const Offset(220, 80)),
        _component('second', position: const Offset(330, 80)),
      ]);

      notifier.selectComponents({'locked', 'first', 'second'});
      notifier.moveSelectedToTabularColumn(1);
      notifier.moveSelectedToTabularRow(3);

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(_componentById(notifier, 'first').position, const Offset(0, 80));
      expect(
        _componentById(notifier, 'second').position,
        const Offset(110, 80),
      );
    });

    test('nudges selected components by tabular tracks', () {
      final notifier = _tabularNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: Offset.zero),
        _component('second', position: const Offset(110, 0)),
      ]);

      notifier.selectComponents({'locked', 'first', 'second'});
      notifier.nudgeSelectedByTabularColumns(1);
      notifier.nudgeSelectedByTabularRows(1);

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(_componentById(notifier, 'first').position, const Offset(110, 40));
      expect(
        _componentById(notifier, 'second').position,
        const Offset(220, 40),
      );
    });
  });
}

LayoutStateNotifier _tabularNotifier() {
  final notifier = LayoutStateNotifier();
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 430,
      canvasHeight: 430,
      minComponentWidth: 40,
      minComponentHeight: 40,
      layoutMechanism: LayoutMechanism.tabularColumns,
      tabularColumnCount: 4,
      tabularColumnGap: 10,
      tabularRowHeight: 40,
    ),
  );
  return notifier;
}

ComponentData _component(
  String id, {
  required Offset position,
  Size size = const Size(100, 40),
  bool isLocked = false,
  bool isVisible = true,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: size,
  ).copyWith(isLocked: isLocked, isVisible: isVisible);
}

ComponentData _componentById(LayoutStateNotifier notifier, String id) {
  return notifier.state.components.firstWhere(
    (component) => component.id == id,
  );
}
