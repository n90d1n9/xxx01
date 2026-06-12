import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';

void main() {
  test('domain custom attributes provide adaptive templates', () {
    final construction = defaultProjectCustomAttributesForDomain(
      'Construction',
    );
    final wedding = defaultProjectCustomAttributesForDomain(
      'Wedding Organizer',
    );

    expect(
      construction.map((attribute) => attribute.label),
      contains('Permit ID'),
    );
    expect(
      wedding.map((attribute) => attribute.label),
      contains('Guest Count'),
    );
  });

  test('domain merge preserves filled custom values', () {
    final merged = mergeProjectCustomAttributesForDomain(
      domain: 'Construction',
      currentAttributes: const [
        ProjectCustomAttribute(
          key: 'permit-id',
          label: 'Permit ID',
          type: ProjectCustomAttributeType.text,
          value: 'IMB-2026-77',
        ),
        ProjectCustomAttribute(
          key: 'legacy-risk-code',
          label: 'Legacy Risk Code',
          type: ProjectCustomAttributeType.text,
          value: 'R-42',
        ),
      ],
    );

    expect(
      merged.firstWhere((attribute) => attribute.key == 'permit-id').value,
      'IMB-2026-77',
    );
    expect(
      merged
          .firstWhere((attribute) => attribute.key == 'legacy-risk-code')
          .value,
      'R-42',
    );
  });

  test('storage custom attributes drop blank templates', () {
    final stored = projectCustomAttributesForStorage(const [
      ProjectCustomAttribute(
        key: 'site-location',
        label: 'Site Location',
        type: ProjectCustomAttributeType.text,
      ),
      ProjectCustomAttribute(
        key: 'permit-id',
        label: 'Permit ID',
        type: ProjectCustomAttributeType.text,
        value: 'IMB-2026-77',
      ),
    ]);

    expect(stored, hasLength(1));
    expect(stored.single.key, 'permit-id');
  });
}
