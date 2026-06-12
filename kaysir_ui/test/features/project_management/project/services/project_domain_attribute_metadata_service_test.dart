import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_attribute_metadata_service.dart';

void main() {
  test('domain attribute metadata marks required watched template fields', () {
    const service = ProjectDomainAttributeMetadataService();

    final metadata = service.build(
      businessDomain: 'Software Development',
      attributes: const [
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'No',
        ),
        ProjectCustomAttribute(
          key: 'customer-segment',
          label: 'Customer Segment',
          type: ProjectCustomAttributeType.text,
          value: 'Enterprise',
        ),
      ],
    );

    expect(metadata, hasLength(2));
    expect(metadata.first.key, 'api-contract');
    expect(metadata.first.label, 'API Contract');
    expect(metadata.first.type, ProjectCustomAttributeType.boolean);
    expect(
      metadata.first.importance,
      ProjectCustomAttributeImportance.requiredField,
    );
    expect(metadata.first.isDomainTemplate, isTrue);
    expect(metadata.first.isRiskWatched, isTrue);
    expect(metadata.first.sourceLabel, 'Required');

    expect(metadata.last.key, 'customer-segment');
    expect(metadata.last.importance, ProjectCustomAttributeImportance.optional);
    expect(metadata.last.isDomainTemplate, isFalse);
    expect(metadata.last.isRiskWatched, isFalse);
    expect(metadata.last.sourceLabel, 'Custom');
  });

  test(
    'domain attribute metadata falls back to general business templates',
    () {
      const service = ProjectDomainAttributeMetadataService();

      final metadata = service.build(
        businessDomain: 'Custom Logistics',
        attributes: const [
          ProjectCustomAttribute(
            key: 'workstream',
            label: 'Workstream',
            type: ProjectCustomAttributeType.text,
            value: 'Fulfillment',
          ),
        ],
      );

      expect(metadata.single.isDomainTemplate, isTrue);
      expect(
        metadata.single.importance,
        ProjectCustomAttributeImportance.requiredField,
      );
      expect(metadata.single.sourceLabel, 'Required');
    },
  );
}
