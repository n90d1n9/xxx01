import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_command_bar.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_freshness.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_status_chip.dart';

void main() {
  testWidgets('layout switcher reports selected layout', (tester) async {
    POSLayoutPreference? selectedLayout;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: POSLayoutSwitcher(
              value: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
              compact: false,
              onChanged: (value) => selectedLayout = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(selectedLayout, POSLayoutPreference.checkout);
  });

  testWidgets('layout switcher describes the active strategy contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: POSLayoutSwitcher(
              value: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
              compact: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip(
        'Active layout: Counter - Product-first desk layout for full cashier workstations.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('command bar disables hold until an order has items', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 0,
            total: 0,
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    final holdButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Hold'),
    );

    expect(holdButton.onPressed, isNull);
    expect(
      find.byTooltip('Hold (F6) - Add items to the order before holding it.'),
      findsOneWidget,
    );
  });

  testWidgets('command bar exposes shortcut tooltips for command actions', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 1,
            total: 50000,
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            heldOrderCount: 1,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Scan (F4)'), findsOneWidget);
    expect(find.byTooltip('New (Ctrl+N)'), findsOneWidget);
    expect(find.byTooltip('Hold (F6)'), findsOneWidget);
    expect(find.byTooltip('Holds (F7)'), findsOneWidget);
    expect(find.byTooltip('Pay (F9)'), findsOneWidget);
  });

  testWidgets('command bar surfaces queued order sync work', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var syncTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 1,
            total: 50000,
            outboxSummary: const POSOrderSaveOutboxSummary(
              health: POSOrderSaveOutboxHealth.failed,
              pendingCount: 0,
              sendingCount: 0,
              failedCount: 1,
              sentCount: 0,
              totalCount: 1,
            ),
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            onSyncOutbox: () => syncTapped = true,
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(OrderSaveOutboxStatusChip), findsOneWidget);
    expect(
      find.byTooltip('Order sync queue: 1 order failed. Tap to sync.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.sync_problem_outlined));

    expect(syncTapped, isTrue);
  });

  testWidgets('command bar shows in-progress order sync state', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var syncTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 1,
            total: 50000,
            outboxSummary: const POSOrderSaveOutboxSummary(
              health: POSOrderSaveOutboxHealth.queued,
              pendingCount: 1,
              sendingCount: 0,
              failedCount: 0,
              sentCount: 0,
              totalCount: 1,
            ),
            outboxSyncState: POSOrderSaveOutboxSyncState.running(
              startedAt: DateTime(2026, 5, 31, 8),
            ),
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            onSyncOutbox: () => syncTapped = true,
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Syncing queued orders'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(CircularProgressIndicator));

    expect(syncTapped, isFalse);
  });

  testWidgets('command bar tooltip includes auto-sync state', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 1,
            total: 50000,
            outboxSummary: const POSOrderSaveOutboxSummary(
              health: POSOrderSaveOutboxHealth.queued,
              pendingCount: 1,
              sendingCount: 0,
              failedCount: 0,
              sentCount: 0,
              totalCount: 1,
            ),
            outboxAutoSyncState: POSOrderSaveOutboxAutoSyncState.skipped(
              reason: POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
              finishedAt: DateTime(2026, 5, 31, 9),
              workCount: 1,
            ),
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byTooltip(
        'Order sync queue: 1 order waiting to sync Auto-sync: Auto-sync is cooling down briefly before another background run.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('command bar tooltip includes stale queue freshness', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var syncTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.counter,
            itemCount: 1,
            total: 50000,
            outboxSummary: const POSOrderSaveOutboxSummary(
              health: POSOrderSaveOutboxHealth.queued,
              pendingCount: 1,
              sendingCount: 0,
              failedCount: 0,
              sentCount: 0,
              totalCount: 1,
            ),
            outboxFreshnessState: const POSOrderSaveOutboxFreshnessState(
              level: POSOrderSaveOutboxFreshnessLevel.stale,
              stalePendingCount: 1,
              staleFailedCount: 0,
              agingPendingCount: 0,
              agingFailedCount: 0,
              oldestPendingAge: Duration(minutes: 15),
              oldestFailedAge: null,
              syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
            ),
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            onSyncOutbox: () => syncTapped = true,
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.schedule_send_outlined), findsOneWidget);
    expect(
      find.byTooltip(
        'Order sync queue: 1 order waiting to sync. Tap to sync. Freshness: 1 queued save waited for 15 min. Run Sync now when ready.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.schedule_send_outlined));

    expect(syncTapped, isTrue);
  });

  testWidgets('command bar hides actions disabled by the POS experience', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            experience: const POSExperience(
              id: 'minimal',
              label: 'Minimal',
              description: 'Minimal checkout experience',
              preferredLayout: POSLayoutPreference.checkout,
              capabilities: POSExperienceCapabilities(
                barcodeScanning: false,
                heldOrders: false,
                promotions: false,
                newOrders: false,
                layoutSwitching: false,
              ),
              modules: [POSFeatureModules.payments],
            ),
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.checkout,
            itemCount: 1,
            total: 120000,
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            heldOrderCount: 2,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Scan'), findsNothing);
    expect(find.text('New'), findsNothing);
    expect(find.text('Hold'), findsNothing);
    expect(find.text('Holds'), findsNothing);
    expect(find.text('Promo'), findsNothing);
    expect(find.text('Pay'), findsOneWidget);
    expect(find.text('1 items | Rp 120.000'), findsOneWidget);
  });

  testWidgets('command bar hides actions unsupported by the active channel', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    final marketplace = defaultPOSCommerceChannelRegistry.channelForId(
      'marketplace',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommandBar(
            experience: defaultPOSExperience,
            actionPolicy: POSExperienceActionPolicy(
              experience: defaultPOSExperience,
              commerceChannel: marketplace,
            ),
            layoutPreference: POSLayoutPreference.auto,
            resolvedStrategy: POSLayoutStrategy.checkout,
            itemCount: 1,
            total: 120000,
            searchFocusNode: focusNode,
            onSearch: (_) {},
            onSearchSubmitted: (_) {},
            onScan: () {},
            onNewOrder: () {},
            onPromotions: () {},
            onPayment: () {},
            onHold: () {},
            onHeldOrders: () {},
            heldOrderCount: 0,
            onLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('New'), findsOneWidget);
    expect(find.text('Promo'), findsNothing);
    expect(find.text('Pay'), findsNothing);
  });
}
