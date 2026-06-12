import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets(
    'service alert panel renders priority alerts and selects tickets',
    (tester) async {
      final selectedIds = <String>[];
      final queue = _testQueue();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KitchenServiceAlertPanel(
              summary: KitchenServiceAlertSummary.fromQueue(queue),
              selectedTicketId: 'late-grill',
              onTicketSelected: (ticket) => selectedIds.add(ticket.id),
            ),
          ),
        ),
      );

      expect(find.text('Service alerts'), findsOneWidget);
      expect(find.text('3 alerts'), findsWidgets);
      expect(find.text('1 critical'), findsOneWidget);
      expect(find.text('2 tickets'), findsOneWidget);
      expect(find.text('Table 12'), findsNWidgets(2));
      expect(find.text('Grill - Allergy: Peanut allergy'), findsOneWidget);
      expect(find.text('Use clean utensils.'), findsOneWidget);
      expect(find.text('Table 4'), findsOneWidget);
      expect(find.text('Bar - Preference: Low sugar'), findsOneWidget);

      final allergyTop = tester
          .getTopLeft(find.text('Grill - Allergy: Peanut allergy'))
          .dy;
      final preferenceTop = tester
          .getTopLeft(find.text('Bar - Preference: Low sugar'))
          .dy;

      expect(allergyTop, lessThan(preferenceTop));

      await tester.tap(find.byTooltip('Select service alert for Table 4'));
      await tester.pump();

      expect(selectedIds, ['bar-ready']);
    },
  );

  testWidgets('service alert panel renders empty state', (tester) async {
    final now = DateTime(2026, 6, 10, 18, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenServiceAlertPanel(
            summary: KitchenServiceAlertSummary.fromQueue(
              KitchenTicketQueue(now: now, tickets: const []),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Service alerts'), findsOneWidget);
    expect(find.text('0 alerts'), findsWidgets);
    expect(find.text('No active service alerts.'), findsOneWidget);
  });
}

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 10, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'late-grill',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 3)),
        stage: KitchenTicketStage.firing,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              description: 'Use clean utensils.',
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
            quantity: 1,
          ),
        ],
      ),
      KitchenTicket(
        id: 'bar-ready',
        orderId: 'order-2',
        stationId: 'bar',
        stationName: 'Bar',
        customerLabel: 'Table 4',
        dueAt: now.add(const Duration(minutes: 2)),
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
    ],
  );
}
