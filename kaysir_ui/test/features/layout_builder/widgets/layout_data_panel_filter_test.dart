import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_data_panel.dart';

void main() {
  testWidgets('LayoutDataPanel shows removable active filters', (tester) async {
    final container = _container(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 560, child: LayoutDataPanel())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'cart');
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('Cart '));
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('Unused '));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search "cart"'), findsOneWidget);
    expect(find.text('Category Cart'), findsOneWidget);
    expect(find.text('Usage Unused'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Search "cart"'), findsNothing);
    expect(find.text('Category Cart'), findsOneWidget);
    expect(find.text('Usage Unused'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear category filter'));
    await tester.pumpAndSettle();

    expect(find.text('Category Cart'), findsNothing);
    expect(find.text('Usage Unused'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear usage filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Usage Unused'), findsNothing);

    await tester.enterText(find.byType(TextField), 'cart');
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('Cart '));
    await tester.pumpAndSettle();
    await tester.tap(_filterChipStartingWith('Unused '));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Search "cart"'), findsNothing);
    expect(find.text('Category Cart'), findsNothing);
    expect(find.text('Usage Unused'), findsNothing);
    expect(tester.takeException(), isNull);
  });
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
  tester.view.physicalSize = const Size(640, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}
