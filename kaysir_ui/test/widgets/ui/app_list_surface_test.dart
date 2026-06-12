import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('renders layout slots before list items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppListSurface(
            header: Text('Header'),
            metrics: Text('Metrics'),
            filters: Text('Filters'),
            children: [Text('First item'), Text('Second item')],
          ),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Metrics'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('First item'), findsOneWidget);
    expect(find.text('Second item'), findsOneWidget);
    expect(find.text('Empty'), findsNothing);
  });

  testWidgets('uses empty state when list items are absent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppListSurface(
            filters: Text('Filters'),
            emptyState: Text('Empty'),
            children: [],
          ),
        ),
      ),
    );

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
  });
}
