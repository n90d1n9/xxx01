import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_management_measure_audit_service.dart';

void main() {
  group('FinancialReportManagementMeasureAuditService', () {
    test('creates save, approval, removal, and reset events', () {
      var sequence = 0;
      final service = FinancialReportManagementMeasureAuditService(
        nextId: () => 'audit-${++sequence}',
      );

      final saved = service.measureSaved(
        periodKey: _periodKey,
        periodLabel: 'Jan 2026',
        measure: _measure,
        actor: 'Controller',
        occurredAt: DateTime(2026, 2, 1, 9),
      );
      final approved = service.statusChanged(
        periodKey: _periodKey,
        periodLabel: 'Jan 2026',
        measure: _measure.copyWith(
          approvalStatus:
              FinancialReportManagementMeasureApprovalStatus.approved,
        ),
        actor: 'Finance lead',
        note: 'Approved for release.',
        occurredAt: DateTime(2026, 2, 1, 10),
      );
      final removed = service.removed(
        periodKey: _periodKey,
        periodLabel: 'Jan 2026',
        measure: _measure,
        actor: 'Controller',
        occurredAt: DateTime(2026, 2, 1, 11),
      );
      final reset = service.reset(
        periodKey: _periodKey,
        periodLabel: 'Jan 2026',
        actor: 'Controller',
        occurredAt: DateTime(2026, 2, 1, 12),
      );

      expect(saved.id, 'audit-1');
      expect(saved.action, FinancialReportManagementMeasureAuditAction.saved);
      expect(
        saved.status,
        FinancialReportManagementMeasureApprovalStatus.draft,
      );
      expect(approved.id, 'audit-2');
      expect(
        approved.action,
        FinancialReportManagementMeasureAuditAction.approved,
      );
      expect(approved.actor, 'Finance lead');
      expect(
        removed.action,
        FinancialReportManagementMeasureAuditAction.removed,
      );
      expect(reset.measureId, 'uktm-register');

      final sorted = service.newestFirst([saved, reset, approved, removed]);
      expect(sorted.first, reset);
      expect(sorted.last, saved);
    });
  });
}

const _periodKey = '20260101-20260131';

const _measure = FinancialReportManagementMeasure(
  id: 'uktm-adjusted',
  label: 'adjusted operating performance',
  owner: 'Controller',
);
