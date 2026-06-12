import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('kitchen board screen renders station and ticket panes', (
    tester,
  ) async {
    final actions = <KitchenTicketAction>[];
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(
      _testApp(controller, onTicketActionSelected: actions.add),
    );

    expect(find.text('Station board'), findsOneWidget);
    expect(find.text('Stations'), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('Pass'), findsWidgets);
    expect(find.text('1 open ticket'), findsOneWidget);
    expect(find.text('Counter'), findsWidgets);
    expect(find.text('Pass pacing'), findsOneWidget);
    expect(find.text('Next due: Counter - 4m'), findsOneWidget);
    expect(find.text('On pace'), findsOneWidget);
    expect(find.text('3m late to fire'), findsOneWidget);
    expect(find.text('7m fire window'), findsOneWidget);
    expect(find.text('Service alerts'), findsOneWidget);
    expect(find.text('Grill - Allergy: Peanut allergy'), findsOneWidget);
    expect(find.text('Ready to serve'), findsOneWidget);
    expect(find.text('Bar handoff - 2 items'), findsOneWidget);
    expect(find.text('Start firing'), findsOneWidget);
    expect(find.text('Pass - order-2'), findsOneWidget);
    expect(find.text('Grill - order-1'), findsNothing);

    await tester.ensureVisible(find.text('Start firing'));
    await tester.pump();
    await tester.tap(find.text('Start firing'));
    await tester.pump();

    expect(actions, [KitchenTicketAction.startFiring]);
  });

  testWidgets('kitchen board screen selects ready tickets from dispatch', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(
      _testApp(
        controller,
        operatorContext: const KitchenOperatorContext(
          id: 'staff-7',
          displayName: 'Dimas',
          roleLabel: 'Expo lead',
        ),
      ),
    );

    await tester.ensureVisible(find.text('Bar handoff - 2 items'));
    await tester.pump();
    await tester.tap(find.text('Bar handoff - 2 items'));
    await tester.pump();

    expect(controller.selectedStationId, 'bar');
    expect(controller.selectedTicketId, 'bar-ready');
    expect(find.text('Serve'), findsWidgets);
    expect(find.text('Handoff checks'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(controller.verifiedHandoffStepIdsFor('bar-ready'), {
      'service-alerts',
    });
    final record = controller.handoffVerificationRecordsFor(
      'bar-ready',
    )['service-alerts'];
    expect(record?.verifiedById, 'staff-7');
    expect(record?.verifiedByRole, 'Expo lead');
    expect(find.text('Verified: Dimas - 18:30'), findsOneWidget);
  });

  testWidgets('kitchen board screen selects tickets from service alerts', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.ensureVisible(
      find.byTooltip('Select service alert for Table 12'),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Select service alert for Table 12'));
    await tester.pump();

    expect(controller.selectedStationId, 'grill');
    expect(controller.selectedTicketId, 'late-grill');
    expect(find.text('Grill pacing'), findsOneWidget);
  });

  testWidgets('kitchen board screen focuses station from pressure callout', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'bar',
    );

    await tester.pumpWidget(_testApp(controller));

    expect(controller.selectedStationId, 'bar');
    expect(find.text('Unblock Pass'), findsOneWidget);

    await tester.tap(find.text('Clear blocker with Dimas'));
    await tester.pump();

    expect(controller.selectedStationId, 'pass');
    expect(find.text('Pass pacing'), findsOneWidget);
  });

  testWidgets('kitchen board screen serves ready tickets from dispatch', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.ensureVisible(find.text('Bar handoff - 2 items'));
    await tester.pump();
    await tester.tap(find.text('Bar handoff - 2 items'));
    await tester.pump();

    expect(find.byTooltip(kitchenHandoffVerificationBlockReason), findsWidgets);

    await tester.ensureVisible(find.text('Handoff checks'));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    await tester.ensureVisible(find.byTooltip('Serve Table 4'));
    await tester.pump();
    await tester.tap(find.byTooltip('Serve Table 4'));
    await tester.pump();

    expect(
      controller.queue.tickets
          .firstWhere((ticket) => ticket.id == 'bar-ready')
          .stage,
      KitchenTicketStage.served,
    );
    expect(controller.lastActionResult?.action, KitchenTicketAction.serve);
    expect(controller.lastActionResult?.applied, isTrue);
    expect(find.text('Serve applied to Table 4.'), findsWidgets);
    expect(find.text('No tickets ready for service.'), findsOneWidget);
    expect(find.text('Handoff audit'), findsOneWidget);
    expect(find.text('1 check verified by Expo'), findsOneWidget);
    expect(find.text('Served at 18:30'), findsOneWidget);
  });

  testWidgets('kitchen board screen selects next due ticket from pacing', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.ensureVisible(find.byTooltip('Show all tickets'));
    await tester.pump();
    await tester.tap(find.byTooltip('Show all tickets'));
    await tester.pump();

    expect(find.text('Kitchen pacing'), findsOneWidget);
    expect(find.text('Next due: Table 12 - 2m late'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Select Table 12'));
    await tester.pump();
    await tester.tap(find.byTooltip('Select Table 12'));
    await tester.pump();

    expect(controller.selectedStationId, 'grill');
    expect(controller.selectedTicketId, 'late-grill');
    expect(find.text('Grill pacing'), findsOneWidget);
  });

  testWidgets(
    'kitchen board screen scopes and clears ticket queue by station',
    (tester) async {
      final controller = KitchenBoardController(
        stations: _stations,
        queue: _testQueue(),
      );

      await tester.pumpWidget(_testApp(controller));

      await tester.tap(find.text('Grill').first);
      await tester.pump();

      expect(controller.selectedStationId, 'grill');
      expect(find.text('Grill - order-1'), findsOneWidget);
      expect(find.text('Pass - order-2'), findsNothing);

      await tester.ensureVisible(find.byTooltip('Show all tickets'));
      await tester.pump();
      await tester.tap(find.byTooltip('Show all tickets'));
      await tester.pump();

      expect(controller.selectedStationId, isNull);
      expect(find.text('Grill - order-1'), findsOneWidget);
      expect(find.text('Bar - order-3'), findsOneWidget);
      expect(find.text('Pass - order-2'), findsOneWidget);
    },
  );

  testWidgets('kitchen board screen applies ticket action by default', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.ensureVisible(find.text('Start firing'));
    await tester.pump();
    await tester.tap(find.text('Start firing'));
    await tester.pump();

    expect(controller.selectedTicket?.stage, KitchenTicketStage.firing);
    expect(find.text('Start firing applied to Counter.'), findsWidgets);
    expect(find.byTooltip('Undo last ticket action'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('All 1'), findsOneWidget);
    expect(find.text('Applied 1'), findsOneWidget);
    expect(find.text('Issues 0'), findsOneWidget);
    expect(find.text('Ticket 1'), findsOneWidget);
    expect(find.text('Firing'), findsWidgets);
    expect(find.text('Move to plating'), findsOneWidget);

    await tester.ensureVisible(find.text('Ticket 1'));
    await tester.pump();
    await tester.tap(find.text('Ticket 1'));
    await tester.pump();

    expect(
      controller.selectedActionHistoryFilter,
      KitchenTicketActionHistoryFilter.ticket,
    );

    await tester.ensureVisible(find.byTooltip('Undo last ticket action'));
    await tester.pump();
    await tester.tap(find.byTooltip('Undo last ticket action'));
    await tester.pump();

    expect(controller.selectedTicket?.stage, KitchenTicketStage.queued);
    expect(find.text('Start firing'), findsOneWidget);
    expect(find.text('Start firing applied to Counter.'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
  });

  testWidgets('kitchen board screen rehomes station when filter changes', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'pass',
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.tap(find.text('Delayed 1'));
    await tester.pump();

    expect(controller.selectedFilter, FnbKitchenStationFilter.delayed);
    expect(controller.selectedStationId, 'grill');
    expect(find.text('Grill - order-1'), findsOneWidget);
    expect(find.text('Pass - order-2'), findsNothing);
  });

  testWidgets('kitchen board screen renders recipe production review', (
    tester,
  ) async {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      recipes: _recipes,
      menu: _menu,
    )..clearStationSelection();

    await tester.pumpWidget(_testApp(controller));

    expect(find.text('Recipe production'), findsOneWidget);
    expect(find.text('All stations - 3 recipes'), findsOneWidget);
    expect(find.text('Nasi Ulam: Link to a menu item'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsWidgets);
    expect(find.text('Pandan Spritz'), findsWidgets);

    await tester.ensureVisible(
      find.byTooltip('Review recipe production for Short Rib Rendang'),
    );
    await tester.pump();
    await tester.tap(
      find.byTooltip('Review recipe production for Short Rib Rendang'),
    );
    await tester.pump();

    expect(controller.selectedStationId, 'grill');
    expect(find.text('Station grill - 1 recipe'), findsOneWidget);
  });
}

Widget _testApp(
  KitchenBoardController controller, {
  ValueChanged<KitchenTicketAction>? onTicketActionSelected,
  KitchenOperatorContext? operatorContext,
}) {
  return MaterialApp(
    home: Scaffold(
      body: KitchenBoardScreen(
        controller: controller,
        operatorContext: operatorContext,
        onTicketActionSelected: onTicketActionSelected,
      ),
    ),
  );
}

const _stations = [
  FnbKitchenStation(
    id: 'grill',
    name: 'Grill',
    lead: 'Ayu',
    ticketsInProgress: 0,
    averageFireMinutes: 18,
    queueLabel: 'Clear',
    status: FnbServiceStatus.calm,
  ),
  FnbKitchenStation(
    id: 'pass',
    name: 'Pass',
    lead: 'Dimas',
    ticketsInProgress: 0,
    averageFireMinutes: 7,
    queueLabel: 'Expo blocked',
    status: FnbServiceStatus.blocked,
  ),
  FnbKitchenStation(
    id: 'bar',
    name: 'Bar',
    lead: 'Citra',
    ticketsInProgress: 0,
    averageFireMinutes: 6,
    queueLabel: 'Clear',
    status: FnbServiceStatus.calm,
  ),
];

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 9, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'late-grill',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 2)),
        stage: KitchenTicketStage.firing,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              description: 'Use clean utensils.',
              critical: true,
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'rib',
            name: 'Short Rib Rendang',
            quantity: 2,
          ),
        ],
      ),
      KitchenTicket(
        id: 'bar-ready',
        orderId: 'order-3',
        stationId: 'bar',
        stationName: 'Bar',
        customerLabel: 'Table 4',
        dueAt: now.add(const Duration(minutes: 1)),
        stage: KitchenTicketStage.ready,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.preference,
              label: 'Low sugar',
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'spritz',
            name: 'Pandan Spritz',
            quantity: 2,
          ),
        ],
      ),
      KitchenTicket(
        id: 'pass-ticket',
        orderId: 'order-2',
        stationId: 'pass',
        stationName: 'Pass',
        customerLabel: 'Counter',
        dueAt: now.add(const Duration(minutes: 4)),
        stage: KitchenTicketStage.queued,
        items: const [
          KitchenTicketItem(
            menuItemId: 'salad',
            name: 'Herb Garden Salad',
            quantity: 1,
          ),
        ],
      ),
    ],
  );
}

const _menu = FnbMenu(
  id: 'dinner',
  name: 'Dinner',
  items: [
    FnbMenuItem(
      id: 'rib',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      recipeId: 'rendang',
      stationId: 'grill',
      priceCents: 3200,
      availability: FnbMenuAvailability.limited,
      dietaryTags: {FnbDietaryTag.containsNuts},
    ),
    FnbMenuItem(
      id: 'spritz',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      recipeId: 'spritz',
      stationId: 'bar',
      priceCents: 1400,
    ),
  ],
);

const _recipes = [
  FnbRecipe(
    id: 'rendang',
    name: 'Short Rib Rendang',
    categoryId: 'mains',
    stationId: 'grill',
    prepMinutes: 12,
    fireMinutes: 18,
    yieldQuantity: 4,
    yieldUnit: 'portions',
    costCents: 1420,
    dietaryTags: {FnbDietaryTag.containsNuts},
    ingredients: [
      FnbRecipeIngredient(
        inventoryItemId: 'rib',
        name: 'Braised short rib',
        quantity: 1.2,
        unit: 'kg',
      ),
      FnbRecipeIngredient(
        inventoryItemId: 'spice',
        name: 'Rendang paste',
        quantity: 240,
        unit: 'g',
      ),
    ],
    steps: [
      'Warm sauce and glaze short rib.',
      'Finish over grill.',
      'Confirm allergen garnish path.',
    ],
  ),
  FnbRecipe(
    id: 'spritz',
    name: 'Pandan Spritz',
    categoryId: 'beverage',
    stationId: 'bar',
    prepMinutes: 4,
    fireMinutes: 2,
    yieldQuantity: 1,
    yieldUnit: 'glass',
    costCents: 360,
    steps: ['Build syrup and citrus over ice.', 'Top with soda.'],
  ),
  FnbRecipe(
    id: 'ulam',
    name: 'Nasi Ulam',
    categoryId: 'mains',
    stationId: 'pass',
    prepMinutes: 8,
    fireMinutes: 6,
    yieldQuantity: 2,
    yieldUnit: 'bowls',
    costCents: 520,
    dietaryTags: {FnbDietaryTag.vegetarian},
    steps: ['Toss rice, herbs, sambal, and garnish.'],
  ),
];
