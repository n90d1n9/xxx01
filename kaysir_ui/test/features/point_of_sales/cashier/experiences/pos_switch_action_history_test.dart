import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';

void main() {
  test(
    'switch action history records newest entries first and trims limit',
    () {
      final occurredAt = DateTime(2026, 6, 8, 10);
      var history = POSSwitchActionHistory.empty(limit: 2);

      history = history.record(
        _result('standard_cashier', POSSwitchActionOutcome.applied),
        occurredAt: occurredAt,
        sequence: 1,
      );
      history = history.record(
        _result('online_pack', POSSwitchActionOutcome.cancelled),
        occurredAt: occurredAt.add(const Duration(minutes: 1)),
        sequence: 2,
      );
      history = history.record(
        _result('delivery_app', POSSwitchActionOutcome.blocked),
        occurredAt: occurredAt.add(const Duration(minutes: 2)),
        sequence: 3,
      );

      expect(history.entries.map((entry) => entry.result.targetId), [
        'delivery_app',
        'online_pack',
      ]);
      expect(history.appliedCount, 0);
      expect(history.cancelledCount, 1);
      expect(history.blockedCount, 1);
      expect(history.attentionCount, 1);
      expect(history.latest?.summaryLabel, 'Blocked POS mode: delivery_app');
      expect(history.searchTerms, contains('blocked'));
    },
  );

  test('switch action history notifier records and clears entries', () {
    final occurredAt = DateTime(2026, 6, 8, 11);
    final notifier = POSSwitchActionHistoryNotifier(
      clock: () => occurredAt,
      limit: 2,
    );

    final entry = notifier.record(
      _result('quick_checkout', POSSwitchActionOutcome.applied),
    );

    expect(entry.id, 'pos_switch_${occurredAt.microsecondsSinceEpoch}_1');
    expect(notifier.state.entries.single, same(entry));
    expect(notifier.state.appliedCount, 1);

    notifier.clear();

    expect(notifier.state.isEmpty, isTrue);
    expect(notifier.state.limit, 2);
  });
}

POSSwitchActionResult _result(String targetId, POSSwitchActionOutcome outcome) {
  return POSSwitchActionResult(
    kind: POSSwitchActionKind.mode,
    outcome: outcome,
    targetId: targetId,
    targetLabel: targetId,
    reason: outcome == POSSwitchActionOutcome.applied ? null : outcome.name,
  );
}
