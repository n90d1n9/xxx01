import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_workspace.dart';

void main() {
  testWidgets('omni-channel activity workspace wires selection and actions', (
    tester,
  ) async {
    OmniChannelActivityEntry? selectedEntry;
    OmniChannelActivityEntry? selectedActionEntry;
    OmniChannelActivityAction? selectedAction;
    final feed = OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'sync-failed',
          kind: OmniChannelActivityKind.orderSync,
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sale',
          occurredAt: DateTime(2026, 6, 9, 11, 30),
          title: 'Order sync failed',
          detail: 'Retry the queued counter order.',
          severity: OmniChannelActivitySeverity.attention,
          channelId: 'marketplace',
          channelLabel: 'Marketplace',
          orderId: 'ECOM-1',
          supportSummary: 'Retry the failed sync before closing shift.',
        ),
        OmniChannelActivityEntry(
          id: 'marketplace-review',
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
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityWorkspace(
              feed: feed,
              entries: feed.entries,
              selectedEntry: feed.entries.first,
              hasActiveFilters: false,
              onEntrySelected: (entry) => selectedEntry = entry,
              onActionSelected: (entry, action) {
                selectedActionEntry = entry;
                selectedAction = action;
              },
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Retry the failed sync before closing shift.'),
      findsWidgets,
    );
    expect(find.text('Related activity'), findsOneWidget);
    expect(find.text('Marketplace pickup needs review'), findsWidgets);

    final marketplaceTimelineRow = find.descendant(
      of: find.byKey(const ValueKey('omni-channel-activity-timeline')),
      matching: find.text('Marketplace pickup needs review'),
    );

    await tester.ensureVisible(marketplaceTimelineRow);
    await tester.pump();

    await tester.tap(marketplaceTimelineRow);
    await tester.pump();

    expect(selectedEntry?.id, 'marketplace-review');

    final detailAction = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/cashier'),
    );
    await tester.ensureVisible(detailAction);
    await tester.pump();

    await tester.tap(detailAction);
    await tester.pump();

    expect(selectedActionEntry?.id, 'sync-failed');
    expect(selectedAction?.location, '/cashier');
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity workspace accepts injected registry', (
    tester,
  ) async {
    OmniChannelActivityEntry? selectedActionEntry;
    OmniChannelActivityAction? selectedAction;
    final feed = OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'custom-review',
          kind: OmniChannelActivityKind.system,
          sourceId: 'custom_module',
          sourceLabel: 'Custom module',
          occurredAt: DateTime(2026, 6, 9, 12),
          title: 'Module review needed',
          detail: 'A module-specific activity needs resolution.',
          severity: OmniChannelActivitySeverity.review,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityWorkspace(
              feed: feed,
              entries: feed.entries,
              selectedEntry: feed.entries.first,
              hasActiveFilters: false,
              actionRegistry: const OmniChannelActivityActionRegistry(
                contributors: [_workspaceTestActionContributor],
              ),
              onEntrySelected: (_) {},
              onActionSelected: (entry, action) {
                selectedActionEntry = entry;
                selectedAction = action;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Handle locally'), findsWidgets);

    final detailAction = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/custom-resolution'),
    );
    await tester.ensureVisible(detailAction);
    await tester.pump();
    await tester.tap(detailAction);
    await tester.pump();

    expect(selectedActionEntry?.id, 'custom-review');
    expect(selectedAction?.label, 'Handle locally');
    expect(selectedAction?.location, '/custom-resolution');
    expect(tester.takeException(), isNull);
  });
}

Iterable<OmniChannelActivityAction> _workspaceTestActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  yield const OmniChannelActivityAction(
    id: 'custom-resolution',
    label: 'Handle locally',
    location: '/custom-resolution',
    tooltip: 'Open the module-specific resolution surface',
    intent: OmniChannelActivityActionIntent.review,
  );
}
