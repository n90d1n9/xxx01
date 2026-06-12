import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_components.dart';
import 'package:kaysir/features/project_management/project/widgets/project_team_avatar_stack.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets(
    'project portfolio components render reusable summary and cards',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 900,
                child: Column(
                  children: [
                    ProjectPortfolioSummaryGrid(projects: [_project()]),
                    const SizedBox(height: 16),
                    ProjectPortfolioSavedViewsBar(
                      projects: [_project()],
                      value: ProjectPortfolioViewPreset.all,
                      onChanged: (_) {},
                      today: DateTime(2026, 5, 31),
                    ),
                    const SizedBox(height: 16),
                    ProjectPortfolioList(projects: [_project()]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppMetricGrid), findsOneWidget);
      expect(find.text('Active Projects'), findsOneWidget);
      expect(find.text('Needs Attention'), findsWidgets);
      expect(find.text('Domain Context'), findsOneWidget);
      expect(find.text('1 need context - 0 ready'), findsOneWidget);
      expect(find.text('All Projects'), findsOneWidget);
      expect(find.byType(ProjectPortfolioCard), findsOneWidget);
      expect(find.byType(AppStatusPill), findsWidgets);
      expect(find.text('Retail Modernization'), findsOneWidget);
      expect(find.text('General Business'), findsOneWidget);
      expect(find.text('0/4 Needs Context'), findsOneWidget);
      expect(find.text('Pilot Jun 21'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('project-team-avatar-summary')),
        findsOneWidget,
      );
      expect(find.text('4 contributors'), findsOneWidget);
      expect(find.text('58% avg'), findsOneWidget);
    },
  );

  testWidgets('project portfolio list exposes focused gantt action', (
    tester,
  ) async {
    ProjectPortfolioItem? focusedProject;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: ProjectPortfolioList(
              projects: [_project()],
              onFocusGantt: (project) => focusedProject = project,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Focus Gantt'), findsOneWidget);

    await tester.tap(find.text('Focus Gantt'));
    await tester.pump();

    expect(focusedProject?.id, 'retail-modernization');
  });

  testWidgets('project team avatar stack exposes overflow members', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectTeamAvatarSummary(members: _team(), maxVisible: 2),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('project-team-avatar-stack')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-team-avatar-maya-santoso')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-team-avatar-overflow')),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        '3 more team members\n'
        'Dian Lestari - Retail Analyst, 60% allocated\n'
        'Iqbal Karim - QA Lead, 40% allocated\n'
        'Nadia Putri - Delivery Analyst, 50% allocated',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Project team member: Maya Santoso - Delivery Lead, 80% allocated',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        '3 more team members: '
        'Dian Lestari - Retail Analyst, 60% allocated, '
        'Iqbal Karim - QA Lead, 40% allocated, '
        'Nadia Putri - Delivery Analyst, 50% allocated',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('project portfolio list uses shared empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 320,
            child: ProjectPortfolioList(projects: []),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No projects found'), findsOneWidget);
  });

  testWidgets('project active filters bar reports custom board view', (
    tester,
  ) async {
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectPortfolioActiveFiltersBar(
            query: 'mobile',
            viewPreset: ProjectPortfolioViewPreset.budgetPressure,
            healthFilter: ProjectHealth.blocked,
            domainReadinessFilter: ProjectDomainReadinessFilter.needsContext,
            domainGapFocus: ProjectDomainGapFocus.missingRequired,
            sortOption: ProjectPortfolioSortOption.budget,
            visibleCount: 1,
            totalCount: 4,
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.text('Active view'), findsOneWidget);
    expect(find.text('1 of 4 projects'), findsOneWidget);
    expect(find.text('"mobile"'), findsOneWidget);
    expect(find.text('Budget Pressure'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Needs Context'), findsOneWidget);
    expect(find.text('Required Gaps'), findsOneWidget);
    expect(find.text('Sort: Budget Used'), findsOneWidget);

    await tester.tap(find.text('Clear View'));
    expect(cleared, true);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'retail-modernization',
    name: 'Retail Modernization',
    owner: 'Maya Santoso',
    client: 'Kaysir Retail',
    startDate: DateTime(2026, 5),
    endDate: DateTime(2026, 8, 14),
    progress: 0.62,
    budgetUsed: 0.58,
    health: ProjectHealth.onTrack,
    milestones: [
      ProjectMilestone(
        label: 'Pilot',
        dueDate: DateTime(2026, 6, 21),
        isComplete: false,
      ),
    ],
    team: _team(),
  );
}

List<ProjectTeamMember> _team() {
  return const [
    ProjectTeamMember(
      name: 'Maya Santoso',
      role: 'Delivery Lead',
      allocation: 0.8,
    ),
    ProjectTeamMember(
      name: 'Dian Lestari',
      role: 'Retail Analyst',
      allocation: 0.6,
    ),
    ProjectTeamMember(name: 'Iqbal Karim', role: 'QA Lead', allocation: 0.4),
    ProjectTeamMember(
      name: 'Nadia Putri',
      role: 'Delivery Analyst',
      allocation: 0.5,
    ),
  ];
}
