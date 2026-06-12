import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation_navigation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_filter.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_sort.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_coverage_panel.dart';

void main() {
  testWidgets('DomainPackContractCoveragePanel renders registry coverage', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(tester, DomainPackContractCoveragePanel(report: report));

    expect(find.text('Domain-pack contracts'), findsOneWidget);
    expect(find.text(report.summaryLabel), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Hardening'), findsWidgets);
    expect(find.text('Business domain'), findsOneWidget);
    expect(find.text('All domains'), findsOneWidget);
    expect(find.text('Contract focus'), findsOneWidget);
    expect(find.text('Registry order'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Hardening 3'), findsOneWidget);
    expect(
      find.text('All domains · All contracts · 3 contracts'),
      findsOneWidget,
    );
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Construction'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
    expect(find.text('Release ready'), findsWidgets);
  });

  testWidgets('DomainPackContractCoveragePanel applies internal sort', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(tester, DomainPackContractCoveragePanel(report: report));

    await tester.tap(
      find.byKey(const ValueKey('domain-pack-contract-coverage-sort-menu')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Domain name'));
    await tester.pumpAndSettle();

    expect(
      find.text('All domains · All contracts · Domain name · 3 contracts'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('domain-pack-contract-coverage-reset-filters')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('All domains · All contracts · 3 contracts'),
      findsOneWidget,
    );
    expect(find.text('Registry order'), findsOneWidget);
  });

  testWidgets('DomainPackContractCoveragePanel accepts controlled sort', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: report,
        selectedSort: DomainPackContractCoverageSort.attention,
      ),
    );

    expect(find.text('Needs attention'), findsOneWidget);
    expect(
      find.text('All domains · All contracts · Needs attention · 3 contracts'),
      findsOneWidget,
    );
  });

  testWidgets('DomainPackContractCoveragePanel applies internal domains', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(tester, DomainPackContractCoveragePanel(report: report));

    await tester.tap(
      find.byKey(const ValueKey('domain-pack-contract-domain-filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Construction · 1 contract'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-commerce')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-construction')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-digital')),
      findsNothing,
    );
    expect(find.text('All 1'), findsOneWidget);
    expect(find.text('Hardening 1'), findsOneWidget);
    expect(
      find.text('Construction · All contracts · 1 contract'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('domain-pack-contract-coverage-reset-filters')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-commerce')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-construction')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-digital')),
      findsOneWidget,
    );
    expect(
      find.text('All domains · All contracts · 3 contracts'),
      findsOneWidget,
    );
  });

  testWidgets('DomainPackContractCoveragePanel accepts controlled domains', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: report,
        selectedDomainSelection: DomainPackContractDomainFilterSelection.domain(
          'digital',
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-commerce')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-construction')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('domain-pack-contract-coverage-digital')),
      findsOneWidget,
    );
    expect(find.text('All 1'), findsOneWidget);
  });

  testWidgets('DomainPackContractCoveragePanel forwards contract actions', (
    tester,
  ) async {
    final readiness = _standardReadiness();
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      readiness,
    );
    final action = plan.actions.first;
    BillingNavigationDestinationId? selectedDestination;

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: DomainPackContractRegistryReport.fromReadiness(readiness),
        remediationPlan: plan,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    final actionFinder = find.byKey(
      ValueKey('domain-pack-contract-open-${action.id}'),
    );
    await tester.ensureVisible(actionFinder);
    await tester.tap(actionFinder);
    await tester.pump();

    expect(
      selectedDestination,
      billingBusinessDomainPackRemediationNavigationTargetFor(
        action,
      ).destinationId,
    );
  });

  testWidgets('DomainPackContractCoveragePanel applies internal filters', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: report,
        showDomainFilter: false,
        showZeroFilters: true,
      ),
    );

    await tester.tap(find.text('Complete 0'));
    await tester.pump();

    expect(find.text('Commerce'), findsNothing);
    expect(find.text('All domains · Complete · 0 contracts'), findsOneWidget);
    expect(
      find.text('No fully specified domain-pack contracts yet.'),
      findsOneWidget,
    );
  });

  testWidgets('DomainPackContractCoveragePanel accepts controlled filters', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: report,
        selectedFilter: DomainPackContractCoverageFilter.complete,
        showZeroFilters: true,
      ),
    );

    expect(find.text('Commerce'), findsNothing);
    expect(
      find.text('No fully specified domain-pack contracts yet.'),
      findsOneWidget,
    );
  });

  testWidgets('DomainPackContractCoveragePanel hides overflow contracts', (
    tester,
  ) async {
    final report = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );

    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(report: report, maxVisibleContracts: 1),
    );

    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Construction'), findsNothing);
    expect(find.text('+2 more domain-pack contracts hidden'), findsOneWidget);
  });

  testWidgets('DomainPackContractCoveragePanel renders empty state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      DomainPackContractCoveragePanel(
        report: DomainPackContractRegistryReport(packReports: const []),
      ),
    );

    expect(
      find.text('No domain-pack contracts are registered yet.'),
      findsOneWidget,
    );
  });
}

BillingBusinessDomainPackRegistryReadinessReport _standardReadiness() {
  return BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
    standardBillingDomainPackRegistry(),
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 980, child: child)),
      ),
    ),
  );
}
