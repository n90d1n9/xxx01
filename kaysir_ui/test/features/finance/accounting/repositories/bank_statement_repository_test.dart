import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/repositories/bank_statement_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_bank_statement_repository.dart';

void main() {
  group('InMemoryBankStatementRepository', () {
    test('loads saved statement lines defensively', () {
      final repository = InMemoryBankStatementRepository();
      final line = _line('line-1');

      repository.appendLine(line);
      final loaded = repository.loadLines();

      expect(loaded.single, line);
      expect(() => loaded.add(_line('line-2')), throwsUnsupportedError);
    });

    test('removes a single statement line by id', () {
      final repository = InMemoryBankStatementRepository(
        lines: [_line('line-1'), _line('line-2')],
      );

      repository.removeLine('line-1');

      expect(repository.loadLines().map((line) => line.id), ['line-2']);
    });
  });

  group('LocalBankStatementRepository', () {
    test('hydrates statement lines from a snapshot store', () async {
      final line = _line('line-1', amount: 1200, reference: 'BNK-001');
      final store = _MemorySnapshotStore(
        snapshot: BankStatementRepositorySnapshot(lines: [line]).toJson(),
      );
      final repository = LocalBankStatementRepository(store: store);

      await repository.hydrate();

      expect(repository.loadLines().single.id, 'line-1');
      expect(repository.loadLines().single.reference, 'BNK-001');
      expect(repository.loadLines().single.isDeposit, isTrue);
    });

    test('persists statement lines as a snapshot', () async {
      final line = _line('line-1', amount: -250, reference: 'BNK-FEE');
      final store = _MemorySnapshotStore();
      final repository = LocalBankStatementRepository(store: store);

      repository.appendLine(line);
      await repository.persist();

      final persisted = BankStatementRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.lines.single.reference, 'BNK-FEE');
      expect(persisted.lines.single.amount, -250);
    });

    test('persists removed statement lines', () async {
      final store = _MemorySnapshotStore();
      final repository = LocalBankStatementRepository(
        store: store,
        lines: [_line('line-1'), _line('line-2')],
      );

      repository.removeLine('line-1');
      await repository.persist();

      final persisted = BankStatementRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.lines.map((line) => line.id), ['line-2']);
    });

    test(
      'keeps newer in-memory statement lines when hydration completes late',
      () async {
        final stored = _line('stored', reference: 'OLD');
        final newer = _line('newer', reference: 'NEW');
        final store = _MemorySnapshotStore(
          snapshot: BankStatementRepositorySnapshot(lines: [stored]).toJson(),
          readDelay: const Duration(milliseconds: 1),
        );
        final repository = LocalBankStatementRepository(store: store);

        final hydration = repository.hydrate();
        repository.appendLine(newer);
        await hydration;
        await repository.persist();

        expect(repository.loadLines().map((line) => line.id), ['newer']);
        expect(
          BankStatementRepositorySnapshot.fromJson(
            store.snapshot!,
          ).lines.single.id,
          'newer',
        );
      },
    );
  });

  group('BankStatementLine JSON', () {
    test('round-trips persisted statement lines', () {
      final line = _line('line-1', amount: -99.5, reference: 'ADM-001');

      final decoded = BankStatementLine.fromJson(line.toJson());

      expect(decoded.id, 'line-1');
      expect(decoded.date, DateTime(2026, 1, 5));
      expect(decoded.description, 'Bank movement');
      expect(decoded.amount, -99.5);
      expect(decoded.reference, 'ADM-001');
      expect(decoded.isDeposit, isFalse);
    });
  });
}

class _MemorySnapshotStore implements BankStatementSnapshotStore {
  Map<String, dynamic>? snapshot;
  final Duration? readDelay;

  _MemorySnapshotStore({this.snapshot, this.readDelay});

  @override
  Future<Map<String, dynamic>?> read() async {
    final delay = readDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}

BankStatementLine _line(String id, {double amount = 1200, String? reference}) {
  return BankStatementLine(
    id: id,
    date: DateTime(2026, 1, 5),
    description: 'Bank movement',
    amount: amount,
    reference: reference,
  );
}
