import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_channel.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_edition.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_status.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_queue.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_queue_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook.dart';

void main() {
  test('channel launch queue groups ready runbook steps by lane', () {
    final queue = BillingProductReleaseChannelLaunchQueue.fromRunbook(
      _standardRunbook(),
    );

    expect(queue.itemCount, 14);
    expect(queue.readyNowCount, 14);
    expect(queue.needsRoutingCount, 0);
    expect(queue.blockedCount, 0);
    expect(queue.needsWorkCount, 0);
    expect(queue.nextReadyItem, isNotNull);
    expect(queue.summaryLabel, '14 launch tasks ready now.');

    final readyLane = queue.laneFor(
      BillingProductReleaseChannelLaunchQueueLane.readyNow,
    );
    final checkoutItems = readyLane.items.where(
      (item) =>
          item.destinationId == BillingNavigationDestinationId.cartCheckout,
    );

    expect(readyLane.label, 'Ready now');
    expect(readyLane.summaryLabel, '14 tasks ready.');
    expect(checkoutItems.single.callToActionLabel, 'Open checkout');
    expect(
      checkoutItems.single.status,
      BillingProductReleaseChannelLaunchDispatchStatus.route,
    );
    expect(checkoutItems.single.payload['status'], 'route');
  });

  test('channel launch queue keeps blocked release steps separate', () {
    final queue = BillingProductReleaseChannelLaunchQueue.fromRunbook(
      _standardRunbook(hasTenant: false),
    );

    expect(queue.itemCount, 14);
    expect(queue.readyNowCount, 0);
    expect(queue.needsRoutingCount, 0);
    expect(queue.blockedCount, 14);
    expect(queue.summaryLabel, '14 launch tasks need release or routing work.');
    expect(
      queue
          .laneFor(BillingProductReleaseChannelLaunchQueueLane.blocked)
          .summaryLabel,
      '14 tasks blocked.',
    );
  });

  test(
    'channel launch queue detects routing work independently of blockers',
    () {
      final queue = BillingProductReleaseChannelLaunchQueue.fromRunbook(
        BillingProductReleaseChannelLaunchRunbook(
          groups: [
            BillingProductReleaseChannelLaunchRunbookGroup(
              destinationId: BillingNavigationDestinationId.invoices,
              destinationLabel: 'Invoices',
              steps: [
                BillingProductReleaseChannelLaunchRunbookStep(
                  id: 'manual-routing',
                  title: 'Open invoice desk',
                  detail: 'Destination is not exposed by this billing domain.',
                  destinationLabel: 'Invoices',
                  callToActionLabel: 'Open invoices',
                  statusLabel: 'Unavailable',
                  status:
                      BillingProductReleaseChannelLaunchDispatchStatus
                          .notExposed,
                  destinationId: BillingNavigationDestinationId.invoices,
                  isActionable: false,
                  isBlocked: false,
                  checklistItems: const ['Expose invoice navigation.'],
                ),
              ],
            ),
          ],
        ),
      );

      expect(queue.readyNowCount, 0);
      expect(queue.needsRoutingCount, 1);
      expect(queue.blockedCount, 0);
      expect(
        queue.summaryLabel,
        '1 launch task needs release or routing work.',
      );
      expect(
        queue
            .laneFor(BillingProductReleaseChannelLaunchQueueLane.needsRouting)
            .summaryLabel,
        '1 task needs routing.',
      );
      expect(queue.items.single.status.needsRoutingWork, isTrue);
    },
  );

  testWidgets('BillingProductReleaseChannelLaunchQueuePanel renders actions', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await _pumpPanel(
      tester,
      BillingProductReleaseChannelLaunchQueuePanel(
        queue: _singleReadyQueue(),
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(find.text('1 launch task ready now.'), findsOneWidget);
    expect(find.text('Ready now'), findsWidgets);
    expect(find.text('Open checkout'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Open checkout'));
    await tester.pumpAndSettle();

    expect(selectedDestination, BillingNavigationDestinationId.cartCheckout);
  });

  testWidgets(
    'BillingProductReleaseChannelLaunchQueuePanel renders empty state',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingProductReleaseChannelLaunchQueuePanel(
          queue: BillingProductReleaseChannelLaunchQueue(),
        ),
      );

      expect(find.text('Channel launch queue'), findsOneWidget);
      expect(
        find.text('No channel launch tasks are queued yet.'),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 1100, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

BillingProductReleaseChannelLaunchQueue _singleReadyQueue() {
  return BillingProductReleaseChannelLaunchQueue.fromRunbook(
    BillingProductReleaseChannelLaunchRunbook(
      groups: [
        BillingProductReleaseChannelLaunchRunbookGroup(
          destinationId: BillingNavigationDestinationId.cartCheckout,
          destinationLabel: 'Cart & checkout',
          steps: [
            BillingProductReleaseChannelLaunchRunbookStep(
              id: 'checkout-ready',
              title: 'Launch POS counter',
              detail: 'Ready to open checkout.',
              destinationLabel: 'Cart & checkout',
              callToActionLabel: 'Open checkout',
              statusLabel: 'Route',
              status: BillingProductReleaseChannelLaunchDispatchStatus.route,
              destinationId: BillingNavigationDestinationId.cartCheckout,
              isActionable: true,
              isBlocked: false,
              checklistItems: const [
                'Verify active catalog items and pricing.',
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

BillingProductReleaseChannelLaunchRunbook _standardRunbook({
  bool hasTenant = true,
}) {
  return BillingProductReleaseChannelLaunchRunbook.fromDispatchPlan(
    BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
      launchPlan: _standardLaunchPlan(hasTenant: hasTenant),
      dispatchSnapshot: _commerceDispatchSnapshot(hasTenant: hasTenant),
    ),
  );
}

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan({
  bool hasTenant = true,
}) {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(
    BillingProductReleaseChannelMatrix.forEditionCatalog(
      registry: standardBillingProductReleaseChannelRegistry(),
      editionCatalog: _standardEditionCatalog(hasTenant: hasTenant),
    ),
  );
}

BillingProductReleaseEditionCatalog _standardEditionCatalog({
  bool hasTenant = true,
}) {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
    hasTenant: hasTenant,
  );
  final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    blueprintRegistry,
  );
  final launchPortfolio =
      BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);
  final packagePortfolio = BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );
  final playbook = BillingProductPackageLaunchPlaybook.forPortfolio(
    packagePortfolio,
  );
  final manifestCatalog =
      BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: packagePortfolio,
        playbook: playbook,
      );

  return BillingProductReleaseEditionCatalog.forManifestCatalog(
    registry: standardBillingProductReleaseEditionRegistry(),
    manifestCatalog: manifestCatalog,
  );
}

BillingNavigationDispatchSnapshot _commerceDispatchSnapshot({
  required bool hasTenant,
}) {
  return BillingNavigationLaunchPlanner(
    hasTenant: hasTenant,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
  );
}
