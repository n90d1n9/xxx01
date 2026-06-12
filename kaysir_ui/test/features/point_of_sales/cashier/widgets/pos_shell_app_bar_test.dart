import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_shell_app_bar.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';

void main() {
  testWidgets('shell app bar renders POS identity and top-level actions', (
    tester,
  ) async {
    final channel = defaultPOSCommerceChannelRegistry.defaultChannel;
    var queueOpened = false;
    var dashboardOpened = false;
    var customerOpened = false;
    POSLayoutPreference? selectedLayout;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: POSShellAppBar(
              experience: defaultPOSExperience,
              commerceChannel: channel,
              actionPolicy: POSExperienceActionPolicy(
                experience: defaultPOSExperience,
                commerceChannel: channel,
              ),
              viewportWidth: 1280,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.counter,
              layoutPack: defaultPOSLayoutStrategyPack,
              outboxSummary: const POSOrderSaveOutboxSummary(
                health: POSOrderSaveOutboxHealth.failed,
                pendingCount: 0,
                sendingCount: 0,
                failedCount: 1,
                sentCount: 0,
                totalCount: 1,
              ),
              onOpenOrderSyncQueue: () => queueOpened = true,
              onDashboard: () => dashboardOpened = true,
              onCustomerSelection: () => customerOpened = true,
              onLayoutChanged: (layout) => selectedLayout = layout,
              showTerminalSelector: false,
              showCommerceChannelMenu: false,
              showExperienceMenu: false,
              showDiagnostics: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kaysir POS'), findsOneWidget);
    expect(find.text('Standard Cashier | In-store'), findsOneWidget);
    expect(
      find.byTooltip('Order sync queue: 1 order failed. Tap to review.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.sync_problem_outlined));
    await tester.tap(find.byTooltip('Dashboard'));
    await tester.tap(find.byTooltip('Customer'));
    await tester.tap(find.byTooltip('Auto layout'));

    expect(queueOpened, isTrue);
    expect(dashboardOpened, isTrue);
    expect(customerOpened, isTrue);
    expect(selectedLayout, POSLayoutPreference.auto);
  });

  testWidgets('shell app bar respects disabled experience actions', (
    tester,
  ) async {
    final channel = defaultPOSCommerceChannelRegistry.defaultChannel;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: POSShellAppBar(
              experience: quickCheckoutPOSExperience,
              commerceChannel: channel,
              actionPolicy: POSExperienceActionPolicy(
                experience: quickCheckoutPOSExperience,
                commerceChannel: channel,
              ),
              viewportWidth: 640,
              layoutPreference: POSLayoutPreference.checkout,
              resolvedStrategy: POSLayoutStrategy.checkout,
              layoutPack: defaultPOSLayoutStrategyPack,
              onOpenOrderSyncQueue: () {},
              onDashboard: () {},
              onCustomerSelection: () {},
              onLayoutChanged: (_) {},
              showTerminalSelector: false,
              showCommerceChannelMenu: false,
              showExperienceMenu: false,
              showDiagnostics: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Quick Checkout | In-store'), findsOneWidget);
    expect(find.byTooltip('Dashboard'), findsNothing);
    expect(find.byTooltip('More POS actions'), findsOneWidget);
    expect(find.byTooltip('Customer'), findsNothing);
    expect(find.byTooltip('Auto layout'), findsNothing);

    await tester.tap(find.byTooltip('More POS actions'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Customer'), findsNothing);
    expect(find.text('Auto layout'), findsNothing);
  });

  testWidgets('shell app bar moves secondary actions into compact overflow', (
    tester,
  ) async {
    final channel = defaultPOSCommerceChannelRegistry.defaultChannel;
    var dashboardOpened = false;
    var customerOpened = false;
    POSLayoutPreference? selectedLayout;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: POSShellAppBar(
              experience: defaultPOSExperience,
              commerceChannel: channel,
              actionPolicy: POSExperienceActionPolicy(
                experience: defaultPOSExperience,
                commerceChannel: channel,
              ),
              viewportWidth: 640,
              layoutPreference: POSLayoutPreference.auto,
              resolvedStrategy: POSLayoutStrategy.checkout,
              layoutPack: defaultPOSLayoutStrategyPack,
              onOpenOrderSyncQueue: () {},
              onDashboard: () => dashboardOpened = true,
              onCustomerSelection: () => customerOpened = true,
              onLayoutChanged: (layout) => selectedLayout = layout,
              showTerminalSelector: false,
              showCommerceChannelMenu: false,
              showExperienceMenu: false,
              showDiagnostics: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Customer'), findsNothing);
    expect(find.byTooltip('Auto layout'), findsNothing);
    expect(find.byTooltip('More POS actions'), findsOneWidget);

    await tester.tap(find.byTooltip('More POS actions'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Auto layout'), findsOneWidget);

    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    expect(customerOpened, isTrue);

    await tester.tap(find.byTooltip('More POS actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto layout'));
    await tester.pumpAndSettle();

    expect(selectedLayout, POSLayoutPreference.auto);

    await tester.tap(find.byTooltip('More POS actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(dashboardOpened, isTrue);
  });
}
