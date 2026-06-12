import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_extension_manifest_panel.dart';

void main() {
  testWidgets('BillingRouteExtensionManifestPanel renders ready state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingRouteExtensionManifestPanel(
        report: BillingRouteExtensionManifestReport.forManifests(const []),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-route-extension-manifest-panel')),
      findsOneWidget,
    );
    expect(find.text('Route extension manifests'), findsOneWidget);
    expect(
      find.text(
        'Billing route extension manifests are ready across 0 manifests.',
      ),
      findsOneWidget,
    );
    expect(find.text('Manifests'), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Builders'), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-route-extension-manifest-ready')),
      findsOneWidget,
    );
    expect(
      find.text(
        'All billing route extension manifests have matching route definitions and page builders.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'BillingRouteExtensionManifestPanel renders issues and overflow',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingRouteExtensionManifestPanel(
          report: _issueReport(),
          maxVisibleIssues: 2,
          maxVisibleActions: 2,
        ),
      );

      expect(
        find.text(
          'Billing route extension manifests have 2 blockers and 1 warning.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('billing-route-extension-manifest-issues')),
        findsOneWidget,
      );
      expect(find.text('Blocker'), findsWidgets);
      expect(find.text('Warning'), findsNothing);
      expect(find.text('Missing page builder'), findsOneWidget);
      expect(find.text('Duplicate page builder'), findsOneWidget);
      expect(find.text('Orphan page builder'), findsNothing);
      expect(find.text('billing.entitlements'), findsOneWidget);
      expect(find.text('billing.retail'), findsOneWidget);
      expect(find.text('+1 more issue hidden'), findsOneWidget);
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
      expect(find.text('+1 more fix hidden'), findsOneWidget);
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

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
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
