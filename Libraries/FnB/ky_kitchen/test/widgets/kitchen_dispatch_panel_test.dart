import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('dispatch panel renders ready tickets and reports selection', (
    tester,
  ) async {
    final selectedIds = <String>[];
    final actions = <String>[];
    final queue = _testQueue();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenDispatchPanel(
            summary: KitchenDispatchSummary.fromQueue(queue),
            selectedTicketId: 'late-ready',
            onTicketSelected: (ticket) => selectedIds.add(ticket.id),
            actionBlockReason: (_, _) => null,
            onTicketActionSelected: (ticket, action) {
              actions.add('${ticket.id}:${action.name}');
            },
          ),
        ),
      ),
    );

    expect(find.text('Ready to serve'), findsOneWidget);
    expect(find.text('2 ready'), findsWidgets);
    expect(find.text('1 late'), findsOneWidget);
    expect(find.text('1 in production'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Grill handoff - 1 item'), findsOneWidget);
    expect(find.text('Verify 1 critical alert'), findsOneWidget);
    expect(find.text('Table 4'), findsOneWidget);
    expect(find.text('Bar handoff - 2 items'), findsOneWidget);
    expect(find.text('Review 1 alert'), findsOneWidget);
    expect(find.text('Counter'), findsNothing);

    await tester.tap(find.text('Table 4'));
    await tester.pump();

    expect(selectedIds, ['soon-ready']);

    await tester.tap(find.byTooltip('Serve Table 4'));
    await tester.pump();

    expect(actions, ['soon-ready:serve']);
  });

  testWidgets('dispatch panel blocks serve until handoff checks are verified', (
    tester,
  ) async {
    final actions = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenDispatchPanel(
            summary: KitchenDispatchSummary.fromQueue(_testQueue()),
            onTicketActionSelected: (ticket, action) {
              actions.add('${ticket.id}:${action.name}');
            },
          ),
        ),
      ),
    );

    expect(
      find.byTooltip(kitchenHandoffVerificationBlockReason),
      findsNWidgets(2),
    );
    expect(
      tester
          .widgetList<FilledButton>(find.widgetWithText(FilledButton, 'Serve'))
          .every((button) => button.onPressed == null),
      isTrue,
    );
    expect(actions, isEmpty);
  });

  testWidgets('dispatch panel renders empty state', (tester) async {
    final now = DateTime(2026, 6, 10, 18, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenDispatchPanel(
            summary: KitchenDispatchSummary.fromQueue(
              KitchenTicketQueue(
                now: now,
                tickets: [
                  KitchenTicket(
                    id: 'firing-ticket',
                    orderId: 'order-3',
                    stationId: 'pass',
                    stationName: 'Pass',
                    customerLabel: 'Counter',
                    dueAt: now.add(const Duration(minutes: 7)),
                    stage: KitchenTicketStage.firing,
                    items: const [
                      KitchenTicketItem(
                        menuItemId: 'salad',
                        name: 'Herb Garden Salad',
                        quantity: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ready to serve'), findsOneWidget);
    expect(find.text('0 ready'), findsWidgets);
    expect(find.text('No tickets ready for service.'), findsOneWidget);
  });
}

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 10, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'soon-ready',
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
      KitchenTicket(
        id: 'late-ready',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 3)),
        stage: KitchenTicketStage.ready,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              critical: true,
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
        id: 'firing-ticket',
        orderId: 'order-3',
        stationId: 'pass',
        stationName: 'Pass',
        customerLabel: 'Counter',
        dueAt: now.add(const Duration(minutes: 7)),
        stage: KitchenTicketStage.firing,
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
