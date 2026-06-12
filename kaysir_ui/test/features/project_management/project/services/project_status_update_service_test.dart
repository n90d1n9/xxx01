import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project status update adapts wording for software delivery', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final brief = buildProjectStatusUpdateBrief(
      project: project,
      vocabulary: ProjectStatusUpdateVocabulary.software,
      timelineTasks: [
        gantt.GanttTask(
          id: '3',
          title: 'Development',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 20),
          progress: 0.35,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(brief.signal, ProjectStatusUpdateSignal.blocked);
    expect(brief.audience, ProjectStatusUpdateAudience.stakeholder);
    expect(brief.headline, contains('product release is blocked'));
    expect(brief.summary, contains('delivery review'));
    expect(brief.summary, contains('release readiness'));
    expect(brief.watchItems.join(' '), contains('delivery risk'));
    expect(brief.nextActions.join(' '), contains('delivery owner'));
    expect(brief.draftText, contains('Highlights'));
    expect(brief.draftText, contains('Watch items'));
    expect(brief.draftText, contains('Next actions'));
    expect(brief.draftText, contains('- 18% product release progress'));
  });

  test('project status update adapts intent for client audience', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'retail-modernization',
    );
    final brief = buildProjectStatusUpdateBrief(
      project: project,
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.client,
      timelineTasks: const [],
      today: DateTime(2026, 5, 31),
    );

    expect(brief.audience, ProjectStatusUpdateAudience.client);
    expect(brief.summary, contains('client delivery update'));
    expect(brief.draftText, startsWith('Audience: Client'));
    expect(
      brief.nextActions.join(' '),
      contains('client-facing note on release checkpoint timing'),
    );
  });

  test('project status update adapts wording for retail operations', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'retail-modernization',
    );
    final brief = buildProjectStatusUpdateBrief(
      project: project,
      vocabulary: ProjectStatusUpdateVocabulary.retailOperations,
      audience: ProjectStatusUpdateAudience.team,
      timelineTasks: [
        gantt.GanttTask(
          id: 'store-wave',
          title: 'Jakarta pilot store launch',
          startDate: DateTime(2026, 5, 20),
          endDate: DateTime(2026, 6, 12),
          progress: 0.42,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(brief.headline, contains('store rollout'));
    expect(brief.summary, contains('rollout calendar team sync'));
    expect(brief.summary, contains('launch readiness'));
    expect(brief.highlights.join(' '), contains('rollout budget'));
    expect(brief.watchItems.join(' '), contains('store readiness risk'));
    expect(brief.nextActions.join(' '), contains('store rollout owner'));
  });

  test('project status update accepts custom business vocabulary', () {
    const custom = ProjectStatusUpdateVocabulary(
      id: 'legal-casework',
      label: 'Legal',
      icon: Icons.gavel_outlined,
      workLabel: 'casework matter',
      milestoneLabel: 'filing checkpoint',
      riskLabel: 'case risk',
      scheduleLabel: 'court calendar',
      scheduleItemLabel: 'case task',
      budgetLabel: 'fee plan',
      ownerLabel: 'case owner',
      readinessLabel: 'case readiness',
      audienceLabel: 'client case update',
    );
    final project = demoProjectPortfolio.first;
    final brief = buildProjectStatusUpdateBrief(
      project: project,
      vocabulary: custom,
      timelineTasks: const [],
      today: DateTime(2026, 5, 31),
    );

    expect(brief.headline, contains('casework matter'));
    expect(brief.summary, contains('client case update'));
    expect(brief.highlights.join(' '), contains('fee plan'));
    expect(brief.nextActions.first, contains('case owner'));
    expect(brief.draftText, startsWith(brief.headline));
    expect(brief.draftText, contains('- Confirm case owner handoff'));
  });
}
