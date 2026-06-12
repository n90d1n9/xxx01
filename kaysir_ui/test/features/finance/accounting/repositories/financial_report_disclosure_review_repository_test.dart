import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_disclosure_review_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_financial_report_disclosure_review_repository.dart';

void main() {
  group('FinancialReportDisclosureReviewRepository', () {
    test('in-memory repository upserts and removes review resolutions', () {
      final repository = InMemoryFinancialReportDisclosureReviewRepository();

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(
          requirementId: 'note-2-income-tax',
          status: FinancialReportDisclosureResolutionStatus.prepared,
        ),
      );
      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(
          requirementId: 'note-2-income-tax',
          status: FinancialReportDisclosureResolutionStatus.approved,
        ),
      );

      final resolutions =
          repository.loadResolutions()['20260101-20260131'] ?? const [];
      expect(resolutions, hasLength(1));
      expect(
        resolutions.single.status,
        FinancialReportDisclosureResolutionStatus.approved,
      );

      repository.removeResolution(
        periodKey: '20260101-20260131',
        requirementId: 'note-2-income-tax',
      );

      expect(repository.loadResolutions(), isEmpty);
    });

    test('local repository hydrates stored disclosure reviews', () async {
      final store = _MemoryDisclosureReviewStore({
        'schemaVersion': 1,
        'resolutionsByPeriod': {
          '20260101-20260131': [
            _resolution(requirementId: 'note-1-basis').toJson(),
          ],
        },
      });
      final repository = LocalFinancialReportDisclosureReviewRepository(
        store: store,
      );

      await repository.hydrate();

      expect(
        repository.loadResolutions()['20260101-20260131']?.single.requirementId,
        'note-1-basis',
      );
    });

    test('local repository persists disclosure review updates', () async {
      final store = _MemoryDisclosureReviewStore();
      final repository = LocalFinancialReportDisclosureReviewRepository(
        store: store,
      );

      repository.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: _resolution(requirementId: 'policy-management-assertions'),
      );
      await repository.persist();

      final rawPeriods = store.snapshot!['resolutionsByPeriod'] as Map;
      final persisted = (rawPeriods['20260101-20260131'] as List).single as Map;
      expect(persisted['requirementId'], 'policy-management-assertions');
    });
  });
}

FinancialReportDisclosureResolution _resolution({
  required String requirementId,
  FinancialReportDisclosureResolutionStatus status =
      FinancialReportDisclosureResolutionStatus.approved,
}) {
  return FinancialReportDisclosureResolution(
    requirementId: requirementId,
    status: status,
    reviewer: 'Controller',
    reviewedAt: DateTime(2026, 2, 1, 10),
    note: 'Reviewed.',
  );
}

class _MemoryDisclosureReviewStore
    implements FinancialReportDisclosureReviewSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemoryDisclosureReviewStore([this.snapshot]);

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}
