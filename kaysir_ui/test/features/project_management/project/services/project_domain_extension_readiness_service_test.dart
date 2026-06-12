import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';

void main() {
  test('domain extension readiness summarizes template and risk coverage', () {
    const service = ProjectDomainExtensionReadinessService();
    final summary = service.build(
      businessDomain: 'Retail Operations',
      attributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta Flagships',
        ),
        ProjectCustomAttribute(
          key: 'launch-wave',
          label: 'Launch Wave',
          type: ProjectCustomAttributeType.text,
        ),
        ProjectCustomAttribute(
          key: 'sku-scope',
          label: 'SKU Scope',
          type: ProjectCustomAttributeType.number,
        ),
        ProjectCustomAttribute(
          key: 'omnichannel-impact',
          label: 'Omnichannel Impact',
          type: ProjectCustomAttributeType.boolean,
          value: 'Yes',
        ),
        ProjectCustomAttribute(
          key: 'legacy-rollout-code',
          label: 'Legacy Rollout Code',
          type: ProjectCustomAttributeType.text,
          value: 'R-2026',
        ),
      ],
    );

    expect(summary.businessDomain, 'Retail Operations');
    expect(summary.templateFieldCount, 4);
    expect(summary.completedTemplateFieldCount, 2);
    expect(summary.requiredFieldCount, 2);
    expect(summary.completedRequiredFieldCount, 1);
    expect(summary.recommendedFieldCount, 2);
    expect(summary.completedRecommendedFieldCount, 1);
    expect(summary.filledCustomFieldCount, 1);
    expect(summary.riskRuleCount, 3);
    expect(summary.watchedFieldCount, 3);
    expect(summary.completionRatio, 0.5);
    expect(summary.status, ProjectDomainExtensionReadinessStatus.needsContext);
    expect(summary.statusLabel, 'Needs Context');
    expect(
      summary.missingRequiredFields.map((field) => field.label),
      contains('Launch Wave'),
    );
    expect(
      summary.missingRecommendedFields.map((field) => field.label),
      contains('SKU Scope'),
    );
    expect(
      summary.missingTemplateFields.map((field) => field.label),
      containsAll(['Launch Wave', 'SKU Scope']),
    );
    expect(
      summary.missingWatchedFields.map((field) => field.label),
      containsAll(['Launch Wave', 'SKU Scope']),
    );
  });

  test('domain extension readiness falls back to general business pack', () {
    const service = ProjectDomainExtensionReadinessService();
    final summary = service.build(
      businessDomain: 'Custom Logistics',
      attributes: const [
        ProjectCustomAttribute(
          key: 'priority',
          label: 'Priority',
          type: ProjectCustomAttributeType.choice,
          value: 'High',
        ),
      ],
    );

    expect(summary.businessDomain, 'General Business');
    expect(summary.templateFieldCount, 4);
    expect(summary.completedTemplateFieldCount, 1);
    expect(summary.requiredFieldCount, 2);
    expect(summary.completedRequiredFieldCount, 1);
    expect(summary.recommendedFieldCount, 2);
    expect(summary.completedRecommendedFieldCount, 0);
    expect(summary.riskRuleCount, 1);
    expect(summary.watchedFieldCount, 1);
    expect(summary.status, ProjectDomainExtensionReadinessStatus.needsContext);
    expect(
      summary.missingRequiredFields.map((field) => field.label),
      contains('Workstream'),
    );
    expect(summary.missingWatchedFields, isEmpty);
  });

  test(
    'domain extension readiness is ready when required and recommended are complete',
    () {
      const service = ProjectDomainExtensionReadinessService();
      final summary = service.build(
        businessDomain: 'Wedding Organizer',
        attributes: const [
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
            value: '180',
          ),
          ProjectCustomAttribute(
            key: 'ceremony-type',
            label: 'Ceremony Type',
            type: ProjectCustomAttributeType.text,
            value: 'Reception',
          ),
          ProjectCustomAttribute(
            key: 'vendor-package',
            label: 'Vendor Package',
            type: ProjectCustomAttributeType.text,
            value: 'Full service',
          ),
        ],
      );

      expect(summary.readinessFieldCount, 4);
      expect(summary.completedReadinessFieldCount, 4);
      expect(summary.templateFieldCount, 4);
      expect(summary.status, ProjectDomainExtensionReadinessStatus.ready);
      expect(summary.missingTemplateFields, isEmpty);
    },
  );
}
