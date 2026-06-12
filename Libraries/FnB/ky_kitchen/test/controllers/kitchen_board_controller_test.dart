import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('controller initializes with prioritized station and ticket', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    expect(controller.selectedFilter, FnbKitchenStationFilter.all);
    expect(controller.visibleLoads, hasLength(3));
    expect(controller.selectedStationId, 'pass');
    expect(controller.selectedLoad?.station.name, 'Pass');
    expect(controller.visibleTickets.map((ticket) => ticket.id), [
      'pass-ticket',
    ]);
    expect(controller.selectedTicketId, 'pass-ticket');
    expect(controller.selectedTicket?.customerLabel, 'Counter');
  });

  test('controller keeps station selection inside the selected filter', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'pass',
    );

    controller.selectFilter(FnbKitchenStationFilter.delayed);

    expect(controller.selectedFilter, FnbKitchenStationFilter.delayed);
    expect(controller.visibleLoads.map((load) => load.station.id), ['grill']);
    expect(controller.selectedStationId, 'grill');
    expect(controller.visibleTickets.map((ticket) => ticket.id), [
      'late-grill',
    ]);
    expect(controller.selectedTicketId, 'late-grill');
  });

  test('controller scopes and clears station ticket visibility', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );
    final changes = <String?>[];
    controller.addListener(() => changes.add(controller.selectedStationId));

    controller.selectStation('grill');

    expect(controller.selectedStationId, 'grill');
    expect(controller.visibleTickets.map((ticket) => ticket.id), [
      'late-grill',
    ]);
    expect(controller.selectedTicketId, 'late-grill');

    controller.clearStationSelection();

    expect(controller.selectedStationId, isNull);
    expect(controller.visibleTickets.map((ticket) => ticket.id), [
      'late-grill',
      'bar-ready',
      'pass-ticket',
    ]);
    expect(controller.selectedTicketId, 'late-grill');
    expect(changes, ['grill', null]);
  });

  test('controller selects ticket and moves station selection with it', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'grill',
    );

    controller.selectTicket('bar-ready');

    expect(controller.selectedStationId, 'bar');
    expect(controller.selectedTicketId, 'bar-ready');
    expect(controller.selectedTicket?.stationName, 'Bar');
  });

  test('controller tracks and prunes handoff verification steps', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'bar',
      initialTicketId: 'bar-ready',
    );
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.verifiedHandoffStepIdsFor('bar-ready'), isEmpty);

    controller.setHandoffStepVerified(
      ticketId: 'bar-ready',
      stepId: 'service-alerts',
      verified: true,
    );

    expect(controller.verifiedHandoffStepIdsFor('bar-ready'), {
      'service-alerts',
    });
    final record = controller.handoffVerificationRecordsFor(
      'bar-ready',
    )['service-alerts'];
    expect(record?.verifiedAt, controller.queue.now);
    expect(record?.verifiedBy, 'Expo');
    expect(record?.verifiedById, 'expo');
    expect(record?.verifiedByRole, isNull);
    expect(record?.auditLabel, 'Verified: Expo - 18:30');
    expect(notifyCount, 1);

    controller.setHandoffStepVerified(
      ticketId: 'bar-ready',
      stepId: 'service-alerts',
      verified: false,
    );

    expect(controller.verifiedHandoffStepIdsFor('bar-ready'), isEmpty);
    expect(controller.handoffVerificationRecordsFor('bar-ready'), isEmpty);
    expect(notifyCount, 2);

    controller.setHandoffStepVerified(
      ticketId: 'bar-ready',
      stepId: 'service-alerts',
      verified: true,
    );
    controller.applySelectedTicketAction(KitchenTicketAction.serve);

    expect(controller.verifiedHandoffStepIdsFor('bar-ready'), isEmpty);
    expect(controller.handoffAuditEntries, hasLength(1));
    expect(controller.handoffAuditEntries.first.ticketId, 'bar-ready');
    expect(
      controller.handoffAuditEntries.first.summaryLabel,
      '1 check verified by Expo',
    );
    expect(controller.handoffAuditEntries.first.closedLabel, 'Served at 18:30');
    expect(controller.selectedTicketId, isNull);
    expect(notifyCount, 4);
  });

  test('controller blocks serving until handoff checks are verified', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueueWithHandoffRequirement(),
      initialStationId: 'bar',
      initialTicketId: 'bar-ready',
    );

    final ticket = controller.selectedTicket!;
    expect(
      controller.handoffVerificationPlanFor(ticket).progressLabel,
      '0 / 1 verified',
    );
    expect(
      controller.canApplyTicketAction(
        ticket: ticket,
        action: KitchenTicketAction.serve,
      ),
      isFalse,
    );
    expect(
      controller.ticketActionBlockReason(
        ticket: ticket,
        action: KitchenTicketAction.serve,
      ),
      kitchenHandoffVerificationBlockReason,
    );

    final blocked = controller.applySelectedTicketActionResult(
      KitchenTicketAction.serve,
    );

    expect(blocked.applied, isFalse);
    expect(blocked.outcome, KitchenTicketActionOutcome.unavailable);
    expect(controller.selectedTicket?.stage, KitchenTicketStage.ready);

    controller.setHandoffStepVerified(
      ticketId: 'bar-ready',
      stepId: 'service-alerts',
      verified: true,
      verifiedBy: 'Ayu',
    );

    final verifiedTicket = controller.selectedTicket!;
    expect(
      controller
          .handoffVerificationPlanFor(verifiedTicket)
          .recordFor('service-alerts')
          ?.auditLabel,
      'Verified: Ayu - 18:30',
    );
    expect(
      controller
          .handoffVerificationPlanFor(verifiedTicket)
          .recordFor('service-alerts')
          ?.verifiedById,
      'ayu',
    );
    expect(
      controller.canApplyTicketAction(
        ticket: verifiedTicket,
        action: KitchenTicketAction.serve,
      ),
      isTrue,
    );

    final applied = controller.applySelectedTicketActionResult(
      KitchenTicketAction.serve,
    );

    expect(applied.applied, isTrue);
    expect(controller.selectedTicketId, isNull);
    expect(controller.handoffAuditEntries, hasLength(1));
    expect(
      controller.handoffAuditEntries.first.summaryLabel,
      '1 check verified by Ayu',
    );
    expect(
      controller.queue.tickets
          .firstWhere((ticket) => ticket.id == 'bar-ready')
          .stage,
      KitchenTicketStage.served,
    );
  });

  test('controller records handoff checks with operator context metadata', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueueWithHandoffRequirement(),
      initialStationId: 'bar',
      initialTicketId: 'bar-ready',
      handoffOperatorContext: const KitchenOperatorContext(
        id: 'staff-7',
        displayName: 'Dimas',
        roleLabel: 'Expo lead',
      ),
    );

    controller.setHandoffStepVerified(
      ticketId: 'bar-ready',
      stepId: 'service-alerts',
      verified: true,
    );

    final record = controller.handoffVerificationRecordsFor(
      'bar-ready',
    )['service-alerts'];

    expect(controller.handoffVerifierLabel, 'Dimas');
    expect(record?.verifiedBy, 'Dimas');
    expect(record?.verifiedById, 'staff-7');
    expect(record?.verifiedByRole, 'Expo lead');
    expect(record?.auditLabel, 'Verified: Dimas - 18:30');
  });

  test(
    'controller updates time and queue data while normalizing selection',
    () {
      final now = DateTime(2026, 6, 9, 18, 30);
      final controller = KitchenBoardController(
        stations: _stations,
        queue: _testQueue(now: now),
        initialStationId: 'bar',
        initialTicketId: 'bar-ready',
      );
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.updateNow(now.add(const Duration(minutes: 5)));

      expect(controller.queue.now, now.add(const Duration(minutes: 5)));
      expect(
        controller.selectedTicket?.timingLabel(controller.queue.now),
        '4m late',
      );
      expect(notifyCount, 1);

      controller.updateData(
        queue: KitchenTicketQueue(
          now: controller.queue.now,
          tickets: controller.queue.tickets
              .map((ticket) {
                if (ticket.id != 'bar-ready') return ticket;
                return ticket.copyWith(stage: KitchenTicketStage.served);
              })
              .toList(growable: false),
        ),
      );

      expect(controller.selectedStationId, 'bar');
      expect(controller.visibleTickets, isEmpty);
      expect(controller.selectedTicket, isNull);
      expect(notifyCount, 2);
    },
  );

  test('controller scopes recipe production to station selection', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      recipes: _recipes,
      menu: _menu,
    );

    expect(controller.hasRecipeProductionData, isTrue);
    expect(controller.scopedRecipeProductionSummary.scopeLabel, 'Station pass');
    expect(controller.scopedRecipeProductionSummary.entries.single.id, 'ulam');

    controller.clearStationSelection();

    expect(controller.recipeProductionSummary.recipeCount, 3);
    expect(controller.scopedRecipeProductionSummary.scopeLabel, 'All stations');
    expect(
      controller.scopedRecipeProductionSummary.entries.map((entry) => entry.id),
      ['ulam', 'rendang', 'spritz'],
    );

    final rendang = controller.recipeProductionSummary.entries.firstWhere(
      (entry) => entry.id == 'rendang',
    );
    controller.selectRecipeProductionEntry(rendang);

    expect(controller.selectedStationId, 'grill');
    expect(
      controller.scopedRecipeProductionSummary.entries.single.id,
      'rendang',
    );

    controller.updateRecipeProductionCatalog(recipes: const []);

    expect(controller.hasRecipeProductionData, isFalse);
    expect(controller.scopedRecipeProductionSummary.entries, isEmpty);
  });

  test('controller ignores invalid station and ticket selections', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );

    controller.selectStation('missing');
    controller.selectTicket('missing');

    expect(controller.selectedStationId, 'pass');
    expect(controller.selectedTicketId, 'pass-ticket');
  });

  test(
    'controller applies selected ticket action and rebuilds board state',
    () {
      final controller = KitchenBoardController(
        stations: _stations,
        queue: _testQueue(),
      );
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final applied = controller.applySelectedTicketAction(
        KitchenTicketAction.startFiring,
      );

      expect(applied, isTrue);
      expect(controller.lastActionResult?.applied, isTrue);
      expect(
        controller.lastActionResult?.previousTicket?.stage,
        KitchenTicketStage.queued,
      );
      expect(
        controller.lastActionResult?.updatedTicket?.stage,
        KitchenTicketStage.firing,
      );
      expect(controller.selectedTicketId, 'pass-ticket');
      expect(controller.selectedTicket?.stage, KitchenTicketStage.firing);
      expect(
        controller.queue.tickets
            .firstWhere((ticket) => ticket.id == 'pass-ticket')
            .stage,
        KitchenTicketStage.firing,
      );
      expect(controller.selectedLoad?.activeTicketCount, 1);
      expect(notifyCount, 1);
    },
  );

  test('controller closes selected ticket and normalizes ticket selection', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'bar',
      initialTicketId: 'bar-ready',
    );

    final applied = controller.applySelectedTicketAction(
      KitchenTicketAction.serve,
    );

    expect(applied, isTrue);
    expect(controller.selectedStationId, 'bar');
    expect(controller.visibleTickets, isEmpty);
    expect(controller.selectedTicketId, isNull);
    expect(
      controller.queue.tickets
          .firstWhere((ticket) => ticket.id == 'bar-ready')
          .stage,
      KitchenTicketStage.served,
    );
  });

  test(
    'controller records invalid ticket actions without changing tickets',
    () {
      final controller = KitchenBoardController(
        stations: _stations,
        queue: _testQueue(),
      );
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final applied = controller.applyTicketAction(
        ticketId: 'pass-ticket',
        action: KitchenTicketAction.serve,
      );

      expect(applied, isFalse);
      expect(
        controller.lastActionResult?.outcome,
        KitchenTicketActionOutcome.unavailable,
      );
      expect(controller.lastActionResult?.ticketId, 'pass-ticket');
      expect(controller.selectedTicket?.stage, KitchenTicketStage.queued);
      expect(controller.actionHistory.latest, controller.lastActionResult);
      expect(notifyCount, 1);
    },
  );

  test(
    'controller returns detailed result for missing selection and ticket',
    () {
      final controller = KitchenBoardController(
        stations: _stations,
        queue: _testQueue(),
      );

      controller.clearTicketSelection();
      final noSelectionResult = controller.applySelectedTicketActionResult(
        KitchenTicketAction.startFiring,
      );
      final missingTicketResult = controller.applyTicketActionResult(
        ticketId: 'missing',
        action: KitchenTicketAction.startFiring,
      );

      expect(
        noSelectionResult.outcome,
        KitchenTicketActionOutcome.noSelectedTicket,
      );
      expect(controller.lastActionResult, missingTicketResult);
      expect(
        missingTicketResult.outcome,
        KitchenTicketActionOutcome.ticketNotFound,
      );
      expect(controller.actionHistory.results, [
        missingTicketResult,
        noSelectionResult,
      ]);
    },
  );

  test('controller undoes the most recent applied ticket action', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    final applied = controller.applySelectedTicketActionResult(
      KitchenTicketAction.startFiring,
    );
    final undone = controller.undoLastTicketAction();

    expect(applied.applied, isTrue);
    expect(undone, isTrue);
    expect(controller.lastActionResult, isNull);
    expect(controller.selectedTicketId, 'pass-ticket');
    expect(controller.selectedTicket?.stage, KitchenTicketStage.queued);
    expect(controller.canUndoLastTicketAction, isFalse);
    expect(notifyCount, 2);
  });

  test('controller restores a closed ticket during undo', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      initialStationId: 'bar',
      initialTicketId: 'bar-ready',
    );

    controller.applySelectedTicketAction(KitchenTicketAction.serve);

    expect(controller.visibleTickets, isEmpty);
    expect(controller.selectedTicketId, isNull);

    final undone = controller.undoLastTicketAction();

    expect(undone, isTrue);
    expect(controller.selectedStationId, 'bar');
    expect(controller.selectedTicketId, 'bar-ready');
    expect(controller.selectedTicket?.stage, KitchenTicketStage.ready);
  });

  test('controller clears stored action feedback without changing tickets', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
    );
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    controller.applySelectedTicketAction(KitchenTicketAction.startFiring);
    controller.clearLastActionResult();

    expect(controller.lastActionResult, isNull);
    expect(controller.actionHistory.isNotEmpty, isTrue);
    expect(controller.selectedTicket?.stage, KitchenTicketStage.firing);
    expect(notifyCount, 2);
  });

  test('controller keeps bounded action history and clears it explicitly', () {
    final controller = KitchenBoardController(
      stations: _stations,
      queue: _testQueue(),
      actionHistoryLimit: 2,
    );
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    controller.applyTicketAction(
      ticketId: 'pass-ticket',
      action: KitchenTicketAction.startFiring,
    );
    controller.applyTicketAction(
      ticketId: 'pass-ticket',
      action: KitchenTicketAction.moveToPlating,
    );
    controller.applyTicketAction(
      ticketId: 'pass-ticket',
      action: KitchenTicketAction.serve,
    );

    expect(controller.actionHistory.results, hasLength(2));
    expect(controller.actionHistory.results.map((result) => result.action), [
      KitchenTicketAction.serve,
      KitchenTicketAction.moveToPlating,
    ]);
    expect(
      controller.actionHistory.results.every(
        (result) => result.occurredAt == controller.queue.now,
      ),
      isTrue,
    );
    expect(controller.actionHistory.appliedCount, 1);
    expect(controller.actionHistory.issueCount, 1);
    expect(
      controller.visibleActionHistoryResults.map((result) => result.action),
      [KitchenTicketAction.serve, KitchenTicketAction.moveToPlating],
    );

    controller.selectActionHistoryFilter(
      KitchenTicketActionHistoryFilter.issues,
    );

    expect(
      controller.selectedActionHistoryFilter,
      KitchenTicketActionHistoryFilter.issues,
    );
    expect(
      controller.visibleActionHistoryResults.map((result) => result.action),
      [KitchenTicketAction.serve],
    );

    controller.clearActionHistory();

    expect(controller.actionHistory.isEmpty, isTrue);
    expect(
      controller.selectedActionHistoryFilter,
      KitchenTicketActionHistoryFilter.all,
    );
    expect(controller.visibleActionHistoryResults, isEmpty);
    expect(notifyCount, 5);
  });
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

KitchenTicketQueue _testQueue({DateTime? now}) {
  final clock = now ?? DateTime(2026, 6, 9, 18, 30);

  return KitchenTicketQueue(
    now: clock,
    tickets: [
      KitchenTicket(
        id: 'late-grill',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: clock.subtract(const Duration(minutes: 2)),
        stage: KitchenTicketStage.firing,
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
        dueAt: clock.add(const Duration(minutes: 1)),
        stage: KitchenTicketStage.ready,
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
        dueAt: clock.add(const Duration(minutes: 4)),
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

KitchenTicketQueue _testQueueWithHandoffRequirement() {
  final queue = _testQueue();

  return KitchenTicketQueue(
    now: queue.now,
    tickets: queue.tickets
        .map((ticket) {
          if (ticket.id != 'bar-ready') return ticket;
          return ticket.copyWith(
            serviceContext: const FnbServiceContext(
              alerts: [
                FnbServiceAlert(
                  type: FnbServiceAlertType.preference,
                  label: 'Low sugar',
                ),
              ],
            ),
          );
        })
        .toList(growable: false),
  );
}
