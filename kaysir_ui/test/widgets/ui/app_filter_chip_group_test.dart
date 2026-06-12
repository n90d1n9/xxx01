import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';

void main() {
  testWidgets('renders options and reports selected filter changes', (
    tester,
  ) async {
    var selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: AppFilterChipGroup<String>(
                  value: selected,
                  options: const [
                    AppFilterChipOption(
                      value: 'all',
                      label: 'All',
                      icon: Icons.all_inclusive,
                    ),
                    AppFilterChipOption(
                      value: 'overdue',
                      label: 'Overdue',
                      icon: Icons.warning_amber_rounded,
                      count: 3,
                      tooltip: 'Overdue work needs attention',
                    ),
                  ],
                  onChanged: (value) => setState(() => selected = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Overdue'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byTooltip('Overdue work needs attention'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
    await tester.pump();

    expect(selected, 'overdue');
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Overdue'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('disabled chip group ignores taps', (tester) async {
    var selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppFilterChipGroup<String>(
              value: selected,
              enabled: false,
              options: const [
                AppFilterChipOption(value: 'all', label: 'All'),
                AppFilterChipOption(value: 'paid', label: 'Paid'),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Paid'));
    await tester.pump();

    expect(selected, 'all');
  });
}
