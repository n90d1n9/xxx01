import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('provides a Material boundary for lightweight hosts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AppSelectField<String>(
            label: 'Period',
            value: 'This Week',
            options: const [
              AppSelectOption(value: 'This Week', label: 'This Week'),
              AppSelectOption(value: 'Last Week', label: 'Last Week'),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders selected option and reports changes', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppSelectField<String>(
              label: 'Period',
              icon: Icons.calendar_month_outlined,
              value: 'This Week',
              options: const [
                AppSelectOption(value: 'This Week', label: 'This Week'),
                AppSelectOption(value: 'Last Week', label: 'Last Week'),
              ],
              onChanged: (value) => selected = value,
            ),
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

  testWidgets('disabled select field ignores option changes', (tester) async {
    var selected = 'Open';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppSelectField<String>(
              label: 'Status',
              value: selected,
              enabled: false,
              options: const [
                AppSelectOption(value: 'Open', label: 'Open'),
                AppSelectOption(value: 'Closed', label: 'Closed'),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsNothing);
    expect(selected, 'Open');
  });

  testWidgets('supports nullable options for all filters', (tester) async {
    String? selected = 'Open';

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: AppSelectField<String?>(
                  label: 'Status',
                  value: selected,
                  options: const [
                    AppSelectOption(value: null, label: 'All Statuses'),
                    AppSelectOption(value: 'Open', label: 'Open'),
                    AppSelectOption(value: 'Closed', label: 'Closed'),
                  ],
                  onChanged: (value) => setState(() => selected = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Statuses').last);
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('All Statuses'), findsOneWidget);
  });

  testWidgets('supports form validation messages', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppSelectField<String?>(
              label: 'Product',
              value: null,
              options: const [
                AppSelectOption(value: null, label: 'Select Product'),
                AppSelectOption(value: 'p1', label: 'Laptop'),
              ],
              validator:
                  (value) => value == null ? 'Please select a product.' : null,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please select a product.'), findsOneWidget);
  });
}
