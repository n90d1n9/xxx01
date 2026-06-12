import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_form_creation_service.dart';

void main() {
  test('project form creation builds unique portfolio records', () {
    const service = ProjectFormCreationService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Retail Modernization',
      client: 'Store Ops',
      owner: 'Maya Santoso',
      sponsor: 'Retail Operations',
      businessDomain: 'Retail Operations',
      summary:
          'Extends store operations rollout with evidence, timeline, and launch controls.',
      progress: 0.4,
      budgetUsed: 0.3,
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta pilot',
          isPinned: true,
        ),
        ProjectCustomAttribute(
          key: 'blank-template',
          label: 'Blank Template',
          type: ProjectCustomAttributeType.text,
        ),
      ],
    );

    final project = service.createProject(
      draft: draft,
      existingProjects: demoProjectPortfolio,
    );

    expect(project.id, 'retail-modernization-2');
    expect(project.name, 'Retail Modernization');
    expect(project.milestones, hasLength(3));
    expect(project.milestones.first.label, 'Jakarta pilot: Store pilot ready');
    expect(project.milestones.first.isComplete, isTrue);
    expect(project.customAttributes, hasLength(1));
    expect(project.customAttributes.single.displayValue, 'Jakarta pilot');
    expect(project.risks, hasLength(1));
    expect(project.risks.single.title, 'Launch wave readiness');
    expect(project.team, hasLength(3));
    expect(project.team.first.role, 'Store Rollout Lead');
    expect(project.team.last.name, 'Jakarta pilot Store Crew');
  });

  test('project form creation updates project while preserving identity', () {
    const service = ProjectFormCreationService();
    final existing = ProjectPortfolioItem(
      id: 'campus-renovation',
      name: 'Campus Renovation',
      owner: 'Dewi Lestari',
      client: 'Education Office',
      startDate: DateTime(2026, 6),
      endDate: DateTime(2026, 8),
      progress: 0.2,
      budgetUsed: 0.1,
      health: ProjectHealth.onTrack,
      milestones: const [],
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'campus',
          label: 'Campus',
          type: ProjectCustomAttributeType.text,
          value: 'North Campus',
          isPinned: true,
        ),
      ],
      risks: const [
        ProjectDeliveryRisk(
          title: 'Inspection readiness',
          detail: 'Site proof needs owner signoff.',
          severity: ProjectHealth.atRisk,
        ),
      ],
      team: const [
        ProjectTeamMember(
          name: 'Dewi Lestari',
          role: 'Delivery Lead',
          allocation: 0.7,
        ),
      ],
    );
    final draft = ProjectFormDraft.fromProject(existing).copyWith(
      name: 'Campus Renovation Phase 2',
      health: ProjectHealth.atRisk,
      progress: 0.5,
    );

    final updated = service.updateProject(project: existing, draft: draft);

    expect(updated.id, 'campus-renovation');
    expect(updated.name, 'Campus Renovation Phase 2');
    expect(updated.health, ProjectHealth.atRisk);
    expect(updated.risks.single.title, 'Inspection readiness');
    expect(updated.team.single.role, 'Delivery Lead');
    expect(updated.milestones, hasLength(3));
    expect(updated.customAttributes.single.label, 'Campus');
  });
}
