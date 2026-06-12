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
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_metric_provider_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_panel_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_panel_sources.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_queue.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook.dart';

void main() {
  test('standard channel launch panel registry keeps launch order', () {
    final registry = standardBillingProductReleaseChannelLaunchPanelRegistry();

    expect(registry.descriptorIds, [
      billingProductReleaseChannelLaunchPlanPanelId,
      billingProductReleaseChannelLaunchRunbookPanelId,
      billingProductReleaseChannelLaunchQueuePanelId,
    ]);
  });

  test(
    'standard channel launch panel registry resolves source-specific panels',
    () {
      final registry =
          standardBillingProductReleaseChannelLaunchPanelRegistry();

      expect(
        registry
            .descriptorsForSource(_standardLaunchPlanSource())
            .map((descriptor) => descriptor.id),
        [billingProductReleaseChannelLaunchPlanPanelId],
      );
      expect(
        registry
            .descriptorsForSource(_standardRunbook())
            .map((descriptor) => descriptor.id),
        [billingProductReleaseChannelLaunchRunbookPanelId],
      );
      expect(
        registry
            .descriptorsForSource(
              BillingProductReleaseChannelLaunchQueuePanelSource(
                queue: _standardQueue(),
              ),
            )
            .map((descriptor) => descriptor.id),
        [billingProductReleaseChannelLaunchQueuePanelId],
      );
    },
  );

  test('standard channel launch metric registry resolves source wrappers', () {
    final registry =
        standardBillingProductReleaseChannelLaunchMetricProviderRegistry();

    expect(registry.providerIds, [
      billingProductReleaseChannelLaunchPlanMetricProviderId,
      billingProductReleaseChannelLaunchRunbookMetricProviderId,
      billingProductReleaseChannelLaunchQueueMetricProviderId,
    ]);
    expect(
      registry
          .resolve(
            billingProductReleaseChannelLaunchPlanMetricProviderId,
            _standardLaunchPlanSource(),
          )
          .metricForLabel('Routes')
          ?.value,
      '14',
    );
    expect(
      registry
          .resolve(
            billingProductReleaseChannelLaunchQueueMetricProviderId,
            BillingProductReleaseChannelLaunchQueuePanelSource(
              queue: _standardQueue(),
            ),
          )
          .metricForLabel('Ready now')
          ?.value,
      '14',
    );
  });

  testWidgets('channel launch panel registry builds launch plan actions', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;
    final source = _standardLaunchPlanSource(
      onDestinationSelected: (destination) {
        selectedDestination = destination;
      },
    );

    await _pumpPanel(
      tester,
      standardBillingProductReleaseChannelLaunchPanelRegistry().build(
        billingProductReleaseChannelLaunchPlanPanelId,
        source,
      ),
    );

    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(
      find.text('2 channel launches can publish; 12 need review.'),
      findsOneWidget,
    );
    expect(find.text('Open checkout'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Open checkout'));
    await tester.pumpAndSettle();

    expect(selectedDestination, BillingNavigationDestinationId.cartCheckout);
  });

  testWidgets('channel launch panel registry builds empty queue panel', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      standardBillingProductReleaseChannelLaunchPanelRegistry().build(
        billingProductReleaseChannelLaunchQueuePanelId,
        BillingProductReleaseChannelLaunchQueuePanelSource(
          queue: BillingProductReleaseChannelLaunchQueue(),
        ),
      ),
    );

    expect(find.text('Channel launch queue'), findsOneWidget);
    expect(
      find.text('No channel launch tasks are queued yet.'),
      findsOneWidget,
    );
  });
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

BillingProductReleaseChannelLaunchPlanPanelSource _standardLaunchPlanSource({
  ValueChanged<BillingNavigationDestinationId>? onDestinationSelected,
}) {
  final launchPlan = _standardLaunchPlan();
  return BillingProductReleaseChannelLaunchPlanPanelSource(
    launchPlan: launchPlan,
    dispatchPlan: BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
      launchPlan: launchPlan,
      dispatchSnapshot: _commerceDispatchSnapshot(),
    ),
    onDestinationSelected: onDestinationSelected,
  );
}

BillingProductReleaseChannelLaunchQueue _standardQueue() {
  return BillingProductReleaseChannelLaunchQueue.fromRunbook(
    _standardRunbook(),
  );
}

BillingProductReleaseChannelLaunchRunbook _standardRunbook() {
  return BillingProductReleaseChannelLaunchRunbook.fromDispatchPlan(
    BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
      launchPlan: _standardLaunchPlan(),
      dispatchSnapshot: _commerceDispatchSnapshot(),
    ),
  );
}

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan() {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(
    BillingProductReleaseChannelMatrix.forEditionCatalog(
      registry: standardBillingProductReleaseChannelRegistry(),
      editionCatalog: _standardEditionCatalog(),
    ),
  );
}

BillingProductReleaseEditionCatalog _standardEditionCatalog() {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
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

BillingNavigationDispatchSnapshot _commerceDispatchSnapshot() {
  return BillingNavigationLaunchPlanner(
    hasTenant: true,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
  );
}
