import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('renders search, filters, and trailing controls in a surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFilterBar(
            search: Text('Search'),
            filters: [Text('Status filter')],
            trailing: [Text('Sort control')],
          ),
        ),
      ),
    );

    expect(find.byType(AppSurface), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Status filter'), findsOneWidget);
    expect(find.text('Sort control'), findsOneWidget);
  });

  testWidgets('can render uncontained for existing panels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppFilterBar(
            contained: false,
            filters: [Text('Only filter')],
            trailing: [Text('Only sort')],
          ),
        ),
      ),
    );

    expect(find.byType(AppSurface), findsNothing);
    expect(find.text('Only filter'), findsOneWidget);
    expect(find.text('Only sort'), findsOneWidget);
  });
}
