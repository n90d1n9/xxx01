import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier Grid placement', () {
    test('nudges selected components by grid cells', () {
      final notifier = _gridNotifier();
      notifier.addComponents([
        _component('locked', position: Offset.zero, isLocked: true),
        _component('first', position: Offset.zero),
        _component('second', position: const Offset(40, 0)),
      ]);

      notifier.selectComponents({'locked', 'first', 'second'});
      notifier.nudgeSelectedComponent(const Offset(20, 20));

      expect(_componentById(notifier, 'locked').position, Offset.zero);
      expect(_componentById(notifier, 'first').position, const Offset(20, 20));
      expect(_componentById(notifier, 'second').position, const Offset(60, 20));
    });

    test('snaps selected movement to grid cells', () {
      final notifier = _gridNotifier();
      notifier.addComponents([
        _component('first', position: Offset.zero),
        _component('second', position: const Offset(40, 0)),
      ]);

      notifier.selectComponents({'first', 'second'});
      notifier.moveSelectedComponents(const Offset(13, 27));

      expect(_componentById(notifier, 'first').position, const Offset(20, 20));
      expect(_componentById(notifier, 'second').position, const Offset(60, 20));
    });

    test('skips history when selection alignment is already satisfied', () {
      final notifier = _gridNotifier();
      notifier.addComponents([
        _component('first', position: const Offset(60, 20)),
        _component('second', position: const Offset(100, 80)),
      ]);
      notifier.selectComponents({'first', 'second'});

      notifier.alignSelected(ComponentAlignment.left);

      final beforeIndex = notifier.state.currentVersionIndex;
      final beforeVersionCount = notifier.state.versions.length;

      notifier.alignSelected(ComponentAlignment.left);

      expect(_componentById(notifier, 'first').position, const Offset(60, 20));
      expect(_componentById(notifier, 'second').position, const Offset(60, 80));
      expect(notifier.state.currentVersionIndex, beforeIndex);
      expect(notifier.state.versions.length, beforeVersionCount);
    });

    test('skips history when stack arrangement is already satisfied', () {
      final notifier = _gridNotifier();
      notifier.addComponents([
        _component('first', position: const Offset(20, 20)),
        _component('second', position: const Offset(80, 20)),
      ]);
      notifier.selectComponents({'first', 'second'});

      final beforeIndex = notifier.state.currentVersionIndex;
      final beforeVersionCount = notifier.state.versions.length;

      notifier.stackSelectedComponents(ComponentDistribution.horizontal);

      expect(_componentById(notifier, 'first').position, const Offset(20, 20));
      expect(_componentById(notifier, 'second').position, const Offset(80, 20));
      expect(notifier.state.currentVersionIndex, beforeIndex);
      expect(notifier.state.versions.length, beforeVersionCount);
    });

    test('snaps visible positions and sizes to grid rules', () {
      final notifier = _gridNotifier(snapToGrid: false);
      notifier.addComponents([
        _component(
          'locked',
          position: const Offset(13, 27),
          size: const Size(33, 44),
          isLocked: true,
        ),
        _component(
          'visible',
          position: const Offset(13, 27),
          size: const Size(33, 44),
        ),
        _component(
          'hidden',
          position: const Offset(13, 27),
          size: const Size(33, 44),
          isVisible: false,
        ),
      ]);
      notifier.updateGridSettings(const GridSettings(gridSize: 20));

      notifier.snapVisibleComponentsToLayoutRules();
      notifier.snapVisibleComponentSizesToLayoutRules();

      final locked = _componentById(notifier, 'locked');
      final visible = _componentById(notifier, 'visible');
      final hidden = _componentById(notifier, 'hidden');
      expect(locked.position, const Offset(13, 27));
      expect(locked.size, const Size(33, 44));
      expect(visible.position, const Offset(20, 20));
      expect(visible.size, const Size(40, 40));
      expect(hidden.position, const Offset(13, 27));
      expect(hidden.size, const Size(33, 44));
    });

    test('moves dragged components into the suggested conflict clear spot', () {
      final notifier = _gridNotifier();
      notifier.addComponents([
        _component('blocker', position: const Offset(20, 20)),
        _component('dragged', position: Offset.zero),
      ]);

      notifier.selectComponent('dragged');
      notifier.moveComponent('dragged', const Offset(20, 20));

      expect(
        _componentById(notifier, 'dragged').position,
        const Offset(20, 20),
      );

      final resolved = notifier.resolveActiveDragConflict('dragged');

      expect(resolved, isTrue);
      expect(
        _componentById(notifier, 'blocker').position,
        const Offset(20, 20),
      );
      expect(
        _componentById(notifier, 'dragged').position,
        const Offset(60, 20),
      );
    });

    test('keeps conflict clear spots as guides when snapping is disabled', () {
      final notifier = _gridNotifier(snapToGrid: false);
      notifier.addComponents([
        _component('blocker', position: const Offset(20, 20)),
        _component('dragged', position: Offset.zero),
      ]);

      notifier.selectComponent('dragged');
      notifier.moveComponent('dragged', const Offset(20, 20));

      final resolved = notifier.resolveActiveDragConflict('dragged');

      expect(resolved, isFalse);
      expect(
        _componentById(notifier, 'dragged').position,
        const Offset(20, 20),
      );
    });

    test('manually resolves selected conflicts when snapping is disabled', () {
      final notifier = _gridNotifier(snapToGrid: false);
      notifier.addComponents([
        _component('blocker', position: const Offset(20, 20)),
        _component('dragged', position: const Offset(20, 20)),
      ]);

      notifier.selectComponent('dragged');

      final preview = notifier.selectedConflictResolutionPreview();

      expect(preview, isNotNull);
      expect(preview!.conflictResolvedRuleLabel, 'Grid c4 r2');

      final resolved = notifier.resolveSelectedConflict();

      expect(resolved, isTrue);
      expect(
        _componentById(notifier, 'dragged').position,
        const Offset(60, 20),
      );
    });

    test(
      'places dropped components into the suggested conflict clear spot',
      () {
        final notifier = _gridNotifier();
        notifier.addComponent(
          _component('blocker', position: const Offset(20, 20)),
        );

        notifier.addComponentsWithDropResolution([
          _component('dropped', position: const Offset(20, 20)),
        ]);

        expect(
          _componentById(notifier, 'blocker').position,
          const Offset(20, 20),
        );
        expect(
          _componentById(notifier, 'dropped').position,
          const Offset(60, 20),
        );
        expect(notifier.state.selectedComponentId, 'dropped');
      },
    );
  });
}

LayoutStateNotifier _gridNotifier({bool snapToGrid = true}) {
  final notifier = LayoutStateNotifier();
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 240,
      canvasHeight: 240,
      minComponentWidth: 20,
      minComponentHeight: 20,
      layoutMechanism: LayoutMechanism.grid,
    ),
  );
  notifier.updateGridSettings(
    GridSettings(gridSize: 20, snapToGrid: snapToGrid),
  );
  return notifier;
}

ComponentData _component(
  String id, {
  required Offset position,
  Size size = const Size(40, 40),
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
