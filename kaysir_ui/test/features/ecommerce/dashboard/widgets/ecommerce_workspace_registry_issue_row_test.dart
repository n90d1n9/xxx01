import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_issue_row.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('RegistryIssueRow renders issue detail', (tester) async {
    await tester.pumpWorkspaceWidget(
      const RegistryIssueRow(
        issue: RegistryIssueEntry(
          index: 1,
          source: RegistryIssueSource.action,
          typeName: 'unknownDestination',
          message: 'Action rule points to an unknown destination.',
        ),
      ),
    );

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('unknownDestination'), findsOneWidget);
    expect(
      find.text('Action rule points to an unknown destination.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.bolt_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
