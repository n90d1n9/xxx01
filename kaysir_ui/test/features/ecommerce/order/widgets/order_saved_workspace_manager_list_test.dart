import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_callbacks.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_list.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('manager list renders rows with active, pinned, and note state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ListHarness(
        managerView: ecommerceOrderSavedWorkspaceManagerView(
          workspaces: _workspaces,
        ),
        workspaces: _workspaces,
        activeWorkspaceId: savedWorkspaceDeliveryToday.id,
      ),
    );

    expect(_managerItem(savedWorkspaceDeliveryToday.id), findsOneWidget);
    expect(_managerItem(savedWorkspacePinnedPickupPriority.id), findsOneWidget);
    expect(find.text('Delivery / Today'), findsOneWidget);
    expect(find.text('Morning courier note'), findsOneWidget);
    expect(find.text('Pickup priority'), findsOneWidget);
    expect(find.text('Pinned pickup exceptions'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text('Custom note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager list renders empty state for no visible workspaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ListHarness(
        managerView: ecommerceOrderSavedWorkspaceManagerView(
          workspaces: _workspaces,
          query: 'missing',
        ),
        workspaces: _workspaces,
        activeWorkspaceId: null,
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_empty')),
      findsOneWidget,
    );
    expect(find.text('No saved workspaces match this search.'), findsOneWidget);
    expect(_managerItem(savedWorkspaceDeliveryToday.id), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager list exposes configured row actions', (tester) async {
    await tester.pumpWidget(
      _ListHarness(
        managerView: ecommerceOrderSavedWorkspaceManagerView(
          workspaces: _workspaces,
        ),
        workspaces: _workspaces,
        activeWorkspaceId: null,
      ),
    );

    await tester.tap(_managerActionsButton(savedWorkspaceDeliveryToday.id));
    await tester.pumpAndSettle();

    expect(_managerPinButton(savedWorkspaceDeliveryToday.id), findsOneWidget);
    expect(
      _managerDuplicateButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerRenameButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerEditNoteButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerResetNoteButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerMoveEarlierButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerMoveLaterButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(
      _managerDeleteButton(savedWorkspaceDeliveryToday.id),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _ListHarness extends StatelessWidget {
  final OrderSavedWorkspaceManagerView managerView;
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;

  const _ListHarness({
    required this.managerView,
    required this.workspaces,
    required this.activeWorkspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 720,
          child: OrderSavedWorkspaceManagerList(
            managerView: managerView,
            workspaces: workspaces,
            activeWorkspaceId: activeWorkspaceId,
            callbacks: OrderSavedWorkspaceManagerCallbacks(
              onSelected: (_) {},
              onDeleted: (_) {},
              onDuplicated: (_) {},
              onPinnedChanged: (_, _) {},
              onRenamed: (_, _) {},
              onDescriptionChanged: (_, _) {},
              onDescriptionReset: (_) {},
              onMoved: (_, _) {},
            ),
          ),
        ),
      ),
    );
  }
}

Finder _managerItem(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_$id'));
}

Finder _managerActionsButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_actions_$id'));
}

Finder _managerPinButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_pin_$id'));
}

Finder _managerDuplicateButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_duplicate_$id'));
}

Finder _managerRenameButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_rename_$id'));
}

Finder _managerEditNoteButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_edit_note_$id'));
}

Finder _managerResetNoteButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_reset_note_$id'));
}

Finder _managerMoveEarlierButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_move_earlier_$id'));
}

Finder _managerMoveLaterButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_move_later_$id'));
}

Finder _managerDeleteButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_delete_$id'));
}

const _workspaces = [
  savedWorkspaceDeliveryToday,
  savedWorkspacePinnedPickupPriority,
];
