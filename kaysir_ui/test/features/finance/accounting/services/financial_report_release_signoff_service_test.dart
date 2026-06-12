import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_signoff_service.dart';

void main() {
  group('FinancialReportReleaseSignOffService', () {
    const service = FinancialReportReleaseSignOffService();

    test('builds the release sign-off chain from report policy', () {
      final requirements = service.buildRequirements(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile,
      );

      expect(requirements, hasLength(3));
      expect(
        requirements.first.role,
        FinancialReportReleaseSignOffRole.preparer,
      );
      expect(requirements[1].owner, 'Controller');
      expect(requirements.last.owner, 'Finance director');
      expect(requirements.last.reference, 'Indonesia release approval');
    });

    test('tracks signed, pending, returned, and release-ready state', () {
      final requirements = service.buildRequirements(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile,
      );
      final partialItems = service.buildReviewItems(
        requirements: requirements,
        resolutions: [
          _resolution(
            requirementId: 'prepared-by-accounting',
            status: FinancialReportReleaseSignOffStatus.signed,
          ),
          _resolution(
            requirementId: 'reviewed-by-controller',
            status: FinancialReportReleaseSignOffStatus.returned,
          ),
        ],
      );
      final signedItems = service.buildReviewItems(
        requirements: requirements,
        resolutions: [
          for (final requirement in requirements)
            _resolution(requirementId: requirement.id),
        ],
      );

      expect(service.signedCount(partialItems), 1);
      expect(service.pendingCount(partialItems), 1);
      expect(service.returnedCount(partialItems), 1);
      expect(service.releaseReady(partialItems), isFalse);
      expect(service.releaseReady(signedItems), isTrue);
      expect(service.completionRatio(signedItems), 1);
    });
  });
}

FinancialReportReleaseSignOffResolution _resolution({
  required String requirementId,
  FinancialReportReleaseSignOffStatus status =
      FinancialReportReleaseSignOffStatus.signed,
}) {
  return FinancialReportReleaseSignOffResolution(
    requirementId: requirementId,
    status: status,
    signer: 'Controller',
    signedAt: DateTime(2026, 2, 1, 10),
    note: 'Signed.',
  );
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir',
    frameworkName: 'SAK Indonesia (IFRS-converged)',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}
