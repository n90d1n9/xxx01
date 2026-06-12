import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_domain_registry.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_domain_pack.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_preferences_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project domain registry covers every selectable business domain', () {
    expect(projectBusinessDomainOptions, projectDomainBusinessDomainOptions);
    expect(
      projectDomainPacks.map((pack) => pack.businessDomain),
      projectDomainBusinessDomainOptions,
    );
    expect(projectDomainPacks.map((pack) => pack.id).toSet(), hasLength(8));

    for (final domain in projectDomainBusinessDomainOptions) {
      final pack = projectDomainPackForBusinessDomain(domain);
      final vocabulary = resolveStatusUpdateVocabulary(
        availableVocabularies: ProjectStatusUpdateVocabulary.defaults,
        vocabularyId: pack.statusVocabularyId,
      );
      final audience = resolveStatusUpdateAudience(
        availableAudiences: ProjectStatusUpdateAudience.values,
        audienceId: pack.statusAudienceId,
      );

      expect(pack.businessDomain, domain);
      expect(vocabulary.id, pack.statusVocabularyId);
      expect(audience.id, pack.statusAudienceId);
      expect(pack.customAttributeTemplates, hasLength(greaterThanOrEqualTo(4)));
      expect(
        pack.customAttributeTemplates.map((template) => template.key).toSet(),
        hasLength(pack.customAttributeTemplates.length),
      );
      expect(
        pack.customAttributeTemplates.where(
          (template) =>
              template.importance ==
              ProjectCustomAttributeImportance.requiredField,
        ),
        isNotEmpty,
      );
      expect(
        pack.customAttributeTemplates.where(
          (template) =>
              template.importance ==
              ProjectCustomAttributeImportance.recommended,
        ),
        isNotEmpty,
      );
      expect(pack.milestoneTemplate.kickoffLabel, isNotEmpty);
      expect(pack.milestoneTemplate.handoverLabel, isNotEmpty);
      expect(pack.teamTemplate.leadRole, isNotEmpty);
      expect(pack.teamTemplate.supportRole, isNotEmpty);
      expect(pack.playbookControlTemplate.title, isNotEmpty);
      expect(pack.playbookControlTemplate.detail, isNotEmpty);
      _expectValidRiskRules(pack);
      expect(
        projectDomainPackForStatusVocabularyId(pack.statusVocabularyId),
        pack,
      );
    }
  });

  test('project domain registry normalizes and falls back predictably', () {
    expect(
      projectDomainPackForBusinessDomain(' retail operations ').id,
      'retail-operations',
    );
    expect(
      projectDomainPackForBusinessDomain('Custom Logistics').businessDomain,
      'General Business',
    );
    expect(
      projectDomainPackForStatusVocabularyId(
        'unknown-vocabulary',
      ).businessDomain,
      'General Business',
    );
  });
}

void _expectValidRiskRules(ProjectDomainPack pack) {
  final templatesByKey = {
    for (final template in pack.customAttributeTemplates)
      template.key: template,
  };

  expect(pack.riskRules, isNotEmpty);
  expect(
    pack.riskRules.map((rule) => rule.title).toSet(),
    hasLength(pack.riskRules.length),
  );

  for (final rule in pack.riskRules) {
    final template = templatesByKey[rule.attributeKey];

    expect(rule.title, isNotEmpty);
    expect(rule.detail, isNotEmpty);
    expect(rule.attributeKey, isNotEmpty);
    expect(template, isNotNull);
    expect(const ['blocked', 'atRisk', 'onTrack'], contains(rule.severityId));

    switch (rule.trigger) {
      case ProjectDomainRiskRuleTrigger.missingAttribute:
        break;
      case ProjectDomainRiskRuleTrigger.attributeEquals:
        expect(rule.expectedValue, isNotEmpty);
        expect(template!.type, ProjectCustomAttributeType.choice);
        break;
      case ProjectDomainRiskRuleTrigger.booleanMissing:
      case ProjectDomainRiskRuleTrigger.booleanFalse:
      case ProjectDomainRiskRuleTrigger.booleanTrue:
        expect(template!.type, ProjectCustomAttributeType.boolean);
        break;
      case ProjectDomainRiskRuleTrigger.numberAtLeast:
        expect(rule.threshold, greaterThan(0));
        expect(template!.type, ProjectCustomAttributeType.number);
        break;
      case ProjectDomainRiskRuleTrigger.attributeEqualsWhenProgressBelow:
        expect(rule.expectedValue, isNotEmpty);
        expect(rule.progressBelow, greaterThan(0));
        expect(rule.progressBelow, lessThanOrEqualTo(1));
        expect(template!.type, ProjectCustomAttributeType.choice);
        break;
    }
  }
}
