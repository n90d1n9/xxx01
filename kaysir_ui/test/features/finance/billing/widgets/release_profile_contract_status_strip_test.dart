import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_status_strip.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  testWidgets(
    'release workspace profile contract status strip renders counts',
    (tester) async {
      final coverage = BillingReleaseWorkspaceProfileContractCoverage(
        contracts:
            standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              child: BillingReleaseWorkspaceProfileContractStatusStrip(
                summary: coverage.statusSummary,
                showZeroStatuses: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Profile status'), findsOneWidget);
      expect(find.text('1 Standard'), findsOneWidget);
      expect(find.text('2 Extended'), findsOneWidget);
      expect(find.text('0 Constrained'), findsOneWidget);
      expect(find.text('0 Tailored'), findsOneWidget);
    },
  );
}
