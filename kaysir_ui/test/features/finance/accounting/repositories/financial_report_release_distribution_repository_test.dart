import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_release_distribution_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_report_release_distribution_repository.dart';

void main() {
  group('FinancialReportReleaseDistributionRepository', () {
    test('in-memory repository upserts and removes resolutions', () {
      final repository = InMemoryFinancialReportReleaseDistributionRepository();

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(
          recipientId: 'board-owners',
          status: FinancialReportReleaseDistributionStatus.sent,
        ),
      );
      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(
          recipientId: 'board-owners',
          status: FinancialReportReleaseDistributionStatus.acknowledged,
        ),
      );
      repository.appendAuditEvent(_auditEvent(recipientId: 'board-owners'));

      final resolutions =
          repository.loadResolutions()['20260101-20260131'] ?? const [];
      expect(resolutions, hasLength(1));
      expect(
        resolutions.single.status,
        FinancialReportReleaseDistributionStatus.acknowledged,
      );
      expect(repository.loadAuditEvents(), hasLength(1));
      expect(repository.loadAuditEvents().single.id, 'audit-board-owners');

      repository.removeResolution(
        periodKey: '20260101-20260131',
        recipientId: 'board-owners',
      );

      expect(repository.loadResolutions(), isEmpty);
      expect(repository.loadAuditEvents(), hasLength(1));
    });

    test('local repository hydrates stored distribution resolutions', () async {
      final store = _MemoryReleaseDistributionStore({
        'schemaVersion': 1,
        'resolutionsByPeriod': {
          '20260101-20260131': [
            _resolution(recipientId: 'external-auditor').toJson(),
          ],
        },
        'auditEvents': [_auditEvent(recipientId: 'external-auditor').toJson()],
      });
      final repository = LocalFinancialReportReleaseDistributionRepository(
        store: store,
      );

      await repository.hydrate();

      expect(
        repository.loadResolutions()['20260101-20260131']?.single.recipientId,
        'external-auditor',
      );
      expect(
        repository.loadAuditEvents().single.recipientId,
        'external-auditor',
      );
    });

    test('local repository persists distribution updates', () async {
      final store = _MemoryReleaseDistributionStore();
      final repository = LocalFinancialReportReleaseDistributionRepository(
        store: store,
      );

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(recipientId: 'tax-statutory'),
      );
      repository.appendAuditEvent(_auditEvent(recipientId: 'tax-statutory'));
      await repository.persist();

      final rawPeriods = store.snapshot!['resolutionsByPeriod'] as Map;
      final persisted = (rawPeriods['20260101-20260131'] as List).single as Map;
      final persistedEvents = store.snapshot!['auditEvents'] as List;
      expect(persisted['recipientId'], 'tax-statutory');
      expect((persistedEvents.single as Map)['recipientId'], 'tax-statutory');
    });
  });
}

FinancialReportReleaseDistributionAuditEvent _auditEvent({
  required String recipientId,
}) {
  return FinancialReportReleaseDistributionAuditEvent(
    id: 'audit-$recipientId',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    recipientId: recipientId,
    recipientName: 'Board / owners',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    action: FinancialReportReleaseDistributionAuditAction.acknowledged,
    occurredAt: DateTime(2026, 2, 1, 10),
    actor: 'Controller',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    note: 'Acknowledged.',
    evidenceReference: 'DIST-$recipientId',
  );
}

FinancialReportReleaseDistributionResolution _resolution({
  required String recipientId,
  FinancialReportReleaseDistributionStatus status =
      FinancialReportReleaseDistributionStatus.sent,
}) {
  return FinancialReportReleaseDistributionResolution(
    recipientId: recipientId,
    status: status,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 1, 10),
    note: 'Distributed.',
    evidenceReference: 'DIST-$recipientId',
  );
}

class _MemoryReleaseDistributionStore
    implements FinancialReportReleaseDistributionSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemoryReleaseDistributionStore([this.snapshot]);

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}
