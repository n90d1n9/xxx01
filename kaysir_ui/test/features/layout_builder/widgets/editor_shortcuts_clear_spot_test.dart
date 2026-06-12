import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/editor_shortcuts.dart';

void main() {
  testWidgets(
    'EditorShortcutScope moves selection to a clear spot with Alt+M',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(layoutStateProvider.notifier);
      _configureGrid(notifier);
      notifier.addComponents([
        _component('blocker', position: const Offset(20, 20)),
        _component('dragged', position: const Offset(20, 20)),
      ]);
      notifier.selectComponent('dragged');

      await _pumpShortcutScope(tester, container);
      await _pressAltM(tester);

      expect(
        container.read(layoutStateProvider).componentsById['dragged']?.position,
        const Offset(60, 20),
      );
      expect(
        find.text('Moved selection to clear spot at Grid c4 r2'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('EditorShortcutScope reports missing selection for Alt+M', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _configureGrid(container.read(layoutStateProvider.notifier));

    await _pumpShortcutScope(tester, container);
    await _pressAltM(tester);

    expect(find.text('Select a component first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope reports unavailable clear spot for Alt+M', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureGrid(notifier);
    notifier.addComponent(_component('solo', position: const Offset(20, 20)));
    notifier.selectComponent('solo');

    await _pumpShortcutScope(tester, container);
    await _pressAltM(tester);

    expect(
      container.read(layoutStateProvider).componentsById['solo']?.position,
      const Offset(20, 20),
    );
    expect(find.text('No clear spot available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _configureGrid(LayoutStateNotifier notifier) {
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
}

Future<void> _pumpShortcutScope(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: EditorShortcutScope(
            child: SizedBox.expand(child: ColoredBox(color: Colors.white)),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pressAltM(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  await tester.pumpAndSettle();
}

ComponentData _component(String id, {required Offset position}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: const Size(40, 40),
  );
}
