import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/layout_spec.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/operations_section.dart';

import '../fixtures/test_fixtures.dart';
import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('OperationsSection stacks compact layout', (tester) async {
    final selectedActions = <String>[];

    await tester.pumpWorkspaceWidget(
      OperationsSection(
        workspace: testWorkspace(),
        layoutSpec: const LayoutSpec(
          mode: LayoutMode.compact,
          contentPadding: 10,
          actionPanelWidth: 300,
        ),
        onActionSelected: selectedActions.add,
      ),
      width: 500,
    );

    expect(find.byKey(const ValueKey('operations_stacked')), findsOneWidget);
    expect(find.text('Priority actions'), findsOneWidget);
    expect(find.text('Channel and fulfillment mix'), findsOneWidget);

    await tester.tap(find.text('Open renewals'));
    await tester.pump();

    expect(selectedActions, ['/commerce/renewals']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OperationsSection uses side panel layout', (tester) async {
    await tester.pumpWorkspaceWidget(
      OperationsSection(
        workspace: testWorkspace(),
        layoutSpec: const LayoutSpec(
          mode: LayoutMode.sidePanel,
          contentPadding: 16,
          actionPanelWidth: 360,
        ),
        onActionSelected: (_) {},
      ),
      width: 1100,
    );

    expect(find.byKey(const ValueKey('operations_side_panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('operations_stacked')), findsNothing);
    expect(find.text('Priority actions'), findsOneWidget);
    expect(find.text('Channel and fulfillment mix'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OperationsSection can invoke action objects', (tester) async {
    Action? invokedAction;

    await tester.pumpWorkspaceWidget(
      OperationsSection(
        workspace: testWorkspace(),
        layoutSpec: const LayoutSpec(
          mode: LayoutMode.compact,
          contentPadding: 10,
          actionPanelWidth: 300,
        ),
        onActionSelected: (_) {},
        onActionInvoked: (action) => invokedAction = action,
      ),
      width: 500,
    );

    await tester.tap(find.text('Open renewals'));
    await tester.pump();

    expect(invokedAction?.id, 'renewals');
    expect(invokedAction?.routePath, '/commerce/renewals');
    expect(tester.takeException(), isNull);
  });
}
