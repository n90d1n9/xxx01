import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier health repairs', () {
    test(
      'moves visible unlocked components inside canvas in one undo step',
      () {
        final notifier = LayoutStateNotifier();
        notifier.updateLayoutConfig(
          const LayoutConfig(canvasWidth: 400, canvasHeight: 400),
        );
        notifier.updateGridSettings(
          const GridSettings(gridSize: 20, snapToGrid: false),
        );
        notifier.addComponents([
          _component('outside', position: const Offset(-24, -12)),
          _component('inside', position: const Offset(100, 120)),
          _component(
            'locked',
            position: const Offset(-30, -30),
            isLocked: true,
          ),
          _component(
            'hidden',
            position: const Offset(-40, -40),
            isVisible: false,
          ),
        ]);

        final beforeIndex = notifier.state.currentVersionIndex;
        final beforeVersionCount = notifier.state.versions.length;
        final beforeComponents = {
          for (final component in notifier.state.components)
            component.id: component.position,
        };

        notifier.moveVisibleComponentsInsideCanvas();

        expect(notifier.state.currentVersionIndex, beforeIndex + 1);
        expect(notifier.state.versions.length, beforeVersionCount + 1);
        expect(
          notifier.state.currentVersion!.name,
          'Layout health: Reposition inside canvas',
        );
        expect(_componentById(notifier, 'outside').position, Offset.zero);
        expect(
          _componentById(notifier, 'inside').position,
          const Offset(124, 132),
        );
        expect(
          _componentById(notifier, 'locked').position,
          beforeComponents['locked'],
        );
        expect(
          _componentById(notifier, 'hidden').position,
          beforeComponents['hidden'],
        );

        notifier.undo();

        for (final entry in beforeComponents.entries) {
          expect(_componentById(notifier, entry.key).position, entry.value);
        }
      },
    );

    test(
      'skips history when editable components are already inside canvas',
      () {
        final notifier = LayoutStateNotifier();
        notifier.updateGridSettings(
          const GridSettings(gridSize: 20, snapToGrid: false),
        );
        notifier.addComponent(
          _component('inside', position: const Offset(16, 20)),
        );

        final beforeIndex = notifier.state.currentVersionIndex;
        final beforeVersionCount = notifier.state.versions.length;

        notifier.moveVisibleComponentsInsideCanvas();

        expect(notifier.state.currentVersionIndex, beforeIndex);
        expect(notifier.state.versions.length, beforeVersionCount);
        expect(
          _componentById(notifier, 'inside').position,
          const Offset(16, 20),
        );
      },
    );
  });
}

ComponentData _component(
  String id, {
  required Offset position,
  bool isLocked = false,
  bool isVisible = true,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: const Size(80, 80),
  ).copyWith(isLocked: isLocked, isVisible: isVisible);
}

ComponentData _componentById(LayoutStateNotifier notifier, String id) {
  return notifier.state.components.firstWhere(
    (component) => component.id == id,
  );
}
