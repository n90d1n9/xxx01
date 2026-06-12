import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_station_board.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_queue.dart';

/// Builds sample station board data for widget previews.
KitchenStationBoard kitchenStationBoardPreviewData() {
  return KitchenStationBoard.fromQueue(
    stations: kitchenStationPreviewData(),
    queue: kitchenTicketQueuePreviewData(),
  );
}

/// Builds sample station metadata for widget and screen previews.
List<FnbKitchenStation> kitchenStationPreviewData() {
  return const [
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
}

/// Builds sample kitchen ticket queue data for widget previews.
KitchenTicketQueue kitchenTicketQueuePreviewData() {
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
        notes: 'Fire together with table mains.',
        serviceContext: FnbServiceContext(
          guestName: 'Siti Rahma',
          partySize: 4,
          reservationTime: now.subtract(const Duration(minutes: 15)),
          vip: true,
          occasion: 'Anniversary',
          notes: 'Prefers window seating.',
          alerts: const [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              description: 'Use clean utensils and separate garnish.',
              critical: true,
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.dietary,
              label: 'No shellfish',
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'rib',
            name: 'Short Rib Rendang',
            quantity: 2,
          ),
          KitchenTicketItem(
            menuItemId: 'ulam',
            name: 'Nasi Ulam',
            quantity: 1,
            modifiers: ['No peanuts'],
          ),
          KitchenTicketItem(
            menuItemId: 'satay',
            name: 'Mushroom Satay',
            quantity: 1,
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
        serviceContext: FnbServiceContext(
          partySize: 2,
          reservationTime: now.subtract(const Duration(minutes: 5)),
          alerts: const [
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
