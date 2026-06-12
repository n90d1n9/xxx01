import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_subsequent_event_review.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_subsequent_event_review_service.dart';

void main() {
  group('FinancialReportSubsequentEventReviewService', () {
    const service = FinancialReportSubsequentEventReviewService();

    test('flags blocked and overdue subsequent-event checks', () {
      final summary = service.summarize(
        pack: _pack(),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        signOffItems: [_returnedReviewer, _pendingApprover],
        disclosureReviewItems: [_deferredDisclosure],
        distributionItems: const [],
        asOf: DateTime(2026, 2, 10),
      );

      expect(summary.reviewWindowDays, 3);
      expect(summary.completeCount, 1);
      expect(summary.blockedCount, 3);
      expect(summary.overdueCount, 2);
      expect(
        summary.nextAction,
        contains('Management subsequent-event inquiry'),
      );
      expect(
        summary.items.map((item) => item.status),
        contains(FinancialReportSubsequentEventReviewStatus.blocked),
      );
    });

    test('marks review complete through authorization for issue', () {
      final summary = service.summarize(
        pack: _pack(),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        signOffItems: [_signedReviewer, _signedApprover],
        disclosureReviewItems: [_approvedDisclosure],
        distributionItems: const [],
        asOf: DateTime(2026, 2, 3),
      );

      expect(summary.authorizationTargetDate, DateTime(2026, 2, 3));
      expect(summary.reviewWindowDays, 3);
      expect(summary.completeCount, 6);
      expect(summary.isComplete, isTrue);
      expect(
        summary.nextAction,
        'Subsequent events review is complete through authorization for issue.',
      );
    });
  });
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Demo',
    frameworkName: 'SAK Indonesia / IFRS aligned',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1, 9),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
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

final _returnedReviewer = FinancialReportReleaseSignOffItem(
  requirement: _requirement(
    id: 'reviewed-by-controller',
    role: FinancialReportReleaseSignOffRole.reviewer,
  ),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'reviewed-by-controller',
    status: FinancialReportReleaseSignOffStatus.returned,
    signer: 'Controller',
    signedAt: DateTime(2026, 2, 2),
    note: 'Subsequent event inquiry needs follow-up.',
  ),
);

final _signedReviewer = FinancialReportReleaseSignOffItem(
  requirement: _requirement(
    id: 'reviewed-by-controller',
    role: FinancialReportReleaseSignOffRole.reviewer,
  ),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'reviewed-by-controller',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Controller',
    signedAt: DateTime(2026, 2, 2),
    note: 'Management inquiry completed.',
    evidenceReference: 'SE-REVIEW-001',
  ),
);

final _pendingApprover = FinancialReportReleaseSignOffItem(
  requirement: _requirement(
    id: 'approved-for-release',
    role: FinancialReportReleaseSignOffRole.approver,
  ),
);

final _signedApprover = FinancialReportReleaseSignOffItem(
  requirement: _requirement(
    id: 'approved-for-release',
    role: FinancialReportReleaseSignOffRole.approver,
  ),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance director',
    signedAt: DateTime(2026, 2, 3),
    note: 'Authorized for issue.',
    evidenceReference: 'AUTH-001',
  ),
);

FinancialReportReleaseSignOffRequirement _requirement({
  required String id,
  required FinancialReportReleaseSignOffRole role,
}) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role: role,
    title: id,
    description: 'Release sign-off.',
    owner:
        role == FinancialReportReleaseSignOffRole.reviewer
            ? 'Controller'
            : 'Finance director',
    reference: 'Release approval',
  );
}

final _deferredDisclosure = FinancialReportDisclosureReviewItem(
  requirement: _disclosureRequirement,
  resolution: FinancialReportDisclosureResolution(
    requirementId: 'note-1',
    status: FinancialReportDisclosureResolutionStatus.deferred,
    reviewer: 'Controller',
    reviewedAt: DateTime(2026, 2, 2),
    note: 'Need subsequent event assessment.',
  ),
);

final _approvedDisclosure = FinancialReportDisclosureReviewItem(
  requirement: _disclosureRequirement,
  resolution: FinancialReportDisclosureResolution(
    requirementId: 'note-1',
    status: FinancialReportDisclosureResolutionStatus.approved,
    reviewer: 'Controller',
    reviewedAt: DateTime(2026, 2, 2),
    note: 'Disclosure approved.',
    evidenceReference: 'DISC-001',
  ),
);

const _disclosureRequirement = FinancialReportDisclosureRequirement(
  id: 'note-1',
  noteNumber: '1',
  title: 'Events after reporting period',
  description: 'Review subsequent events.',
  standardReferences: ['PSAK 210 / IAS 10'],
  owner: 'Controller',
  priority: FinancialReportDisclosureRequirementPriority.required,
);
