import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_risk_template_service.dart';

void main() {
  test('domain risk template blocks unsigned software API contracts', () {
    const service = ProjectDomainRiskTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      businessDomain: 'Software Development',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'No',
        ),
        ProjectCustomAttribute(
          key: 'target-environment',
          label: 'Target Environment',
          type: ProjectCustomAttributeType.choice,
          value: 'Production',
        ),
      ],
    );

    final risks = service.buildRisks(draft);

    expect(risks.first.title, 'API contract not signed');
    expect(risks.first.severity, ProjectHealth.blocked);
    expect(
      risks.map((risk) => risk.title),
      contains('Repository traceability'),
    );
  });

  test('domain risk template adapts event capacity signals', () {
    const service = ProjectDomainRiskTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      businessDomain: 'Wedding Organizer',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'venue',
          label: 'Venue',
          type: ProjectCustomAttributeType.text,
          value: 'Grand Hall',
        ),
        ProjectCustomAttribute(
          key: 'guest-count',
          label: 'Guest Count',
          type: ProjectCustomAttributeType.number,
          value: '480',
          unit: 'guests',
        ),
      ],
    );

    final risks = service.buildRisks(draft);

    expect(risks.map((risk) => risk.title), contains('Guest capacity'));
    expect(risks.map((risk) => risk.title), contains('Vendor package'));
    expect(
      risks.singleWhere((risk) => risk.title == 'Guest capacity').detail,
      contains('480 guests'),
    );
  });

  test('domain risk template gates production readiness by progress', () {
    const service = ProjectDomainRiskTemplateService();
    final baseDraft = ProjectFormDraft.initial(
      today: DateTime(2026, 6),
    ).copyWith(
      businessDomain: 'Software Development',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'Yes',
        ),
        ProjectCustomAttribute(
          key: 'repository',
          label: 'Repository',
          type: ProjectCustomAttributeType.url,
          value: 'https://example.com/repo',
        ),
        ProjectCustomAttribute(
          key: 'target-environment',
          label: 'Target Environment',
          type: ProjectCustomAttributeType.choice,
          value: 'Production',
        ),
      ],
    );

    final earlyRisks = service.buildRisks(baseDraft.copyWith(progress: 0.25));
    final matureRisks = service.buildRisks(baseDraft.copyWith(progress: 0.6));

    expect(
      earlyRisks.map((risk) => risk.title),
      contains('Production readiness'),
    );
    expect(
      matureRisks.map((risk) => risk.title),
      isNot(contains('Production readiness')),
    );
  });

  test('domain risk template keeps low-risk projects actionable', () {
    const service = ProjectDomainRiskTemplateService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      businessDomain: 'General Business',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'priority',
          label: 'Priority',
          type: ProjectCustomAttributeType.choice,
          value: 'Medium',
        ),
      ],
    );

    final risks = service.buildRisks(draft);

    expect(risks, hasLength(1));
    expect(risks.single.title, 'General Business assumptions');
    expect(risks.single.severity, ProjectHealth.onTrack);
  });
}
