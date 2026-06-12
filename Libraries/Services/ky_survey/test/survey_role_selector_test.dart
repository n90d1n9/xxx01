import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_role_selector.dart';

void main() {
  group('SurveyRoleSelector', () {
    testWidgets('renders configured roles and forwards selection changes', (
      tester,
    ) async {
      SurveyRole? selectedRole;

      await tester.pumpWidget(
        _selectorHarness(
          roles: const [SurveyRole.admin, SurveyRole.analyst],
          onChanged: (role) => selectedRole = role,
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Analyst'), findsOneWidget);
      expect(find.text('Participant'), findsNothing);
      expect(find.byTooltip('Switch to Insight Lab'), findsOneWidget);

      await tester.tap(find.text('Analyst'));

      expect(selectedRole, SurveyRole.analyst);
    });

    testWidgets('keeps the selected role visible when host roles omit it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _selectorHarness(
          selectedRole: SurveyRole.reportViewer,
          roles: const [SurveyRole.admin, SurveyRole.analyst],
        ),
      );

      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Analyst'), findsOneWidget);
      expect(find.byTooltip('Switch to Report Room'), findsOneWidget);
    });

    testWidgets('renders a fixed role indicator for single-role dashboards', (
      tester,
    ) async {
      SurveyRole? selectedRole;

      await tester.pumpWidget(
        _selectorHarness(
          roles: const [SurveyRole.admin],
          onChanged: (role) => selectedRole = role,
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
      expect(find.byType(SegmentedButton<SurveyRole>), findsNothing);
      expect(
        find.byTooltip('Only Survey Command Center is available'),
        findsOneWidget,
      );

      await tester.tap(find.text('Admin'));
      await tester.pump();

      expect(selectedRole, isNull);
    });
  });
}

Widget _selectorHarness({
  SurveyRole selectedRole = SurveyRole.admin,
  List<SurveyRole> roles = SurveyRole.values,
  ValueChanged<SurveyRole>? onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SurveyRoleSelector(
          selectedRole: selectedRole,
          roles: roles,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
}
