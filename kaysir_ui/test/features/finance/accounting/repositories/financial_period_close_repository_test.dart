import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_audit.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_period_close_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_period_close_repository.dart';

void main() {
  group('InMemoryFinancialPeriodCloseRepository', () {
    test('loads saved close records defensively', () {
      final repository = InMemoryFinancialPeriodCloseRepository();
      final record = _record();

      repository.upsertRecord(record);
      final loaded = repository.loadRecords();

      expect(loaded[record.periodKey], record);
      expect(() => loaded['other'] = record, throwsUnsupportedError);
    });

    test('replaces an existing period close record by period key', () {
      final repository = InMemoryFinancialPeriodCloseRepository();
      final closed = _record();
      final reopened = closed.copyWith(
        status: FinancialPeriodCloseStatus.reopened,
        reopenedAt: DateTime(2026, 2, 2),
        reopenedBy: 'Controller',
        reopenReason: 'Late vendor bill',
      );

      repository.upsertRecord(closed);
      repository.upsertRecord(reopened);

      expect(
        repository.loadRecords()[closed.periodKey]?.status,
        FinancialPeriodCloseStatus.reopened,
      );
      expect(
        repository.loadRecords()[closed.periodKey]?.reopenReason,
        'Late vendor bill',
      );
    });

    test('loads saved audit events defensively in append order', () {
      final repository = InMemoryFinancialPeriodCloseRepository();
      final first = _auditEvent(id: 'audit-1');
      final second = _auditEvent(id: 'audit-2');

      repository.appendAuditEvent(first);
      repository.appendAuditEvent(second);
      final loaded = repository.loadAuditEvents();

      expect(loaded.map((event) => event.id), ['audit-1', 'audit-2']);
      expect(
        () => loaded.add(_auditEvent(id: 'audit-3')),
        throwsUnsupportedError,
      );
    });
  });

  group('LocalFinancialPeriodCloseRepository', () {
    test(
      'hydrates close records and audit events from a snapshot store',
      () async {
        final record = _record();
        final event = _auditEvent(id: 'audit-1');
        final store = _MemorySnapshotStore(
          snapshot:
              FinancialPeriodCloseRepositorySnapshot(
                records: {record.periodKey: record},
                auditEvents: [event],
              ).toJson(),
        );
        final repository = LocalFinancialPeriodCloseRepository(store: store);

        await repository.hydrate();

        expect(
          repository.loadRecords()[record.periodKey]?.closedBy,
          'Controller',
        );
        expect(repository.loadAuditEvents().single.id, 'audit-1');
      },
    );

    test('persists close records and audit events as a snapshot', () async {
      final record = _record();
      final event = _auditEvent(id: 'audit-1');
      final store = _MemorySnapshotStore();
      final repository = LocalFinancialPeriodCloseRepository(store: store);

      repository.upsertRecord(record);
      repository.appendAuditEvent(event);
      await repository.persist();

      final persisted = FinancialPeriodCloseRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(
        persisted.records[record.periodKey]?.reportPackageHash,
        'abcdef1234567890',
      );
      expect(
        persisted.auditEvents.single.reportPackageHashAlgorithm,
        'SHA-256',
      );
      expect(
        persisted.records[record.periodKey]?.closingEntryReference,
        'CL-2026-01',
      );
      expect(
        persisted.auditEvents.single.closingEntryPostingId,
        'posting-close-jan',
      );
    });

    test(
      'keeps newer in-memory writes when hydration completes late',
      () async {
        final oldRecord = _record();
        final newRecord = oldRecord.copyWith(
          closedBy: 'Accounting Lead',
          reportPackageHash: 'new-package-hash',
        );
        final store = _MemorySnapshotStore(
          snapshot:
              FinancialPeriodCloseRepositorySnapshot(
                records: {oldRecord.periodKey: oldRecord},
                auditEvents: const [],
              ).toJson(),
          readDelay: const Duration(milliseconds: 1),
        );
        final repository = LocalFinancialPeriodCloseRepository(store: store);

        final hydration = repository.hydrate();
        repository.upsertRecord(newRecord);
        await hydration;
        await repository.persist();

        expect(
          repository.loadRecords()[oldRecord.periodKey]?.closedBy,
          'Accounting Lead',
        );
        expect(
          FinancialPeriodCloseRepositorySnapshot.fromJson(
            store.snapshot!,
          ).records[oldRecord.periodKey]?.reportPackageHash,
          'new-package-hash',
        );
      },
    );
  });

  group('Financial period close JSON', () {
    test('round-trips close records and audit events', () {
      final record = _record();
      final event = _auditEvent(id: 'audit-1');

      final decodedRecord = FinancialPeriodCloseRecord.fromJson(
        record.toJson(),
      );
      final decodedEvent = FinancialPeriodCloseAuditEvent.fromJson(
        event.toJson(),
      );

      expect(decodedRecord.periodKey, record.periodKey);
      expect(decodedRecord.status, FinancialPeriodCloseStatus.closed);
      expect(decodedRecord.reportPackageHashAlgorithm, 'SHA-256');
      expect(decodedRecord.closingEntryReference, 'CL-2026-01');
      expect(decodedRecord.closingEntryPostedAt, DateTime(2026, 2, 1, 8, 45));
      expect(decodedEvent.id, 'audit-1');
      expect(decodedEvent.action, FinancialPeriodCloseAuditAction.closed);
      expect(decodedEvent.reportPackageShortHash, 'ABCDEF123456');
      expect(decodedEvent.closingEntryPostingId, 'posting-close-jan');
    });
  });
}

class _MemorySnapshotStore implements FinancialPeriodCloseSnapshotStore {
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

FinancialPeriodCloseRecord _record() {
  return FinancialPeriodCloseRecord(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 1, 2026 - Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    status: FinancialPeriodCloseStatus.closed,
    closedAt: DateTime(2026, 2, 1, 9),
    closedBy: 'Controller',
    reopenedAt: null,
    reopenedBy: null,
    reopenReason: null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportGeneratedAt: DateTime(2026, 2, 1, 8),
    reportPackageHash: 'abcdef1234567890',
    reportPackageHashAlgorithm: 'SHA-256',
    closingEntryPostingId: 'posting-close-jan',
    closingEntryReference: 'CL-2026-01',
    closingEntryPostedAt: DateTime(2026, 2, 1, 8, 45),
  );
}

FinancialPeriodCloseAuditEvent _auditEvent({required String id}) {
  return FinancialPeriodCloseAuditEvent(
    id: id,
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 1, 2026 - Jan 31, 2026',
    action: FinancialPeriodCloseAuditAction.closed,
    occurredAt: DateTime(2026, 2, 1, 9),
    actor: 'Controller',
    reason: null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportPackageHash: 'abcdef1234567890',
    reportPackageHashAlgorithm: 'SHA-256',
    closingEntryPostingId: 'posting-close-jan',
    closingEntryReference: 'CL-2026-01',
    closingEntryPostedAt: DateTime(2026, 2, 1, 8, 45),
  );
}
