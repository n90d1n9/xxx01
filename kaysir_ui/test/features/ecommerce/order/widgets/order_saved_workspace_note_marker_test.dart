import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_note_marker.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('note marker names the custom workspace note', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSavedWorkspaceNoteMarker(
              workspace: savedWorkspaceDeliveryToday,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip('Custom note for Delivery / Today: Morning courier note'),
      findsOneWidget,
    );
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Custom note for Delivery / Today workspace',
      ),
    );
    expect(semantics.properties.hint, 'Morning courier note');
    expect(
      find.byKey(
        const ValueKey(
          'order_saved_workspace_note_marker_saved_delivery_today',
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('note marker stays hidden without a custom note', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSavedWorkspaceNoteMarker(
              workspace: savedWorkspacePickupPriority,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey(
          'order_saved_workspace_note_marker_saved_pickup_priority',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Custom note for Pickup priority workspace',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
