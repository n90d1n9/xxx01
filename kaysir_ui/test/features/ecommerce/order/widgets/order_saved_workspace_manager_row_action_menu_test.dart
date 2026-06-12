import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_callbacks.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_row_action_menu.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('manager row action menu exposes configured actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ManagerActionHarness(
        workspace: savedWorkspacePinnedDeliveryToday,
        onDeleted: (_) {},
        onDuplicated: (_) {},
        onPinnedChanged: (_, _) {},
        onRenamed: (_, _) {},
        onDescriptionChanged: (_, _) {},
        onDescriptionReset: (_) {},
        onMoved: (_, _) {},
        canMoveEarlier: false,
        canMoveLater: true,
      ),
    );

    await _openHostDialog(tester);
    await _openActions(tester);

    expect(_actionButton(OrderSavedWorkspaceAction.togglePin), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.duplicate), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.rename), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.editNote), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.resetNote), findsOneWidget);
    expect(
      _actionButton(OrderSavedWorkspaceAction.moveEarlier),
      findsOneWidget,
    );
    expect(_actionButton(OrderSavedWorkspaceAction.moveLater), findsOneWidget);
    expect(_actionButton(OrderSavedWorkspaceAction.delete), findsOneWidget);
    expect(
      _popupItem(tester, OrderSavedWorkspaceAction.moveEarlier).enabled,
      false,
    );
    expect(
      _popupItem(tester, OrderSavedWorkspaceAction.moveLater).enabled,
      true,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager row action menu hides when no actions are configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _ManagerActionHarness(
        workspace: savedWorkspacePinnedDeliveryToday,
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
    );

    await _openHostDialog(tester);

    expect(_actionsButton(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'manager row action menu emits direct callbacks and closes host',
    (tester) async {
      OrderSavedWorkspace? deletedWorkspace;
      OrderSavedWorkspace? duplicatedWorkspace;
      OrderSavedWorkspace? pinnedWorkspace;
      bool? pinnedState;
      OrderSavedWorkspace? resetWorkspace;
      OrderSavedWorkspace? movedWorkspace;
      OrderSavedWorkspaceMoveDirection? moveDirection;

      await tester.pumpWidget(
        _ManagerActionHarness(
          workspace: savedWorkspacePinnedDeliveryToday,
          onDeleted: (workspace) => deletedWorkspace = workspace,
          onDuplicated: (workspace) => duplicatedWorkspace = workspace,
          onPinnedChanged: (workspace, isPinned) {
            pinnedWorkspace = workspace;
            pinnedState = isPinned;
          },
          onRenamed: (_, _) {},
          onDescriptionChanged: (_, _) {},
          onDescriptionReset: (workspace) => resetWorkspace = workspace,
          onMoved: (workspace, direction) {
            movedWorkspace = workspace;
            moveDirection = direction;
          },
          canMoveEarlier: true,
          canMoveLater: true,
        ),
      );

      await _tapAction(tester, OrderSavedWorkspaceAction.togglePin);
      expect(pinnedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(pinnedState, false);
      expect(_hostDialog(), findsNothing);

      await _tapAction(tester, OrderSavedWorkspaceAction.duplicate);
      expect(duplicatedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(_hostDialog(), findsNothing);

      await _tapAction(tester, OrderSavedWorkspaceAction.resetNote);
      expect(resetWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(_hostDialog(), findsNothing);

      await _tapAction(tester, OrderSavedWorkspaceAction.moveLater);
      expect(movedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(moveDirection, OrderSavedWorkspaceMoveDirection.later);
      expect(_hostDialog(), findsNothing);

      await _tapAction(tester, OrderSavedWorkspaceAction.delete);
      expect(deletedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(_hostDialog(), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'manager row action menu emits dialog callbacks and closes host',
    (tester) async {
      OrderSavedWorkspace? renamedWorkspace;
      String? renamedLabel;
      OrderSavedWorkspace? describedWorkspace;
      String? description;

      await tester.pumpWidget(
        _ManagerActionHarness(
          workspace: savedWorkspacePinnedDeliveryToday,
          onDeleted: null,
          onDuplicated: null,
          onPinnedChanged: null,
          onRenamed: (workspace, label) {
            renamedWorkspace = workspace;
            renamedLabel = label;
          },
          onDescriptionChanged: (workspace, value) {
            describedWorkspace = workspace;
            description = value;
          },
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
        '  Manager courier  ',
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('order_saved_workspace_rename_save')),
      );
      await tester.pumpAndSettle();
      expect(renamedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(renamedLabel, 'Manager courier');
      expect(_hostDialog(), findsNothing);

      await _tapAction(tester, OrderSavedWorkspaceAction.editNote);
      expect(find.text('Edit workspace note'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('order_saved_workspace_description_field')),
        '  Manager courier note  ',
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('order_saved_workspace_description_save')),
      );
      await tester.pumpAndSettle();
      expect(describedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(description, 'Manager courier note');
      expect(_hostDialog(), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _ManagerActionHarness extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final ValueChanged<OrderSavedWorkspace>? onDeleted;
  final ValueChanged<OrderSavedWorkspace>? onDuplicated;
  final void Function(OrderSavedWorkspace workspace, bool isPinned)?
  onPinnedChanged;
  final void Function(OrderSavedWorkspace workspace, String label)? onRenamed;
  final void Function(OrderSavedWorkspace workspace, String description)?
  onDescriptionChanged;
  final ValueChanged<OrderSavedWorkspace>? onDescriptionReset;
  final void Function(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  )?
  onMoved;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const _ManagerActionHarness({
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
          child: Builder(
            builder:
                (context) => FilledButton(
                  key: const ValueKey(
                    'order_saved_workspace_manager_action_host_open',
                  ),
                  onPressed:
                      () => showDialog<void>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              key: const ValueKey(
                                'order_saved_workspace_manager_action_host_dialog',
                              ),
                              content: OrderSavedWorkspaceManagerRowActionMenu(
                                workspace: workspace,
                                callbacks: OrderSavedWorkspaceManagerCallbacks(
                                  onDeleted: onDeleted,
                                  onDuplicated: onDuplicated,
                                  onPinnedChanged: onPinnedChanged,
                                  onRenamed: onRenamed,
                                  onDescriptionChanged: onDescriptionChanged,
                                  onDescriptionReset: onDescriptionReset,
                                  onMoved: onMoved,
                                ),
                                canMoveEarlier: canMoveEarlier,
                                canMoveLater: canMoveLater,
                              ),
                            ),
                      ),
                  child: const Text('Open'),
                ),
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
  await _openHostDialog(tester);
  await _openActions(tester);
  await tester.tap(_actionButton(action));
  await tester.pumpAndSettle();
}

Future<void> _openHostDialog(WidgetTester tester) async {
  await tester.tap(
    find.byKey(
      const ValueKey('order_saved_workspace_manager_action_host_open'),
    ),
  );
  await tester.pumpAndSettle();
  expect(_hostDialog(), findsOneWidget);
}

Future<void> _openActions(WidgetTester tester) async {
  await tester.tap(_actionsButton());
  await tester.pumpAndSettle();
}

Finder _hostDialog() {
  return find.byKey(
    const ValueKey('order_saved_workspace_manager_action_host_dialog'),
  );
}

Finder _actionsButton() {
  return find.byKey(
    ValueKey(
      'order_saved_workspace_manager_actions_${savedWorkspacePinnedDeliveryToday.id}',
    ),
  );
}

Finder _actionButton(OrderSavedWorkspaceAction action) {
  return find.byKey(
    ValueKey(
      'order_saved_workspace_manager_${action.keySuffix}_${savedWorkspacePinnedDeliveryToday.id}',
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
