import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_diagnostics_activity_panel.dart';

void main() {
  testWidgets('diagnostics activity list searches and filters entries', (
    tester,
  ) async {
    final snapshot = POSDiagnosticsActivitySnapshot(
      entries: [
        POSDiagnosticsActivityEntry(
          id: 'switch_1',
          source: POSDiagnosticsActivitySource.channelSwitch,
          occurredAt: DateTime(2026, 6, 1, 9),
          title: 'Switched to Delivery app',
          detail: 'Checkout layout, Delivery fulfillment.',
          searchTerms: const ['delivery', 'channel'],
        ),
        POSDiagnosticsActivityEntry(
          id: 'sync_1',
          source: POSDiagnosticsActivitySource.orderSync,
          occurredAt: DateTime(2026, 6, 1, 10),
          title: 'Order #123456 failed',
          detail: 'Network down',
          requiresAttention: true,
          searchTerms: const ['network', 'outbox'],
        ),
        POSDiagnosticsActivityEntry(
          id: 'switch_action_1',
          source: POSDiagnosticsActivitySource.switchAction,
          occurredAt: DateTime(2026, 6, 1, 11),
          title: 'Blocked Runtime pack: No Payment Pack',
          detail: 'Runtime pack switch blocked: Finish current order first.',
          requiresAttention: true,
          supportSummary:
              'Blocked Runtime pack: No Payment Pack - Finish current order first.',
          searchTerms: const ['runtime', 'blocked'],
        ),
        POSDiagnosticsActivityEntry(
          id: 'switch_action_2',
          source: POSDiagnosticsActivitySource.switchAction,
          occurredAt: DateTime(2026, 6, 1, 12),
          title: 'Cancelled Commerce channel: Web store',
          detail: 'Commerce channel switch cancelled: Keep current order?',
          severity: POSDiagnosticsActivitySeverity.review,
          searchTerms: const ['web', 'review'],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: POSDiagnosticsActivityList(snapshot: snapshot),
          ),
        ),
      ),
    );

    expect(find.text('Search activity'), findsOneWidget);
    expect(find.text('Activity needs attention'), findsOneWidget);
    expect(
      find.text(
        'Blocked Runtime pack: No Payment Pack - Finish current order first.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Next: Resolve attention events before rollout.'),
      findsOneWidget,
    );
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Attention'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Channel'), findsWidgets);
    expect(find.text('Switches'), findsWidgets);
    expect(find.text('Order sync'), findsWidgets);
    expect(find.text('Cancelled Commerce channel: Web store'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);
    expect(find.text('Order #123456 failed'), findsOneWidget);
    expect(find.text('Switched to Delivery app'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'network');
    await tester.pump();

    expect(find.text('Order #123456 failed'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsNothing);
    expect(find.text('Cancelled Commerce channel: Web store'), findsNothing);
    expect(find.text('Switched to Delivery app'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Attention'));
    await tester.pump();

    expect(find.text('Order #123456 failed'), findsOneWidget);
    expect(find.text('Cancelled Commerce channel: Web store'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Review'));
    await tester.pump();

    expect(find.text('Cancelled Commerce channel: Web store'), findsOneWidget);
    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(-260, 0),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Switches'));
    await tester.pump();

    expect(find.text('Blocked Runtime pack: No Payment Pack'), findsOneWidget);
    expect(find.text('Order #123456 failed'), findsNothing);
  });

  testWidgets('diagnostics activity list shows empty and no-match states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSDiagnosticsActivityList(
            snapshot: POSDiagnosticsActivitySnapshot(),
          ),
        ),
      ),
    );

    expect(find.text('No POS activity yet'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            child: POSDiagnosticsActivityList(
              snapshot: POSDiagnosticsActivitySnapshot(
                entries: [
                  POSDiagnosticsActivityEntry(
                    id: 'switch_1',
                    source: POSDiagnosticsActivitySource.channelSwitch,
                    occurredAt: DateTime(2026, 6, 1, 9),
                    title: 'Switched to Delivery app',
                    detail: 'Checkout layout, Delivery fulfillment.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'network');
    await tester.pump();

    expect(find.text('No matching activity'), findsOneWidget);
  });
}
