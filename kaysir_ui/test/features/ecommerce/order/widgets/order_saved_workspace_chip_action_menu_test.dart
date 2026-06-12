import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_chip_action_menu.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('chip action menu exposes configured actions', (tester) async {
    await tester.pumpWidget(
      _MenuHarness(
        workspace: savedWorkspacePinnedDeliveryToday,
        onDeleted: () {},
        onDuplicated: () {},
        onPinnedChanged: (_) {},
        onRenamed: (_) {},
        onDescriptionChanged: (_) {},
        onDescriptionReset: () {},
        onMoved: (_) {},
        canMoveEarlier: false,
        canMoveLater: true,
      ),
    );

    expect(find.byTooltip('Manage Delivery / Today workspace'), findsOneWidget);

    await _openActions(tester, savedWorkspacePinnedDeliveryToday.id);

    expect(_actionButton(OrderSavedWorkspaceAction.details), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.editNote), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.resetNote), findsOneWidget);
    expect(
      _actionButton(OrderSavedWorkspaceAction.moveEarlier),
      findsOneWidget,
    );
    expect(_actionButton(OrderSavedWorkspaceAction.moveLater), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.rename), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.duplicate), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.togglePin), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.delete), findsOneWidget);
    expect(
      _popupItem(tester, OrderSavedWorkspaceAction.moveEarlier).enabled,
      false,
    );
    expect(
      _popupItem(tester, OrderSavedWorkspaceAction.moveLater).enabled,
      true,
    );
    expect(find.text('Unpin'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chip action menu emits direct action callbacks', (tester) async {
    var deleted = false;
    var duplicated = false;
    bool? pinnedState;
    var resetDescription = false;
    OrderSavedWorkspaceMoveDirection? moveDirection;

    await tester.pumpWidget(
      _MenuHarness(
        workspace: savedWorkspacePinnedDeliveryToday,
        onDeleted: () => deleted = true,
        onDuplicated: () => duplicated = true,
        onPinnedChanged: (value) => pinnedState = value,
        onRenamed: (_) {},
        onDescriptionChanged: (_) {},
        onDescriptionReset: () => resetDescription = true,
        onMoved: (direction) => moveDirection = direction,
        canMoveEarlier: true,
        canMoveLater: true,
      ),
    );

    await _tapAction(tester, OrderSavedWorkspaceAction.togglePin);
    expect(pinnedState, false);

    await _tapAction(tester, OrderSavedWorkspaceAction.duplicate);
    expect(duplicated, true);

    await _tapAction(tester, OrderSavedWorkspaceAction.resetNote);
    expect(resetDescription, true);

    await _tapAction(tester, OrderSavedWorkspaceAction.moveLater);
    expect(moveDirection, OrderSavedWorkspaceMoveDirection.later);

    await _tapAction(tester, OrderSavedWorkspaceAction.delete);
    expect(deleted, true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chip action menu emits dialog action callbacks', (tester) async {
    String? renamedLabel;
    String? description;

    await tester.pumpWidget(
      _MenuHarness(
        workspace: savedWorkspacePinnedDeliveryToday,
        onDeleted: null,
        onDuplicated: null,
        onPinnedChanged: null,
        onRenamed: (value) => renamedLabel = value,
        onDescriptionChanged: (value) => description = value,
        onDescriptionReset: null,
        onMoved: null,
        canMoveEarlier: false,
        canMoveLater: false,
      ),
    );

    await _tapAction(tester, OrderSavedWorkspaceAction.rename);
    expect(find.text('Rename workspace'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_rename_field')),
      '  Courier rush  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_rename_save')),
    );
    await tester.pumpAndSettle();
    expect(renamedLabel, 'Courier rush');

    await _tapAction(tester, OrderSavedWorkspaceAction.editNote);
    expect(find.text('Edit workspace note'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_description_field')),
      '  Morning courier queue  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_description_save')),
    );
    await tester.pumpAndSettle();
    expect(description, 'Morning courier queue');
    expect(tester.takeException(), isNull);
  });
}

class _MenuHarness extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final VoidCallback? onDeleted;
  final VoidCallback? onDuplicated;
  final ValueChanged<bool>? onPinnedChanged;
  final ValueChanged<String>? onRenamed;
  final ValueChanged<String>? onDescriptionChanged;
  final VoidCallback? onDescriptionReset;
  final ValueChanged<OrderSavedWorkspaceMoveDirection>? onMoved;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const _MenuHarness({
    required this.workspace,
    required this.onDeleted,
    required this.onDuplicated,
    required this.onPinnedChanged,
    required this.onRenamed,
    required this.onDescriptionChanged,
    required this.onDescriptionReset,
    required this.onMoved,
    required this.canMoveEarlier,
    required this.canMoveLater,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OrderSavedWorkspaceChipActionMenu(
            workspace: workspace,
            foregroundColor: Colors.black,
            onDeleted: onDeleted,
            onDuplicated: onDuplicated,
            onPinnedChanged: onPinnedChanged,
            onRenamed: onRenamed,
            onDescriptionChanged: onDescriptionChanged,
            onDescriptionReset: onDescriptionReset,
            onMoved: onMoved,
            canMoveEarlier: canMoveEarlier,
            canMoveLater: canMoveLater,
          ),
        ),
      ),
    );
  }
}

Future<void> _tapAction(
  WidgetTester tester,
  OrderSavedWorkspaceAction action,
) async {
  await _openActions(tester, savedWorkspacePinnedDeliveryToday.id);
  await tester.tap(_actionButton(action));
  await tester.pumpAndSettle();
}

Future<void> _openActions(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey('order_saved_workspace_actions_$id')));
  await tester.pumpAndSettle();
}

Finder _actionButton(OrderSavedWorkspaceAction action) {
  return find.byKey(
    ValueKey(
      'order_saved_workspace_${action.keySuffix}_${savedWorkspacePinnedDeliveryToday.id}',
    ),
  );
}

PopupMenuItem<OrderSavedWorkspaceAction> _popupItem(
  WidgetTester tester,
  OrderSavedWorkspaceAction action,
) {
  return tester.widget<PopupMenuItem<OrderSavedWorkspaceAction>>(
    find.byWidgetPredicate(
      (widget) =>
          widget is PopupMenuItem<OrderSavedWorkspaceAction> &&
          widget.value == action,
    ),
  );
}
