import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/dialog_utils.dart';

void main() {
  testWidgets('Layout Rules dialog applies a rule preset', (tester) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    expect(_applyButton(tester).onPressed, isNull);
    expect(find.text('No pending changes'), findsOneWidget);

    await tester.tap(find.text('Responsive Columns'));
    await tester.pump();

    expect(_applyButton(tester).onPressed, isNotNull);
    expect(find.text('Update Rules'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('layout-rules-apply-button')));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    expect(layoutState.config.layoutMechanism, LayoutMechanism.tabularColumns);
    expect(layoutState.config.tabularColumnCount, 12);
    expect(layoutState.config.tabularColumnGap, 24);
    expect(layoutState.config.tabularRowHeight, 72);
    expect(layoutState.config.canvasSize, const Size(1200, 760));
    expect(layoutState.gridSettings.gridSize, 24);
    expect(layoutState.gridSettings.snapToGrid, isTrue);
    expect(layoutState.currentVersion!.name, 'Layout rules: Update rules');
    await _dismissSnackBar(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog reverts draft changes', (tester) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    expect(_applyButton(tester).onPressed, isNull);
    expect(_textButton(tester, 'Revert').onPressed, isNull);

    await tester.tap(find.text('Responsive Columns'));
    await tester.pump();

    expect(_applyButton(tester).onPressed, isNotNull);
    expect(find.text('Update Rules'), findsOneWidget);
    expect(_textButton(tester, 'Revert').onPressed, isNotNull);
    expect(find.text('Mechanism: Grid -> Tabular Columns'), findsOneWidget);

    await tester.tap(find.text('Revert'));
    await tester.pump();

    expect(find.text('No pending changes'), findsOneWidget);
    expect(find.text('Mechanism: Grid -> Tabular Columns'), findsNothing);
    expect(find.text('Apply'), findsOneWidget);
    expect(_applyButton(tester).onPressed, isNull);
    expect(_textButton(tester, 'Revert').onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog converts visible components on apply', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(layoutMechanism: LayoutMechanism.freeform),
    );
    notifier.addComponents([
      ComponentData.create(
        id: 'button',
        type: ComponentType.customButton,
        position: const Offset(13, 27),
        size: const Size(120, 80),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;
    final beforeApplyComponent =
        container.read(layoutStateProvider).components.single;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    await tester.tap(find.text('Precision Grid'));
    await tester.pump();
    await tester.ensureVisible(find.text('Convert'));
    await tester.pump();
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.text('1 will move'), findsOneWidget);
    expect(find.text('No geometry changes'), findsNothing);
    expect(find.text('Update + Convert'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('layout-rules-apply-button')));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    final component = layoutState.components.single;
    expect(
      find.text('Layout rules applied - rules updated, 1 moved'),
      findsOneWidget,
    );
    expect(find.text('Undo'), findsOneWidget);
    expect(layoutState.currentVersionIndex, beforeApplyIndex + 1);
    expect(layoutState.versions.length, beforeApplyVersionCount + 1);
    expect(layoutState.currentVersion!.name, 'Layout rules: Convert to Grid');
    expect(component.position, const Offset(20, 20));
    expect(component.size, const Size(120, 80));

    await tester.tap(find.text('Undo'));
    await _pumpMaterialTransition(tester);

    final restoredState = container.read(layoutStateProvider);
    final restoredComponent = restoredState.components.single;
    expect(restoredState.currentVersionIndex, beforeApplyIndex);
    expect(restoredState.config.layoutMechanism, LayoutMechanism.freeform);
    expect(restoredComponent.position, beforeApplyComponent.position);
    expect(restoredComponent.size, beforeApplyComponent.size);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog previews Auto Grid conflict cleanup', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(layoutMechanism: LayoutMechanism.freeform),
    );
    notifier.addComponents([
      ComponentData.create(
        id: 'first',
        type: ComponentType.customButton,
        position: const Offset(3, 3),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'second',
        type: ComponentType.customButton,
        position: const Offset(4, 6),
        size: const Size(120, 80),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;
    final beforeApplyComponents = {
      for (final component in container.read(layoutStateProvider).components)
        component.id: component,
    };

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    await tester.ensureVisible(find.text('Auto Cards'));
    await tester.pump();
    await tester.tap(find.text('Auto Cards'));
    await tester.pump();
    await tester.ensureVisible(find.text('Convert'));
    await tester.pump();
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.text('2 will move'), findsOneWidget);
    expect(find.text('2 will resize'), findsOneWidget);
    expect(find.text('2 Auto Grid conflicts'), findsOneWidget);
    expect(find.text('Update + Convert'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('layout-rules-apply-button')));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    final first = _componentById(layoutState.components, 'first');
    final second = _componentById(layoutState.components, 'second');
    expect(
      find.text(
        'Layout rules applied - rules updated, 2 moved, 2 resized, 2 conflicts resolved',
      ),
      findsOneWidget,
    );
    expect(layoutState.currentVersionIndex, beforeApplyIndex + 1);
    expect(layoutState.versions.length, beforeApplyVersionCount + 1);
    expect(
      layoutState.currentVersion!.name,
      'Layout rules: Convert to Auto Grid',
    );
    expect(layoutState.config.layoutMechanism, LayoutMechanism.autoGrid);
    expect(first.position, Offset.zero);
    expect(first.size, const Size(288, 140));
    expect(second.position, const Offset(304, 0));
    expect(second.size, const Size(288, 140));

    await tester.tap(find.text('Undo'));
    await _pumpMaterialTransition(tester);

    final restoredState = container.read(layoutStateProvider);
    final restoredFirst = _componentById(restoredState.components, 'first');
    final restoredSecond = _componentById(restoredState.components, 'second');
    expect(restoredState.currentVersionIndex, beforeApplyIndex);
    expect(restoredState.config.layoutMechanism, LayoutMechanism.freeform);
    expect(restoredFirst.position, beforeApplyComponents['first']!.position);
    expect(restoredFirst.size, beforeApplyComponents['first']!.size);
    expect(restoredSecond.position, beforeApplyComponents['second']!.position);
    expect(restoredSecond.size, beforeApplyComponents['second']!.size);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog reports when snap changes nothing', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      ComponentData.create(
        id: 'button',
        type: ComponentType.customButton,
        position: const Offset(20, 20),
        size: const Size(120, 80),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    await tester.ensureVisible(find.text('Snap'));
    await tester.pump();
    await tester.tap(find.text('Snap'));
    await tester.pump();

    expect(find.text('No geometry changes'), findsOneWidget);
    expect(find.text('Snap Visible'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('layout-rules-apply-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final layoutState = container.read(layoutStateProvider);
    expect(find.text('Layout rules already matched'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    expect(layoutState.currentVersionIndex, beforeApplyIndex);
    expect(layoutState.versions.length, beforeApplyVersionCount);
    await _dismissSnackBar(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog selects off-canvas components', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(canvasWidth: 200, canvasHeight: 200),
    );
    notifier.updateGridSettings(
      const GridSettings(gridSize: 20, snapToGrid: false),
    );
    notifier.addComponents([
      ComponentData.create(
        id: 'outside-left',
        type: ComponentType.customButton,
        position: const Offset(-24, -12),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'outside-right',
        type: ComponentType.customButton,
        position: const Offset(190, 20),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'inside',
        type: ComponentType.customButton,
        position: const Offset(20, 110),
        size: const Size(80, 60),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    expect(find.text('2 off canvas'), findsOneWidget);
    expect(find.text('Select Left/Top'), findsOneWidget);
    expect(find.text('Select Overflow'), findsOneWidget);

    await tester.ensureVisible(find.text('Select Off Canvas'));
    await tester.pump();
    await tester.tap(find.text('Select Off Canvas'));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    expect(find.text('Layout Rules'), findsNothing);
    expect(find.text('Selected 2 off-canvas components'), findsOneWidget);
    expect(layoutState.selectedComponentIds, {'outside-left', 'outside-right'});
    expect(layoutState.currentVersionIndex, beforeApplyIndex);
    expect(layoutState.versions.length, beforeApplyVersionCount);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog selects only overflow components', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(canvasWidth: 200, canvasHeight: 200),
    );
    notifier.updateGridSettings(
      const GridSettings(gridSize: 20, snapToGrid: false),
    );
    notifier.addComponents([
      ComponentData.create(
        id: 'outside-left',
        type: ComponentType.customButton,
        position: const Offset(-24, -12),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'outside-right',
        type: ComponentType.customButton,
        position: const Offset(190, 20),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'inside',
        type: ComponentType.customButton,
        position: const Offset(20, 110),
        size: const Size(80, 60),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    await tester.ensureVisible(find.text('Select Overflow'));
    await tester.pump();
    await tester.tap(find.text('Select Overflow'));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    expect(find.text('Layout Rules'), findsNothing);
    expect(
      find.text('Selected 1 right/bottom overflow component'),
      findsOneWidget,
    );
    expect(layoutState.selectedComponentIds, {'outside-right'});
    expect(layoutState.currentVersionIndex, beforeApplyIndex);
    expect(layoutState.versions.length, beforeApplyVersionCount);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Layout Rules dialog selects off-rule position components', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateGridSettings(
      const GridSettings(gridSize: 20, snapToGrid: false),
    );
    notifier.addComponents([
      ComponentData.create(
        id: 'off-position',
        type: ComponentType.customButton,
        position: const Offset(13, 20),
        size: const Size(120, 80),
      ),
      ComponentData.create(
        id: 'aligned',
        type: ComponentType.customButton,
        position: const Offset(40, 40),
        size: const Size(120, 80),
      ),
    ]);
    final beforeApplyIndex =
        container.read(layoutStateProvider).currentVersionIndex;
    final beforeApplyVersionCount =
        container.read(layoutStateProvider).versions.length;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder:
                  (context, ref, _) => FilledButton(
                    onPressed: () => showGridSettingsDialog(context, ref),
                    child: const Text('Open rules'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rules'));
    await _pumpMaterialTransition(tester);

    expect(find.text('1 off position rule'), findsOneWidget);

    await tester.ensureVisible(find.text('Select Position'));
    await tester.pump();
    await tester.tap(find.text('Select Position'));
    await _pumpMaterialTransition(tester);

    final layoutState = container.read(layoutStateProvider);
    expect(find.text('Layout Rules'), findsNothing);
    expect(
      find.text('Selected 1 component with off-rule position'),
      findsOneWidget,
    );
    expect(layoutState.selectedComponentIds, {'off-position'});
    expect(layoutState.currentVersionIndex, beforeApplyIndex);
    expect(layoutState.versions.length, beforeApplyVersionCount);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Layout Rules dialog repositions left top off-canvas components',
    (tester) async {
      final container = _container(tester);
      final notifier = container.read(layoutStateProvider.notifier);
      notifier.updateGridSettings(
        const GridSettings(gridSize: 20, snapToGrid: false),
      );
      notifier.addComponents([
        ComponentData.create(
          id: 'outside',
          type: ComponentType.customButton,
          position: const Offset(-24, -12),
          size: const Size(120, 80),
        ),
        ComponentData.create(
          id: 'inside',
          type: ComponentType.customButton,
          position: const Offset(100, 120),
          size: const Size(120, 80),
        ),
      ]);
      final beforeApplyIndex =
          container.read(layoutStateProvider).currentVersionIndex;
      final beforeApplyVersionCount =
          container.read(layoutStateProvider).versions.length;
      final beforeApplyComponents = {
        for (final component in container.read(layoutStateProvider).components)
          component.id: component,
      };

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder:
                    (context, ref, _) => FilledButton(
                      onPressed: () => showGridSettingsDialog(context, ref),
                      child: const Text('Open rules'),
                    ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open rules'));
      await _pumpMaterialTransition(tester);

      expect(find.text('1 left/top outside'), findsOneWidget);

      await tester.ensureVisible(find.text('Reposition +24px, +12px'));
      await tester.pump();
      await tester.tap(find.text('Reposition +24px, +12px'));
      await _pumpMaterialTransition(tester);

      final layoutState = container.read(layoutStateProvider);
      final outside = _componentById(layoutState.components, 'outside');
      final inside = _componentById(layoutState.components, 'inside');
      expect(
        find.text('Moved editable components inside the canvas'),
        findsOneWidget,
      );
      expect(find.text('Undo'), findsOneWidget);
      expect(layoutState.currentVersionIndex, beforeApplyIndex + 1);
      expect(layoutState.versions.length, beforeApplyVersionCount + 1);
      expect(
        layoutState.currentVersion!.name,
        'Layout health: Reposition inside canvas',
      );
      expect(outside.position, Offset.zero);
      expect(inside.position, const Offset(124, 132));

      await tester.tap(find.text('Undo'));
      await _pumpMaterialTransition(tester);

      final restoredState = container.read(layoutStateProvider);
      final restoredOutside = _componentById(
        restoredState.components,
        'outside',
      );
      final restoredInside = _componentById(restoredState.components, 'inside');
      expect(restoredState.currentVersionIndex, beforeApplyIndex);
      expect(
        restoredOutside.position,
        beforeApplyComponents['outside']!.position,
      );
      expect(
        restoredInside.position,
        beforeApplyComponents['inside']!.position,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

ProviderContainer _container(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

FilledButton _applyButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.byKey(const ValueKey('layout-rules-apply-button')),
  );
}

TextButton _textButton(WidgetTester tester, String label) {
  return tester.widget<TextButton>(
    find.ancestor(of: find.text(label), matching: find.byType(TextButton)),
  );
}

ComponentData _componentById(List<ComponentData> components, String id) {
  return components.firstWhere((component) => component.id == id);
}

Future<void> _pumpMaterialTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await _pumpMaterialTransition(tester);
}
