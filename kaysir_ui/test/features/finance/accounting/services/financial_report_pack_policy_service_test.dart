import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_pack_service.dart';

void main() {
  group('FinancialReportPackService accounting policy integration', () {
    test(
      'uses selected accounting policy for framework, jurisdiction, and currency',
      () {
        final policy = AccountingPolicyProfiles.defaultProfile.copyWith(
          entityName: 'PT Kayys Retail',
          framework: AccountingPolicyFramework.sakEntitasPrivat,
          jurisdiction: 'Indonesia',
          presentationCurrency: 'USD',
        );
        final service = FinancialReportPackService(accountingPolicy: policy);

        final pack = service.build(
          entries: [_entry()],
          periodLabel: 'Jan 2026',
          asOfLabel: 'Jan 31, 2026',
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(pack.entityName, 'PT Kayys Retail');
        expect(pack.frameworkName, 'SAK Entitas Privat');
        expect(pack.jurisdiction, 'Indonesia');
        expect(pack.presentationCurrency, 'USD');
        expect(
          _note(pack, 'Basis of preparation').body,
          contains('SAK Entitas Privat'),
        );
      },
    );
  });
}

FinancialEntry _entry() {
  return FinancialEntry(
    name: 'Sales',
    amount: 1000,
    date: DateTime(2026, 1, 15),
    category: 'Revenue',
    type: 'income',
  );
}

FinancialReportDisclosureNote _note(FinancialReportPack pack, String title) {
  return pack.notes.firstWhere((note) => note.title == title);
}
