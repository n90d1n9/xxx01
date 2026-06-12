import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('handoff verification checklist reports step changes', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenHandoffVerificationChecklist(
            plan: KitchenHandoffVerificationPlan(
              steps: const [
                KitchenHandoffVerificationStep(
                  id: 'critical-alerts',
                  type: KitchenHandoffVerificationStepType.criticalAlerts,
                  label: 'Verify critical alert',
                  description: 'Allergy: Peanut allergy',
                ),
                KitchenHandoffVerificationStep(
                  id: 'service-notes',
                  type: KitchenHandoffVerificationStepType.serviceNotes,
                  label: 'Review service note',
                  description: 'Window table.',
                ),
              ],
              records: [
                KitchenHandoffVerificationRecord(
                  stepId: 'critical-alerts',
                  verifiedAt: DateTime(2026, 6, 10, 18, 30),
                  verifiedBy: 'Expo',
                ),
              ],
            ),
            onStepChanged: (stepId, verified) {
              changes.add('$stepId:$verified');
            },
          ),
        ),
      ),
    );

    expect(find.text('Handoff checks'), findsOneWidget);
    expect(find.text('1 / 2 verified'), findsOneWidget);
    expect(find.text('Verify critical alert'), findsOneWidget);
    expect(find.text('Verified: Expo - 18:30'), findsOneWidget);
    expect(find.text('Review service note'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();

    expect(changes, ['service-notes:true']);
  });

  testWidgets('handoff verification checklist renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenHandoffVerificationChecklist(
            plan: KitchenHandoffVerificationPlan(steps: const []),
          ),
        ),
      ),
    );

    expect(find.text('Handoff checks'), findsOneWidget);
    expect(find.text('No checks needed'), findsOneWidget);
    expect(find.text('Ready to serve'), findsOneWidget);
  });
}
