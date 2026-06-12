import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest_remediation.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_extension_manifest_remediation_list.dart';

void main() {
  testWidgets(
    'BillingRouteExtensionManifestRemediationList renders visible actions',
    (tester) async {
      final plan = BillingRouteExtensionManifestRemediationPlan.forReport(
        _issueReport(),
      );

      await _pumpList(
        tester,
        BillingRouteExtensionManifestRemediationList(
          actions: plan.actions,
          maxVisibleActions: 2,
        ),
      );

      expect(
        find.byKey(
          const ValueKey('billing-route-extension-manifest-remediation-list'),
        ),
        findsOneWidget,
      );
      expect(find.text('Suggested fixes'), findsOneWidget);
      expect(
        find.text('Deduplicate billing.retail page builder'),
        findsOneWidget,
      );
      expect(
        find.text('Attach billing.entitlements page builder'),
        findsOneWidget,
      );
      expect(
        find.text('Resolve billing.subscription orphan builder'),
        findsNothing,
      );
      expect(find.text('+1 more fix hidden'), findsOneWidget);
      expect(find.text('Blocker'), findsWidgets);
    },
  );
}

BillingRouteExtensionManifestReport _issueReport() {
  return BillingRouteExtensionManifestReport(
    manifests: const [],
    issues: [
      BillingRouteExtensionManifestIssue(
        kind: BillingRouteExtensionManifestIssueKind.missingPageBuilder,
        severity: BillingRouteExtensionManifestIssueSeverity.blocker,
        manifestId: 'billing.entitlements',
        message:
            'billingEntitlements is declared without a manifest page builder.',
        details: const ['routeIdentityKey=billingEntitlements'],
      ),
      BillingRouteExtensionManifestIssue(
        kind: BillingRouteExtensionManifestIssueKind.duplicatePageBuilder,
        severity: BillingRouteExtensionManifestIssueSeverity.blocker,
        manifestId: 'billing.retail',
        message:
            'billingRetail has page builders in multiple billing route manifests.',
        details: const ['routeIdentityKey=billingRetail'],
      ),
      BillingRouteExtensionManifestIssue(
        kind: BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
        severity: BillingRouteExtensionManifestIssueSeverity.warning,
        manifestId: 'billing.subscription',
        message:
            'billingSubscription has a page builder but no route definition.',
        details: const ['routeIdentityKey=billingSubscription'],
      ),
    ],
  );
}

Future<void> _pumpList(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(960, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(width: 720, child: child),
          ),
        ),
      ),
    ),
  );
}
