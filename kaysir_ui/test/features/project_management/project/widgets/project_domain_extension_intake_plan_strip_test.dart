import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_intake_plan_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_extension_intake_plan_strip.dart';

void main() {
  testWidgets('domain extension intake plan strip focuses lane targets', (
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
    final plan = const ProjectDomainExtensionIntakePlanService().build(
      summary: summary,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProjectDomainExtensionIntakePlanStrip(
              plan: plan,
              onFocusField: (fieldKey) => focusedFieldKey = fieldKey,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('1/2 required'), findsOneWidget);
    expect(find.text('Risk Watch'), findsOneWidget);
    expect(find.text('0/3 watched'), findsOneWidget);
    expect(find.text('3 risk signal gaps'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('0 custom fields'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-extension-intake-lane-risk-watch'),
      ),
    );

    expect(focusedFieldKey, 'sku-scope');
  });
}
