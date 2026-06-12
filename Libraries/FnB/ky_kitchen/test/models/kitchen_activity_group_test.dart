import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('activity grouping summarizes results by ticket and station', () {
    final grillTicket = _ticket();
    final barTicket = _ticket(
      id: 'ticket-2',
      orderId: 'order-2',
      stationId: 'bar',
      stationName: 'Bar',
      customerLabel: 'Table 4',
      stage: KitchenTicketStage.ready,
    );
    final barServed = KitchenTicketActionResult(
      action: KitchenTicketAction.serve,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: barTicket.id,
      previousTicket: barTicket,
      updatedTicket: KitchenTicketAction.serve.applyTo(barTicket),
    );
    final grillIssue = KitchenTicketActionResult(
      action: KitchenTicketAction.serve,
      outcome: KitchenTicketActionOutcome.unavailable,
      ticketId: grillTicket.id,
      previousTicket: grillTicket,
    );
    final grillStarted = KitchenTicketActionResult(
      action: KitchenTicketAction.startFiring,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: grillTicket.id,
      previousTicket: grillTicket,
      updatedTicket: KitchenTicketAction.startFiring.applyTo(grillTicket),
    );

    final grouping = KitchenActivityGrouping(
      results: [barServed, grillIssue, grillStarted],
    );

    final ticketGroups = grouping.groupsBy(KitchenActivityGroupScope.ticket);
    final stationGroups = grouping.groupsBy(KitchenActivityGroupScope.station);

    expect(ticketGroups.map((group) => group.label), ['Table 4', 'Table 12']);
    expect(ticketGroups.first.subtitle, 'Bar - order-2');
    expect(ticketGroups.last.actionCount, 2);
    expect(ticketGroups.last.appliedCount, 1);
    expect(ticketGroups.last.issueCount, 1);
    expect(ticketGroups.last.hasIssues, isTrue);
    expect(ticketGroups.last.actionCountLabel, '2 actions');
    expect(ticketGroups.last.issueCountLabel, '1 issue');
    expect(stationGroups.map((group) => group.label), ['Bar', 'Grill']);
    expect(
      grouping.groupsBy(KitchenActivityGroupScope.ticket, limit: 1),
      hasLength(1),
    );
  });

  test('activity grouping can build from filtered history', () {
    final ticket = _ticket();
    final applied = KitchenTicketActionResult(
      action: KitchenTicketAction.startFiring,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: ticket.id,
      previousTicket: ticket,
      updatedTicket: KitchenTicketAction.startFiring.applyTo(ticket),
    );
    final issue = KitchenTicketActionResult(
      action: KitchenTicketAction.serve,
      outcome: KitchenTicketActionOutcome.unavailable,
      ticketId: ticket.id,
      previousTicket: ticket,
    );
    final history = KitchenTicketActionHistory(results: [issue, applied]);

    final grouping = KitchenActivityGrouping.fromHistory(
      history,
      filter: KitchenTicketActionHistoryFilter.issues,
      ticketId: ticket.id,
    );

    final groups = grouping.groupsBy(KitchenActivityGroupScope.ticket);

    expect(groups, hasLength(1));
    expect(groups.first.label, 'Table 12');
    expect(groups.first.results, [issue]);
  });
}

KitchenTicket _ticket({
  String id = 'ticket-1',
  String orderId = 'order-1',
  String stationId = 'grill',
  String stationName = 'Grill',
  String customerLabel = 'Table 12',
  KitchenTicketStage stage = KitchenTicketStage.queued,
}) {
  return KitchenTicket(
    id: id,
    orderId: orderId,
    stationId: stationId,
    stationName: stationName,
    customerLabel: customerLabel,
    dueAt: DateTime(2026, 6, 10, 18, 30),
    stage: stage,
    items: const [
      KitchenTicketItem(
        menuItemId: 'rib',
        name: 'Short Rib Rendang',
        quantity: 2,
      ),
    ],
  );
}
