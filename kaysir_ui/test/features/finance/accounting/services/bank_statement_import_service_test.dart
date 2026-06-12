import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/services/bank_statement_import_service.dart';

void main() {
  group('BankStatementImportService', () {
    const service = BankStatementImportService();

    test('imports signed amount CSV rows with quoted descriptions', () {
      final result = service.parseCsv('''
date,description,reference,amount
2026-01-05,"Customer transfer, Jakarta",BNK-001,"Rp 1.200,50"
2026-01-06,Bank fee,ADM-001,(25.00)
''', importId: 'test');

      expect(result.issues, isEmpty);
      expect(result.lines, hasLength(2));
      expect(result.lines.first.id, 'bank-stmt-test-row-2');
      expect(result.lines.first.description, 'Customer transfer, Jakarta');
      expect(result.lines.first.amount, 1200.5);
      expect(result.lines.last.amount, -25);
    });

    test('imports Indonesian debit and credit statement columns', () {
      final result = service.parseCsv('''
Tanggal,Keterangan,Referensi,Debet,Kredit
05/01/2026,Setoran pelanggan,BNK-001,,1.250.000
06/01/2026,Biaya admin,ADM-001,15.000,
''');

      expect(result.issues, isEmpty);
      expect(result.lines.map((line) => line.amount), [1250000, -15000]);
      expect(result.lines.first.date, DateTime(2026, 1, 5));
      expect(result.lines.last.reference, 'ADM-001');
    });

    test('keeps valid rows and reports invalid rows for review', () {
      final result = service.parseCsv('''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
not-a-date,Bank fee,ADM-001,25
2026-01-07,,BNK-003,30
''');

      expect(result.lines, hasLength(1));
      expect(result.issues.map((issue) => issue.rowNumber), [3, 4]);
      expect(result.issues.map((issue) => issue.message), [
        'Invalid date',
        'Missing description',
      ]);
    });

    test('skips duplicate rows against existing and imported lines', () {
      final existing = BankStatementLine(
        id: 'existing',
        date: DateTime(2026, 1, 5),
        description: 'Existing transfer',
        amount: 1200,
        reference: 'BNK-001',
      );
      final result = service.parseCsv(
        '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
2026-01-06,Bank fee,ADM-001,-25
2026-01-06,Bank fee copy,ADM-001,-25
''',
        existingLines: [existing],
      );

      expect(result.lines.map((line) => line.reference), ['ADM-001']);
      expect(result.issues.map((issue) => issue.rowNumber), [2, 4]);
      expect(result.issues.map((issue) => issue.message), [
        'Duplicate statement line',
        'Duplicate statement line',
      ]);
    });

    test('reports missing required headers', () {
      final result = service.parseCsv('''
posted_at,note
2026-01-05,Customer transfer
''');

      expect(result.lines, isEmpty);
      expect(result.issues.map((issue) => issue.message), [
        'Missing date column',
        'Missing description column',
        'Missing amount or debit/credit columns',
      ]);
    });
  });
}
