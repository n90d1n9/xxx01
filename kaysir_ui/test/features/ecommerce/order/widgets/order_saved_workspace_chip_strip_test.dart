import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_chip_strip.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('chip strip exposes scroll affordance and summary semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: OrderSavedWorkspaceChipStrip(
              workspaces: const [
                savedWorkspaceDeliveryToday,
                savedWorkspacePinnedPickupPriority,
                savedWorkspaceWebOverdue,
              ],
              activeWorkspaceId: savedWorkspaceDeliveryToday.id,
              onSelected: (_) {},
              onDeleted: null,
              onDuplicated: null,
              onPinnedChanged: null,
              onRenamed: null,
              onDescriptionChanged: null,
              onDescriptionReset: null,
              onMoved: null,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_chip_strip_scroll')),
      findsOneWidget,
    );
    expect(find.byType(Scrollbar), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Saved order workspace shortcuts, 3 saved workspaces, 1 pinned, 1 with custom notes',
      ),
    );
    expect(semantics.container, true);
    expect(tester.takeException(), isNull);
  });
}
