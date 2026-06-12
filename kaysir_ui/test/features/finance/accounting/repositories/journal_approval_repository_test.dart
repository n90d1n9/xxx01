import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/data/journal_approval_seed_data.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/repositories/journal_approval_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_journal_approval_repository.dart';

void main() {
  group('InMemoryJournalApprovalRepository', () {
    test('loads requests defensively', () {
      final repository = InMemoryJournalApprovalRepository();
      final request = _request('approval-1');

      repository.replaceAll([request]);
      final loaded = repository.loadRequests();

      expect(loaded.single.id, 'approval-1');
      expect(() => loaded.add(_request('approval-2')), throwsUnsupportedError);
    });
  });

  group('LocalJournalApprovalRepository', () {
    test('hydrates requests from a snapshot store', () async {
      final store = _MemoryJournalApprovalSnapshotStore(
        snapshot:
            JournalApprovalRepositorySnapshot(
              requests: [_request('approval-1')],
            ).toJson(),
      );
      final repository = LocalJournalApprovalRepository(store: store);

      await repository.hydrate();

      expect(repository.loadRequests().single.id, 'approval-1');
      expect(
        repository.loadRequests().single.auditTrail.single.action,
        JournalApprovalAuditAction.submitted,
      );
    });

    test('persists requests as a snapshot', () async {
      final store = _MemoryJournalApprovalSnapshotStore();
      final repository = LocalJournalApprovalRepository(store: store);

      repository.replaceAll([_request('approval-1')]);
      await repository.persist();

      final persisted = JournalApprovalRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.requests.single.draft.reference, 'JE-approval-1');
      expect(
        persisted.requests.single.auditTrail.single.actorName,
        'Accountant',
      );
    });

    test(
      'keeps newer in-memory requests when hydration completes late',
      () async {
        final stored = _request('stored');
        final newer = _request('newer');
        final store = _MemoryJournalApprovalSnapshotStore(
          snapshot:
              JournalApprovalRepositorySnapshot(requests: [stored]).toJson(),
          readDelay: const Duration(milliseconds: 1),
        );
        final repository = LocalJournalApprovalRepository(store: store);

        final hydration = repository.hydrate();
        repository.replaceAll([newer]);
        await hydration;
        await repository.persist();

        expect(repository.loadRequests().single.id, 'newer');
        expect(
          JournalApprovalRepositorySnapshot.fromJson(
            store.snapshot!,
          ).requests.single.id,
          'newer',
        );
      },
    );
  });

  group('Journal approval JSON', () {
    test('round-trips requests, drafts, and audit events', () {
      final baseRequest = seedJournalApprovals().first;
      final request = baseRequest.copyWith(
        reversalDate: DateTime(2026, 6, 12),
        reversalRequestId: 'approval-reversal-1',
        auditTrail: [
          ...baseRequest.auditTrail,
          JournalApprovalAuditEvent(
            id: 'approval-rent-accrual-audit-2',
            action: JournalApprovalAuditAction.reversalRequested,
            actorName: 'Controller',
            occurredAt: DateTime(2026, 6, 11, 10),
          ),
        ],
      );

      final decoded = JournalApprovalRequest.fromJson(request.toJson());

      expect(decoded.id, request.id);
      expect(decoded.draft.source, JournalSource.manualAdjustment);
      expect(decoded.draft.lines.first.side, JournalSide.debit);
      expect(
        decoded.latestAuditEvent?.action,
        JournalApprovalAuditAction.reversalRequested,
      );
      expect(decoded.reversalDate, DateTime(2026, 6, 12));
      expect(decoded.reversalRequestId, 'approval-reversal-1');
    });
  });
}

class _MemoryJournalApprovalSnapshotStore
    implements JournalApprovalSnapshotStore {
  _MemoryJournalApprovalSnapshotStore({this.snapshot, this.readDelay});

  Map<String, dynamic>? snapshot;
  final Duration? readDelay;

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

JournalApprovalRequest _request(String id) {
  return JournalApprovalRequest(
    id: id,
    draft: JournalDraft(
      id: 'journal-$id',
      date: DateTime(2026, 6, 11),
      reference: 'JE-$id',
      description: 'Repository test request',
      source: JournalSource.manualAdjustment,
      lines: const [
        JournalLineDraft(
          accountId: 'cash',
          accountName: 'Cash',
          side: JournalSide.debit,
          amount: 100,
        ),
        JournalLineDraft(
          accountId: 'revenue',
          accountName: 'Revenue',
          side: JournalSide.credit,
          amount: 100,
        ),
      ],
    ),
    preparerName: 'Accountant',
    reviewerName: 'Controller',
    status: JournalApprovalStatus.pendingReview,
    submittedAt: DateTime(2026, 6, 11, 9),
    dueAt: DateTime(2026, 6, 12, 9),
    auditTrail: [
      JournalApprovalAuditEvent(
        id: '$id-audit-1',
        action: JournalApprovalAuditAction.submitted,
        actorName: 'Accountant',
        occurredAt: DateTime(2026, 6, 11, 9),
      ),
    ],
  );
}
