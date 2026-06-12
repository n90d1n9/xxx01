import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history_filter.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';

void main() {
  test('switch action history filter searches and filters attempts', () {
    final entries = _history().entries;

    final runtime = const POSSwitchActionHistoryFilter(
      query: 'runtime',
    ).apply(entries);
    final blocked = const POSSwitchActionHistoryFilter(
      status: POSSwitchActionHistoryFilterStatus.blocked,
    ).apply(entries);
    final channels = const POSSwitchActionHistoryFilter(
      status: POSSwitchActionHistoryFilterStatus.commerceChannels,
    ).apply(entries);

    expect(runtime.single.result.targetId, 'no_payment_pack');
    expect(blocked.single.result.targetId, 'no_payment_pack');
    expect(channels.single.result.targetId, 'web_store');
  });

  test('switch action history filter counts visible query results', () {
    final entries = _history().entries.where(
      const POSSwitchActionHistoryFilter(query: 'pack').matches,
    );
    final counts = POSSwitchActionHistoryFilterCounts.fromEntries(entries);

    expect(counts.all, 1);
    expect(counts.blocked, 1);
    expect(counts.runtimePacks, 1);
    expect(counts.countFor(POSSwitchActionHistoryFilterStatus.runtimePacks), 1);
    expect(POSSwitchActionHistoryFilterStatus.runtimePacks.label, 'Packs');
  });
}

POSSwitchActionHistory _history() {
  var history = POSSwitchActionHistory.empty();
  history = history.record(
    const POSSwitchActionResult.applied(
      kind: POSSwitchActionKind.mode,
      targetId: 'quick_checkout',
      targetLabel: 'Quick Checkout',
    ),
    occurredAt: DateTime(2026, 6, 1, 9),
    sequence: 1,
  );
  history = history.record(
    const POSSwitchActionResult.blocked(
      kind: POSSwitchActionKind.runtimePack,
      targetId: 'no_payment_pack',
      targetLabel: 'No Payment Pack',
      reason: 'Finish current order first',
    ),
    occurredAt: DateTime(2026, 6, 1, 10),
    sequence: 2,
  );
  history = history.record(
    const POSSwitchActionResult.cancelled(
      kind: POSSwitchActionKind.commerceChannel,
      targetId: 'web_store',
      targetLabel: 'Web store',
      reason: 'Keep current order?',
    ),
    occurredAt: DateTime(2026, 6, 1, 11),
    sequence: 3,
  );
  return history;
}
