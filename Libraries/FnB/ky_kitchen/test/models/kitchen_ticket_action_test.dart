import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('ticket action plan exposes legal stage transitions', () {
    expect(KitchenTicketActionPlan.availableFor(_ticket()), [
      KitchenTicketAction.startFiring,
      KitchenTicketAction.cancel,
    ]);
    expect(
      KitchenTicketActionPlan.availableFor(
        _ticket(stage: KitchenTicketStage.firing),
      ),
      [
        KitchenTicketAction.moveToPlating,
        KitchenTicketAction.markReady,
        KitchenTicketAction.cancel,
      ],
    );
    expect(
      KitchenTicketActionPlan.availableFor(
        _ticket(stage: KitchenTicketStage.served),
      ),
      isEmpty,
    );
  });

  test(
    'ticket action plan applies valid actions and ignores invalid actions',
    () {
      final queuedTicket = _ticket();

      final firingTicket = KitchenTicketAction.startFiring.applyTo(
        queuedTicket,
      );
      final invalidTicket = KitchenTicketAction.serve.applyTo(queuedTicket);

      expect(firingTicket.stage, KitchenTicketStage.firing);
      expect(invalidTicket.stage, KitchenTicketStage.queued);
      expect(
        KitchenTicketAction.startFiring.resultStage,
        KitchenTicketStage.firing,
      );
      expect(KitchenTicketAction.cancel.isDestructive, isTrue);
      expect(KitchenTicketAction.serve.canApplyTo(queuedTicket), isFalse);
    },
  );

  test('ticket action plan resolves primary action', () {
    expect(
      KitchenTicketActionPlan.primaryFor(_ticket()),
      KitchenTicketAction.startFiring,
    );
    expect(
      KitchenTicketActionPlan.primaryFor(
        _ticket(stage: KitchenTicketStage.ready),
      ),
      KitchenTicketAction.serve,
    );
    expect(
      KitchenTicketActionPlan.primaryFor(
        _ticket(stage: KitchenTicketStage.cancelled),
      ),
      isNull,
    );
  });

  test('ticket action result exposes status and message', () {
    final ticket = _ticket();
    final result = KitchenTicketActionResult(
      action: KitchenTicketAction.startFiring,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: ticket.id,
      previousTicket: ticket,
      updatedTicket: KitchenTicketAction.startFiring.applyTo(ticket),
    );

    expect(result.applied, isTrue);
    expect(result.previousTicket?.stage, KitchenTicketStage.queued);
    expect(result.updatedTicket?.stage, KitchenTicketStage.firing);
    expect(result.message, 'Start firing applied to Table 12.');
  });

  test('ticket action history keeps newest-first bounded results', () {
    final ticket = _ticket();
    final first = KitchenTicketActionResult(
      action: KitchenTicketAction.startFiring,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: ticket.id,
      previousTicket: ticket,
      updatedTicket: KitchenTicketAction.startFiring.applyTo(ticket),
    );
    final second = KitchenTicketActionResult(
      action: KitchenTicketAction.serve,
      outcome: KitchenTicketActionOutcome.unavailable,
      ticketId: ticket.id,
      previousTicket: ticket,
    );

    final history = KitchenTicketActionHistory()
        .record(first, limit: 2)
        .record(second, limit: 2)
        .record(first, limit: 2);

    expect(history.results, [first, second]);
    expect(history.latest, first);
    expect(history.appliedCount, 1);
    expect(history.issueCount, 1);
    expect(history.forTicket(ticket.id), [first, second]);
    expect(history.filtered(filter: KitchenTicketActionHistoryFilter.applied), [
      first,
    ]);
    expect(history.filtered(filter: KitchenTicketActionHistoryFilter.issues), [
      second,
    ]);
    expect(
      history.filtered(
        filter: KitchenTicketActionHistoryFilter.ticket,
        ticketId: ticket.id,
      ),
      [first, second],
    );
    expect(
      history.filtered(filter: KitchenTicketActionHistoryFilter.ticket),
      isEmpty,
    );
    expect(history.summary(ticketId: ticket.id).ticketCount, 2);
    expect(history.summary(ticketId: 'missing').ticketCount, 0);
    expect(
      history
          .summary(ticketId: ticket.id)
          .countFor(KitchenTicketActionHistoryFilter.issues),
      1,
    );
    expect(KitchenTicketActionHistoryFilter.ticket.label, 'Ticket');
    expect(history.clear().isEmpty, isTrue);
  });
}

KitchenTicket _ticket({KitchenTicketStage stage = KitchenTicketStage.queued}) {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: DateTime(2026, 6, 9, 18, 30),
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
