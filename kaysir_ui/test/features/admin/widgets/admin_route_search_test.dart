import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/admin/models/admin_route_search_entry.dart';
import 'package:kaysir/features/admin/widgets/admin_route_search.dart';

void main() {
  testWidgets('route search filters and reports the selected page', (
    tester,
  ) async {
    AdminRouteSearchEntry? selectedEntry;
    final entries = [
      _entry(title: 'Dashboard', path: '/dashboard'),
      _entry(title: 'Cashier', path: '/pos/cashier', section: 'POS'),
      _entry(title: 'Inventory', path: '/inventory'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 720)),
          child: Scaffold(
            body: AdminRouteSearchPanel(
              entries: entries,
              onSelected: (entry) => selectedEntry = entry,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Cashier'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cash');
    await tester.pump();

    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Cashier'), findsOneWidget);

    await tester.tap(find.text('Cashier'));
    await tester.pump();

    expect(selectedEntry?.title, 'Cashier');
  });

  testWidgets('route search clear action restores the full result list', (
    tester,
  ) async {
    final entries = [
      _entry(title: 'Dashboard', path: '/dashboard'),
      _entry(title: 'Cashier', path: '/pos/cashier', section: 'POS'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 720)),
          child: Scaffold(
            body: AdminRouteSearchPanel(entries: entries, initialQuery: 'cash'),
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Cashier'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Cashier'), findsOneWidget);
  });

  testWidgets('route search submit selects the top filtered result', (
    tester,
  ) async {
    AdminRouteSearchEntry? selectedEntry;
    final entries = [
      _entry(title: 'Dashboard', path: '/dashboard'),
      _entry(title: 'Cashier', path: '/pos/cashier', section: 'POS'),
      _entry(title: 'Inventory', path: '/inventory'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 720)),
          child: Scaffold(
            body: AdminRouteSearchPanel(
              entries: entries,
              onSelected: (entry) => selectedEntry = entry,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'cash');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(selectedEntry?.title, 'Cashier');
  });
}

AdminRouteSearchEntry _entry({
  required String title,
  required String path,
  String? section,
}) {
  return AdminRouteSearchEntry(
    route: FeatureRoutes(title: title, path: path),
    title: title,
    section: section,
  );
}
