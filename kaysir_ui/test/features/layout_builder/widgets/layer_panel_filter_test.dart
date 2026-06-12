import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/component_properties.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/layer_panel.dart';

void main() {
  testWidgets('LayerPanel shows removable active filters', (tester) async {
    final container = _container(tester);
    final notifier = container.read(layoutStateProvider.notifier);
    notifier.addComponents([
      _component('alpha-layer', 'Alpha Layer'),
      _component('locked-layer', 'Locked Layer', isLocked: true),
      _component('hidden-layer', 'Hidden Layer', isVisible: false),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 520, child: LayerPanel())),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pumpAndSettle();
    await tester.tap(_filterChip('Locked 1'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search "alpha"'), findsOneWidget);
    expect(find.text('Filter Locked'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Search "alpha"'), findsNothing);
    expect(find.text('Filter Locked'), findsOneWidget);
    expect(find.text('Locked Layer'), findsOneWidget);
    expect(find.text('Alpha Layer'), findsNothing);

    await tester.tap(find.byTooltip('Clear state filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Filter Locked'), findsNothing);
    expect(find.text('Alpha Layer'), findsOneWidget);
    expect(find.text('Locked Layer'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pumpAndSettle();
    await tester.tap(_filterChip('Locked 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Alpha Layer'), findsOneWidget);
    expect(find.text('Locked Layer'), findsOneWidget);
    expect(find.text('Hidden Layer'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
  String name, {
  bool isLocked = false,
  bool isVisible = true,
}) {
  final component = ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: Offset.zero,
  );

  return component.copyWith(
    isLocked: isLocked,
    isVisible: isVisible,
    properties: component.properties.copyWith(
      attributes: <String, dynamic>{'name': name},
    ),
  );
}
