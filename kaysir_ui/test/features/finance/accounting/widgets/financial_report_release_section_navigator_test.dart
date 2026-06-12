import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_action_queue.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_section_navigator.dart';

void main() {
  testWidgets('renders compact release section controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseSectionNavigator(
            selectedDestination:
                FinancialReportReleaseActionDestination.distribution,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Release Sections'), findsOneWidget);
    expect(find.text('6 controls'), findsOneWidget);
    expect(find.text('Sign-off'), findsOneWidget);
    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('Distribution'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Retention'), findsOneWidget);
    expect(find.text('Filing'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('selects a release section destination', (tester) async {
    FinancialReportReleaseActionDestination? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseSectionNavigator(
            selectedDestination: null,
            onSelect: (destination) => selected = destination,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('release-section-statutoryFiling')),
    );
    await tester.pump();

    expect(selected, FinancialReportReleaseActionDestination.statutoryFiling);
  });
}
