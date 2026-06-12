import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/search/screens/search_form.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';

void main() {
  testWidgets('uses compact toolbar layout in tight vertical space', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 50, width: 500, child: SearchForm()),
          ),
        ),
      ),
    );

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(AppIconActionButton), findsNWidgets(2));
    expect(find.text('No results found'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses expanded layout when there is enough room', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 420, width: 640, child: SearchForm()),
          ),
        ),
      ),
    );

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('advanced filters use reusable checkbox rows', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 420, width: 640, child: SearchForm()),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Advanced search'));
    await tester.pumpAndSettle();

    expect(find.byType(AppCheckboxRow), findsNWidgets(2));
    expect(find.text('Filter 1'), findsOneWidget);
    expect(find.text('Filter 2'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isFalse);

    await tester.tap(find.text('Filter 1'));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
  });
}
