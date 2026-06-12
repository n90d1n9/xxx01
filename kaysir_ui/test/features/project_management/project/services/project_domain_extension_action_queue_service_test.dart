import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_action_queue_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_next_action_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';

void main() {
  test('domain extension action queue orders and dedupes missing fields', () {
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
    final queue = const ProjectDomainExtensionActionQueueService().build(
      summary: summary,
    );

    expect(queue.businessDomain, 'Retail Operations');
    expect(queue.totalItemCount, 3);
    expect(queue.hasHiddenItems, isFalse);
    expect(queue.visibleItems.map((item) => item.fieldKey), [
      'launch-wave',
      'sku-scope',
      'omnichannel-impact',
    ]);
    expect(queue.visibleItems.map((item) => item.kind), [
      ProjectDomainExtensionNextActionKind.requiredField,
      ProjectDomainExtensionNextActionKind.watchedField,
      ProjectDomainExtensionNextActionKind.watchedField,
    ]);
  });

  test('domain extension action queue caps visible items', () {
    final summary = const ProjectDomainExtensionReadinessService().build(
      businessDomain: 'Government Program',
      attributes: const [],
    );
    final queue = const ProjectDomainExtensionActionQueueService().build(
      summary: summary,
      maxVisibleItems: 2,
    );

    expect(queue.totalItemCount, 4);
    expect(queue.visibleItems, hasLength(2));
    expect(queue.hiddenItemCount, 2);
    expect(queue.visibleItems.map((item) => item.fieldKey), [
      'program-code',
      'procurement-method',
    ]);
  });

  test('domain extension action queue hides complete summaries', () {
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
    final queue = const ProjectDomainExtensionActionQueueService().build(
      summary: summary,
    );

    expect(queue.hasActions, isFalse);
    expect(queue.visibleItems, isEmpty);
  });
}
