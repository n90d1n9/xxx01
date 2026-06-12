import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';

void main() {
  test('standard pack readiness audits module and pack contracts', () {
    final report = BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    expect(report.isReady, isTrue);
    expect(report.domainKeys, ['commerce', 'construction', 'digital']);
    expect(report.readyDomainKeys, ['commerce', 'construction', 'digital']);
    expect(report.blockedDomainKeys, isEmpty);
    expect(report.warningIssueCount, 4);
    expect(
      report
          .requireReportForDomain('commerce')
          .hasIssueKind(
            BillingBusinessDomainPackReadinessIssueKind
                .missingDiagnosticsProfile,
          ),
      isTrue,
    );
    expect(report.requireReportForDomain('construction').warningIssueCount, 1);
    expect(
      report.summaryLabel,
      '3 billing packs are release-ready with 4 warnings.',
    );
  });

  test('pack readiness keeps tenant-gated module blockers', () {
    final report = BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
      standardBillingDomainPackRegistry(),
      hasTenant: false,
    );

    expect(report.isReady, isFalse);
    expect(report.blockedDomainKeys, ['commerce', 'construction', 'digital']);
    expect(report.blockerIssueCount, 3);
    expect(report.warningIssueCount, 4);
    expect(report.summaryLabel, '3 of 3 billing packs need attention.');
  });

  test('custom pack readiness reports missing pack profiles', () {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
      ),
    );

    expect(report.isReady, isFalse);
    expect(report.blockerIssueCount, 1);
    expect(report.warningIssueCount, 6);
    expect(
      report.hasIssueKind(
        BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingBusinessDomainPackReadinessIssueKind
            .missingReleaseWorkspaceProfile,
      ),
      isTrue,
    );
    expect(
      report.summaryLabel,
      'Service operations billing pack has 1 blocker and 6 warnings.',
    );
  });

  test('custom pack readiness accepts explicit pack contracts', () {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        diagnosticsProfile: BillingDiagnosticsSectionProfile(
          id: 'service-diagnostics',
          businessDomains: const ['service'],
        ),
        releaseWorkspaceProfile: BillingReleaseWorkspaceProfile(
          id: 'service-release',
          businessDomains: const ['service'],
        ),
        releaseProfileSavedViewProfile:
            BillingDiagnosticsReleaseProfileSavedViewProfile(
              id: 'service-release-profile-saved-views',
              businessDomains: const ['service'],
            ),
      ),
    );

    expect(
      report.hasIssueKind(
        BillingBusinessDomainPackReadinessIssueKind.missingDiagnosticsProfile,
      ),
      isFalse,
    );
    expect(
      report.hasIssueKind(
        BillingBusinessDomainPackReadinessIssueKind
            .missingReleaseWorkspaceProfile,
      ),
      isFalse,
    );
    expect(
      report.hasIssueKind(
        BillingBusinessDomainPackReadinessIssueKind
            .missingReleaseProfileSavedViewProfile,
      ),
      isFalse,
    );
    expect(report.warningIssueCount, 3);
  });
}

BillingBusinessDomainProfile _serviceProfile() {
  return BillingBusinessDomainProfile(
    domain: 'service',
    label: 'Service operations',
    defaultSourceType: 'work_order',
    capabilities: const {BillingBusinessDomainCapability.servicePeriods},
  );
}
