import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_toolbar_select.dart';

void main() {
  testWidgets('renders and reports selected toolbar option', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminToolbarSelect<String>(
            label: 'Period',
            icon: Icons.calendar_month_outlined,
            value: 'This Week',
            options: const [
              AdminToolbarSelectOption(value: 'This Week', label: 'This Week'),
              AdminToolbarSelectOption(value: 'Last Week', label: 'Last Week'),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('Period'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Week').last);
    await tester.pumpAndSettle();

    expect(selected, 'Last Week');
  });
}
