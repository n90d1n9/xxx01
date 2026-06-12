import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier layout conversion', () {
    test('converts visible unlocked components to grid rules', () {
      final notifier = _conversionNotifier(
        const LayoutConfig(
          canvasWidth: 240,
          canvasHeight: 240,
          minComponentWidth: 20,
          minComponentHeight: 20,
          layoutMechanism: LayoutMechanism.freeform,
        ),
      );
      notifier.updateGridSettings(
        const GridSettings(gridSize: 20, snapToGrid: false),
      );
      notifier.addComponents([
        _component(
          'visible',
          position: const Offset(13, 27),
          size: const Size(33, 44),
        ),
        _component(
          'locked',
          position: const Offset(13, 27),
          size: const Size(33, 44),
          isLocked: true,
        ),
        _component(
          'hidden',
          position: const Offset(13, 27),
          size: const Size(33, 44),
          isVisible: false,
        ),
      ]);

      notifier.convertLayoutMechanism(LayoutMechanism.grid);

      final visible = _componentById(notifier, 'visible');
      final locked = _componentById(notifier, 'locked');
      final hidden = _componentById(notifier, 'hidden');
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.grid);
      expect(
        notifier.state.currentVersion!.name,
        'Layout rules: Convert to Grid',
      );
      expect(visible.position, const Offset(20, 20));
      expect(visible.size, const Size(40, 40));
      expect(locked.position, const Offset(13, 27));
      expect(locked.size, const Size(33, 44));
      expect(hidden.position, const Offset(13, 27));
      expect(hidden.size, const Size(33, 44));
    });

    test('applies rules and conversion as one undoable version', () {
      final notifier = _conversionNotifier(
        const LayoutConfig(
          canvasWidth: 240,
          canvasHeight: 240,
          minComponentWidth: 20,
          minComponentHeight: 20,
          layoutMechanism: LayoutMechanism.freeform,
        ),
      );
      notifier.addComponents([
        _component(
          'visible',
          position: const Offset(13, 27),
          size: const Size(33, 44),
        ),
      ]);

      final beforeIndex = notifier.state.currentVersionIndex;
      final beforeVersionCount = notifier.state.versions.length;
      final beforeComponent = _componentById(notifier, 'visible');

      notifier.applyLayoutRules(
        gridSettings: const GridSettings(gridSize: 20, snapToGrid: false),
        config: notifier.state.config.copyWith(
          layoutMechanism: LayoutMechanism.grid,
        ),
        snapVisiblePositions: true,
        snapVisibleSizes: true,
      );

      final converted = _componentById(notifier, 'visible');
      expect(notifier.state.currentVersionIndex, beforeIndex + 1);
      expect(notifier.state.versions.length, beforeVersionCount + 1);
      expect(
        notifier.state.currentVersion!.name,
        'Layout rules: Convert to Grid',
      );
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.grid);
      expect(converted.position, const Offset(20, 20));
      expect(converted.size, const Size(40, 40));

      notifier.undo();

      final restored = _componentById(notifier, 'visible');
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.freeform);
      expect(restored.position, beforeComponent.position);
      expect(restored.size, beforeComponent.size);
    });

    test('converts to Auto Grid and resolves visible conflicts', () {
      final notifier = _conversionNotifier(
        const LayoutConfig(
          canvasWidth: 430,
          canvasHeight: 430,
          minComponentWidth: 40,
          minComponentHeight: 40,
          layoutMechanism: LayoutMechanism.freeform,
          autoGridColumnCount: 4,
          autoGridGap: 10,
          autoGridRowHeight: 100,
        ),
      );
      notifier.addComponents([
        _component('first', position: const Offset(3, 3)),
        _component('second', position: const Offset(4, 6)),
      ]);
      final beforeIndex = notifier.state.currentVersionIndex;
      final beforeVersionCount = notifier.state.versions.length;

      notifier.convertLayoutMechanism(LayoutMechanism.autoGrid);

      expect(notifier.state.currentVersionIndex, beforeIndex + 1);
      expect(notifier.state.versions.length, beforeVersionCount + 1);
      expect(
        notifier.state.currentVersion!.name,
        'Layout rules: Convert to Auto Grid',
      );
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.autoGrid);
      expect(_componentById(notifier, 'first').position, Offset.zero);
      expect(_componentById(notifier, 'second').position, const Offset(110, 0));
    });
  });
}

LayoutStateNotifier _conversionNotifier(LayoutConfig config) {
  final notifier = LayoutStateNotifier();
  notifier.updateLayoutConfig(config);
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
