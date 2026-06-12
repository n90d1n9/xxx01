import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_gate_service.dart';

void main() {
  group('FinancialReportReleaseGateService', () {
    const service = FinancialReportReleaseGateService();

    test('locks distribution until every release sign-off is complete', () {
      final reason = service.distributionLockedReason(
        signOffItems: [_signedSignOff, _pendingSignOff],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
      );

      expect(
        reason,
        'Complete all required release sign-offs before distribution.',
      );
      expect(
        service.canDistribute(
          signOffItems: [_signedSignOff, _pendingSignOff],
          packageIntegrity: _integrity(
            FinancialReportPackageIntegrityStatus.verified,
          ),
        ),
        isFalse,
      );
    });

    test('locks distribution when the closed package is not verified', () {
      final reason = service.distributionLockedReason(
        signOffItems: [_signedSignOff],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.notClosed,
        ),
      );

      expect(reason, 'Close the period to certify this report package.');
    });

    test(
      'allows distribution when sign-offs and package integrity are ready',
      () {
        expect(
          service.distributionLockedReason(
            signOffItems: [_signedSignOff],
            packageIntegrity: _integrity(
              FinancialReportPackageIntegrityStatus.verified,
            ),
          ),
          isNull,
        );
        expect(
          service.canDistribute(
            signOffItems: [_signedSignOff],
            packageIntegrity: _integrity(
              FinancialReportPackageIntegrityStatus.verified,
            ),
          ),
          isTrue,
        );
      },
    );

    test(
      'locks distribution until UKTM measures are approved and reconciled',
      () {
        final reason = service.distributionLockedReason(
          signOffItems: [_signedSignOff],
          packageIntegrity: _integrity(
            FinancialReportPackageIntegrityStatus.verified,
          ),
          managementMeasureReconciliations: const [
            FinancialReportManagementMeasureReconciliation(
              measure: FinancialReportManagementMeasure(
                id: 'uktm-operating-performance',
                label: 'management operating performance',
                owner: 'Controller',
                approvalStatus:
                    FinancialReportManagementMeasureApprovalStatus.draft,
              ),
              subtotalAmount: 3800,
              measureAmount: 3800,
              adjustmentTotal: 0,
            ),
          ],
        );

        expect(
          reason,
          'Approve 1 UKTM management measure(s) before distribution.',
        );
      },
    );
  });
}

final _signedSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('approved-for-release'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance Lead',
    signedAt: DateTime(2026, 2, 1, 10),
    note: 'Signed.',
  ),
);

final _pendingSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('reviewed-by-controller'),
);

FinancialReportReleaseSignOffRequirement _requirement(String id) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role: FinancialReportReleaseSignOffRole.approver,
    title: id,
    description: 'Release approval.',
    owner: 'Finance lead',
    reference: 'Release control',
  );
}

FinancialReportPackageIntegrity _integrity(
  FinancialReportPackageIntegrityStatus status,
) {
  return FinancialReportPackageIntegrity(
    status: status,
    closeRecord: null,
    currentFingerprint: const FinancialReportPackageFingerprint(
      algorithm: 'SHA-256',
      hash: 'abcdef1234567890',
    ),
  );
}
