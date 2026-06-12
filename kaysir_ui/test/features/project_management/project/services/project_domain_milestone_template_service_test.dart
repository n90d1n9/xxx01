import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_milestone_template_service.dart';

void main() {
  test('domain milestone template adapts retail projects with attributes', () {
    const service = ProjectDomainMilestoneTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      businessDomain: 'Retail Operations',
      progress: 0.6,
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta pilot',
        ),
        ProjectCustomAttribute(
          key: 'launch-wave',
          label: 'Launch Wave',
          type: ProjectCustomAttributeType.text,
          value: 'Wave 2',
        ),
      ],
    );

    final milestones = service.buildMilestones(draft);

    expect(milestones.map((milestone) => milestone.label), [
      'Jakarta pilot: Store pilot ready',
      'Wave 2: Launch review',
      'Rollout handover',
    ]);
    expect(milestones[0].isComplete, isTrue);
    expect(milestones[1].isComplete, isTrue);
    expect(milestones[2].isComplete, isFalse);
  });

  test('domain milestone template adapts wedding projects', () {
    const service = ProjectDomainMilestoneTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      businessDomain: 'Wedding Organizer',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'venue',
          label: 'Venue',
          type: ProjectCustomAttributeType.text,
          value: 'Grand Hall',
        ),
      ],
    );

    expect(service.buildMilestones(draft).map((milestone) => milestone.label), [
      'Grand Hall: Venue and vendor lock',
      'Run sheet finalization',
      'Event day handoff',
    ]);
  });

  test('domain milestone template keeps a general fallback', () {
    const service = ProjectDomainMilestoneTemplateService();
    final draft = ProjectFormDraft.initial(
      today: DateTime(2026, 6),
    ).copyWith(businessDomain: 'Custom Logistics');

    expect(service.buildMilestones(draft).map((milestone) => milestone.label), [
      'Kickoff',
      'Custom Logistics Review',
      'Handover',
    ]);
  });
}
