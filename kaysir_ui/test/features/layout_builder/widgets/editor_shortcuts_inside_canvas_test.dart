import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/editor_shortcuts.dart';

void main() {
  testWidgets('EditorShortcutScope moves selection inside canvas with Alt+I', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureCanvas(notifier);
    notifier.addComponent(
      _component('outside', position: const Offset(260, 20)),
    );
    notifier.selectComponent('outside');

    await _pumpShortcutScope(tester, container);
    await _pressAltI(tester);

    expect(
      container.read(layoutStateProvider).componentsById['outside']?.position,
      const Offset(200, 20),
    );
    expect(find.text('Moved selection inside canvas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope reports missing selection for Alt+I', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _configureCanvas(container.read(layoutStateProvider.notifier));

    await _pumpShortcutScope(tester, container);
    await _pressAltI(tester);

    expect(find.text('Select a component first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope reports selection already inside canvas', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureCanvas(notifier);
    notifier.addComponent(_component('inside', position: const Offset(20, 20)));
    notifier.selectComponent('inside');

    await _pumpShortcutScope(tester, container);
    await _pressAltI(tester);

    expect(
      container.read(layoutStateProvider).componentsById['inside']?.position,
      const Offset(20, 20),
    );
    expect(find.text('Selection is already inside canvas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope reports locked selection for Alt+I', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureCanvas(notifier);
    notifier.addComponent(
      _component('locked', position: const Offset(260, 20), isLocked: true),
    );
    notifier.selectComponent('locked');

    await _pumpShortcutScope(tester, container);
    await _pressAltI(tester);

    expect(
      container.read(layoutStateProvider).componentsById['locked']?.position,
      const Offset(260, 20),
    );
    expect(find.text('Selected components are locked'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope centers selection on canvas with Alt+C', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(layoutStateProvider.notifier);
    _configureCanvas(notifier);
    notifier.addComponent(_component('offset', position: const Offset(20, 40)));
    notifier.selectComponent('offset');

    await _pumpShortcutScope(tester, container);
    await _pressAltC(tester);

    expect(
      container.read(layoutStateProvider).componentsById['offset']?.position,
      const Offset(100, 100),
    );
    expect(find.text('Centered selection on canvas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EditorShortcutScope reports missing selection for Alt+C', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _configureCanvas(container.read(layoutStateProvider.notifier));

    await _pumpShortcutScope(tester, container);
    await _pressAltC(tester);

    expect(find.text('Select a component first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _configureCanvas(LayoutStateNotifier notifier) {
  notifier.updateLayoutConfig(
    const LayoutConfig(
      canvasWidth: 240,
      canvasHeight: 240,
      minComponentWidth: 20,
      minComponentHeight: 20,
    ),
  );
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

Future<void> _pressAltI(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  await tester.pumpAndSettle();
}

Future<void> _pressAltC(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  await tester.pumpAndSettle();
}

ComponentData _component(
  String id, {
  required Offset position,
  bool isLocked = false,
}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: const Size(40, 40),
  ).copyWith(isLocked: isLocked);
}
