import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_tax_profile.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_policy_center_components.dart';

void main() {
  group('accounting policy center components', () {
    testWidgets('renders policy header and framework options', (tester) async {
      AccountingPolicyFramework? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                AccountingPolicyHeader(
                  profile: AccountingPolicyProfiles.defaultProfile,
                  taxProfile: FinancialReportTaxProfiles.standardCorporate,
                  reviewCount: 0,
                ),
                AccountingPolicyFrameworkSelector(
                  profile: AccountingPolicyProfiles.defaultProfile,
                  onChanged: (framework) => selected = framework,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Accounting Policy Center'), findsOneWidget);
      expect(find.text('SAK Indonesia'), findsOneWidget);
      expect(find.text('SAK Entitas Privat'), findsOneWidget);
      expect(find.text('SAK EMKM'), findsWidgets);
      expect(find.text('IFRS'), findsOneWidget);

      await tester.tap(find.text('SAK EMKM').first);
      await tester.pump();

      expect(selected, AccountingPolicyFramework.sakEmkm);
    });
  });
}
