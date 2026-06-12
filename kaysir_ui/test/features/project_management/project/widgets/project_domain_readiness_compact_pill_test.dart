import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_readiness_compact_pill.dart';

void main() {
  testWidgets('domain readiness compact pill renders scan-friendly status', (
    tester,
  ) async {
    final summary = const ProjectDomainExtensionReadinessService().build(
      businessDomain: 'Software Development',
      attributes: const [
        ProjectCustomAttribute(
          key: 'api-contract',
          label: 'API Contract',
          type: ProjectCustomAttributeType.boolean,
          value: 'No',
        ),
        ProjectCustomAttribute(
          key: 'target-environment',
          label: 'Target Environment',
          type: ProjectCustomAttributeType.choice,
          value: 'Production',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainReadinessCompactPill(summary: summary),
        ),
      ),
    );

    expect(find.text('2/4 Needs Context'), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_outlined), findsOneWidget);
  });
}
