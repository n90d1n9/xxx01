import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_plan_action_summary.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_preview_pill.dart';

void main() {
  testWidgets('switch plan action summary renders action pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: POSSwitchPlanActionSummary(
            items: [
              POSSwitchPlanActionSummaryItem(
                icon: Icons.swap_horiz_outlined,
                label: 'Switch channel',
                tone: POSSwitchPreviewTone.positive,
              ),
              POSSwitchPlanActionSummaryItem(
                icon: Icons.assignment_late_outlined,
                label: 'Review fulfillment',
                tone: POSSwitchPreviewTone.warning,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Switch channel'), findsOneWidget);
    expect(find.text('Review fulfillment'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_outlined), findsOneWidget);
    expect(find.byIcon(Icons.assignment_late_outlined), findsOneWidget);
  });

  testWidgets('switch plan action summary stays empty without actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: POSSwitchPlanActionSummary(items: [])),
      ),
    );

    expect(find.byType(POSSwitchPreviewPill), findsNothing);
  });
}
