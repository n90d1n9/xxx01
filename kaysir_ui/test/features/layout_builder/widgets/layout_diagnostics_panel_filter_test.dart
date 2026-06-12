import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_diagnostics_panel.dart';

void main() {
  testWidgets('LayoutDiagnosticsPanel shows removable active filters', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      _component('outside-layer', 'Outside Layer', Offset(2000, 0)),
      _component('locked-layer', 'Locked Layer', Offset.zero, isLocked: true),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 560, child: LayoutDiagnosticsPanel()),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'outside');
    await tester.pumpAndSettle();
    await tester.tap(_filterChip('Warnings 1'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search "outside"'), findsOneWidget);
    expect(find.text('Filter Warnings'), findsOneWidget);
    expect(find.text('Outside Layer is outside the canvas'), findsOneWidget);
    expect(find.text('Locked Layer is locked'), findsNothing);

    await tester.tap(find.byTooltip('Clear search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Search "outside"'), findsNothing);
    expect(find.text('Filter Warnings'), findsOneWidget);
    expect(find.text('Outside Layer is outside the canvas'), findsOneWidget);
    expect(find.text('Locked Layer is locked'), findsNothing);

    await tester.tap(find.byTooltip('Clear severity filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Outside Layer is outside the canvas'), findsOneWidget);
    expect(find.text('Locked Layer is locked'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'outside');
    await tester.pumpAndSettle();
    await tester.tap(_filterChip('Warnings 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Search "outside"'), findsNothing);
    expect(find.text('Filter Warnings'), findsNothing);
    expect(find.text('Outside Layer is outside the canvas'), findsOneWidget);
    expect(find.text('Locked Layer is locked'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ComponentDiagnosticsCard moves selection to a clear spot', (
    tester,
  ) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      _component(
        'blocker',
        'Blocker',
        const Offset(20, 20),
        size: const Size(40, 40),
      ),
      _component(
        'dragged',
        'Dragged',
        const Offset(20, 20),
        size: const Size(40, 40),
      ),
    ]);
    notifier.selectComponent('dragged');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: ComponentDiagnosticsCard(componentId: 'dragged'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Move to clear spot (Grid c2 r6)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('layout-diagnostics-move-clear-spot')),
      findsOneWidget,
    );

    await tester.tap(find.text('Move to clear spot (Grid c2 r6)'));
    await tester.pumpAndSettle();

    expect(
      notifier.state.componentsById['dragged']?.position,
      const Offset(20, 100),
    );
    expect(
      find.text('Moved selection to clear spot at Grid c2 r6'),
      findsOneWidget,
    );
  });
}

Finder _filterChip(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is FilterChip &&
        widget.label is Text &&
        (widget.label as Text).data == label,
  );
}

ProviderContainer _container(WidgetTester tester) {
  tester.view.physicalSize = const Size(640, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

ComponentData _component(
  String id,
  String name,
  Offset position, {
  Size size = const Size(120, 56),
  bool isLocked = false,
}) {
  final component = ComponentData.create(
    id: id,
    type: ComponentType.textLabel,
    position: position,
    size: size,
  );

  return component.copyWith(
    isLocked: isLocked,
    properties: component.properties.copyWith(
      attributes: <String, dynamic>{'name': name, 'text': name},
    ),
  );
}
