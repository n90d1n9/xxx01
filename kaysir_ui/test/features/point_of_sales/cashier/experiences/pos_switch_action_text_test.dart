import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_text.dart';

void main() {
  test('switch action text formats applied results without guidance', () {
    final text = POSSwitchActionText.fromResult(
      const POSSwitchActionResult.applied(
        kind: POSSwitchActionKind.mode,
        targetId: 'quick_checkout',
        targetLabel: 'Quick Checkout',
      ),
    );

    expect(text.feedbackMessage, 'POS mode switched to Quick Checkout');
    expect(text.historyMessage, 'POS mode switch applied.');
    expect(text.supportSummary, 'Applied POS mode: Quick Checkout');
    expect(text.operatorGuidance, isNull);
  });

  test('switch action text formats blocked results with support guidance', () {
    final text = POSSwitchActionText.fromResult(
      const POSSwitchActionResult.blocked(
        kind: POSSwitchActionKind.runtimePack,
        targetId: 'no_payment_pack',
        targetLabel: 'No Payment Pack',
        reason: 'Finish current order first',
      ),
    );

    expect(
      text.feedbackMessage,
      'Runtime pack switch blocked: Finish current order first',
    );
    expect(
      text.historyMessage,
      'Runtime pack switch blocked: Finish current order first.',
    );
    expect(
      text.supportSummary,
      'Blocked Runtime pack: No Payment Pack - Finish current order first.',
    );
    expect(
      text.operatorGuidance,
      'Finish or hold the current order before retrying this runtime pack.',
    );
  });

  test('switch action text preserves existing punctuation', () {
    final text = POSSwitchActionText.fromResult(
      const POSSwitchActionResult.cancelled(
        kind: POSSwitchActionKind.commerceChannel,
        targetId: 'web_store',
        targetLabel: 'Web store',
        reason: 'Keep current order?',
      ),
    );

    expect(
      text.historyMessage,
      'Commerce channel switch cancelled: Keep current order?',
    );
    expect(
      text.supportSummary,
      'Cancelled Commerce channel: Web store - Keep current order?',
    );
    expect(
      text.operatorGuidance,
      'No change was applied. Operators can retry when ready.',
    );
  });
}
