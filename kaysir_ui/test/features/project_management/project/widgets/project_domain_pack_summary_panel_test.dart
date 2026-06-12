import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_pack_summary_panel.dart';

void main() {
  testWidgets('project domain pack summary panel renders retail profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDomainPackSummaryPanel(
              businessDomain: 'Retail Operations',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Domain Pack'), findsOneWidget);
    expect(find.text('Retail Operations'), findsOneWidget);
    expect(find.text('Retail'), findsWidgets);
    expect(find.text('Retail / Team'), findsOneWidget);
    expect(find.textContaining('store rollout'), findsWidgets);
    expect(find.textContaining('Store Cluster'), findsOneWidget);
    expect(find.textContaining('Omnichannel Impact'), findsOneWidget);
    expect(find.text('Confirm retail rollout controls'), findsOneWidget);
    expect(find.text('Launch wave readiness'), findsOneWidget);
    expect(find.text('SKU scope pressure'), findsOneWidget);
    expect(find.text('Omnichannel dependency'), findsOneWidget);
    expect(find.textContaining('Store pilot ready'), findsOneWidget);
    expect(find.textContaining('Launch review'), findsOneWidget);
    expect(find.textContaining('Store Rollout Lead'), findsOneWidget);
    expect(find.textContaining('Store Enablement Lead'), findsOneWidget);
  });

  testWidgets('project domain pack summary panel renders fallback profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectDomainPackSummaryPanel(
              businessDomain: 'Custom Logistics',
            ),
          ),
        ),
      ),
    );

    expect(find.text('General Business'), findsOneWidget);
    expect(find.text('General / Stakeholder'), findsOneWidget);
    expect(find.textContaining('Custom Logistics'), findsNothing);
    expect(find.textContaining('Workstream, Region, Priority'), findsOneWidget);
    expect(find.textContaining('KPI Owner'), findsOneWidget);
    expect(find.text('Confirm operating rhythm'), findsOneWidget);
    expect(find.text('High priority workstream'), findsOneWidget);
    expect(find.textContaining('Kickoff'), findsOneWidget);
    expect(find.textContaining('Project Lead'), findsOneWidget);
  });
}
