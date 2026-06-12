import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_detail_card.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  testWidgets('release workspace profile contract detail card expands ids', (
    tester,
  ) async {
    final contract =
        standardBillingReleaseWorkspaceProfileCatalog
            .profileForBusinessDomain('construction')!
            .buildContract();

    await _pumpContractCard(tester, contract);

    expect(find.text('construction · 4 decks · 5 views'), findsOneWidget);
    expect(find.text('Extended'), findsOneWidget);
    expect(find.text('Business domains'), findsNothing);

    await tester.tap(find.text('construction · 4 decks · 5 views'));
    await tester.pumpAndSettle();

    expect(find.text('Business domains'), findsOneWidget);
    expect(find.text('construction'), findsWidgets);
    expect(find.text('contracting'), findsOneWidget);
    expect(find.text('projects'), findsOneWidget);
    expect(find.text('Deck IDs'), findsOneWidget);
    expect(find.text('Saved views'), findsOneWidget);
    expect(find.text('Domain deck IDs'), findsOneWidget);
    expect(find.text('Domain saved view IDs'), findsOneWidget);
    expect(
      find.text(billingReleaseWorkspaceConstructionFocusDeckId),
      findsWidgets,
    );
    expect(
      find.text(billingReleaseWorkspaceConstructionFocusSavedViewId),
      findsWidgets,
    );
  });

  testWidgets(
    'release workspace profile contract detail card surfaces hidden decks',
    (tester) async {
      final contract =
          BillingReleaseWorkspaceProfile(
            id: 'retail-constrained',
            businessDomains: const ['retail'],
            hiddenDeckIds: const {billingReleaseWorkspaceChannelLaunchDeckId},
          ).buildContract();

      await _pumpContractCard(tester, contract);

      expect(
        find.text('retail-constrained · 2 decks · 4 views'),
        findsOneWidget,
      );
      expect(find.text('Constrained'), findsOneWidget);

      await tester.tap(find.text('retail-constrained · 2 decks · 4 views'));
      await tester.pumpAndSettle();

      expect(find.text('Hidden standard deck IDs'), findsOneWidget);
      expect(
        find.text(billingReleaseWorkspaceChannelLaunchDeckId),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpContractCard(
  WidgetTester tester,
  BillingReleaseWorkspaceProfileContract contract,
) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 900,
            child: BillingReleaseWorkspaceProfileContractDetailCard(
              contract: contract,
            ),
          ),
        ),
      ),
    ),
  );
}
