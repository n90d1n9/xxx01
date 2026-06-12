import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_search_trigger.dart';

void main() {
  testWidgets('expanded search trigger shows command field and handles taps', (
    tester,
  ) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdminSearchTrigger(
              expanded: true,
              onPressed: () => pressed += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search pages...'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);

    await tester.tap(find.byType(AdminSearchTrigger));

    expect(pressed, 1);
  });

  testWidgets('compact search trigger uses an icon action', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminSearchTrigger(
            expanded: false,
            onPressed: () => pressed += 1,
          ),
        ),
      ),
    );

    expect(find.text('Search pages...'), findsNothing);
    expect(find.byTooltip('Search pages'), findsOneWidget);

    await tester.tap(find.byTooltip('Search pages'));

    expect(pressed, 1);
  });
}
