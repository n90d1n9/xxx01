import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('restaurant workspace renders empty state from repository', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantWorkspaceScreen(
          repository: DemoRestaurantSnapshotRepository(snapshot: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No restaurant snapshot yet'), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceStatePanel), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceRetryButton), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('restaurant workspace renders loading and error states', (
    tester,
  ) async {
    final completer = Completer<RestaurantOperatingSnapshot?>();

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          repository: CallbackRestaurantSnapshotRepository(() {
            return completer.future;
          }),
        ),
      ),
    );

    expect(find.text('Loading restaurant workspace'), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceStatePanel), findsOneWidget);

    completer.completeError(StateError('offline'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurant data is unavailable'), findsOneWidget);
    expect(find.byType(RestaurantWorkspaceRetryButton), findsOneWidget);
    expect(find.textContaining('offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
