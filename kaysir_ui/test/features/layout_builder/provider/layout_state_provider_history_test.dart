import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';

void main() {
  group('LayoutStateNotifier history snapshots', () {
    test('undo and redo restore layout mechanism changes', () {
      final notifier = LayoutStateNotifier();

      notifier.updateLayoutMechanism(LayoutMechanism.autoGrid);

      expect(notifier.state.config.layoutMechanism, LayoutMechanism.autoGrid);

      notifier.undo();
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.grid);

      notifier.redo();
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.autoGrid);
    });

    test('conversion mode changes are undoable without components', () {
      final notifier = LayoutStateNotifier();

      notifier.convertLayoutMechanism(LayoutMechanism.tabularColumns);

      expect(
        notifier.state.config.layoutMechanism,
        LayoutMechanism.tabularColumns,
      );

      notifier.undo();
      expect(notifier.state.config.layoutMechanism, LayoutMechanism.grid);
    });

    test('undo restores canvas size and constrained geometry', () {
      final notifier = LayoutStateNotifier();
      notifier.updateLayoutConfig(
        const LayoutConfig(
          canvasWidth: 500,
          canvasHeight: 400,
          minComponentWidth: 20,
          minComponentHeight: 20,
          layoutMechanism: LayoutMechanism.freeform,
        ),
      );
      notifier.addComponent(
        _component(
          'anchored',
          position: const Offset(300, 120),
          size: const Size(100, 80),
          constraints: const ComponentConstraints(
            horizontalAnchor: ComponentAnchorMode.end,
            verticalAnchor: ComponentAnchorMode.end,
          ),
        ),
      );

      notifier.updateCanvasSize(const Size(600, 500));

      expect(
        _componentById(notifier, 'anchored').position,
        const Offset(400, 220),
      );
      expect(notifier.state.config.canvasSize, const Size(600, 500));

      notifier.undo();

      expect(
        _componentById(notifier, 'anchored').position,
        const Offset(300, 120),
      );
      expect(notifier.state.config.canvasSize, const Size(500, 400));
    });

    test('restore version brings back grid and layout rule settings', () {
      final notifier = LayoutStateNotifier();
      notifier.updateLayoutRules(
        gridSettings: const GridSettings(
          gridSize: 32,
          opacity: 0.5,
          enabled: false,
          snapToGrid: false,
        ),
        config: const LayoutConfig(
          gridSize: 32,
          canvasWidth: 700,
          canvasHeight: 500,
          snapToGrid: false,
          showGrid: false,
          layoutMechanism: LayoutMechanism.tabularColumns,
          tabularColumnCount: 8,
        ),
      );
      final savedVersionId = notifier.state.currentVersion!.id;

      notifier.updateLayoutRules(
        gridSettings: const GridSettings(gridSize: 16),
        config: const LayoutConfig(
          gridSize: 16,
          canvasWidth: 900,
          canvasHeight: 640,
          layoutMechanism: LayoutMechanism.autoGrid,
          autoGridColumnCount: 6,
        ),
      );

      notifier.restoreVersion(savedVersionId);

      expect(
        notifier.state.config.layoutMechanism,
        LayoutMechanism.tabularColumns,
      );
      expect(notifier.state.config.canvasSize, const Size(700, 500));
      expect(notifier.state.config.tabularColumnCount, 8);
      expect(notifier.state.gridSettings.gridSize, 32);
      expect(notifier.state.gridSettings.snapToGrid, isFalse);
      expect(notifier.state.isGridVisible, isFalse);
      expect(notifier.state.gridOpacity, 0.5);
    });

    test('renames and duplicates versions without changing current layout', () {
      final notifier = LayoutStateNotifier();
      notifier.updateLayoutRules(
        gridSettings: const GridSettings(gridSize: 28),
        config: const LayoutConfig(
          gridSize: 28,
          canvasWidth: 720,
          canvasHeight: 520,
          layoutMechanism: LayoutMechanism.tabularColumns,
          tabularColumnCount: 9,
        ),
        versionName: 'Tabular checkpoint',
      );
      final sourceVersionId = notifier.state.currentVersion!.id;

      notifier.renameVersion(sourceVersionId, 'Renamed checkpoint');
      notifier.duplicateVersion(sourceVersionId);

      final renamedIndex = notifier.state.versions.indexWhere(
        (version) => version.id == sourceVersionId,
      );
      final duplicate = notifier.state.versions[renamedIndex + 1];

      expect(notifier.state.currentVersion!.id, sourceVersionId);
      expect(notifier.state.currentVersion!.name, 'Renamed checkpoint');
      expect(duplicate.name, 'Renamed checkpoint copy');
      expect(duplicate.config.layoutMechanism, LayoutMechanism.tabularColumns);
      expect(duplicate.config.canvasSize, const Size(720, 520));
    });

    test('deleting current version restores nearest remaining snapshot', () {
      final notifier = LayoutStateNotifier();
      notifier.updateLayoutRules(
        gridSettings: const GridSettings(gridSize: 28),
        config: const LayoutConfig(
          gridSize: 28,
          canvasWidth: 720,
          canvasHeight: 520,
          layoutMechanism: LayoutMechanism.tabularColumns,
          tabularColumnCount: 9,
        ),
        versionName: 'Tabular checkpoint',
      );
      notifier.updateLayoutRules(
        gridSettings: const GridSettings(gridSize: 20),
        config: const LayoutConfig(
          canvasWidth: 900,
          canvasHeight: 620,
          layoutMechanism: LayoutMechanism.autoGrid,
          autoGridColumnCount: 6,
        ),
        versionName: 'Auto checkpoint',
      );
      final currentVersionId = notifier.state.currentVersion!.id;

      notifier.deleteVersion(currentVersionId);

      expect(notifier.state.currentVersion!.name, 'Tabular checkpoint');
      expect(
        notifier.state.config.layoutMechanism,
        LayoutMechanism.tabularColumns,
      );
      expect(notifier.state.config.canvasSize, const Size(720, 520));
    });
  });
}

ComponentData _component(
  String id, {
  required Offset position,
  required Size size,
  ComponentConstraints constraints = const ComponentConstraints(),
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: size,
  ).copyWith(constraints: constraints);
}

ComponentData _componentById(LayoutStateNotifier notifier, String id) {
  return notifier.state.components.firstWhere(
    (component) => component.id == id,
  );
}
