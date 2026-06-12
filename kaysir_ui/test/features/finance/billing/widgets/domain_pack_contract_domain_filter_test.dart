import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_domain_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_domain_filter.dart';

void main() {
  testWidgets('DomainPackContractDomainFilter renders selected scope', (
    tester,
  ) async {
    await _pumpFilter(
      tester,
      DomainPackContractDomainFilter(
        summary: _standardSummary(),
        selectedSelection: const DomainPackContractDomainFilterSelection.all(),
        onSelectionSelected: (_) {},
      ),
    );

    expect(find.text('Business domain'), findsOneWidget);
    expect(find.text('All domains'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('DomainPackContractDomainFilter forwards selection', (
    tester,
  ) async {
    DomainPackContractDomainFilterSelection? selectedSelection;

    await _pumpFilter(
      tester,
      DomainPackContractDomainFilter(
        summary: _standardSummary(),
        selectedSelection: const DomainPackContractDomainFilterSelection.all(),
        onSelectionSelected: (selection) {
          selectedSelection = selection;
        },
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('domain-pack-contract-domain-filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Construction · 1 contract'));
    await tester.pumpAndSettle();

    expect(
      selectedSelection,
      DomainPackContractDomainFilterSelection.domain('construction'),
    );
  });

  testWidgets('DomainPackContractDomainFilter hides for empty summaries', (
    tester,
  ) async {
    await _pumpFilter(
      tester,
      DomainPackContractDomainFilter(
        summary: DomainPackContractDomainFilterSummary(reports: const []),
        selectedSelection: const DomainPackContractDomainFilterSelection.all(),
        onSelectionSelected: (_) {},
      ),
    );

    expect(find.text('Business domain'), findsNothing);
  });
}

DomainPackContractDomainFilterSummary _standardSummary() {
  return DomainPackContractDomainFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );
}

Future<void> _pumpFilter(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 420, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
