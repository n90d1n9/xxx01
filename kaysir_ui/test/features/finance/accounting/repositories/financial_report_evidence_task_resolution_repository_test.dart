import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_evidence_task_resolution_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_report_evidence_task_resolution_repository.dart';

void main() {
  group('InMemoryFinancialReportEvidenceTaskResolutionRepository', () {
    test('replaces an existing resolution by task id', () {
      final repository =
          InMemoryFinancialReportEvidenceTaskResolutionRepository();
      final first = _resolution(
        status: FinancialReportEvidenceCloseTaskResolutionStatus.deferred,
      );
      final second = _resolution(
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        evidenceReference: 'WP-BANK-001',
      );

      repository.upsertResolution(periodKey: _periodKey, resolution: first);
      repository.upsertResolution(periodKey: _periodKey, resolution: second);

      expect(repository.loadResolutions()[_periodKey], [second]);
      expect(
        repository.loadResolutions()[_periodKey]?.single.evidenceReference,
        'WP-BANK-001',
      );
    });

    test('loads audit events defensively in append order', () {
      final repository =
          InMemoryFinancialReportEvidenceTaskResolutionRepository();
      final first = _auditEvent(id: 'audit-1');
      final second = _auditEvent(id: 'audit-2');

      repository.appendAuditEvent(first);
      repository.appendAuditEvent(second);

      expect(repository.loadAuditEvents().map((event) => event.id), [
        'audit-1',
        'audit-2',
      ]);
      expect(
        () => repository.loadAuditEvents().add(_auditEvent(id: 'audit-3')),
        throwsUnsupportedError,
      );
    });
  });

  group('LocalFinancialReportEvidenceTaskResolutionRepository', () {
    test('hydrates evidence task resolutions from a snapshot store', () async {
      final resolution = _resolution(
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        evidenceReference: 'WP-BANK-001',
      );
      final auditEvent = _auditEvent(id: 'audit-1');
      final store = _MemorySnapshotStore(
        snapshot:
            FinancialReportEvidenceTaskResolutionRepositorySnapshot(
              resolutionsByPeriod: {
                _periodKey: [resolution],
              },
              auditEvents: [auditEvent],
            ).toJson(),
      );
      final repository = LocalFinancialReportEvidenceTaskResolutionRepository(
        store: store,
      );

      await repository.hydrate();

      expect(
        repository.loadResolutions()[_periodKey]?.single.evidenceReference,
        'WP-BANK-001',
      );
      expect(repository.loadAuditEvents().single.id, 'audit-1');
    });

    test(
      'persists evidence task resolutions and audit events as a snapshot',
      () async {
        final store = _MemorySnapshotStore();
        final repository = LocalFinancialReportEvidenceTaskResolutionRepository(
          store: store,
        );

        repository.upsertResolution(
          periodKey: _periodKey,
          resolution: _resolution(
            status: FinancialReportEvidenceCloseTaskResolutionStatus.approved,
            evidenceReference: 'REV-BANK-001',
          ),
        );
        repository.appendAuditEvent(_auditEvent(id: 'audit-1'));
        await repository.persist();

        final persisted =
            FinancialReportEvidenceTaskResolutionRepositorySnapshot.fromJson(
              store.snapshot!,
            );
        expect(
          persisted.resolutionsByPeriod[_periodKey]?.single.evidenceReference,
          'REV-BANK-001',
        );
        expect(persisted.auditEvents.single.id, 'audit-1');
      },
    );
  });
}

const _periodKey = '20260101-20260131';
const _taskId = 'evidence-bankReconciliation-bank-reconciliation-evidence';

class _MemorySnapshotStore
    implements FinancialReportEvidenceTaskResolutionSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemorySnapshotStore({this.snapshot});

  @override
  Future<Map<String, dynamic>?> read() async => snapshot;

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}

FinancialReportEvidenceCloseTaskResolution _resolution({
  required FinancialReportEvidenceCloseTaskResolutionStatus status,
  String? evidenceReference,
}) {
  return FinancialReportEvidenceCloseTaskResolution(
    taskId: _taskId,
    status: status,
    reviewer: 'Controller',
    resolvedAt: DateTime(2026, 2, 1, 10),
    note: 'Evidence reviewed.',
    evidenceReference: evidenceReference,
  );
}

FinancialReportEvidenceTaskAuditEvent _auditEvent({required String id}) {
  return FinancialReportEvidenceTaskAuditEvent(
    id: id,
    periodKey: _periodKey,
    periodLabel: 'Jan 2026',
    taskId: _taskId,
    taskTitle: 'Bank Reconciliation Evidence evidence follow-up',
    scheduleTitle: 'Bank Reconciliation Evidence',
    action: FinancialReportEvidenceTaskAuditAction.evidenceSaved,
    occurredAt: DateTime(2026, 2, 1, 10),
    actor: 'Controller',
    status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
    note: 'Evidence reviewed.',
    evidenceReference: 'WP-BANK-001',
  );
}
