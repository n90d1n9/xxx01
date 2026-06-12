import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_pack_readiness_badge.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_pack_readiness_tile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_pack_registry_readiness_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';

void main() {
  testWidgets('BillingBusinessDomainPackReadinessBadge renders ready state', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      commerceBillingDomainPack(
        diagnosticsProfile: _commerceProfile(),
        releaseProfileSavedViewProfile: _commerceSavedViewProfile(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingBusinessDomainPackReadinessBadge(report: report),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byTooltip(report.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('BillingBusinessDomainPackReadinessBadge renders warning state', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      commerceBillingDomainPack(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingBusinessDomainPackReadinessBadge(report: report),
        ),
      ),
    );

    expect(find.text('Warnings'), findsOneWidget);
    expect(find.byTooltip(report.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
  });

  testWidgets('BillingBusinessDomainPackReadinessBadge renders blocker state', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      commerceBillingDomainPack(),
      hasTenant: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingBusinessDomainPackReadinessBadge(report: report),
        ),
      ),
    );

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.byTooltip(report.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('BillingBusinessDomainPackReadinessTile shows pack contracts', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      commerceBillingDomainPack(),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackReadinessTile(report: report),
    );

    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('commerce · commerce'), findsOneWidget);
    expect(find.text(report.summaryLabel), findsOneWidget);
    expect(find.text('Module contract'), findsOneWidget);
    expect(find.text('Diagnostics contract'), findsOneWidget);
    expect(find.text('Release workspace'), findsOneWidget);
    expect(find.text('Release profile views'), findsWidgets);
    expect(find.text('commerce · 3 decks · 4 views'), findsOneWidget);
    expect(find.text('Diagnostics contract'), findsOneWidget);
    expect(find.textContaining('domain-specific pack profile'), findsOneWidget);
    expect(
      find.textContaining('standard release profile saved views'),
      findsWidgets,
    );
  });

  testWidgets('BillingBusinessDomainPackReadinessTile shows missing release', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackReadinessReport.forPack(
      BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
      ),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackReadinessTile(
        report: report,
        maxVisiblePackIssues: 3,
      ),
    );

    expect(find.text('Release workspace'), findsOneWidget);
    expect(find.text('Release profile views'), findsWidgets);
    expect(
      find.textContaining('uses standard release workspace'),
      findsOneWidget,
    );
  });

  testWidgets('BillingBusinessDomainPackRegistryReadinessPanel renders packs', (
    tester,
  ) async {
    final report = BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackRegistryReadinessPanel(report: report),
    );

    expect(find.text('Business domain packs'), findsOneWidget);
    expect(find.text('Ready with pack warnings'), findsOneWidget);
    expect(find.text(report.summaryLabel), findsOneWidget);
    expect(find.text('Packs'), findsOneWidget);
    expect(find.text('Diagnostics'), findsWidgets);
    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Profile views'), findsOneWidget);
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Construction'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
  });

  testWidgets(
    'BillingBusinessDomainPackRegistryReadinessPanel renders empty registry',
    (tester) async {
      final report = BillingBusinessDomainPackRegistryReadinessReport(
        packReports: const [],
      );

      await _pumpPanel(
        tester,
        BillingBusinessDomainPackRegistryReadinessPanel(report: report),
      );

      expect(find.text('Business domain packs'), findsOneWidget);
      expect(
        find.text(
          'No reusable billing business domain packs are registered yet.',
        ),
        findsOneWidget,
      );
    },
  );
}

BillingDiagnosticsSectionProfile _commerceProfile() {
  return BillingDiagnosticsSectionProfile(
    id: 'commerce',
    businessDomains: const ['commerce'],
  );
}

BillingDiagnosticsReleaseProfileSavedViewProfile _commerceSavedViewProfile() {
  return BillingDiagnosticsReleaseProfileSavedViewProfile(
    id: 'commerce-release-profile-saved-views',
    businessDomains: const ['commerce'],
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

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 1000, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
