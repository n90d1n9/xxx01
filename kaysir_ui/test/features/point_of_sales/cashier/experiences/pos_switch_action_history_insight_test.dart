import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history_insight.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';

void main() {
  test('switch action insight flags blocked attempts as attention', () {
    final insight = POSSwitchActionHistoryInsight.fromHistory(
      POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.blocked(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'no_payment_pack',
          targetLabel: 'No Payment Pack',
          reason: 'Finish current order first',
        ),
        occurredAt: DateTime(2026, 6, 1, 9),
        sequence: 1,
      ),
    );

    expect(insight.level, POSSwitchActionHistoryInsightLevel.attention);
    expect(insight.summaryLabel, '1 recorded, 1 blocked');
    expect(insight.headline, 'Blocked switch needs review');
    expect(
      insight.detail,
      'Blocked Runtime pack: No Payment Pack - Finish current order first.',
    );
    expect(
      insight.nextStep,
      'Finish or hold the current order before retrying this runtime pack.',
    );
    expect(insight.referenceEntry?.result.targetId, 'no_payment_pack');
  });

  test('switch action insight treats cancelled attempts as review', () {
    final insight = POSSwitchActionHistoryInsight.fromHistory(
      POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.cancelled(
          kind: POSSwitchActionKind.commerceChannel,
          targetId: 'web_store',
          targetLabel: 'Web store',
          reason: 'Keep current order?',
        ),
        occurredAt: DateTime(2026, 6, 1, 9),
        sequence: 1,
      ),
    );

    expect(insight.level, POSSwitchActionHistoryInsightLevel.review);
    expect(insight.summaryLabel, '1 recorded, 1 cancelled');
    expect(insight.headline, 'Cancelled switch recorded');
    expect(
      insight.detail,
      'Cancelled Commerce channel: Web store - Keep current order?',
    );
    expect(
      insight.nextStep,
      'No change was applied. Operators can retry when ready.',
    );
  });

  test('switch action insight reports healthy applied history', () {
    final insight = POSSwitchActionHistoryInsight.fromHistory(
      POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.applied(
          kind: POSSwitchActionKind.mode,
          targetId: 'quick_checkout',
          targetLabel: 'Quick Checkout',
        ),
        occurredAt: DateTime(2026, 6, 1, 9),
        sequence: 1,
      ),
    );

    expect(insight.level, POSSwitchActionHistoryInsightLevel.ready);
    expect(insight.summaryLabel, '1 recorded, 1 applied');
    expect(insight.headline, 'Switching is healthy');
    expect(
      insight.detail,
      'All recorded switch attempts completed successfully.',
    );
    expect(
      insight.nextStep,
      'Continue monitoring switch attempts during rollout.',
    );
  });
}
