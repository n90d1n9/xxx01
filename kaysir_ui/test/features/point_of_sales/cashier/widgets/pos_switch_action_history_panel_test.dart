import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_action_history_panel.dart';

void main() {
  testWidgets('switch action history list renders recent attempts', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: POSSwitchActionHistoryList(history: history),
          ),
        ),
      ),
    );

    expect(find.text('Recent switch attempts'), findsOneWidget);
    expect(find.text('2 recorded, 1 blocked'), findsOneWidget);
    expect(find.text('Blocked switch needs review'), findsOneWidget);
    expect(
      find.text(
        'Blocked Runtime pack: No Payment Pack - Finish current order first.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Next: Finish or hold the current order before retrying this runtime pack.',
      ),
      findsOneWidget,
    );
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);
    expect(
      find.text('Runtime pack switch blocked: Finish current order first.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Finish or hold the current order before retrying this runtime pack.',
      ),
      findsOneWidget,
    );
    expect(find.text('Runtime pack'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Blocked'), findsOneWidget);
    expect(find.text('Attention'), findsWidgets);
    expect(find.text('Applied POS mode: Quick Checkout'), findsOneWidget);
  });

  testWidgets('switch action history list searches and filters attempts', (
    tester,
  ) async {
    final history = _mixedHistory();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: POSSwitchActionHistoryList(history: history),
          ),
        ),
      ),
    );

    expect(find.text('Search switch attempts'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Packs'), findsWidgets);
    expect(find.text('Cancelled Commerce channel: Web store'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Applied POS mode: Quick Checkout'),
      120,
      scrollable: _historyScrollable(),
    );
    await tester.pump();
    expect(find.text('Applied POS mode: Quick Checkout'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'runtime');
    await tester.pump();

    expect(find.text('1 visible of 3 recorded'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);
    expect(find.text('Cancelled Commerce channel: Web store'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pump();

    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(-700, 0),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Channels'));
    await tester.pump();

    expect(find.text('Cancelled Commerce channel: Web store'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsNothing);
  });

  testWidgets('switch action history list shows no-match state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: POSSwitchActionHistoryList(history: _mixedHistory()),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.text('No matching switch attempts'), findsOneWidget);
  });

  testWidgets('switch action history list limits older attempts', (
    tester,
  ) async {
    var history = POSSwitchActionHistory.empty();
    for (var index = 0; index < 3; index++) {
      history = history.record(
        POSSwitchActionResult.cancelled(
          kind: POSSwitchActionKind.commerceChannel,
          targetId: 'channel_$index',
          targetLabel: 'Channel $index',
          reason: 'Cancelled',
        ),
        occurredAt: DateTime(2026, 6, 1, 9 + index),
        sequence: index + 1,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: POSSwitchActionHistoryList(history: history, maxEntries: 2),
          ),
        ),
      ),
    );

    expect(find.text('Cancelled Commerce channel: Channel 2'), findsOneWidget);
    expect(find.text('Cancelled Commerce channel: Channel 1'), findsOneWidget);
    expect(find.text('Cancelled Commerce channel: Channel 0'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('+1 older attempt'),
      120,
      scrollable: _historyScrollable(),
    );
    await tester.pump();
    expect(find.text('+1 older attempt'), findsOneWidget);
  });

  testWidgets('switch action history panel clears provider state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(posSwitchActionHistoryProvider.notifier)
        .record(
          const POSSwitchActionResult.cancelled(
            kind: POSSwitchActionKind.commerceChannel,
            targetId: 'web_store',
            targetLabel: 'Web store',
            reason: 'Keep current order?',
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: POSSwitchActionHistoryPanel()),
        ),
      ),
    );

    expect(find.text('Recent switch attempts'), findsOneWidget);
    expect(find.text('Cancelled Commerce channel: Web store'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear switch attempts'));
    await tester.pump();

    expect(container.read(posSwitchActionHistoryProvider).isEmpty, isTrue);
    expect(find.text('No switch attempts yet'), findsOneWidget);
  });
}

POSSwitchActionHistory _mixedHistory() {
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

Finder _historyScrollable() {
  return find
      .descendant(
        of: find.byKey(posSwitchActionHistoryScrollKey),
        matching: find.byType(Scrollable),
      )
      .first;
}
