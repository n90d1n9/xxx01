import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_domain_registry.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_risk_rule_preview_list.dart';

void main() {
  testWidgets(
    'domain risk rule preview list renders rule triggers and severity',
    (tester) async {
      final rules =
          projectDomainPackForBusinessDomain('Software Development').riskRules;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectDomainRiskRulePreviewList(
                rules: rules,
                maxItems: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('API contract not signed'), findsOneWidget);
      expect(find.text('API contract readiness'), findsOneWidget);
      expect(find.text('Repository traceability'), findsNothing);
      expect(find.textContaining('No or disabled'), findsOneWidget);
      expect(find.textContaining('Unconfirmed'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('At Risk'), findsOneWidget);
      expect(find.text('+2 more risk signals'), findsOneWidget);
    },
  );

  testWidgets('domain risk rule preview list renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProjectDomainRiskRulePreviewList(rules: [])),
      ),
    );

    expect(find.text('No domain risk signals'), findsOneWidget);
    expect(
      find.textContaining('does not define automated risk'),
      findsOneWidget,
    );
  });
}
