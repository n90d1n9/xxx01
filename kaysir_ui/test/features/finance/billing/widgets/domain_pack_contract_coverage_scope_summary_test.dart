import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_filter.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_sort.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_view_state.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_domain_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_coverage_scope_summary.dart';

void main() {
  testWidgets('DomainPackContractCoverageScopeSummary renders passive scope', (
    tester,
  ) async {
    await _pumpSummary(
      tester,
      DomainPackContractCoverageScopeSummary(viewState: _standardViewState()),
    );

    expect(
      find.text('All domains · All contracts · 3 contracts'),
      findsOneWidget,
    );
    expect(find.text('Reset'), findsNothing);
  });

  testWidgets('DomainPackContractCoverageScopeSummary forwards reset', (
    tester,
  ) async {
    var resetCount = 0;

    await _pumpSummary(
      tester,
      DomainPackContractCoverageScopeSummary(
        viewState: _standardViewState(
          domainSelection: DomainPackContractDomainFilterSelection.domain(
            'construction',
          ),
          filter: DomainPackContractCoverageFilter.hardening,
        ),
        onResetFilters: () {
          resetCount += 1;
        },
      ),
    );

    expect(find.text('Construction · Hardening · 1 contract'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(resetCount, 1);
  });

  testWidgets(
    'DomainPackContractCoverageScopeSummary exposes reset for active sort',
    (tester) async {
      var resetCount = 0;

      await _pumpSummary(
        tester,
        DomainPackContractCoverageScopeSummary(
          viewState: _standardViewState(
            sort: DomainPackContractCoverageSort.attention,
          ),
          onResetFilters: () {
            resetCount += 1;
          },
        ),
      );

      expect(
        find.text(
          'All domains · All contracts · Needs attention · 3 contracts',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(resetCount, 1);
    },
  );
}

DomainPackContractCoverageViewState _standardViewState({
  DomainPackContractDomainFilterSelection domainSelection =
      const DomainPackContractDomainFilterSelection.all(),
  DomainPackContractCoverageFilter filter =
      DomainPackContractCoverageFilter.all,
  DomainPackContractCoverageSort sort = DomainPackContractCoverageSort.registry,
}) {
  return DomainPackContractCoverageViewState.resolve(
    report: DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
    domainSelection: domainSelection,
    filter: filter,
    sort: sort,
  );
}

Future<void> _pumpSummary(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 640, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
