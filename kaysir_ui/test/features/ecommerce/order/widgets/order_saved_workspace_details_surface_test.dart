import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_surface.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test(
    'details surface resolver chooses compact, medium, and large surfaces',
    () {
      expect(
        orderSavedWorkspaceDetailsSurfaceForWidth(480),
        OrderSavedWorkspaceDetailsSurfaceKind.bottomSheet,
      );
      expect(
        orderSavedWorkspaceDetailsSurfaceForWidth(
          orderSavedWorkspaceDetailsCompactBreakpoint,
        ),
        OrderSavedWorkspaceDetailsSurfaceKind.sideSheet,
      );
      expect(
        orderSavedWorkspaceDetailsSurfaceForWidth(900),
        OrderSavedWorkspaceDetailsSurfaceKind.sideSheet,
      );
      expect(
        orderSavedWorkspaceDetailsSurfaceForWidth(
          orderSavedWorkspaceDetailsMediumBreakpoint,
        ),
        OrderSavedWorkspaceDetailsSurfaceKind.dialog,
      );
      expect(
        orderSavedWorkspaceDetailsSurfaceForWidth(1280),
        OrderSavedWorkspaceDetailsSurfaceKind.dialog,
      );
    },
  );

  testWidgets('details surface opens a dialog on large layouts', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(1280, 800));
    await tester.pumpWidget(const _DetailsSurfaceHarness());

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_sheet')),
      findsNothing,
    );
    expect(find.text('Workspace details'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('details surface opens a side sheet on medium layouts', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(900, 800));
    await tester.pumpWidget(const _DetailsSurfaceHarness());

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_side_sheet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_dialog')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_sheet')),
      findsNothing,
    );
    expect(find.text('Workspace details'), findsOneWidget);
    expect(find.text('Exact filters'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('details surface opens a bottom sheet on compact layouts', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(480, 800));
    await tester.pumpWidget(const _DetailsSurfaceHarness());

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_sheet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_dialog')),
      findsNothing,
    );
    expect(find.text('Workspace details'), findsOneWidget);
    expect(find.text('Exact filters'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('details surface renders optional actions and emits selection', (
    tester,
  ) async {
    final selectedActions = <OrderSavedWorkspaceAction>[];
    await _setSurfaceSize(tester, const Size(900, 800));
    await tester.pumpWidget(
      _DetailsSurfaceHarness(
        actionEntries: const [
          OrderSavedWorkspaceActionEntry(
            action: OrderSavedWorkspaceAction.rename,
          ),
          OrderSavedWorkspaceActionEntry(
            action: OrderSavedWorkspaceAction.togglePin,
          ),
        ],
        onActionSelected: (action) async => selectedActions.add(action),
      ),
    );

    await tester.tap(find.byKey(_openDetailsKey));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_actions')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('order_saved_workspace_details_sticky_actions'),
      ),
      findsOneWidget,
    );
    final pinAction = find.byKey(
      ValueKey(
        'order_saved_workspace_details_action_pin_'
        '${savedWorkspacePinnedDeliveryToday.id}',
      ),
    );
    await tester.tap(pinAction);
    await tester.pump();

    expect(selectedActions, [OrderSavedWorkspaceAction.togglePin]);
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _DetailsSurfaceHarness extends StatelessWidget {
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final Future<void> Function(OrderSavedWorkspaceAction action)?
  onActionSelected;

  const _DetailsSurfaceHarness({
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return FilledButton(
                key: _openDetailsKey,
                onPressed:
                    () => showOrderSavedWorkspaceDetailsSurface(
                      context: context,
                      workspace: savedWorkspacePinnedDeliveryToday,
                      actionEntries: actionEntries,
                      onActionSelected: onActionSelected,
                    ),
                child: const Text('Open details'),
              );
            },
          ),
        ),
      ),
    );
  }
}

const _openDetailsKey = ValueKey('open_saved_workspace_details_surface');
