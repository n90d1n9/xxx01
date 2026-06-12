import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_intake_plan_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';

void main() {
  test('domain extension intake plan summarizes domain lanes', () {
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
    final plan = const ProjectDomainExtensionIntakePlanService().build(
      summary: summary,
    );

    final requiredLane = plan.lane(
      ProjectDomainExtensionIntakeLaneKind.requiredContext,
    );
    final riskLane = plan.lane(ProjectDomainExtensionIntakeLaneKind.riskWatch);
    final recommendedLane = plan.lane(
      ProjectDomainExtensionIntakeLaneKind.recommendedContext,
    );
    final customLane = plan.lane(
      ProjectDomainExtensionIntakeLaneKind.customContext,
    );

    expect(plan.businessDomain, 'Retail Operations');
    expect(plan.openFieldCount, 3);
    expect(plan.hasMissingFields, isTrue);
    expect(requiredLane.metricLabel, '1/2 required');
    expect(requiredLane.detail, '1 required gap');
    expect(requiredLane.focusFieldKey, 'launch-wave');
    expect(riskLane.metricLabel, '0/3 watched');
    expect(riskLane.detail, '3 risk signal gaps');
    expect(riskLane.focusFieldKey, 'sku-scope');
    expect(recommendedLane.metricLabel, '0/2 recommended');
    expect(recommendedLane.detail, '2 recommended gaps');
    expect(recommendedLane.focusFieldKey, 'sku-scope');
    expect(customLane.metricLabel, '0 custom fields');
    expect(customLane.canFocusField, isFalse);
  });

  test('domain extension intake plan reports complete lanes', () {
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
    final plan = const ProjectDomainExtensionIntakePlanService().build(
      summary: summary,
    );

    expect(plan.openFieldCount, 0);
    expect(plan.hasMissingFields, isFalse);
    expect(
      plan.lane(ProjectDomainExtensionIntakeLaneKind.requiredContext).detail,
      'Required context complete',
    );
    expect(
      plan.lane(ProjectDomainExtensionIntakeLaneKind.riskWatch).detail,
      'Watched fields covered',
    );
    expect(
      plan.lane(ProjectDomainExtensionIntakeLaneKind.recommendedContext).detail,
      'Recommended context covered',
    );
  });
}
