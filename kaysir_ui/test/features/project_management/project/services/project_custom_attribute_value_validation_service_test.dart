import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_value_validation_service.dart';

void main() {
  test('custom attribute value validation accepts typed values', () {
    const service = ProjectCustomAttributeValueValidationService();
    final issues = service.validate(const [
      ProjectCustomAttribute(
        key: 'sku-scope',
        label: 'SKU Scope',
        type: ProjectCustomAttributeType.number,
        value: '1,200.5',
      ),
      ProjectCustomAttribute(
        key: 'permit-window',
        label: 'Permit Window',
        type: ProjectCustomAttributeType.date,
        value: '2026-06-12',
      ),
      ProjectCustomAttribute(
        key: 'repository',
        label: 'Repository',
        type: ProjectCustomAttributeType.url,
        value: 'https://example.com/repo',
      ),
      ProjectCustomAttribute(
        key: 'api-contract',
        label: 'API Contract',
        type: ProjectCustomAttributeType.boolean,
        value: 'Enabled',
      ),
      ProjectCustomAttribute(
        key: 'target-environment',
        label: 'Target Environment',
        type: ProjectCustomAttributeType.choice,
        value: 'Sandbox',
        options: ['Development', 'Staging', 'Production'],
      ),
    ]);

    expect(issues, isEmpty);
  });

  test('custom attribute value validation reports invalid typed values', () {
    const service = ProjectCustomAttributeValueValidationService();
    final issues = service.validate(const [
      ProjectCustomAttribute(
        key: 'sku-scope',
        label: 'SKU Scope',
        type: ProjectCustomAttributeType.number,
        value: 'many',
      ),
      ProjectCustomAttribute(
        key: 'student-impact',
        label: 'Student Impact',
        type: ProjectCustomAttributeType.number,
        value: 'NaN',
      ),
      ProjectCustomAttribute(
        key: 'permit-window',
        label: 'Permit Window',
        type: ProjectCustomAttributeType.date,
        value: '12/06/2026',
      ),
      ProjectCustomAttribute(
        key: 'repository',
        label: 'Repository',
        type: ProjectCustomAttributeType.url,
        value: 'example.com/repo',
      ),
      ProjectCustomAttribute(
        key: 'api-contract',
        label: 'API Contract',
        type: ProjectCustomAttributeType.boolean,
        value: 'maybe',
      ),
    ]);

    expect(
      issues.map((issue) => issue.message),
      containsAll([
        'Custom attribute "SKU Scope" must be a valid number.',
        'Custom attribute "Student Impact" must be a valid number.',
        'Custom attribute "Permit Window" must use YYYY-MM-DD.',
        'Custom attribute "Repository" must use an http:// or https:// URL.',
        'Custom attribute "API Contract" must be Yes or No.',
      ]),
    );
  });
}
