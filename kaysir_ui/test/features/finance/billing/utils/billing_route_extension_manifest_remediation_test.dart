import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest_remediation.dart';

void main() {
  test('manifest remediation reports empty ready manifests', () {
    final plan = BillingRouteExtensionManifestRemediationPlan.forReport(
      BillingRouteExtensionManifestReport.forManifests(const []),
    );

    expect(plan.isEmpty, isTrue);
    expect(plan.actionCount, 0);
    expect(
      plan.summaryLabel,
      'Billing route extension manifests have no remediation actions.',
    );
  });

  test('manifest remediation sorts blockers before warnings', () {
    final plan = BillingRouteExtensionManifestRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
          severity: BillingRouteExtensionManifestIssueSeverity.warning,
          manifestId: 'billing.subscription',
          message: 'Orphan builder',
          details: const ['routeIdentityKey=billingSubscription'],
        ),
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.duplicatePageBuilder,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: 'billing.retail',
          message: 'Duplicate builder',
          details: const ['routeIdentityKey=billingRetail'],
        ),
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.missingPageBuilder,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: 'billing.entitlements',
          message: 'Missing builder',
          details: const ['routeIdentityKey=billingEntitlements'],
        ),
      ]),
    );

    expect(plan.actionCount, 3);
    expect(plan.blockerActions.length, 2);
    expect(plan.warningActions.length, 1);
    expect(
      plan.summaryLabel,
      '2 manifest blockers should be cleared before release.',
    );
    expect(
      plan.actions.first.kind,
      BillingRouteExtensionManifestRemediationActionKind.deduplicatePageBuilder,
    );
    expect(plan.actions.first.label, 'Deduplicate billing.retail page builder');
    expect(plan.actions.first.facts, ['routeIdentityKey=billingRetail']);
    expect(
      plan.actions.last.kind,
      BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder,
    );
  });

  test('manifest remediation maps duplicate ids', () {
    final plan = BillingRouteExtensionManifestRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteExtensionManifestIssue(
          kind: BillingRouteExtensionManifestIssueKind.duplicateManifestId,
          severity: BillingRouteExtensionManifestIssueSeverity.blocker,
          manifestId: 'billing.entitlements',
          message: 'Duplicate manifest id',
        ),
      ]),
    );

    expect(plan.hasBlockers, isTrue);
    expect(
      plan.actions.single.kind,
      BillingRouteExtensionManifestRemediationActionKind.deduplicateManifestId,
    );
    expect(
      plan.actions.single.detail,
      'Give each extension manifest a stable unique id before it is registered.',
    );
  });
}

BillingRouteExtensionManifestReport _reportWithIssues(
  Iterable<BillingRouteExtensionManifestIssue> issues,
) {
  return BillingRouteExtensionManifestReport(
    manifests: const [],
    issues: issues,
  );
}
