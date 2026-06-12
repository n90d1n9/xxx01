import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_summary_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_lens_bar.dart';

void main() {
  testWidgets('domain gap lens bar emits reusable focus changes', (
    tester,
  ) async {
    var selectedFocus = ProjectDomainGapFocus.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapLensBar(
            summary: _summaryWithGaps,
            value: selectedFocus,
            onChanged: (focus) => selectedFocus = focus,
          ),
        ),
      ),
    );

    expect(find.text('All Fields'), findsOneWidget);
    expect(find.text('Any Gaps (6)'), findsOneWidget);
    expect(find.text('Required (3)'), findsOneWidget);
    expect(find.text('Recommended (3)'), findsOneWidget);
    expect(find.text('Risk (2)'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-table-brief-any-gap-focus')),
    );
    expect(selectedFocus, ProjectDomainGapFocus.missingAny);

    await tester.tap(
      find.byKey(const ValueKey('project-table-brief-required-gap-focus')),
    );
    expect(selectedFocus, ProjectDomainGapFocus.missingRequired);
  });

  testWidgets('domain gap lens bar hides when no field gaps exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapLensBar(
            summary: const ProjectDomainGapSummary(
              columnCount: 4,
              applicableFieldCount: 12,
              filledFieldCount: 12,
              missingRequiredCount: 0,
              missingRecommendedCount: 0,
              missingRiskSignalCount: 0,
            ),
            value: ProjectDomainGapFocus.all,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('All Fields'), findsNothing);
  });
}

const _summaryWithGaps = ProjectDomainGapSummary(
  columnCount: 4,
  applicableFieldCount: 12,
  filledFieldCount: 6,
  missingRequiredCount: 3,
  missingRecommendedCount: 3,
  missingRiskSignalCount: 2,
);
