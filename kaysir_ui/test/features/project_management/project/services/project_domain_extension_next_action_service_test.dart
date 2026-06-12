import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_next_action_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';

void main() {
  test('domain extension next action prioritizes required gaps', () {
    final summary = const ProjectDomainExtensionReadinessService().build(
      businessDomain: 'Retail Operations',
      attributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta Flagships',
        ),
      ],
    );
    final action = const ProjectDomainExtensionNextActionService().build(
      summary,
    );

    expect(action.kind, ProjectDomainExtensionNextActionKind.requiredField);
    expect(action.fieldKey, 'launch-wave');
    expect(action.fieldLabel, 'Launch Wave');
    expect(action.title, 'Next: Launch Wave');
    expect(action.detail, contains('required'));
    expect(action.actionLabel, 'Focus Field');
  });

  test('domain extension next action prioritizes watched risk fields', () {
    final summary = const ProjectDomainExtensionReadinessService().build(
      businessDomain: 'Construction',
      attributes: const [
        ProjectCustomAttribute(
          key: 'site-location',
          label: 'Site Location',
          type: ProjectCustomAttributeType.text,
          value: 'Tower A',
        ),
        ProjectCustomAttribute(
          key: 'permit-id',
          label: 'Permit ID',
          type: ProjectCustomAttributeType.text,
          value: 'P-42',
        ),
      ],
    );
    final action = const ProjectDomainExtensionNextActionService().build(
      summary,
    );

    expect(action.kind, ProjectDomainExtensionNextActionKind.watchedField);
    expect(action.fieldKey, 'safety-level');
    expect(action.fieldLabel, 'Safety Level');
    expect(action.title, 'Stabilize: Safety Level');
    expect(action.detail, contains('risk rules'));
  });

  test('domain extension next action returns complete state', () {
    final summary = const ProjectDomainExtensionReadinessService().build(
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
    final action = const ProjectDomainExtensionNextActionService().build(
      summary,
    );

    expect(action.kind, ProjectDomainExtensionNextActionKind.complete);
    expect(action.isComplete, isTrue);
    expect(action.hasField, isFalse);
    expect(action.title, 'Wedding Organizer context ready');
  });
}
