import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('handoff audit list renders archived verification entries', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 10, 18, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenHandoffAuditList(
            entries: [
              KitchenHandoffAuditEntry.fromTicket(
                ticket: _ticket(now: now, stage: KitchenTicketStage.served),
                archivedAt: now.add(const Duration(minutes: 2)),
                records: [
                  KitchenHandoffVerificationRecord.fromOperator(
                    stepId: 'service-alerts',
                    verifiedAt: now,
                    operatorContext: const KitchenOperatorContext(
                      id: 'staff-7',
                      displayName: 'Dimas',
                      roleLabel: 'Expo lead',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Handoff audit'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Table 4'), findsOneWidget);
    expect(find.text('1 check verified by Dimas'), findsOneWidget);
    expect(find.text('Served at 18:32'), findsOneWidget);
  });

  testWidgets('handoff audit list renders empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: KitchenHandoffAuditList(entries: [])),
      ),
    );

    expect(find.text('Handoff audit'), findsOneWidget);
    expect(find.text('No handoff verifications archived.'), findsOneWidget);
  });
}

KitchenTicket _ticket({
  required DateTime now,
  required KitchenTicketStage stage,
}) {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'bar',
    stationName: 'Bar',
    customerLabel: 'Table 4',
    dueAt: now,
    stage: stage,
    items: const [
      KitchenTicketItem(
        menuItemId: 'spritz',
        name: 'Pandan Spritz',
        quantity: 2,
      ),
    ],
  );
}
