import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_lane_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';

import '../helpers/domain_pack_contract_expectations.dart';

void main() {
  test('DomainPackContractRegistryReport summarizes standard packs', () {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    expect(report.isReleaseReady, isTrue);
    expect(report.isFullySpecified, isFalse);
    expect(report.domainKeys, ['commerce', 'construction', 'digital']);
    expect(report.blockedDomainKeys, isEmpty);
    expect(report.warningDomainKeys, ['commerce', 'construction', 'digital']);
    expect(report.warningRequirementCount, 4);
    expect(
      report.summaryLabel,
      '3 billing domain-pack contracts are release-ready with '
      '4 hardening requirements.',
    );

    final commerceReport = report.requireReportForDomain('commerce');
    expect(
      commerceReport
          .requireRequirement(domainPackContractDiagnosticsProfileId)
          .status,
      DomainPackContractStatus.warning,
    );
  });

  test('DomainPackContractReport accepts a fully specified pack', () {
    final report = DomainPackContractReport.forPack(
      _servicePack(targetReleaseGateLane: true),
    );

    expectDomainPackContractReleaseReady(report);
    expectDomainPackContractFullySpecified(report);
    expect(
      report.summaryLabel,
      'Service operations billing pack contract is fully specified.',
    );
    expect(
      report.requireRequirement(domainPackContractReleaseGateTargetsId).details,
      ['service-handoff'],
    );
  });

  test('DomainPackContractReport flags release gate lanes without targets', () {
    final report = DomainPackContractReport.forPack(
      _servicePack(targetReleaseGateLane: false),
    );

    expectDomainPackContractReleaseReady(report);
    expect(report.isFullySpecified, isFalse);
    expect(report.warningRequirementCount, 1);
    expect(
      report.summaryLabel,
      'Service operations billing pack contract is release-ready with '
      '1 hardening requirement.',
    );

    final releaseGateRequirement = report.requireRequirement(
      domainPackContractReleaseGateTargetsId,
    );
    expect(releaseGateRequirement.status, DomainPackContractStatus.warning);
    expect(releaseGateRequirement.details, ['service-handoff']);
  });
}

BillingBusinessDomainPack _servicePack({required bool targetReleaseGateLane}) {
  return BillingBusinessDomainPack(
    module: BillingBusinessDomainModule(
      profile: _serviceProfile(),
      lineItemAdapters: [_serviceLineItemAdapter()],
      issuePolicy: BillingInvoiceIssuePolicy(
        domain: 'service',
        label: 'Service operations',
        taxMode: BillingInvoiceTaxMode.exclusive,
      ),
      navigationPolicy: BillingBusinessDomainNavigationPolicy(
        destinationIds: const [
          BillingNavigationDestinationId.dashboard,
          BillingNavigationDestinationId.createInvoice,
        ],
        quickActionIds: const [BillingNavigationDestinationId.createInvoice],
        defaultDestinationId: BillingNavigationDestinationId.createInvoice,
      ),
      screenRegistry: BillingBusinessDomainScreenRegistry(
        screens: const [
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.dashboard,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.dashboard',
            requiresTenant: false,
          ),
          BillingBusinessDomainScreenDescriptor(
            destinationId: BillingNavigationDestinationId.createInvoice,
            surface: BillingNavigationSurface.dashboard,
            key: 'service.create_invoice',
          ),
        ],
      ),
    ),
    diagnosticsProfile: BillingDiagnosticsSectionProfile(
      id: 'service-diagnostics',
      businessDomains: const ['service'],
    ),
    releaseWorkspaceProfile: BillingReleaseWorkspaceProfile(
      id: 'service-release-workspace',
      businessDomains: const ['service'],
    ),
    releaseProfileSavedViewProfile:
        BillingDiagnosticsReleaseProfileSavedViewProfile(
          id: 'service-release-profile-saved-views',
          businessDomains: const ['service'],
        ),
    releaseGateLanes: const [
      BillingReleaseGateLane(
        id: 'service-handoff',
        title: 'Service handoff',
        status: BillingReleaseGateStatus.ready,
        summaryLabel: 'Service handoff is ready.',
        blockerCount: 0,
        warningCount: 0,
        actionCount: 0,
        priority: 500,
      ),
    ],
    releaseGateLaneTargets:
        targetReleaseGateLane
            ? const [
              BillingReleaseGateLaneTarget(
                laneId: 'service-handoff',
                sectionId: 'service-release-readiness',
              ),
            ]
            : const [],
  );
}

BillingBusinessDomainProfile _serviceProfile() {
  return BillingBusinessDomainProfile(
    domain: 'service',
    label: 'Service operations',
    defaultSourceType: 'work_order',
    capabilities: const {BillingBusinessDomainCapability.servicePeriods},
  );
}

BillingInvoiceLineItemAdapter _serviceLineItemAdapter() {
  return BillingInvoiceLineItemAdapter(
    domain: 'service',
    type: 'work_order',
    canAdapt: (_) => true,
    toLineItem:
        (_) => const BillingInvoiceLineItem(
          id: 'service-work',
          description: 'Service work',
          quantity: 1,
          unitPrice: 120,
        ),
  );
}
