import 'package:flutter_test/flutter_test.dart';

import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('order statuses use shared FnB service pressure', () {
    expect(OrderStatus.pending.serviceStatus, FnbServiceStatus.busy);
    expect(OrderStatus.processing.serviceStatus, FnbServiceStatus.critical);
    expect(OrderStatus.delivered.serviceStatus, FnbServiceStatus.calm);
    expect(OrderStatus.cancelled.serviceStatus.needsAttention, isTrue);
  });

  test('kitchen ticket queue ranks open tickets by shared pressure', () {
    final now = DateTime(2026, 6, 9, 18, 30);
    final lateTicket = KitchenTicket(
      id: 'late-grill',
      orderId: 'order-1',
      stationId: 'grill',
      stationName: 'Grill',
      customerLabel: 'Table 12',
      dueAt: now.subtract(const Duration(minutes: 4)),
      stage: KitchenTicketStage.firing,
      items: const [
        KitchenTicketItem(
          menuItemId: 'rib',
          name: 'Short Rib Rendang',
          quantity: 2,
        ),
      ],
    );
    final readyTicket = KitchenTicket(
      id: 'ready-pass',
      orderId: 'order-2',
      stationId: 'pass',
      stationName: 'Pass',
      customerLabel: 'Counter',
      dueAt: now.add(const Duration(minutes: 1)),
      stage: KitchenTicketStage.ready,
      items: const [
        KitchenTicketItem(
          menuItemId: 'spritz',
          name: 'Pandan Spritz',
          quantity: 1,
        ),
      ],
    );
    final servedTicket = readyTicket.copyWith(stage: KitchenTicketStage.served);

    final queue = KitchenTicketQueue(
      now: now,
      tickets: [readyTicket, servedTicket, lateTicket],
    );

    expect(queue.serviceStatus, FnbServiceStatus.critical);
    expect(queue.activeTicketCount, 2);
    expect(queue.lateTicketCount, 1);
    expect(queue.readyTicketCount, 1);
    expect(queue.totalItemCount, 3);
    expect(queue.priorityTickets.first.id, 'late-grill');
    expect(lateTicket.timingLabel(now), '4m late');
    expect(queue.ticketsForStation('pass'), [readyTicket]);
  });

  test('kitchen ticket carries shared service context', () {
    final now = DateTime(2026, 6, 9, 18, 30);
    final context = FnbServiceContext(
      guestName: 'Siti Rahma',
      partySize: 4,
      reservationTime: DateTime(2026, 6, 9, 18, 15),
      vip: true,
      occasion: 'Anniversary',
      notes: 'Window table',
      alerts: const [
        FnbServiceAlert(
          type: FnbServiceAlertType.allergy,
          label: 'Peanut allergy',
          critical: true,
        ),
      ],
    );
    final ticket = KitchenTicket(
      id: 'late-grill',
      orderId: 'order-1',
      stationId: 'grill',
      stationName: 'Grill',
      customerLabel: 'Table 12',
      dueAt: now.subtract(const Duration(minutes: 4)),
      stage: KitchenTicketStage.queued,
      serviceContext: context,
      items: const [
        KitchenTicketItem(
          menuItemId: 'rib',
          name: 'Short Rib Rendang',
          quantity: 2,
        ),
      ],
    );

    final updated = ticket.copyWith(stage: KitchenTicketStage.firing);

    expect(ticket.serviceContext, same(context));
    expect(updated.serviceContext, same(context));
    expect(updated.serviceContext?.summaryLabels, [
      'VIP',
      'Siti Rahma',
      '4 guests',
      '18:15 reservation',
      'Anniversary',
    ]);
    expect(
      updated.serviceContext?.alertSummaryLabel,
      'Allergy: Peanut allergy',
    );
  });

  test('kitchen package re-exports shared menu and recipe models', () {
    const recipe = FnbRecipe(
      id: 'rendang-recipe',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      stationId: 'grill',
      prepMinutes: 12,
      fireMinutes: 21,
      yieldQuantity: 4,
      yieldUnit: 'portions',
    );
    const item = FnbMenuItem(
      id: 'rendang',
      name: 'Short Rib Rendang',
      categoryId: 'mains',
      priceCents: 2450,
      recipeId: 'rendang-recipe',
      stationId: 'grill',
      availability: FnbMenuAvailability.limited,
    );

    expect(recipe.fireTimeLabel, '21m fire');
    expect(item.priceLabel, r'$24.50');
    expect(item.availabilityLabel, 'Limited');
    expect(
      FnbRecipeProductionEntry(recipe: recipe, menuItem: item).attentionLabel,
      'Limited availability',
    );
    expect(
      FnbRecipeProductionSummary.fromCatalog(
        recipes: const [recipe],
        menu: const FnbMenu(id: 'dinner', name: 'Dinner', items: [item]),
      ).linkedItemCount,
      1,
    );
  });

  test('kitchen station load uses shared station model', () {
    final now = DateTime(2026, 6, 9, 18, 30);
    const station = FnbKitchenStation(
      id: 'grill',
      name: 'Grill',
      lead: 'Ayu',
      ticketsInProgress: 0,
      averageFireMinutes: 0,
      queueLabel: 'Clear',
      status: FnbServiceStatus.calm,
    );
    final queue = KitchenTicketQueue(
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
          items: const [
            KitchenTicketItem(
              menuItemId: 'rib',
              name: 'Short Rib Rendang',
              quantity: 2,
            ),
          ],
        ),
        KitchenTicket(
          id: 'ready-pass',
          orderId: 'order-2',
          stationId: 'pass',
          stationName: 'Pass',
          customerLabel: 'Counter',
          dueAt: now.add(const Duration(minutes: 1)),
          stage: KitchenTicketStage.ready,
          items: const [
            KitchenTicketItem(
              menuItemId: 'spritz',
              name: 'Pandan Spritz',
              quantity: 1,
            ),
          ],
        ),
      ],
    );

    final load = KitchenStationLoad.fromQueue(station: station, queue: queue);

    expect(load.station, station);
    expect(load.activeTicketCount, 1);
    expect(load.lateTicketCount, 1);
    expect(load.itemCount, 2);
    expect(load.queueLabel, '1 late');
    expect(load.status, FnbServiceStatus.critical);

    final summary = FnbKitchenStationSummary.fromStations([
      load.stationSnapshot,
    ]);

    expect(summary.pressureCount, 1);
    expect(summary.totalTickets, 1);
    expect(load.stationSnapshot.queueLabel, '1 late');
    expect(
      FnbKitchenStationFilter.pressure.includes(load.stationSnapshot),
      isTrue,
    );
    expect(
      FnbKitchenStationPriorityQueue.fromStations([
        load.stationSnapshot,
      ]).topStation?.id,
      'grill',
    );
  });

  test('kitchen station board derives shared operating state', () {
    final now = DateTime(2026, 6, 9, 18, 30);
    const stations = [
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
    final queue = KitchenTicketQueue(
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
          items: const [
            KitchenTicketItem(
              menuItemId: 'rib',
              name: 'Short Rib Rendang',
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
              menuItemId: 'spritz',
              name: 'Pandan Spritz',
              quantity: 1,
            ),
          ],
        ),
      ],
    );

    final board = KitchenStationBoard.fromQueue(
      stations: stations,
      queue: queue,
    );

    expect(board.loads, hasLength(3));
    expect(board.activeTicketCount, 2);
    expect(board.lateTicketCount, 1);
    expect(board.itemCount, 3);
    expect(board.summary.pressureCount, 2);
    expect(board.priorityQueue.topStation?.id, 'pass');
    expect(board.topLoad?.station.id, 'pass');
    expect(
      board
          .filteredLoads(FnbKitchenStationFilter.pressure)
          .map((load) => load.station.id),
      ['grill', 'pass'],
    );
    expect(
      board
          .filteredLoads(FnbKitchenStationFilter.calm)
          .map((load) => load.station.id),
      ['bar'],
    );
  });
}
