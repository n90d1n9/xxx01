import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_chip.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('chip exposes accessible selected workspace action', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSavedWorkspaceChip(
              workspace: savedWorkspacePinnedDeliveryToday,
              selected: true,
              onSelected: () => selected = true,
              onDeleted: null,
              onDuplicated: null,
              onPinnedChanged: null,
              onRenamed: null,
              onDescriptionChanged: null,
              onDescriptionReset: null,
              onMoved: null,
              canMoveEarlier: false,
              canMoveLater: false,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip('Delivery / Today: Morning courier note'),
      findsOneWidget,
    );
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Selected saved workspace: Delivery / Today, pinned',
      ),
    );
    expect(
      semantics.properties.hint,
      'Morning courier note. Open this saved order workspace',
    );
    expect(semantics.properties.button, true);
    expect(semantics.properties.enabled, true);
    expect(semantics.properties.selected, true);

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_saved_delivery_today')),
    );
    await tester.pump();

    expect(selected, true);
    expect(tester.takeException(), isNull);
  });
}
