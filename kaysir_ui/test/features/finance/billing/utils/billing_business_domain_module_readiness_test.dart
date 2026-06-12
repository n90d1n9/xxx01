import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_module_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('standard modules are launch-ready with adapter warnings', () {
    final report = BillingDomainModuleRegistryReadinessReport.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    expect(report.isReady, isTrue);
    expect(report.blockedDomainKeys, isEmpty);
    expect(report.readyDomainKeys, ['commerce', 'construction', 'digital']);
    expect(report.warningIssueCount, 2);
    expect(
      report.warningIssues.map((issue) => issue.kind),
      everyElement(
        BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
      ),
    );
    expect(
      report
          .requireReportForDomain('commerce')
          .hasIssueKind(
            BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
          ),
      isFalse,
    );
    expect(
      report.summaryLabel,
      '3 billing modules are launch-ready with 2 warnings.',
    );
  });

  test('module readiness blocks tenant-gated navigation gaps', () {
    final report = BillingDomainModuleReadinessReport.forModule(
      commerceBillingDomainModule(),
      hasTenant: false,
    );

    expect(report.isReady, isFalse);
    expect(report.blockerIssueCount, 1);
    expect(report.warningIssueCount, 0);

    final coverageIssue = report.issueForKind(
      BillingDomainModuleReadinessIssueKind.navigationCoverage,
    );

    expect(coverageIssue, isNotNull);
    expect(coverageIssue?.isBlocker, isTrue);
    expect(
      coverageIssue?.details,
      contains(BillingNavigationDestinationId.createInvoice.name),
    );
    expect(
      report.summaryLabel,
      'Commerce billing module has 1 blocker and 0 warnings.',
    );
  });

  test('module readiness reports missing custom module contracts', () {
    final module = profileOnlyBillingDomainModule(
      BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
        capabilities: const {BillingBusinessDomainCapability.servicePeriods},
      ),
    );
    final report = BillingDomainModuleReadinessReport.forModule(module);

    expect(report.isReady, isFalse);
    expect(
      report.hasIssueKind(
        BillingDomainModuleReadinessIssueKind.missingScreenRegistry,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingDomainModuleReadinessIssueKind.missingNavigationPolicy,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
      ),
      isTrue,
    );
    expect(report.blockerIssueCount, 1);
    expect(report.warningIssueCount, 2);
  });

  test('module readiness catches silently unregistered screens', () {
    final module = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
        capabilities: const {BillingBusinessDomainCapability.servicePeriods},
      ),
      screenRegistry: BillingBusinessDomainScreenRegistry(
        screens: const [
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.dashboard,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.dashboard',
            requiresTenant: false,
          ),
        ],
      ),
    );
    final report = BillingDomainModuleReadinessReport.forModule(module);
    final issue = report.issueForKind(
      BillingDomainModuleReadinessIssueKind.missingRegisteredScreens,
    );

    expect(issue, isNotNull);
    expect(issue?.isBlocker, isTrue);
    expect(
      issue?.details,
      contains(BillingNavigationDestinationId.invoices.name),
    );
    expect(
      issue?.details,
      contains(BillingNavigationDestinationId.createInvoice.name),
    );
  });

  test('registry readiness groups blocked domains', () {
    final serviceModule = profileOnlyBillingDomainModule(
      BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
      ),
    );
    final report = BillingDomainModuleRegistryReadinessReport.forRegistry(
      standardBillingDomainModuleRegistry(additionalModules: [serviceModule]),
    );

    expect(report.isReady, isFalse);
    expect(report.blockedDomainKeys, ['service']);
    expect(report.requireReportForDomain('SERVICE').isReady, isFalse);
    expect(report.summaryLabel, '1 of 4 billing modules needs attention.');
  });
}
