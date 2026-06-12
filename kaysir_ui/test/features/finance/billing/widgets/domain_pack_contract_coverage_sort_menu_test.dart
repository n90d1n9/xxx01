import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_sort.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_coverage_sort_menu.dart';

void main() {
  testWidgets('DomainPackContractCoverageSortMenu changes sort option', (
    tester,
  ) async {
    var selected = DomainPackContractCoverageSort.registry;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DomainPackContractCoverageSortMenu(
              value: selected,
              onChanged: (value) {
                selected = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Sort domain-pack contracts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Domain name'));
    await tester.pumpAndSettle();

    expect(selected, DomainPackContractCoverageSort.domain);
  });
}
