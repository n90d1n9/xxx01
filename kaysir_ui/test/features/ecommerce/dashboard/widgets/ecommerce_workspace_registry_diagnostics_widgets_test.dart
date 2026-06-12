import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_diagnostics_widgets.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_issue_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_source_pill.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('RegistrySourcePills renders source health', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistrySourcePills(
            sourceSummaries: [
              RegistrySourceSummary(
                source: RegistryIssueSource.profile,
                count: 0,
              ),
              RegistrySourceSummary(
                source: RegistryIssueSource.module,
                count: 2,
              ),
              RegistrySourceSummary(
                source: RegistryIssueSource.action,
                count: 1,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(POSMetricPill), findsNWidgets(3));
    expect(find.byType(RegistrySourcePill), findsNWidgets(3));
    expect(find.text('Profiles | Ready'), findsOneWidget);
    expect(find.text('Modules | 2'), findsOneWidget);
    expect(find.text('Actions | 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegistryIssueList renders mixed issues', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryIssueList(
            diagnostics: RegistryDiagnostics(
              productProfileIssueCount: 1,
              moduleIssueCount: 1,
              actionRuleIssueCount: 1,
              sourceSummaries: [
                RegistrySourceSummary(
                  source: RegistryIssueSource.profile,
                  count: 1,
                ),
                RegistrySourceSummary(
                  source: RegistryIssueSource.module,
                  count: 1,
                ),
                RegistrySourceSummary(
                  source: RegistryIssueSource.action,
                  count: 1,
                ),
              ],
              issues: [
                RegistryIssueEntry(
                  index: 0,
                  source: RegistryIssueSource.profile,
                  typeName: 'blankProfileLabel',
                  message: 'Commerce product profile needs a visible label.',
                ),
                RegistryIssueEntry(
                  index: 1,
                  source: RegistryIssueSource.module,
                  typeName: 'blankModuleTitle',
                  message: 'Workspace module needs a title.',
                ),
                RegistryIssueEntry(
                  index: 2,
                  source: RegistryIssueSource.action,
                  typeName: 'unknownDestination',
                  message: 'Action rule points to an unknown destination.',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RegistryIssueRow), findsNWidgets(3));
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Module'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('blankProfileLabel'), findsOneWidget);
    expect(find.text('blankModuleTitle'), findsOneWidget);
    expect(find.text('unknownDestination'), findsOneWidget);
    expect(
      find.text('Commerce product profile needs a visible label.'),
      findsOneWidget,
    );
    expect(find.text('Workspace module needs a title.'), findsOneWidget);
    expect(
      find.text('Action rule points to an unknown destination.'),
      findsOneWidget,
    );
    expect(find.byType(EmptyState), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegistryIssueList renders empty diagnostics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryIssueList(
            diagnostics: RegistryDiagnostics(
              productProfileIssueCount: 0,
              moduleIssueCount: 0,
              actionRuleIssueCount: 0,
              sourceSummaries: [],
              issues: [],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No registry issues found.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
