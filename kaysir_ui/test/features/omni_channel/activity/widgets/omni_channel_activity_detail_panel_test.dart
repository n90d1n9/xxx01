import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_key.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_relation.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_detail_panel.dart';

void main() {
  testWidgets('omni-channel activity detail panel renders selected context', (
    tester,
  ) async {
    OmniChannelActivityAction? selectedAction;
    OmniChannelActivityEntry? selectedActionEntry;
    OmniChannelActivityEntry? selectedRelatedEntry;
    final entry = OmniChannelActivityEntry(
      id: 'order',
      kind: OmniChannelActivityKind.order,
      sourceId: 'ecommerce',
      sourceLabel: 'Ecommerce',
      occurredAt: DateTime(2026, 6, 9, 11),
      title: 'Marketplace pickup needs review',
      detail: 'Confirm pickup capacity.',
      severity: OmniChannelActivitySeverity.review,
      channelId: 'marketplace',
      channelLabel: 'Marketplace',
      orderId: 'ECOM-1',
      fulfillmentModeLabel: 'Pickup',
      supportSummary: 'Review pickup capacity with store ops.',
      attributes: {'slaWindow': '30 min'},
    );
    const action = OmniChannelActivityAction(
      label: 'Open orders',
      location: '/commerce/orders?order_search=ECOM-1',
      tooltip: 'Open the matching ecommerce order workspace',
      intent: OmniChannelActivityActionIntent.review,
    );
    const secondaryAction = OmniChannelActivityAction(
      id: 'commerce-workspace',
      label: 'Open commerce',
      location: '/commerce',
      tooltip: 'Open the commerce command workspace',
      intent: OmniChannelActivityActionIntent.inspect,
    );
    final relatedEntry = OmniChannelActivityEntry(
      id: 'sync',
      kind: OmniChannelActivityKind.orderSync,
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: DateTime(2026, 6, 9, 10, 45),
      title: 'Counter sync completed',
      detail: 'The POS handoff reached ecommerce.',
      channelId: 'marketplace',
      channelLabel: 'Marketplace',
      orderId: 'ECOM-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityDetailPanel(
              entry: entry,
              action: action,
              secondaryActions: const [secondaryAction],
              relatedActivity: [
                OmniChannelRelatedActivityEntry(
                  entry: relatedEntry,
                  relation: OmniChannelActivityRelationKind.sameOrder,
                ),
              ],
              onActionSelected: (entry, action) {
                selectedActionEntry = entry;
                selectedAction = action;
              },
              onRelatedEntrySelected: (value) => selectedRelatedEntry = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Review pickup capacity with store ops.'), findsOneWidget);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('ECOM-1'), findsWidgets);
    expect(find.text('Sla Window'), findsOneWidget);
    expect(find.text('Counter sync completed'), findsOneWidget);
    expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    expect(find.byIcon(Icons.manage_search_outlined), findsOneWidget);

    await tester.tap(find.text('Open orders'));
    await tester.pump();

    expect(selectedActionEntry, entry);
    expect(selectedAction, action);

    await tester.tap(find.text('Open commerce'));
    await tester.pump();

    expect(selectedAction, secondaryAction);

    await tester.ensureVisible(find.text('Counter sync completed'));
    await tester.pump();
    await tester.tap(find.text('Counter sync completed'));
    await tester.pump();

    expect(selectedRelatedEntry, relatedEntry);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity detail panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OmniChannelActivityDetailPanel(entry: null)),
      ),
    );

    expect(find.text('Select an activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'omni-channel activity detail panel disables unavailable action',
    (tester) async {
      var selected = false;
      const action = OmniChannelActivityAction(
        label: 'Open sync queue',
        location: '/cashier',
        tooltip: 'Retry failed POS sync',
        intent: OmniChannelActivityActionIntent.retry,
        enabled: false,
        disabledReason: 'Sync is already running.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OmniChannelActivityDetailPanel(
                entry: OmniChannelActivityEntry(
                  id: 'sync',
                  kind: OmniChannelActivityKind.orderSync,
                  sourceId: 'point_of_sales',
                  sourceLabel: 'Point of sale',
                  occurredAt: DateTime(2026, 6, 9, 11),
                  title: 'Order sync failed',
                  detail: 'Retry the queued order.',
                  severity: OmniChannelActivitySeverity.attention,
                ),
                action: action,
                onActionSelected: (_, _) => selected = true,
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Open sync queue'),
      );

      expect(button.onPressed, isNull);
      expect(find.text('Unavailable actions'), findsOneWidget);
      expect(find.text('Sync is already running.'), findsOneWidget);
      expect(selected, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('omni-channel activity detail panel disables busy action', (
    tester,
  ) async {
    var selected = false;
    final entry = OmniChannelActivityEntry(
      id: 'sync',
      kind: OmniChannelActivityKind.orderSync,
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: DateTime(2026, 6, 9, 11),
      title: 'Order sync failed',
      detail: 'Retry the queued order.',
      severity: OmniChannelActivitySeverity.attention,
    );
    const action = OmniChannelActivityAction(
      id: 'retry-sync',
      label: 'Open sync queue',
      location: '/cashier',
      tooltip: 'Retry failed POS sync',
      intent: OmniChannelActivityActionIntent.retry,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityDetailPanel(
              entry: entry,
              action: action,
              busyActionKeys: {
                OmniChannelActivityActionExecutionKey.fromAction(
                  entry: entry,
                  action: action,
                ).value,
              },
              onActionSelected: (_, _) => selected = true,
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Working...'),
    );

    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
