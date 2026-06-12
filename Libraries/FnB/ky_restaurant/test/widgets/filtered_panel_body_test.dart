import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('filtered panel body shows source empty state without controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantFilteredPanelBody(
          hasItems: false,
          hasVisibleItems: false,
          emptyState: Text('No source items'),
          controls: Text('Controls'),
          emptyResultsState: Text('No filtered items'),
          results: Text('Results'),
        ),
      ),
    );

    expect(find.text('No source items'), findsOneWidget);
    expect(find.text('Controls'), findsNothing);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('filtered panel body swaps filtered empty state and results', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantFilteredPanelBody(
          hasItems: true,
          hasVisibleItems: false,
          emptyState: Text('No source items'),
          controls: Text('Controls'),
          emptyResultsState: Text('No filtered items'),
          results: Text('Results'),
        ),
      ),
    );

    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('No filtered items'), findsOneWidget);
    expect(find.text('Results'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: RestaurantFilteredPanelBody(
          hasItems: true,
          hasVisibleItems: true,
          emptyState: Text('No source items'),
          controls: Text('Controls'),
          emptyResultsState: Text('No filtered items'),
          results: Text('Results'),
        ),
      ),
    );

    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('No filtered items'), findsNothing);
    expect(find.text('Results'), findsOneWidget);
  });
}
