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
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_plan_panel.dart';

void main() {
  testWidgets('BillingProductReleaseChannelLaunchPlanPanel renders actions', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;
    final launchPlan = _standardLaunchPlan();

    await _pumpPanel(
      tester,
      BillingProductReleaseChannelLaunchPlanPanel(
        launchPlan: launchPlan,
        dispatchPlan: _dispatchPlan(launchPlan),
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    expect(find.text('Channel launch plan'), findsOneWidget);
    expect(
      find.text('2 channel launches can publish; 12 need review.'),
      findsOneWidget,
    );
    expect(
      find.text('Publish Commerce essentials on POS counter'),
      findsOneWidget,
    );
    expect(find.text('Review Omni business for POS counter'), findsOneWidget);
    expect(find.text('Launch now'), findsWidgets);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Cart & checkout - Route'), findsOneWidget);
    expect(find.text('Open checkout'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Open checkout'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.cartCheckout);
  });

  testWidgets(
    'BillingProductReleaseChannelLaunchPlanPanel renders empty state',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingProductReleaseChannelLaunchPlanPanel(
          launchPlan: BillingProductReleaseChannelLaunchPlan(),
        ),
      );

      expect(find.text('Channel launch plan'), findsOneWidget);
      expect(
        find.text('No channel launch actions are available yet.'),
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

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan() {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(_standardMatrix());
}

BillingProductReleaseChannelLaunchDispatchPlan _dispatchPlan(
  BillingProductReleaseChannelLaunchPlan launchPlan,
) {
  final dispatchSnapshot = BillingNavigationLaunchPlanner(
    hasTenant: true,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
  );

  return BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
    launchPlan: launchPlan,
    dispatchSnapshot: dispatchSnapshot,
  );
}

BillingProductReleaseChannelMatrix _standardMatrix() {
  return BillingProductReleaseChannelMatrix.forEditionCatalog(
    registry: standardBillingProductReleaseChannelRegistry(),
    editionCatalog: _standardEditionCatalog(),
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
