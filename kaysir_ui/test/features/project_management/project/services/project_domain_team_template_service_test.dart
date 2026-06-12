import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_team_template_service.dart';

void main() {
  test('domain team template adapts retail rollout roles', () {
    const service = ProjectDomainTeamTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      owner: 'Maya Santoso',
      sponsor: 'Retail Operations',
      businessDomain: 'Retail Operations',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta pilot',
        ),
      ],
    );

    final team = service.buildTeam(draft);

    expect(team, hasLength(3));
    expect(team[0].name, 'Maya Santoso');
    expect(team[0].role, 'Store Rollout Lead');
    expect(team[1].role, 'Retail Sponsor');
    expect(team[2].name, 'Jakarta pilot Store Crew');
    expect(team[2].role, 'Store Enablement Lead');
  });

  test('domain team template adapts software release roles', () {
    const service = ProjectDomainTeamTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      owner: 'Nadia Putri',
      sponsor: 'Customer Service',
      businessDomain: 'Software Development',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'target-environment',
          label: 'Target Environment',
          type: ProjectCustomAttributeType.choice,
          value: 'Production',
        ),
      ],
    );

    expect(service.buildTeam(draft).map((member) => member.role), [
      'Product Owner',
      'Business Sponsor',
      'Release Lead',
    ]);
    expect(service.buildTeam(draft).last.name, 'Production Release Crew');
  });

  test('domain team template falls back for missing names', () {
    const service = ProjectDomainTeamTemplateService();
    final draft = ProjectFormDraft.initial(
      today: DateTime(2026, 6),
    ).copyWith(businessDomain: 'General Business');

    final team = service.buildTeam(draft);

    expect(team.first.name, 'Unassigned delivery lead');
    expect(team[1].name, 'Unassigned sponsor');
    expect(team.last.role, 'Workstream Coordinator');
  });
}
