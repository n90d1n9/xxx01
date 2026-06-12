import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract_remediation.dart';

void main() {
  test('route contract remediation reports empty complete contracts', () {
    final plan = BillingRouteContractRemediationPlan.forReport(
      BillingRouteContractReport.forRouteRegistry(),
    );

    expect(plan.isEmpty, isTrue);
    expect(plan.actionCount, 0);
    expect(
      plan.summaryLabel,
      'Billing route contract has no remediation actions.',
    );
  });

  test('route contract remediation sorts blockers before warnings', () {
    final plan = BillingRouteContractRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.featureRouteOrderMismatch,
          severity: BillingRouteContractIssueSeverity.warning,
          routeName: BillingRoutes.managementRouteName,
          message: 'Order drift',
        ),
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.duplicatePath,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: BillingRoutes.invoicesRouteName,
          message: 'Duplicate path',
          details: [BillingRoutes.invoicesPath],
        ),
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.missingRouteMetadata,
          severity: BillingRouteContractIssueSeverity.warning,
          routeName: BillingRoutes.diagnosticsRouteName,
          message: 'Metadata missing',
          details: const ['description'],
        ),
      ]),
    );

    expect(plan.actionCount, 3);
    expect(plan.blockerActions.length, 1);
    expect(plan.warningActions.length, 2);
    expect(
      plan.summaryLabel,
      '1 route blocker should be cleared before release.',
    );
    expect(
      plan.actions.first.kind,
      BillingRouteContractRemediationActionKind.cleanupRegistry,
    );
    expect(
      plan.actions.first.label,
      'Clean up ${BillingRoutes.invoicesRouteName} route registry',
    );
    expect(plan.actions.first.facts, [BillingRoutes.invoicesPath]);
    expect(
      plan.actions.last.kind,
      BillingRouteContractRemediationActionKind.restoreRouteOrder,
    );
  });

  test('route contract remediation maps page builder blockers', () {
    final plan = BillingRouteContractRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: BillingRoutes.checkoutRouteName,
          message: 'Missing page builder',
        ),
      ]),
    );

    expect(plan.hasBlockers, isTrue);
    expect(
      plan.actions.single.kind,
      BillingRouteContractRemediationActionKind.attachPageBuilder,
    );
    expect(
      plan.actions.single.detail,
      'Add the missing page builder so the generated route can be opened.',
    );
  });
}

BillingRouteContractReport _reportWithIssues(
  Iterable<BillingRouteContractIssue> issues,
) {
  final registryReport = BillingRouteContractReport.forRouteRegistry();

  return BillingRouteContractReport(
    rootRoute: registryReport.rootRoute,
    routeDefinitions: registryReport.routeDefinitions,
    issues: issues,
  );
}
