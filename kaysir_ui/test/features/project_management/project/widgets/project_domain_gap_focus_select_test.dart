import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_focus_select.dart';

void main() {
  testWidgets('domain gap focus select renders reusable options', (
    tester,
  ) async {
    var selectedFocus = ProjectDomainGapFocus.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapFocusSelect(
            fieldKey: const ValueKey('domain-gap-focus-select'),
            value: selectedFocus,
            onChanged: (focus) => selectedFocus = focus,
          ),
        ),
      ),
    );

    expect(find.text('Gaps'), findsOneWidget);
    expect(find.text('All Projects'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('domain-gap-focus-select')));
    await tester.pumpAndSettle();

    expect(find.text('Any Field Gaps'), findsOneWidget);
    expect(find.text('Required Gaps'), findsOneWidget);
    expect(find.text('Recommended Gaps'), findsOneWidget);
    expect(find.text('Risk Signal Gaps'), findsOneWidget);

    await tester.tap(find.text('Risk Signal Gaps'));
    await tester.pumpAndSettle();

    expect(selectedFocus, ProjectDomainGapFocus.missingRiskSignals);
  });
}
