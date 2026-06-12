import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/services/project_form_validation_service.dart';

void main() {
  test('project form validation reports required fields', () {
    const service = ProjectFormValidationService();
    final issues = service.validate(
      ProjectFormDraft.initial(today: DateTime(2026, 6)),
    );

    expect(issues.map((issue) => issue.field), containsAll(['name', 'client']));
    expect(service.canSubmit(ProjectFormDraft.initial()), isFalse);
  });

  test('project form validation accepts complete multi-domain draft', () {
    const service = ProjectFormValidationService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );

    expect(service.validate(draft), isEmpty);
    expect(service.canSubmit(draft), isTrue);
  });

  test('project form validation rejects duplicate custom attributes', () {
    const service = ProjectFormValidationService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Campus Renovation',
      client: 'Education Office',
      owner: 'Dewi Lestari',
      sponsor: 'Academic Operations',
      businessDomain: 'Construction',
      summary:
          'Coordinates classroom renovation, inspection proof, and opening readiness.',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'permit-id',
          label: 'Permit ID',
          type: ProjectCustomAttributeType.text,
          value: 'IMB-2026-77',
        ),
        ProjectCustomAttribute(
          key: 'permit-id-copy',
          label: 'Permit ID',
          type: ProjectCustomAttributeType.text,
          value: 'IMB-2026-88',
        ),
      ],
    );

    expect(
      service.validate(draft).map((issue) => issue.message),
      contains('Custom attribute "Permit ID" is duplicated.'),
    );
  });

  test('project form validation rejects invalid typed custom values', () {
    const service = ProjectFormValidationService();
    final draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
      name: 'Release Governance',
      client: 'Digital Office',
      owner: 'Rafi Pratama',
      sponsor: 'Technology Steering',
      businessDomain: 'Software Development',
      summary:
          'Coordinates release readiness, API ownership, and production governance.',
      customAttributes: const [
        ProjectCustomAttribute(
          key: 'repository',
          label: 'Repository',
          type: ProjectCustomAttributeType.url,
          value: 'repo.internal/project',
        ),
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'maybe',
        ),
      ],
    );

    expect(
      service.validate(draft).map((issue) => issue.message),
      containsAll([
        'Custom attribute "Repository" must use an http:// or https:// URL.',
        'Custom attribute "API Contract" must be Yes or No.',
      ]),
    );
    expect(service.canSubmit(draft), isFalse);
  });
}
