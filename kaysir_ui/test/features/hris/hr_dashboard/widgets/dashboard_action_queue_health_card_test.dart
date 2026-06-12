import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_health.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_queue_health_card.dart';

void main() {
  testWidgets('dashboard action queue health card renders queue state', (
    tester,
  ) async {
    final focusedUrgencies = <DashboardActionUrgencyTier>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionQueueHealthCard(
            health: const DashboardActionQueueHealth(
              tone: DashboardActionQueueHealthTone.atRisk,
              label: 'At risk',
              headline: '1 due-now action needs ownership',
              detail: 'Start or assign the same-day work.',
              focusUrgency: DashboardActionUrgencyTier.now,
              actionLabel: 'Focus due now',
            ),
            onFocusUrgency: focusedUrgencies.add,
          ),
        ),
      ),
    );

    expect(find.text('Queue health'), findsOneWidget);
    expect(find.text('At risk'), findsOneWidget);
    expect(find.text('1 due-now action needs ownership'), findsOneWidget);
    expect(find.text('Focus due now'), findsOneWidget);
    expect(find.byIcon(Icons.notification_important_outlined), findsOneWidget);

    await tester.tap(find.text('Focus due now'));
    await tester.pump();

    expect(focusedUrgencies, [DashboardActionUrgencyTier.now]);
  });
}
