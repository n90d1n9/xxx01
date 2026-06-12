import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_urgency_overview_strip.dart';

void main() {
  testWidgets('dashboard action urgency overview shows all urgency tiers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardActionUrgencyOverviewStrip(
            urgencies: [
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.now,
                totalCount: 2,
              ),
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.soon,
                totalCount: 1,
              ),
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.closed,
                totalCount: 1,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Urgency overview'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('Due soon'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('dashboard action urgency overview focuses urgency tiers', (
    tester,
  ) async {
    final changes = <DashboardActionUrgencyTier?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionUrgencyOverviewStrip(
            urgencies: const [
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.now,
                totalCount: 2,
              ),
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.soon,
                totalCount: 1,
              ),
            ],
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Focus Due now'));
    await tester.pump();

    expect(changes, [DashboardActionUrgencyTier.now]);
  });

  testWidgets('dashboard action urgency overview clears selected urgency', (
    tester,
  ) async {
    final changes = <DashboardActionUrgencyTier?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionUrgencyOverviewStrip(
            urgencies: const [
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.now,
                totalCount: 2,
              ),
            ],
            selectedUrgency: DashboardActionUrgencyTier.now,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Clear Due now focus'));
    await tester.pump();

    expect(changes, [null]);
  });

  testWidgets('dashboard action urgency overview ignores empty urgency tiers', (
    tester,
  ) async {
    final changes = <DashboardActionUrgencyTier?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionUrgencyOverviewStrip(
            urgencies: const [
              DashboardActionUrgencySummary(
                tier: DashboardActionUrgencyTier.now,
                totalCount: 2,
              ),
            ],
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('No Planned actions'));
    await tester.pump();

    expect(changes, isEmpty);
  });
}
