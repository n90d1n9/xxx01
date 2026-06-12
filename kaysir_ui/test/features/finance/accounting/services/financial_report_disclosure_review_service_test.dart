import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_disclosure_review_service.dart';

void main() {
  group('FinancialReportDisclosureReviewService', () {
    const service = FinancialReportDisclosureReviewService();

    test('builds disclosure requirements from report notes and policy', () {
      final requirements = service.buildRequirements(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile,
      );

      expect(requirements, hasLength(3));
      expect(requirements.first.id, 'note-1-basis-of-preparation');
      expect(requirements.first.owner, 'Controller');
      expect(requirements[1].owner, 'Tax accountant');
      expect(requirements.last.id, 'policy-management-assertions');
    });

    test('adds a currency translation requirement when currencies differ', () {
      final requirements = service.buildRequirements(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile.copyWith(
          functionalCurrency: 'IDR',
          presentationCurrency: 'USD',
        ),
      );

      expect(
        requirements.map((item) => item.id),
        contains('policy-currency-translation'),
      );
    });

    test('keeps required disclosures open until prepared or approved', () {
      final requirement =
          service
              .buildRequirements(
                pack: _pack(),
                policy: AccountingPolicyProfiles.defaultProfile,
              )
              .first;

      final openItems = service.buildReviewItems(requirements: [requirement]);
      final approvedItems = service.buildReviewItems(
        requirements: [requirement],
        resolutions: [
          FinancialReportDisclosureResolution(
            requirementId: requirement.id,
            status: FinancialReportDisclosureResolutionStatus.approved,
            reviewer: 'Controller',
            reviewedAt: DateTime(2026, 2, 1),
            note: 'Approved for release.',
          ),
        ],
      );

      expect(openItems.single.needsReview, isTrue);
      expect(approvedItems.single.needsReview, isFalse);
      expect(service.unresolvedRequiredCount(approvedItems), 0);
      expect(service.approvedCount(approvedItems), 1);
    });
  });
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
    notes: const [
      FinancialReportDisclosureNote(
        number: '1',
        title: 'Basis of Preparation',
        body: 'Prepared using accrual basis and SAK presentation concepts.',
        standardReferences: ['PSAK 201'],
      ),
      FinancialReportDisclosureNote(
        number: '2',
        title: 'Income Tax',
        body: 'Income tax expense follows current Indonesian tax rules.',
        standardReferences: ['PSAK 212'],
      ),
    ],
    complianceItems: const [],
    metrics: const [],
  );
}
