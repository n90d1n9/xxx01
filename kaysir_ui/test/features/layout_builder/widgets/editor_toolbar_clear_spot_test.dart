import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/editor_toolbar.dart';

void main() {
  testWidgets('EditorToolbar explains unavailable clear spot action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        canvasWidth: 240,
        canvasHeight: 240,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );
    notifier.updateGridSettings(const GridSettings(gridSize: 20));
    notifier.addComponent(_component('solo', position: const Offset(20, 20)));
    notifier.selectComponent('solo');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: EditorToolbar())),
      ),
    );

    expect(find.byTooltip('No clear spot available'), findsOneWidget);
  });

  testWidgets('EditorToolbar overflow moves selection to a clear spot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2000, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        canvasWidth: 240,
        canvasHeight: 240,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );
    notifier.updateGridSettings(const GridSettings(gridSize: 20));
    notifier.addComponents([
      _component('blocker', position: const Offset(20, 20)),
      _component('dragged', position: const Offset(20, 20)),
    ]);
    notifier.selectComponent('dragged');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: EditorToolbar())),
      ),
    );

    await tester.tap(find.byTooltip('Selection actions'));
    await tester.pumpAndSettle();

    expect(find.text('Move to clear spot (Grid c4 r2)'), findsOneWidget);

    await tester.tap(find.text('Move to clear spot (Grid c4 r2)'));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutStateProvider).componentsById['dragged']?.position,
      const Offset(60, 20),
    );
    expect(
      find.text('Moved selection to clear spot at Grid c4 r2'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

ComponentData _component(String id, {required Offset position}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: const Size(40, 40),
  );
}
