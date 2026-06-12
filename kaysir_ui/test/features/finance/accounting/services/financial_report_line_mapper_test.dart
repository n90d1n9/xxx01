import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_mapping.dart';

void main() {
  group('FinancialReportLineMapper', () {
    const mapper = FinancialReportLineMapper();

    test('maps balance sheet accounts to standardized report lines', () {
      expect(
        mapper.lineLabelFor(
          _entry(name: 'Cash', category: '1000 - Cash', type: 'asset'),
        ),
        'Cash and cash equivalents',
      );
      expect(
        mapper.lineLabelFor(
          _entry(
            name: 'Accounts Receivable',
            category: '1100 - Accounts Receivable',
            type: 'asset',
          ),
        ),
        'Trade and other receivables',
      );
      expect(
        mapper.lineLabelFor(
          _entry(
            name: 'Accounts Payable',
            category: '2000 - Accounts Payable',
            type: 'liability',
          ),
        ),
        'Trade and other payables',
      );
      expect(
        mapper.lineLabelFor(
          _entry(
            name: 'Retained Earnings',
            category: '3000 - Retained Earnings',
            type: 'equity',
          ),
        ),
        'Retained earnings',
      );
      expect(
        mapper.lineLabelFor(
          _entry(
            name: 'OCI Revaluation Reserve',
            category: '3000 - OCI Reserve',
            type: 'equity',
          ),
        ),
        'Other reserves and OCI',
      );
    });

    test('maps income statement accounts into operating, finance, and tax', () {
      final revenue = _entry(
        name: 'Sales Revenue',
        category: '4000 - Sales Revenue',
        type: 'income',
      );
      final rent = _entry(
        name: 'Rent Expense',
        category: '5000 - Rent Expense',
        type: 'expense',
      );
      final interest = _entry(
        name: 'Interest Expense',
        category: '5600 - Interest Expense',
        type: 'expense',
      );
      final tax = _entry(
        name: 'Income Tax Expense',
        category: '5900 - Income Tax Expense',
        type: 'expense',
        sourceCategory: 'Pajak penghasilan',
      );

      expect(
        mapper.lineLabelFor(revenue),
        'Revenue from contracts with customers',
      );
      expect(mapper.lineLabelFor(rent), 'Occupancy expenses');
      expect(
        mapper.expenseGroupFor(rent),
        FinancialReportExpenseGroup.operating,
      );
      expect(
        mapper.lineLabelFor(interest),
        'Interest expense and finance charges',
      );
      expect(
        mapper.expenseGroupFor(interest),
        FinancialReportExpenseGroup.finance,
      );
      expect(mapper.lineLabelFor(tax), 'Current tax expense');
      expect(mapper.expenseGroupFor(tax), FinancialReportExpenseGroup.tax);
    });

    test(
      'classifies cash movements by operating, investing, and financing',
      () {
        expect(
          mapper.cashFlowGroupFor(
            _entry(
              name: 'Cash',
              category: '1000 - Cash',
              type: 'asset',
              sourceCategory: 'Customer collection',
            ),
          ),
          FinancialReportCashFlowGroup.operating,
        );
        expect(
          mapper.cashFlowGroupFor(
            _entry(
              name: 'Cash',
              category: '1000 - Cash',
              type: 'asset',
              sourceCategory: 'Equipment purchase',
            ),
          ),
          FinancialReportCashFlowGroup.investing,
        );
        expect(
          mapper.cashFlowGroupFor(
            _entry(
              name: 'Cash',
              category: '1000 - Cash',
              type: 'asset',
              sourceCategory: 'Modal disetor',
            ),
          ),
          FinancialReportCashFlowGroup.financing,
        );
      },
    );

    test('maps prepaid and withheld income tax assets separately', () {
      final prepaidTax = _entry(
        name: 'PPh 23 Withholding Credit',
        category: '1350 - Kredit Pajak',
        type: 'asset',
        sourceCategory: 'Bukti potong PPh 23',
      );

      expect(mapper.lineLabelFor(prepaidTax), 'Income tax assets');
      expect(mapper.hasExplicitMapping(prepaidTax), isTrue);
    });

    test('maps VAT input and output accounts separately from income tax', () {
      final inputVat = _entry(
        name: 'Input VAT',
        category: '1300 - PPN Masukan',
        type: 'asset',
      );
      final outputVat = _entry(
        name: 'Output VAT',
        category: '2400 - PPN Keluaran',
        type: 'liability',
      );

      expect(mapper.lineLabelFor(inputVat), 'VAT input tax assets');
      expect(mapper.lineLabelFor(outputVat), 'VAT output tax liabilities');
      expect(mapper.hasExplicitMapping(inputVat), isTrue);
      expect(mapper.hasExplicitMapping(outputVat), isTrue);
    });
  });
}

FinancialEntry _entry({
  required String name,
  required String category,
  required String type,
  String? sourceCategory,
}) {
  return FinancialEntry(
    name: name,
    amount: 1,
    date: DateTime(2026, 1, 1),
    category: category,
    type: type,
    sourceCategory: sourceCategory,
  );
}
