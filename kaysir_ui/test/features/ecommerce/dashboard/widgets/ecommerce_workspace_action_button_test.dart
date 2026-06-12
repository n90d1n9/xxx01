import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ActionButton renders plain action', (tester) async {
    var taps = 0;

    await tester.pumpWorkspaceWidget(
      ActionButton(
        variant: ActionButtonVariant.plain,
        icon: Icons.open_in_new_outlined,
        label: 'View details',
        onPressed: () => taps++,
      ),
    );

    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('View details'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_outlined), findsOneWidget);

    await tester.tap(find.text('View details'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('ActionButton renders filled actions', (tester) async {
    final tapped = <String>[];

    await tester.pumpWorkspaceWidget(
      Column(
        children: [
          ActionButton(
            icon: Icons.arrow_forward,
            label: 'Open checkout',
            onPressed: () => tapped.add('tonal'),
          ),
          ActionButton(
            variant: ActionButtonVariant.primary,
            icon: Icons.check_circle_outline,
            label: 'Use profile',
            onPressed: () => tapped.add('primary'),
          ),
        ],
      ),
    );

    expect(find.byType(FilledButton), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.tap(find.text('Open checkout'));
    await tester.tap(find.text('Use profile'));
    await tester.pump();

    expect(tapped, ['tonal', 'primary']);
  });

  testWidgets('ActionButton renders outlined action', (tester) async {
    var tapped = false;

    await tester.pumpWorkspaceWidget(
      ActionButton(
        variant: ActionButtonVariant.outlined,
        icon: Icons.rule_folder_outlined,
        label: 'Review policy',
        tooltip: 'Promise policy needs review',
        onPressed: () => tapped = true,
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Review policy'), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);

    await tester.tap(find.text('Review policy'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
