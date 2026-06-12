import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section_progress.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_progress.dart';

void main() {
  testWidgets('detail progress returns to overview when active', (
    tester,
  ) async {
    var returnCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionDetailProgress(
            progress: const DashboardActionDetailSectionProgress(
              sectionLabel: 'Playbook',
              ownerActionCue: 'Finish the active playbook step',
              sectionIndex: 5,
              sectionCount: 5,
            ),
            onReturnToOverview: () => returnCount += 1,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Back to overview'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Back to overview'));
    await tester.pump();

    expect(returnCount, 1);
  });

  testWidgets('detail progress advances to the next section', (tester) async {
    var returnCount = 0;
    var nextCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionDetailProgress(
            progress: const DashboardActionDetailSectionProgress(
              sectionLabel: 'Evidence',
              ownerActionCue: 'Share the evidence timeline',
              sectionIndex: 2,
              sectionCount: 5,
            ),
            onReturnToOverview: () => returnCount += 1,
            onGoToNextSection: () => nextCount += 1,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Back to overview'), findsOneWidget);
    expect(find.byTooltip('Next section'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    expect(find.text('Do next: Share the evidence timeline'), findsOneWidget);

    await tester.tap(find.byTooltip('Next section'));
    await tester.pump();

    expect(nextCount, 1);
    expect(returnCount, 0);
  });

  testWidgets('detail progress moves to the previous section', (tester) async {
    var returnCount = 0;
    var previousCount = 0;
    var nextCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionDetailProgress(
            progress: const DashboardActionDetailSectionProgress(
              sectionLabel: 'Impact',
              ownerActionCue: 'Confirm the impact target',
              sectionIndex: 4,
              sectionCount: 5,
            ),
            onReturnToOverview: () => returnCount += 1,
            onGoToPreviousSection: () => previousCount += 1,
            onGoToNextSection: () => nextCount += 1,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Previous section'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsWidgets);
    expect(find.byTooltip('Next section'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous section'));
    await tester.pump();

    expect(previousCount, 1);
    expect(nextCount, 0);
    expect(returnCount, 0);
  });

  testWidgets('detail progress is passive on overview', (tester) async {
    var returnCount = 0;
    var previousCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionDetailProgress(
            progress: DashboardActionDetailSectionProgress.initial,
            onReturnToOverview: () => returnCount += 1,
            onGoToPreviousSection: () => previousCount += 1,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Viewing overview'), findsOneWidget);
    expect(find.byTooltip('First section'), findsOneWidget);

    await tester.tap(find.byTooltip('Viewing overview'));
    await tester.pump();

    expect(returnCount, 0);
    expect(previousCount, 0);
  });
}
