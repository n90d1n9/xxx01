import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('ticket detail panel renders selected ticket and actions', (
    tester,
  ) async {
    final actions = <KitchenTicketAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketDetailPanel(
            ticket: _ticket(),
            now: _now,
            averageFireMinutes: 12,
            onActionSelected: actions.add,
          ),
        ),
      ),
    );

    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Grill'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('order-1'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget);
    expect(find.text('2m late to fire'), findsOneWidget);
    expect(find.text('12m fire window'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('4 guests'), findsOneWidget);
    expect(find.text('18:15 reservation'), findsOneWidget);
    expect(find.text('Anniversary'), findsOneWidget);
    expect(find.text('Window table'), findsOneWidget);
    expect(find.text('Allergy: Peanut allergy'), findsOneWidget);
    expect(find.text('Use clean utensils.'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Dietary: No shellfish'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.text('No peanuts'), findsOneWidget);
    expect(find.text('Fire with mains.'), findsOneWidget);
    expect(find.text('Start firing'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Start firing'));
    await tester.pump();

    expect(actions, [KitchenTicketAction.startFiring]);
  });

  testWidgets('ticket detail panel renders empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: KitchenTicketDetailPanel(ticket: null, now: _now)),
      ),
    );

    expect(find.text('No ticket selected.'), findsOneWidget);
  });

  testWidgets('ticket detail panel renders handoff verification checklist', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KitchenTicketDetailPanel(
              ticket: _ticket(stage: KitchenTicketStage.ready),
              now: _now,
              verifiedHandoffStepIds: const {'critical-alerts'},
              handoffVerificationRecords: {
                'critical-alerts': KitchenHandoffVerificationRecord(
                  stepId: 'critical-alerts',
                  verifiedAt: _now,
                  verifiedBy: 'Expo',
                ),
              },
              onHandoffVerificationChanged: (stepId, verified) {
                changes.add('$stepId:$verified');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Handoff checks'), findsOneWidget);
    expect(find.text('1 / 3 verified'), findsOneWidget);
    expect(find.text('Verify critical alert'), findsOneWidget);
    expect(find.text('Verified: Expo - 18:30'), findsOneWidget);
    expect(find.text('Review service alert'), findsOneWidget);
    expect(find.text('Review service note'), findsOneWidget);
    expect(
      find.byTooltip(kitchenHandoffVerificationBlockReason),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Serve'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();

    expect(changes, ['service-alerts:true']);
  });

  testWidgets('ticket detail panel enables serve after handoff verification', (
    tester,
  ) async {
    final actions = <KitchenTicketAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KitchenTicketDetailPanel(
              ticket: _ticket(stage: KitchenTicketStage.ready),
              now: _now,
              verifiedHandoffStepIds: const {
                'critical-alerts',
                'service-alerts',
                'service-notes',
              },
              onActionSelected: actions.add,
            ),
          ),
        ),
      ),
    );

    final serveButton = find.widgetWithText(FilledButton, 'Serve');
    expect(tester.widget<FilledButton>(serveButton).onPressed, isNotNull);

    await tester.ensureVisible(find.text('Serve'));
    await tester.pump();
    await tester.tap(find.text('Serve'));
    await tester.pump();

    expect(actions, [KitchenTicketAction.serve]);
  });

  testWidgets('ticket detail panel hides actions for closed ticket', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketDetailPanel(
            ticket: _ticket(stage: KitchenTicketStage.served),
            now: _now,
          ),
        ),
      ),
    );

    expect(find.text('Served'), findsWidgets);
    expect(find.text('Start firing'), findsNothing);
    expect(find.text('Serve'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });
}

final _now = DateTime(2026, 6, 9, 18, 30);

KitchenTicket _ticket({KitchenTicketStage stage = KitchenTicketStage.queued}) {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: _now.add(const Duration(minutes: 10)),
    stage: stage,
    notes: 'Fire with mains.',
    serviceContext: FnbServiceContext(
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
        quantity: 2,
        modifiers: ['No peanuts'],
      ),
    ],
  );
}
