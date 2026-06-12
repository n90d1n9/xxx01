import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/layout_builder/provider/component_preset_provider.dart';
import 'package:kaysir/features/layout_builder/screens/editor_screen.dart';

void main() {
  testWidgets('EditorScreen palette shows removable active filters', (
    tester,
  ) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: EditorScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_componentSearchField(), 'button');
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('POS '));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search "button"'), findsOneWidget);
    expect(find.text('Filter POS'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Search "button"'), findsNothing);
    expect(find.text('Filter POS'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear palette filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Filter POS'), findsNothing);

    await tester.enterText(_componentSearchField(), 'button');
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('POS '));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Search "button"'), findsNothing);
    expect(find.text('Filter POS'), findsNothing);
    final exception = tester.takeException();
    if (exception is FlutterError) {
      debugPrint(exception.toStringDeep());
    }
    expect(exception, isNull);
  });
}

Finder _componentSearchField() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Search components',
  );
}

Finder _filterChipStartingWith(String labelPrefix) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is FilterChip &&
        widget.label is Text &&
        ((widget.label as Text).data?.startsWith(labelPrefix) ?? false),
  );
}

ProviderContainer _container(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [componentPresetProvider.overrideWith((ref) async => const [])],
  );
  addTearDown(container.dispose);
  return container;
}
