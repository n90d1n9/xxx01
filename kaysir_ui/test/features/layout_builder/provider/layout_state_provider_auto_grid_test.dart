import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier Auto Grid placement', () {
    test(
      'arranges selection into free cells without moving locked blockers',
      () {
        final notifier = _autoGridNotifier();
        notifier.addComponents([
          _component('locked', position: Offset.zero, isLocked: true),
          _component('moving', position: Offset.zero),
        ]);

        notifier.selectComponents({'moving'});
        notifier.arrangeSelectedIntoAutoGrid();

        expect(_componentById(notifier, 'locked').position, Offset.zero);
        expect(
          _componentById(notifier, 'moving').position,
          const Offset(110, 0),
        );
      },
    );

    test('compacts visible components around locked occupied cells', () {
      final notifier = _autoGridNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: const Offset(330, 0)),
        _component('second', position: const Offset(0, 220)),
      ]);

      notifier.compactVisibleAutoGrid();

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(_componentById(notifier, 'first').position, const Offset(110, 0));
      expect(_componentById(notifier, 'second').position, const Offset(220, 0));
    });

    test('selects only visible Auto Grid conflict participants', () {
      final notifier = _autoGridNotifier();
      notifier.addComponents([
        _component('first', position: Offset.zero),
        _component('second', position: Offset.zero),
        _component('free', position: const Offset(110, 0)),
        _component('hidden', position: Offset.zero, isVisible: false),
      ]);

      notifier.clearSelection();
      notifier.selectVisibleAutoGridConflicts();

      expect(notifier.state.selectedComponentIds, {'first', 'second'});
    });

    test('keeps wide component spans when placing near the right edge', () {
      final notifier = _autoGridNotifier();
      notifier.addComponents([
        _component(
          'wide',
          position: const Offset(330, 0),
          size: const Size(210, 100),
        ),
      ]);

      notifier.compactVisibleAutoGrid();

      final wide = _componentById(notifier, 'wide');
      expect(wide.position, Offset.zero);
      expect(wide.size, const Size(210, 100));
    });

    test('moves selected bounds to requested column and row', () {
      final notifier = _autoGridNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: const Offset(220, 220)),
        _component('second', position: const Offset(330, 220)),
      ]);

      notifier.selectComponents({'locked', 'first', 'second'});
      notifier.moveSelectedToAutoGridColumn(1);
      notifier.moveSelectedToAutoGridRow(2);

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(_componentById(notifier, 'first').position, const Offset(0, 110));
      expect(
        _componentById(notifier, 'second').position,
        const Offset(110, 110),
      );
    });

    test('nudges selected components by Auto Grid tracks', () {
      final notifier = _autoGridNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: Offset.zero),
        _component('second', position: const Offset(110, 0)),
      ]);

      notifier.selectComponents({'locked', 'first', 'second'});
      notifier.nudgeSelectedByAutoGridColumns(1);
      notifier.nudgeSelectedByAutoGridRows(1);

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(
        _componentById(notifier, 'first').position,
        const Offset(110, 110),
      );
      expect(
        _componentById(notifier, 'second').position,
        const Offset(220, 110),
      );
    });
  });
}

LayoutStateNotifier _autoGridNotifier() {
  final notifier = LayoutStateNotifier();
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 430,
      canvasHeight: 430,
      minComponentWidth: 40,
      minComponentHeight: 40,
      layoutMechanism: LayoutMechanism.autoGrid,
      autoGridColumnCount: 4,
      autoGridGap: 10,
      autoGridRowHeight: 100,
    ),
  );
  return notifier;
}

ComponentData _component(
  String id, {
  required Offset position,
  Size size = const Size(100, 100),
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
