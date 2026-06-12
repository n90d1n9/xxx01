import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('registry coverage report audits every standard module', () {
    final report = BillingNavigationRegistryCoverageReport.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    expect(report.isComplete, isTrue);
    expect(report.hasIssues, isFalse);
    expect(report.issues, isEmpty);
    expect(report.summary.isComplete, isTrue);
    expect(
      report.summary.summaryLabel,
      'Billing navigation coverage is complete.',
    );
    expect(report.domainKeys, ['commerce', 'construction', 'digital']);
    expect(report.incompleteDomainKeys, isEmpty);
    expect(
      report.requireReportForDomain('Commerce').destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
    expect(
      report.requireReportForDomain('construction').destinationIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
  });

  test('registry coverage report flags tenant-gated modules', () {
    final report = BillingNavigationRegistryCoverageReport.forRegistry(
      standardBillingDomainModuleRegistry(),
      hasTenant: false,
    );

    expect(report.isComplete, isFalse);
    expect(report.hasIssues, isTrue);
    expect(report.completeDomainKeys, isEmpty);
    expect(
      report.summary.primaryKind,
      BillingNavigationCoverageIssueKind.unavailable,
    );
    expect(report.summary.domainCount, 3);
    expect(report.summary.domainKeys, ['commerce', 'construction', 'digital']);
    expect(report.summary.unavailableIssueCount, report.summary.issueCount);
    expect(
      report.summary.requireGroupForDomain('DIGITAL').destinationIds,
      contains(BillingNavigationDestinationId.createInvoice),
    );
    expect(report.incompleteDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(
      report.requireReportForDomain('commerce').unreachableDestinationIds,
      contains(BillingNavigationDestinationId.createInvoice),
    );

    final commerceIssue = report
        .issuesForDomain('Commerce')
        .firstWhere(
          (issue) =>
              issue.destinationId == BillingNavigationDestinationId.invoices,
        );

    expect(commerceIssue.domainKey, 'commerce');
    expect(commerceIssue.kind, BillingNavigationCoverageIssueKind.unavailable);
    expect(commerceIssue.disabledReason, 'Select a tenant first');
    expect(commerceIssue.checkedSurfaces, [
      BillingNavigationSurface.dashboard,
      BillingNavigationSurface.productWorkspace,
    ]);
    expect(commerceIssue.unavailableSurfaces, [
      BillingNavigationSurface.dashboard,
      BillingNavigationSurface.productWorkspace,
    ]);
    expect(commerceIssue.missingPlanSurfaces, isEmpty);
    expect(
      commerceIssue.summary,
      'Invoices is not reachable for Commerce: Select a tenant first.',
    );
  });

  test('coverage report reaches every commerce module destination', () {
    final report = BillingNavigationCoverageReport.forModule(
      commerceBillingDomainModule(),
    );

    expect(report.isComplete, isTrue);
    expect(report.unreachableDestinationIds, isEmpty);
    expect(
      report.destinationIds,
      containsAll([
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
        BillingNavigationDestinationId.tenants,
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.issueOutbox,
      ]),
    );

    final checkoutCoverage = report.coverageFor(
      BillingNavigationDestinationId.cartCheckout,
    );

    expect(
      checkoutCoverage.actionableSurfaces,
      containsAll([
        BillingNavigationSurface.dashboard,
        BillingNavigationSurface.productWorkspace,
      ]),
    );
    expect(checkoutCoverage.localSurfaces, [
      BillingNavigationSurface.productWorkspace,
    ]);
    expect(checkoutCoverage.routeSurfaces, [
      BillingNavigationSurface.dashboard,
    ]);
  });

  test('coverage report keeps non-commerce modules complete without cart', () {
    final constructionReport = BillingNavigationCoverageReport.forModule(
      constructionBillingDomainModule(),
    );
    final digitalReport = BillingNavigationCoverageReport.forModule(
      digitalSubscriptionBillingDomainModule(),
    );

    expect(constructionReport.isComplete, isTrue);
    expect(digitalReport.isComplete, isTrue);
    expect(
      constructionReport.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      digitalReport.destinationIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
  });

  test('coverage report identifies no-tenant navigation gaps', () {
    final report = BillingNavigationCoverageReport.forModule(
      commerceBillingDomainModule(),
      hasTenant: false,
    );

    expect(report.isComplete, isFalse);
    expect(report.hasIssues, isTrue);
    expect(
      report.reachableDestinationIds,
      containsAll([
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      report.unreachableDestinationIds,
      containsAll([
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.issueOutbox,
      ]),
    );
    expect(
      report
          .coverageFor(BillingNavigationDestinationId.productWorkspace)
          .disabledReason,
      'Select a tenant first',
    );

    final productIssue = report.issues.firstWhere(
      (issue) =>
          issue.destinationId ==
          BillingNavigationDestinationId.productWorkspace,
    );

    expect(productIssue.domainKey, 'commerce');
    expect(productIssue.domainLabel, 'Commerce');
    expect(productIssue.kind, BillingNavigationCoverageIssueKind.unavailable);
    expect(productIssue.disabledReason, 'Select a tenant first');
  });

  test(
    'coverage summary groups issues by domain and prioritizes issue kinds',
    () {
      final profile = BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
        capabilities: const {BillingBusinessDomainCapability.servicePeriods},
      );
      final summary = BillingNavigationCoverageSummary(
        issues: [
          BillingNavigationCoverageIssue(
            profile: profile,
            destination: billingNavigationDestinationFor(
              BillingNavigationDestinationId.reports,
            ),
            surfaceDecisions: const [
              BillingNavigationIssueSurfaceDecision(
                surface: BillingNavigationSurface.dashboard,
                isActionable: false,
                isUnavailable: false,
                isMissingPlan: true,
              ),
            ],
          ),
          BillingNavigationCoverageIssue(
            profile: profile,
            destination: billingNavigationDestinationFor(
              BillingNavigationDestinationId.invoices,
            ),
            surfaceDecisions: const [
              BillingNavigationIssueSurfaceDecision(
                surface: BillingNavigationSurface.dashboard,
                isActionable: false,
                isUnavailable: true,
                isMissingPlan: false,
                disabledReason: 'Select a tenant first',
              ),
            ],
          ),
        ],
      );

      expect(summary.issueCount, 2);
      expect(summary.domainKeys, ['service']);
      expect(summary.destinationIds, [
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.invoices,
      ]);
      expect(
        summary.primaryKind,
        BillingNavigationCoverageIssueKind.unavailable,
      );
      expect(summary.missingPlanIssueCount, 1);
      expect(summary.unavailableIssueCount, 1);
      expect(summary.summaryLabel, '2 navigation gaps across 1 domain.');

      final group = summary.requireGroupForDomain(' SERVICE ');

      expect(group.domainLabel, 'Service operations');
      expect(group.issueCount, 2);
      expect(group.primaryKind, BillingNavigationCoverageIssueKind.unavailable);
      expect(
        group
            .issuesForKind(BillingNavigationCoverageIssueKind.missingPlan)
            .single
            .destinationId,
        BillingNavigationDestinationId.reports,
      );
      expect(group.summaryLabel, 'Service operations has 2 navigation gaps.');
    },
  );
}
