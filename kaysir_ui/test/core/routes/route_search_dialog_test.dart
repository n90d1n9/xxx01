import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/routes/shell/route_search_dialog.dart';
import 'package:kaysir/core/routes/shell/route_search_index.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('route search dialog opens highlighted result from keyboard', (
    tester,
  ) async {
    RouteSearchEntry? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(
            entries: _entries(),
            onSelected: (entry) => selected = entry,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _pressKey(tester, LogicalKeyboardKey.arrowDown);
    await _pressKey(tester, LogicalKeyboardKey.enter);

    expect(selected?.title, 'Beta');
  });

  testWidgets('route search dialog wraps keyboard highlight at boundaries', (
    tester,
  ) async {
    RouteSearchEntry? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(
            entries: _entries(),
            onSelected: (entry) => selected = entry,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _pressKey(tester, LogicalKeyboardKey.arrowUp);
    await _pressKey(tester, LogicalKeyboardKey.enter);

    expect(selected?.title, 'Gamma');

    await _pressKey(tester, LogicalKeyboardKey.arrowDown);
    await _pressKey(tester, LogicalKeyboardKey.enter);

    expect(selected?.title, 'Alpha');
  });

  testWidgets('route search dialog exposes highlighted result semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(entries: _entries(), onSelected: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_resultSemantics(tester, '/alpha').properties.selected, isTrue);
    expect(
      _resultSemantics(tester, '/alpha').properties.label,
      'Alpha, /alpha',
    );
    expect(_resultSemantics(tester, '/beta').properties.selected, isFalse);

    await _pressKey(tester, LogicalKeyboardKey.arrowDown);

    expect(_resultSemantics(tester, '/alpha').properties.selected, isFalse);
    expect(_resultSemantics(tester, '/beta').properties.selected, isTrue);
  });

  testWidgets('route search dialog submits first filtered result', (
    tester,
  ) async {
    RouteSearchEntry? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(
            entries: _entries(),
            onSelected: (entry) => selected = entry,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gamma');
    await tester.pumpAndSettle();
    await _pressKey(tester, LogicalKeyboardKey.enter);

    expect(selected?.title, 'Gamma');
  });

  testWidgets('route search dialog updates route count while filtering', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(entries: _entries(), onSelected: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_countLabel(tester), '3 routes');

    await tester.enterText(find.byType(TextField), 'gamma');
    await tester.pumpAndSettle();

    expect(_countLabel(tester), '1 match');

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();

    expect(_countLabel(tester), '0 matches');
    expect(find.text('No matching routes'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(_countLabel(tester), '3 routes');
  });

  testWidgets('route search dialog clears query on escape before closing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(entries: _entries(), onSelected: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gamma');
    await tester.pumpAndSettle();

    expect(_countLabel(tester), '1 match');

    await _pressKey(tester, LogicalKeyboardKey.escape);

    expect(_countLabel(tester), '3 routes');
    expect(_searchText(tester), isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
    expect(find.byType(RouteSearchDialog), findsOneWidget);
  });

  testWidgets('route search dialog closes on escape when query is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (_) => RouteSearchDialog(
                            entries: _entries(),
                            onSelected: (_) {},
                          ),
                    ),
                child: const Text('Open search'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    expect(find.byType(RouteSearchDialog), findsOneWidget);

    await _pressKey(tester, LogicalKeyboardKey.escape);

    expect(find.byType(RouteSearchDialog), findsNothing);
  });

  testWidgets(
    'route search dialog scrolls highlighted keyboard result into view',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteSearchDialog(
              entries: _manyEntries(),
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _pressKey(tester, LogicalKeyboardKey.end);

      expect(find.text('Route 29'), findsOneWidget);
      expect(_resultSemantics(tester, '/route-29').properties.selected, isTrue);

      await _pressKey(tester, LogicalKeyboardKey.home);

      expect(find.text('Route 00'), findsOneWidget);
      expect(_resultSemantics(tester, '/route-00').properties.selected, isTrue);
    },
  );

  testWidgets('route search dialog labels parent routes as overviews', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(
            entries: buildRouteSearchEntries([
              FeatureRoutes(
                title: 'Inventory',
                subtitle: 'Stock command center',
                path: '/inventory',
                child: const SizedBox.shrink(),
                items: [
                  FeatureRoutes(
                    title: 'Movement History',
                    path: '/inventory/movements',
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ]),
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventory Overview'), findsOneWidget);
    expect(find.text('Overview | Stock command center'), findsOneWidget);
    expect(find.text('Movement History'), findsOneWidget);
  });

  testWidgets('route search dialog shows nested breadcrumb context', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteSearchDialog(
            entries: buildRouteSearchEntries([
              FeatureRoutes(
                title: 'Commerce',
                path: '/commerce',
                child: const SizedBox.shrink(),
                items: [
                  FeatureRoutes(
                    title: 'Orders',
                    path: '/commerce/orders',
                    child: const SizedBox.shrink(),
                    items: [
                      FeatureRoutes(
                        title: 'Evidence',
                        subtitle: 'Proof workspace',
                        path: '/commerce/orders/evidence',
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('Commerce / Orders | Proof workspace'), findsOneWidget);
  });
}

List<RouteSearchEntry> _entries() {
  return buildRouteSearchEntries([
    FeatureRoutes(
      title: 'Alpha',
      path: '/alpha',
      child: const SizedBox.shrink(),
    ),
    FeatureRoutes(title: 'Beta', path: '/beta', child: const SizedBox.shrink()),
    FeatureRoutes(
      title: 'Gamma',
      path: '/gamma',
      child: const SizedBox.shrink(),
    ),
  ]);
}

List<RouteSearchEntry> _manyEntries() {
  return buildRouteSearchEntries([
    for (var index = 0; index < 30; index += 1)
      FeatureRoutes(
        title: 'Route ${index.toString().padLeft(2, '0')}',
        path: '/route-${index.toString().padLeft(2, '0')}',
        child: const SizedBox.shrink(),
      ),
  ]);
}

Future<void> _pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  await tester.pumpAndSettle();
}

Semantics _resultSemantics(WidgetTester tester, String path) {
  return tester.widget<Semantics>(
    find.byKey(ValueKey('route-search-result-semantics-$path')),
  );
}

String _countLabel(WidgetTester tester) {
  return tester
      .widget<AppStatusPill>(
        find.byKey(const ValueKey('route-search-count-pill')),
      )
      .label;
}

String _searchText(WidgetTester tester) {
  return tester.widget<TextField>(find.byType(TextField)).controller!.text;
}
