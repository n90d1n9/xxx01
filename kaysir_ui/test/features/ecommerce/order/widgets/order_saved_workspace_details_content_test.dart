import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_content.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('details content renders custom-note workspace sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsContent(
            workspace: savedWorkspacePinnedDeliveryToday,
          ),
        ),
      ),
    );

    expect(find.text('Delivery / Today'), findsOneWidget);
    expect(find.text('Exact filters'), findsOneWidget);
    expect(find.text('Auto summary preview'), findsOneWidget);
    expect(find.text('Shortcut id'), findsOneWidget);
    expect(find.text(savedWorkspacePinnedDeliveryToday.id), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details content hides auto-summary preview for auto notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsContent(
            workspace: savedWorkspaceWebOverdue,
          ),
        ),
      ),
    );

    expect(find.text('Web overdue'), findsOneWidget);
    expect(find.text('Auto summary'), findsOneWidget);
    expect(find.text('Auto summary preview'), findsNothing);
    expect(find.text(savedWorkspaceWebOverdue.id), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
