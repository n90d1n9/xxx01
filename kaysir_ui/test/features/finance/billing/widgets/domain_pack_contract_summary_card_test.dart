import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_summary_card.dart';

void main() {
  testWidgets('DomainPackContractSummaryCard renders contract health', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DomainPackContractSummaryCard(
            summaryLabel:
                '3 billing domain-pack contracts are release-ready with 4 hardening requirements.',
            contractCount: 3,
            openRequirementCount: 4,
            blockedRequirementCount: 0,
            warningRequirementCount: 4,
          ),
        ),
      ),
    );

    expect(
      find.text(
        '3 billing domain-pack contracts are release-ready with 4 hardening requirements.',
      ),
      findsOneWidget,
    );
    expect(find.text('Contracts'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Hardening'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(2));
  });
}
