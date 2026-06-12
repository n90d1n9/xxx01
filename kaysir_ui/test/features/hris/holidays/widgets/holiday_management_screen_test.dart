import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/holidays/screens/holiday_management_screen.dart';
import 'package:kaysir/features/hris/holidays/states/holiday_provider.dart';

void main() {
  testWidgets('holiday management screen creates and filters holidays', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
        ],
        child: const MaterialApp(home: HolidayManagementScreen()),
      ),
    );

    expect(find.text('Holiday Management'), findsOneWidget);
    expect(find.text('Publish readiness'), findsOneWidget);
    expect(
      find.text('Assign coverage owners before publishing.'),
      findsWidgets,
    );
    expect(find.text('Release approvals'), findsOneWidget);
    expect(find.text('0/5 approved'), findsOneWidget);
    expect(find.text('HR Operations'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
    expect(find.text('Release package'), findsOneWidget);
    expect(find.text('HOL-2026-004'), findsOneWidget);
    expect(find.text('Package blocked'), findsOneWidget);
    expect(find.text('Release checklist'), findsOneWidget);
    expect(find.text('Package action'), findsOneWidget);
    expect(find.text('Holiday timeline'), findsOneWidget);
    expect(find.text('Jun 2026'), findsWidgets);
    expect(find.text('Coverage focus'), findsOneWidget);
    expect(find.text('Workforce impact'), findsOneWidget);
    expect(find.text('146'), findsOneWidget);
    expect(find.text('Coverage owners needed'), findsWidgets);
    expect(
      find.text('Assign coverage owners for People Operations.'),
      findsWidgets,
    );
    expect(find.text('Coverage planner'), findsOneWidget);
    expect(find.text('Policy review'), findsOneWidget);
    expect(find.text('Communication briefs'), findsOneWidget);
    expect(find.text('Calendar audit'), findsOneWidget);
    expect(find.text('No recorded changes yet'), findsOneWidget);
    expect(find.text('Calendar discovery'), findsOneWidget);
    expect(find.byKey(const Key('holiday-search-field')), findsOneWidget);
    expect(find.text('Needs review'), findsWidgets);
    expect(find.text('Confirm coverage owners'), findsOneWidget);
    expect(
      find.text('Holiday notice: Quarterly Wellness Day on Jun 13, 2026'),
      findsOneWidget,
    );
    expect(find.text('Observed date shifted'), findsOneWidget);
    expect(find.text('National Labor Day'), findsOneWidget);
    expect(find.text('Quarterly Wellness Day'), findsWidgets);
    expect(find.text('All (4)'), findsWidgets);

    final approveButton = find.widgetWithText(FilledButton, 'Approve');
    await tester.ensureVisible(approveButton);
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pumpAndSettle();

    expect(find.text('1/5 approved'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Revoke'), findsOneWidget);

    await tester.tap(find.byTooltip('Add holiday'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('holiday-name-field')),
      'Founders Day',
    );
    await tester.enterText(
      find.byKey(const Key('holiday-date-field')),
      '2026-07-01',
    );
    await tester.enterText(
      find.byKey(const Key('holiday-scope-field')),
      'All offices',
    );
    await tester.enterText(
      find.byKey(const Key('holiday-description-field')),
      'Custom annual company celebration',
    );

    final saveButton = find.byKey(const Key('holiday-save-button'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Founders Day'), findsWidgets);
    expect(find.text('Created'), findsWidgets);
    expect(find.text('Added Custom holiday for All offices.'), findsOneWidget);
    expect(find.text('All (5)'), findsWidgets);
    expect(find.text('Custom (2)'), findsOneWidget);

    final customFilter = find.byKey(const Key('holiday-filter-custom'));
    await tester.ensureVisible(customFilter);
    await tester.pumpAndSettle();
    await tester.tap(customFilter);
    await tester.pumpAndSettle();

    expect(find.text('Quarterly Wellness Day'), findsWidgets);
    expect(find.text('Founders Day'), findsWidgets);
    expect(find.text('National Labor Day'), findsNothing);
  });
}
