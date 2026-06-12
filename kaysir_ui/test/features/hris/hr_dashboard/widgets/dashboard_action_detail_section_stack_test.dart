import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_section.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_section_stack.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets(
    'dashboard action detail section stack anchors modeled sections',
    (tester) async {
      final detail = hrisDashboardCriticalDetail();
      final sectionKeys = {
        for (final section in DashboardActionDetailSection.values)
          section: GlobalKey(),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardActionDetailSectionStack(
                detail: detail,
                sectionKey: (section) => sectionKeys[section]!,
              ),
            ),
          ),
        ),
      );

      for (final section in DashboardActionDetailSection.values) {
        expect(sectionKeys[section]!.currentContext, isNotNull);
      }
      expect(find.text('Evidence timeline'), findsOneWidget);
      expect(find.text('Recommended next step'), findsOneWidget);
      expect(find.text('Handoff brief'), findsOneWidget);
      expect(find.text('Impact preview'), findsOneWidget);
      expect(find.text('Guided playbook'), findsOneWidget);
    },
  );
}
