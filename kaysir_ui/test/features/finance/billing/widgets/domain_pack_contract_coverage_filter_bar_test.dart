import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_coverage_filter_bar.dart';

void main() {
  testWidgets('DomainPackContractCoverageFilterBar renders available filters', (
    tester,
  ) async {
    await _pumpFilterBar(
      tester,
      DomainPackContractCoverageFilterBar(
        summary: _standardSummary(),
        selectedFilter: DomainPackContractCoverageFilter.all,
        onFilterSelected: (_) {},
      ),
    );

    expect(find.text('Contract focus'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Hardening 3'), findsOneWidget);
    expect(find.text('Blocked 0'), findsNothing);
    expect(find.text('Complete 0'), findsNothing);
  });

  testWidgets('DomainPackContractCoverageFilterBar forwards selection', (
    tester,
  ) async {
    DomainPackContractCoverageFilter? selectedFilter;

    await _pumpFilterBar(
      tester,
      DomainPackContractCoverageFilterBar(
        summary: _standardSummary(),
        selectedFilter: DomainPackContractCoverageFilter.all,
        onFilterSelected: (filter) {
          selectedFilter = filter;
        },
        showZeroFilters: true,
      ),
    );

    await tester.tap(find.text('Complete 0'));
    await tester.pump();

    expect(selectedFilter, DomainPackContractCoverageFilter.complete);
  });

  testWidgets('DomainPackContractCoverageFilterBar hides for empty summaries', (
    tester,
  ) async {
    await _pumpFilterBar(
      tester,
      DomainPackContractCoverageFilterBar(
        summary: DomainPackContractCoverageFilterSummary(reports: const []),
        selectedFilter: DomainPackContractCoverageFilter.all,
        onFilterSelected: (_) {},
      ),
    );

    expect(find.text('Contract focus'), findsNothing);
  });
}

DomainPackContractCoverageFilterSummary _standardSummary() {
  return DomainPackContractCoverageFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );
}

Future<void> _pumpFilterBar(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 920, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
