import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_release_signoff_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_report_release_signoff_repository.dart';

void main() {
  group('FinancialReportReleaseSignOffRepository', () {
    test('in-memory repository upserts and removes sign-off resolutions', () {
      final repository = InMemoryFinancialReportReleaseSignOffRepository();

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(
          requirementId: 'approved-for-release',
          status: FinancialReportReleaseSignOffStatus.returned,
        ),
      );
      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(requirementId: 'approved-for-release'),
      );
      repository.appendAuditEvent(
        _auditEvent(requirementId: 'approved-for-release'),
      );

      final resolutions =
          repository.loadResolutions()['20260101-20260131'] ?? const [];
      expect(resolutions, hasLength(1));
      expect(
        resolutions.single.status,
        FinancialReportReleaseSignOffStatus.signed,
      );
      expect(repository.loadAuditEvents(), hasLength(1));
      expect(
        repository.loadAuditEvents().single.id,
        'audit-approved-for-release',
      );

      repository.removeResolution(
        periodKey: '20260101-20260131',
        requirementId: 'approved-for-release',
      );

      expect(repository.loadResolutions(), isEmpty);
      expect(repository.loadAuditEvents(), hasLength(1));
    });

    test('local repository hydrates stored sign-offs', () async {
      final store = _MemoryReleaseSignOffStore({
        'schemaVersion': 1,
        'resolutionsByPeriod': {
          '20260101-20260131': [
            _resolution(requirementId: 'prepared-by-accounting').toJson(),
          ],
        },
        'auditEvents': [
          _auditEvent(requirementId: 'prepared-by-accounting').toJson(),
        ],
      });
      final repository = LocalFinancialReportReleaseSignOffRepository(
        store: store,
      );

      await repository.hydrate();

      expect(
        repository.loadResolutions()['20260101-20260131']?.single.requirementId,
        'prepared-by-accounting',
      );
      expect(
        repository.loadAuditEvents().single.requirementId,
        'prepared-by-accounting',
      );
    });

    test('local repository persists sign-off updates', () async {
      final store = _MemoryReleaseSignOffStore();
      final repository = LocalFinancialReportReleaseSignOffRepository(
        store: store,
      );

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(requirementId: 'reviewed-by-controller'),
      );
      repository.appendAuditEvent(
        _auditEvent(requirementId: 'reviewed-by-controller'),
      );
      await repository.persist();

      final rawPeriods = store.snapshot!['resolutionsByPeriod'] as Map;
      final persisted = (rawPeriods['20260101-20260131'] as List).single as Map;
      final persistedEvents = store.snapshot!['auditEvents'] as List;
      expect(persisted['requirementId'], 'reviewed-by-controller');
      expect(
        (persistedEvents.single as Map)['requirementId'],
        'reviewed-by-controller',
      );
    });
  });
}

FinancialReportReleaseSignOffAuditEvent _auditEvent({
  required String requirementId,
}) {
  return FinancialReportReleaseSignOffAuditEvent(
    id: 'audit-$requirementId',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    requirementId: requirementId,
    requirementTitle: 'Approved for release',
    role: FinancialReportReleaseSignOffRole.approver,
    action: FinancialReportReleaseSignOffAuditAction.signed,
    occurredAt: DateTime(2026, 2, 1, 10),
    actor: 'Finance Lead',
    status: FinancialReportReleaseSignOffStatus.signed,
    note: 'Signed.',
    evidenceReference: 'SIGNOFF-APPROVER',
  );
}

FinancialReportReleaseSignOffResolution _resolution({
  required String requirementId,
  FinancialReportReleaseSignOffStatus status =
      FinancialReportReleaseSignOffStatus.signed,
}) {
  return FinancialReportReleaseSignOffResolution(
    requirementId: requirementId,
    status: status,
    signer: 'Finance Lead',
    signedAt: DateTime(2026, 2, 1, 10),
    note: 'Signed.',
  );
}

class _MemoryReleaseSignOffStore
    implements FinancialReportReleaseSignOffSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemoryReleaseSignOffStore([this.snapshot]);

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}
