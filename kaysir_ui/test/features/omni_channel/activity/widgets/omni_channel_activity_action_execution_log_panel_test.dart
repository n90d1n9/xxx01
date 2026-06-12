import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_key.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_log.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_action_execution_log_panel.dart';

void main() {
  testWidgets('omni-channel action execution log panel renders outcomes', (
    tester,
  ) async {
    var cleared = false;
    OmniChannelActivityActionExecutionRecord? selectedRecord;
    OmniChannelActivityActionExecutionRecord? openedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityActionExecutionLogPanel(
              log: _log(),
              selectedEntryId: 'marketplace-review',
              onRecordSelected: (record) => selectedRecord = record,
              onOpenRecord: (record) => openedRecord = record,
              onClear: () => cleared = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recent action outcomes'), findsOneWidget);
    expect(
      find.text('Order workspace opened for ECOM-2026-017.'),
      findsOneWidget,
    );
    expect(
      find.text('Open orders - Marketplace pickup needs review'),
      findsOneWidget,
    );
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Current activity'), findsOneWidget);
    expect(find.text('Ecommerce'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('omni-channel-action-log-select-record-record-1'),
      ),
    );
    await tester.pump();

    expect(selectedRecord?.entryId, 'marketplace-review');

    await tester.tap(
      find.byKey(
        const ValueKey('omni-channel-action-log-open-record-record-1'),
      ),
    );
    await tester.pump();

    expect(openedRecord?.openLocation, '/commerce/orders');

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-clear')),
    );
    await tester.pump();

    expect(cleared, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel action execution log panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OmniChannelActivityActionExecutionLogPanel(
            log: OmniChannelActivityActionExecutionLog.empty(),
          ),
        ),
      ),
    );

    expect(find.text('No handled actions yet'), findsOneWidget);
    expect(find.text('Recent action outcomes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel action execution log panel filters outcomes', (
    tester,
  ) async {
    OmniChannelActivityActionExecutionLogFilter? selectedFilter;
    OmniChannelActivityActionExecutionRecord? retriedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityActionExecutionLogPanel(
              log: _mixedLog(),
              filter: OmniChannelActivityActionExecutionLogFilter.failed,
              onFilterChanged: (filter) => selectedFilter = filter,
              onRetryRecord: (record) => retriedRecord = record,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Failed to open sync queue.'), findsOneWidget);
    expect(
      find.text('Order workspace opened for ECOM-2026-017.'),
      findsNothing,
    );
    expect(find.text('Failed'), findsWidgets);

    await tester.tap(
      find.byKey(
        const ValueKey('omni-channel-action-log-retry-record-record-failed'),
      ),
    );
    await tester.pump();

    expect(retriedRecord?.entryId, 'sync-failed');

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-filter-completed')),
    );
    await tester.pump();

    expect(
      selectedFilter,
      OmniChannelActivityActionExecutionLogFilter.completed,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel action execution log panel disables busy retry', (
    tester,
  ) async {
    final log = _mixedLog();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityActionExecutionLogPanel(
              log: log,
              filter: OmniChannelActivityActionExecutionLogFilter.failed,
              busyActionKeys: {
                OmniChannelActivityActionExecutionKey.fromRecord(
                  log.entries.first,
                ).value,
              },
              onRetryRecord: (_) {},
            ),
          ),
        ),
      ),
    );

    final retryButton = tester.widget<IconButton>(
      find.byKey(
        const ValueKey('omni-channel-action-log-retry-record-record-failed'),
      ),
    );

    expect(retryButton.onPressed, isNull);
    expect(find.byTooltip('Retrying action'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel action execution log panel runs header actions', (
    tester,
  ) async {
    var retriedAttention = false;
    var clearedCompleted = false;
    var clearedAll = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityActionExecutionLogPanel(
              log: _mixedLog(),
              onRetryAttention: () => retriedAttention = true,
              onClearCompleted: () => clearedCompleted = true,
              onClear: () => clearedAll = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-retry-attention')),
    );
    await tester.pump();

    expect(retriedAttention, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-clear-completed')),
    );
    await tester.pump();

    expect(clearedCompleted, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-clear')),
    );
    await tester.pump();

    expect(clearedAll, isTrue);
    expect(tester.takeException(), isNull);
  });
}

OmniChannelActivityActionExecutionLog _log() {
  return OmniChannelActivityActionExecutionLog(
    entries: [
      OmniChannelActivityActionExecutionRecord(
        id: 'record-1',
        result: const OmniChannelActivityActionExecutionResult.completed(
          action: OmniChannelActivityAction(
            id: 'orders',
            label: 'Open orders',
            location: '/commerce/orders',
            tooltip: 'Open orders',
          ),
          message: 'Order workspace opened for ECOM-2026-017.',
          location: '/commerce/orders',
        ),
        entryId: 'marketplace-review',
        entryTitle: 'Marketplace pickup needs review',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11, 8),
        sequence: 1,
      ),
    ],
  );
}

OmniChannelActivityActionExecutionLog _mixedLog() {
  return OmniChannelActivityActionExecutionLog(
    entries: [
      OmniChannelActivityActionExecutionRecord(
        id: 'record-failed',
        result: const OmniChannelActivityActionExecutionResult.failed(
          action: OmniChannelActivityAction(
            id: 'sync',
            label: 'Open sync queue',
            location: '/cashier',
            tooltip: 'Open sync queue',
          ),
          message: 'Failed to open sync queue.',
          location: '/cashier',
        ),
        entryId: 'sync-failed',
        entryTitle: 'Order sync failed',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 11, 10),
        sequence: 2,
      ),
      ..._log().entries,
    ],
  );
}
