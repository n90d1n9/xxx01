import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/quick_actions.dart';

void main() {
  testWidgets('QuickActions opens selected action routes', (tester) async {
    final selectedRoutes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActions(
            actions: _actions,
            onActionSelected: selectedRoutes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open checkout'));
    await tester.pump();
    await tester.tap(find.text('Open orders'));
    await tester.pump();

    expect(selectedRoutes, [Routes.checkoutPath, Routes.ordersPath]);
    expect(find.text('Priority actions'), findsOneWidget);
    expect(find.text('Continue the active ecommerce basket.'), findsOneWidget);
    expect(find.byType(PanelHeader), findsOneWidget);
    expect(find.byType(PanelSurface), findsOneWidget);
    expect(find.byType(ActionButton), findsNWidgets(2));
  });

  testWidgets('QuickActions surfaces priority action hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActions(
            actions: const [
              Action(
                id: 'promise_policy_review',
                title: 'Review promise policy',
                description: '1 promise target needs configuration.',
                actionLabel: 'Review policy',
                routePath: Routes.ordersPath,
                icon: Icons.rule_folder_outlined,
                tone: ActionTone.warning,
                priority: 10,
              ),
            ],
            onActionSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Review policy'), findsOneWidget);
    expect(find.text('1 promise target needs configuration.'), findsOneWidget);
    expect(find.byType(ActionButton), findsOneWidget);
  });

  testWidgets('QuickActions can pass the selected action', (tester) async {
    Action? selectedAction;
    final selectedRoutes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickActions(
            actions: const [
              Action(
                id: 'channel_playbook_review',
                title: 'Review channel playbook',
                description: '1 channel coverage gap needs strategy review.',
                actionLabel: 'Review playbook',
                routePath: Routes.routePath,
                icon: Icons.route_outlined,
                tone: ActionTone.warning,
                priority: 35,
              ),
            ],
            onActionSelected: selectedRoutes.add,
            onActionInvoked: (action) => selectedAction = action,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Review playbook'));
    await tester.pump();

    expect(selectedAction?.id, 'channel_playbook_review');
    expect(selectedRoutes, isEmpty);
  });
}

const _actions = [
  Action(
    id: 'continue_checkout',
    title: 'Continue active checkout',
    description: 'Continue the active ecommerce basket.',
    actionLabel: 'Open checkout',
    routePath: Routes.checkoutPath,
    icon: Icons.point_of_sale_outlined,
    tone: ActionTone.primary,
    priority: 10,
  ),
  Action(
    id: 'open_orders',
    title: 'Open order workspace',
    description: 'Review fulfillment and settlement.',
    actionLabel: 'Open orders',
    routePath: Routes.ordersPath,
    icon: Icons.receipt_long_outlined,
    tone: ActionTone.secondary,
    priority: 20,
  ),
];
