import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_action_context_binding.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_action_feedback.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_action_presentation.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_preview_pill.dart';

void main() {
  test(
    'switch action feedback formats applied, blocked, and cancelled results',
    () {
      final applied = POSSwitchActionFeedback.fromResult(
        const POSSwitchActionResult.applied(
          kind: POSSwitchActionKind.mode,
          targetId: 'quick_checkout',
          targetLabel: 'Quick Checkout',
        ),
      );
      final blocked = POSSwitchActionFeedback.fromResult(
        const POSSwitchActionResult.blocked(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'no_payment_pack',
          targetLabel: 'No Payment Pack',
          reason: 'Finish current order first',
        ),
      );
      final cancelled = POSSwitchActionFeedback.fromResult(
        const POSSwitchActionResult.cancelled(
          kind: POSSwitchActionKind.commerceChannel,
          targetId: 'web_store',
          targetLabel: 'Web store',
          reason: 'Keep current order?',
        ),
      );

      expect(applied.message, 'POS mode switched to Quick Checkout');
      expect(applied.icon, Icons.check_circle_outline);
      expect(applied.showCloseIcon, isFalse);
      expect(
        blocked.message,
        'Runtime pack switch blocked: Finish current order first',
      );
      expect(blocked.icon, Icons.block_outlined);
      expect(blocked.showCloseIcon, isTrue);
      expect(
        cancelled.message,
        'Commerce channel switch cancelled: Keep current order?',
      );
      expect(cancelled.icon, Icons.cancel_outlined);
      expect(cancelled.showCloseIcon, isTrue);
    },
  );

  test('switch action presentation exposes reusable tone metadata', () {
    final presentation = POSSwitchActionPresentation.fromResult(
      const POSSwitchActionResult.cancelled(
        kind: POSSwitchActionKind.commerceChannel,
        targetId: 'web_store',
        targetLabel: 'Web store',
        reason: 'Keep current order?',
      ),
    );

    expect(presentation.kindIcon, Icons.storefront_outlined);
    expect(presentation.outcomeIcon, Icons.cancel_outlined);
    expect(presentation.outcomeTone, POSSwitchPreviewTone.warning);
    expect(
      presentation.feedbackMessage,
      'Commerce channel switch cancelled: Keep current order?',
    );
    expect(
      presentation.historyMessage,
      'Commerce channel switch cancelled: Keep current order?',
    );
    expect(presentation.showCloseIcon, isTrue);
  });

  test('switch action presentation trims blank reasons consistently', () {
    expect(
      POSSwitchActionPresentation.fromResult(
        const POSSwitchActionResult.blocked(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'no_payment_pack',
          targetLabel: 'No Payment Pack',
          reason: '   ',
        ),
      ).feedbackMessage,
      'Runtime pack switch blocked',
    );
    expect(
      POSSwitchActionPresentation.fromResult(
        const POSSwitchActionResult.blocked(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'no_payment_pack',
          targetLabel: 'No Payment Pack',
          reason: '   ',
        ),
      ).historyMessage,
      'Runtime pack switch blocked.',
    );
  });

  testWidgets('switch action feedback shows a snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed:
                    () => showPOSSwitchActionFeedback(
                      context,
                      const POSSwitchActionResult.applied(
                        kind: POSSwitchActionKind.runtimePack,
                        targetId: 'online_pack',
                        targetLabel: 'Online Pack',
                      ),
                    ),
                child: const Text('Show feedback'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show feedback'));
    await tester.pump();

    expect(find.text('Runtime pack switched to Online Pack'), findsOneWidget);
  });

  testWidgets('switch action context binding records and reports feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: _SwitchActionBindingProbe())),
      ),
    );

    await tester.tap(find.text('Emit result'));
    await tester.pump();

    expect(find.text('POS mode switched to Quick Checkout'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SwitchActionBindingProbe)),
    );
    final history = container.read(posSwitchActionHistoryProvider);

    expect(history.latest?.result.targetId, 'quick_checkout');
    expect(history.latest?.result.applied, isTrue);
  });

  testWidgets('switch action context binding can suppress feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: _SwitchActionBindingProbe(showFeedback: false)),
        ),
      ),
    );

    await tester.tap(find.text('Emit result'));
    await tester.pump();

    expect(find.text('POS mode switched to Quick Checkout'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SwitchActionBindingProbe)),
    );
    expect(container.read(posSwitchActionHistoryProvider).isNotEmpty, isTrue);
  });
}

class _SwitchActionBindingProbe extends ConsumerWidget {
  final bool showFeedback;

  const _SwitchActionBindingProbe({this.showFeedback = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () {
        final actionContext = buildPOSSwitchActionContext(
          context: context,
          ref: ref,
          showFeedback: showFeedback,
        );
        actionContext.complete(
          const POSSwitchActionResult.applied(
            kind: POSSwitchActionKind.mode,
            targetId: 'quick_checkout',
            targetLabel: 'Quick Checkout',
          ),
        );
      },
      child: const Text('Emit result'),
    );
  }
}
