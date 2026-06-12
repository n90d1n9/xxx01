import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_tile.dart';

void main() {
  testWidgets('omni-channel activity tile invokes action callback', (
    tester,
  ) async {
    OmniChannelActivityEntry? selectedEntry;
    OmniChannelActivityAction? selectedAction;
    final entry = OmniChannelActivityEntry(
      id: 'sync',
      kind: OmniChannelActivityKind.orderSync,
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: DateTime(2026, 6, 9, 11),
      title: 'Order sync failed',
      detail: 'Retry the queued order.',
      severity: OmniChannelActivitySeverity.attention,
      orderId: 'POS-1',
    );
    const action = OmniChannelActivityAction(
      label: 'Open sync queue',
      location: '/cashier',
      tooltip: 'Retry failed POS sync',
      intent: OmniChannelActivityActionIntent.retry,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OmniChannelActivityTile(
              entry: entry,
              action: action,
              onActionSelected: (entry, action) {
                selectedEntry = entry;
                selectedAction = action;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Open sync queue'), findsOneWidget);
    expect(find.byIcon(Icons.replay_circle_filled_outlined), findsOneWidget);

    await tester.tap(find.text('Open sync queue'));
    await tester.pump();

    expect(selectedEntry, entry);
    expect(selectedAction, action);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity tile invokes selection callback', (
    tester,
  ) async {
    OmniChannelActivityEntry? selectedEntry;
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OmniChannelActivityTile(
              entry: entry,
              selected: true,
              onSelected: (value) => selectedEntry = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Order sync failed'));
    await tester.pump();

    expect(selectedEntry, entry);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity tile disables unavailable action', (
    tester,
  ) async {
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
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OmniChannelActivityTile(
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

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Open sync queue'),
    );

    expect(button.onPressed, isNull);
    expect(selected, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity tile disables busy action', (
    tester,
  ) async {
    var selected = false;
    const action = OmniChannelActivityAction(
      label: 'Open sync queue',
      location: '/cashier',
      tooltip: 'Retry failed POS sync',
      intent: OmniChannelActivityActionIntent.retry,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OmniChannelActivityTile(
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
              actionBusy: true,
              onActionSelected: (_, _) => selected = true,
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Working...'),
    );

    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(selected, isFalse);
    expect(tester.takeException(), isNull);
  });
}
