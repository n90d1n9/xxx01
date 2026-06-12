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
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_runbook_panel.dart';

void main() {
  test('channel launch runbook groups dispatch entries by destination', () {
    final runbook = _standardRunbook();

    expect(runbook.destinationCount, 6);
    expect(runbook.stepCount, 14);
    expect(runbook.actionableStepCount, 14);
    expect(runbook.needsWorkStepCount, 0);
    expect(runbook.summaryLabel, '14 launch steps ready to execute.');

    final checkoutGroup = runbook.requireGroupForDestination(
      BillingNavigationDestinationId.cartCheckout,
    );

    expect(checkoutGroup.destinationLabel, 'Cart & checkout');
    expect(checkoutGroup.stepCount, 1);
    expect(checkoutGroup.summaryLabel, '1 step ready.');
    expect(checkoutGroup.steps.single.callToActionLabel, 'Open checkout');
    expect(
      checkoutGroup.steps.single.status,
      BillingProductReleaseChannelLaunchDispatchStatus.route,
    );
    expect(checkoutGroup.steps.single.payload['status'], 'route');
    expect(
      checkoutGroup.steps.single.checklistItems.first,
      'Verify active catalog items and pricing.',
    );

    final reportsGroup = runbook.requireGroupForDestination(
      BillingNavigationDestinationId.reports,
    );

    expect(reportsGroup.stepCount, 4);
    expect(reportsGroup.actionableStepCount, 4);
  });

  test('channel launch runbook keeps blocked routes as work items', () {
    final runbook = _standardRunbook(hasTenant: false);

    expect(runbook.destinationCount, 1);
    expect(runbook.stepCount, 14);
    expect(runbook.actionableStepCount, 0);
    expect(runbook.blockedStepCount, 14);
    expect(runbook.needsWorkStepCount, 14);
    expect(
      runbook.summaryLabel,
      '14 launch steps need routing or readiness work.',
    );

    final diagnosticsGroup = runbook.requireGroupForDestination(
      BillingNavigationDestinationId.diagnostics,
    );

    expect(diagnosticsGroup.stepCount, 14);
    expect(diagnosticsGroup.summaryLabel, '14 steps need work.');
    expect(diagnosticsGroup.steps.first.statusLabel, 'Blocked');
    expect(
      diagnosticsGroup.steps.first.status,
      BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease,
    );
  });

  testWidgets('BillingProductReleaseChannelLaunchRunbookPanel renders steps', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductReleaseChannelLaunchRunbookPanel(
        runbook: _standardRunbook(),
      ),
    );

    expect(find.text('Channel launch runbook'), findsOneWidget);
    expect(find.text('14 launch steps ready to execute.'), findsOneWidget);
    expect(find.text('Cart & checkout'), findsOneWidget);
    expect(find.text('Open checkout'), findsOneWidget);
    expect(
      find.text('Verify active catalog items and pricing.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'BillingProductReleaseChannelLaunchRunbookPanel renders empty state',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingProductReleaseChannelLaunchRunbookPanel(
          runbook: BillingProductReleaseChannelLaunchRunbook(),
        ),
      );

      expect(find.text('Channel launch runbook'), findsOneWidget);
      expect(
        find.text('No channel launch runbook steps are available yet.'),
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
