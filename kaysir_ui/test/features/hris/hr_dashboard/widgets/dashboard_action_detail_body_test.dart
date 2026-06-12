import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section_progress.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_body.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action detail body jumps between sections', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail();
    final progressUpdates = <DashboardActionDetailSectionProgress>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            height: 360,
            child: DashboardActionDetailBody(
              detail: detail,
              onSectionProgressChanged: progressUpdates.add,
            ),
          ),
        ),
      ),
    );

    for (final section in DashboardActionDetailSection.values) {
      expect(
        find.byTooltip('Jump to ${section.label.toLowerCase()}'),
        findsOneWidget,
      );
    }
    expect(find.byTooltip('Jump to playbook'), findsOneWidget);
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Overview')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Playbook')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isFalse),
    );

    final beforeJump = tester.getTopLeft(find.text('Guided playbook')).dy;

    await tester.tap(find.byTooltip('Jump to playbook'));
    await tester.pumpAndSettle();

    final afterJump = tester.getTopLeft(find.text('Guided playbook')).dy;
    expect(afterJump, lessThan(beforeJump));
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Playbook')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );
    expect(progressUpdates.last.sectionLabel, 'Playbook');
    expect(
      progressUpdates.last.positionLabel,
      'Section ${DashboardActionDetailSection.playbook.index + 1} '
      'of ${DashboardActionDetailSection.values.length}',
    );
  });

  testWidgets('dashboard action detail body tracks section while scrolling', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            height: 360,
            child: DashboardActionDetailBody(detail: detail),
          ),
        ),
      ),
    );

    final playbookChip = find.widgetWithText(ChoiceChip, 'Playbook');
    final initialChipTop = tester.getTopLeft(playbookChip).dy;
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Overview')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2200),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(playbookChip).dy, closeTo(initialChipTop, 0.1));
    expect(
      tester.widget<ChoiceChip>(playbookChip),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );
  });
}
