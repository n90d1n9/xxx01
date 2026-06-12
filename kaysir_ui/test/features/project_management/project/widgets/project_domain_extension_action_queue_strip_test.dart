import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_action_queue_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_extension_action_queue_strip.dart';

void main() {
  testWidgets('domain extension action queue strip focuses fields', (
    tester,
  ) async {
    String? focusedFieldKey;
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainExtensionActionQueueStrip(
            queue: queue,
            onFocusField: (fieldKey) => focusedFieldKey = fieldKey,
          ),
        ),
      ),
    );

    expect(find.text('Required: Launch Wave'), findsOneWidget);
    expect(find.text('Risk: SKU Scope'), findsOneWidget);
    expect(find.text('Risk: Omnichannel Impact'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-extension-queue-sku-scope')),
    );

    expect(focusedFieldKey, 'sku-scope');
  });
}
