import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_status_update_draft_card.dart';
import 'package:kaysir/features/project_management/project/widgets/project_status_update_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project status update panel switches business vocabulary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 980,
              child: ProjectStatusUpdateComposerPanel(
                project: _weddingProject(),
                timelineTasks: [
                  gantt.GanttTask(
                    id: 'vendor',
                    title: 'Vendor confirmation',
                    startDate: DateTime(2026, 5, 20),
                    endDate: DateTime(2026, 5, 29),
                    progress: 0.35,
                  ),
                ],
                today: DateTime(2026, 5, 31),
                availableVocabularies: const [
                  ProjectStatusUpdateVocabulary.general,
                  ProjectStatusUpdateVocabulary.wedding,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
    expect(find.text('Stakeholder'), findsOneWidget);
    expect(find.text('Sponsor'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Suggested: Wedding / Client'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    expect(find.textContaining('project is blocked'), findsWidgets);
    expect(find.textContaining('stakeholder update'), findsWidgets);
    expect(find.byType(ProjectStatusUpdateDraftCard), findsOneWidget);
    expect(find.text('Briefing draft'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.textContaining('Highlights'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Wedding'));
    await tester.pump();

    expect(find.textContaining('wedding production is blocked'), findsWidgets);
    expect(find.textContaining('client planning update'), findsWidgets);
    expect(find.textContaining('wedding budget'), findsWidgets);
    expect(find.textContaining('vendor risk'), findsWidgets);
    expect(find.textContaining('planner'), findsWidgets);
    expect(find.textContaining('Next actions'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Client'));
    await tester.pump();

    expect(find.textContaining('client delivery update'), findsWidgets);
    expect(find.textContaining('Audience: Client'), findsWidgets);
    expect(find.textContaining('client-facing note'), findsWidgets);
  });

  testWidgets(
    'project status update panel applies recommended wording profile',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 980,
                child: ProjectStatusUpdateComposerPanel(
                  project: _weddingProject(),
                  timelineTasks: [
                    gantt.GanttTask(
                      id: 'vendor',
                      title: 'Vendor confirmation',
                      startDate: DateTime(2026, 5, 20),
                      endDate: DateTime(2026, 5, 29),
                      progress: 0.35,
                    ),
                  ],
                  availableVocabularies: const [
                    ProjectStatusUpdateVocabulary.general,
                    ProjectStatusUpdateVocabulary.wedding,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(find.text('Suggested: Wedding / Client'), findsNothing);
      expect(
        find.textContaining('wedding production is blocked'),
        findsWidgets,
      );
      expect(find.textContaining('client delivery update'), findsWidgets);
      expect(find.textContaining('Audience: Client'), findsWidgets);
    },
  );

  testWidgets('project status update panel supports controlled vocabulary', (
    tester,
  ) async {
    var selectedVocabulary = ProjectStatusUpdateVocabulary.general;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 980,
                  child: ProjectStatusUpdateComposerPanel(
                    project: _weddingProject(),
                    timelineTasks: const [],
                    selectedVocabulary: selectedVocabulary,
                    availableVocabularies: const [
                      ProjectStatusUpdateVocabulary.general,
                      ProjectStatusUpdateVocabulary.wedding,
                    ],
                    onVocabularyChanged:
                        (vocabulary) => setState(() {
                          selectedVocabulary = vocabulary;
                        }),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('project is blocked'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Wedding'));
    await tester.pump();

    expect(selectedVocabulary, ProjectStatusUpdateVocabulary.wedding);
    expect(find.textContaining('wedding production is blocked'), findsWidgets);
  });
}

ProjectPortfolioItem _weddingProject() {
  return ProjectPortfolioItem(
    id: 'grand-hall-wedding',
    name: 'Grand Hall Wedding',
    owner: 'Ayu Prameswari',
    client: 'Sari & Bagas',
    sponsor: 'Family Committee',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 6, 20),
    progress: 0.52,
    budgetUsed: 0.73,
    health: ProjectHealth.blocked,
    milestones: [
      ProjectMilestone(
        label: 'Vendor Lock',
        dueDate: DateTime(2026, 6, 4),
        isComplete: false,
      ),
    ],
    risks: const [
      ProjectDeliveryRisk(
        title: 'Catering confirmation',
        detail: 'Menu and guest count need a signed final order.',
        severity: ProjectHealth.blocked,
      ),
    ],
  );
}
