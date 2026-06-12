import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_readiness_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_extension_readiness_panel.dart';

void main() {
  testWidgets('domain extension readiness panel renders coverage summary', (
    tester,
  ) async {
    final summary = const ProjectDomainExtensionReadinessService().build(
      businessDomain: 'Retail Operations',
      attributes: const [
        ProjectCustomAttribute(
          key: 'store-cluster',
          label: 'Store Cluster',
          type: ProjectCustomAttributeType.text,
          value: 'Jakarta Flagships',
        ),
        ProjectCustomAttribute(
          key: 'omnichannel-impact',
          label: 'Omnichannel Impact',
          type: ProjectCustomAttributeType.boolean,
          value: 'Yes',
        ),
        ProjectCustomAttribute(
          key: 'legacy-rollout-code',
          label: 'Legacy Rollout Code',
          type: ProjectCustomAttributeType.text,
          value: 'R-2026',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDomainExtensionReadinessPanel(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('2/4 domain fields complete'), findsOneWidget);
    expect(find.text('Needs Context'), findsOneWidget);
    expect(find.text('1/2 required'), findsOneWidget);
    expect(find.text('1/2 recommended'), findsOneWidget);
    expect(find.text('1 custom filled'), findsOneWidget);
    expect(find.text('3 risk signals'), findsOneWidget);
    expect(find.text('3 watched fields'), findsOneWidget);
    expect(find.textContaining('Launch Wave'), findsOneWidget);
    expect(find.textContaining('1 required field missing'), findsOneWidget);
  });

  testWidgets('domain extension readiness panel renders ready state', (
    tester,
  ) async {
    const summary = ProjectDomainExtensionReadinessSummary(
      businessDomain: 'General Business',
      templateFieldCount: 2,
      completedTemplateFieldCount: 2,
      requiredFieldCount: 1,
      completedRequiredFieldCount: 1,
      recommendedFieldCount: 1,
      completedRecommendedFieldCount: 1,
      filledCustomFieldCount: 0,
      riskRuleCount: 1,
      watchedFieldCount: 1,
      missingTemplateFields: [],
      missingRequiredFields: [],
      missingRecommendedFields: [],
      missingWatchedFields: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectDomainExtensionReadinessPanel(summary: summary),
        ),
      ),
    );

    expect(find.text('2/2 domain fields complete'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.textContaining('Domain context is ready'), findsOneWidget);
    expect(find.textContaining('missing'), findsNothing);
  });
}
