import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_management_measure_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_report_management_measure_repository.dart';

void main() {
  group('FinancialReportManagementMeasureRepository', () {
    test('in-memory repository upserts and removes period measures', () {
      final repository = InMemoryFinancialReportManagementMeasureRepository();

      repository.upsertMeasure(
        periodKey: '20260101-20260131',
        measure: _measure(id: 'uktm-operating', label: 'operating'),
      );
      repository.upsertMeasure(
        periodKey: '20260101-20260131',
        measure: _measure(
          id: 'uktm-operating',
          label: 'updated operating',
          owner: 'Controller',
        ),
      );
      repository.appendAuditEvent(_auditEvent(measureId: 'uktm-operating'));

      final measures =
          repository.loadMeasures()['20260101-20260131'] ?? const [];
      expect(measures, hasLength(1));
      expect(measures.single.label, 'updated operating');
      expect(measures.single.owner, 'Controller');
      expect(repository.loadAuditEvents(), hasLength(1));
      expect(repository.loadAuditEvents().single.measureId, 'uktm-operating');

      repository.removeMeasure(
        periodKey: '20260101-20260131',
        measureId: 'uktm-operating',
      );

      expect(repository.loadMeasures(), isEmpty);
      expect(repository.loadAuditEvents(), hasLength(1));
    });

    test('local repository hydrates stored management measures', () async {
      final store = _MemoryManagementMeasureStore({
        'schemaVersion': 1,
        'measuresByPeriod': {
          '20260101-20260131': [
            _measure(id: 'uktm-adjusted', label: 'adjusted').toJson(),
          ],
        },
        'auditEvents': [_auditEvent(measureId: 'uktm-adjusted').toJson()],
      });
      final repository = LocalFinancialReportManagementMeasureRepository(
        store: store,
      );

      await repository.hydrate();

      expect(
        repository.loadMeasures()['20260101-20260131']?.single.id,
        'uktm-adjusted',
      );
      expect(repository.loadAuditEvents().single.measureId, 'uktm-adjusted');
    });

    test('local repository persists management measure updates', () async {
      final store = _MemoryManagementMeasureStore();
      final repository = LocalFinancialReportManagementMeasureRepository(
        store: store,
      );

      repository.upsertMeasure(
        periodKey: '20260101-20260131',
        measure: _measure(id: 'uktm-adjusted', label: 'adjusted'),
      );
      repository.appendAuditEvent(_auditEvent(measureId: 'uktm-adjusted'));
      await repository.persist();

      final rawPeriods = store.snapshot!['measuresByPeriod'] as Map;
      final persisted = (rawPeriods['20260101-20260131'] as List).single as Map;
      final persistedEvents = store.snapshot!['auditEvents'] as List;
      expect(persisted['id'], 'uktm-adjusted');
      expect(persisted['approvalStatus'], 'draft');
      expect((persistedEvents.single as Map)['measureId'], 'uktm-adjusted');
    });
  });
}

FinancialReportManagementMeasure _measure({
  required String id,
  required String label,
  String owner = 'Financial reporting lead',
}) {
  return FinancialReportManagementMeasure(
    id: id,
    label: label,
    owner: owner,
    amountOverride: 4000,
    adjustments: const [
      FinancialReportManagementMeasureAdjustment(
        label: 'Non-recurring setup cost',
        amount: 200,
        sourceReference: 'MGMT-ADJ-001',
      ),
    ],
  );
}

FinancialReportManagementMeasureAuditEvent _auditEvent({
  required String measureId,
}) {
  return FinancialReportManagementMeasureAuditEvent(
    id: 'audit-$measureId',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    measureId: measureId,
    measureLabel: 'adjusted operating performance',
    action: FinancialReportManagementMeasureAuditAction.saved,
    occurredAt: DateTime(2026, 2, 1, 10),
    actor: 'Controller',
    status: FinancialReportManagementMeasureApprovalStatus.draft,
    note: 'Saved.',
  );
}

class _MemoryManagementMeasureStore
    implements FinancialReportManagementMeasureSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemoryManagementMeasureStore([this.snapshot]);

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}
