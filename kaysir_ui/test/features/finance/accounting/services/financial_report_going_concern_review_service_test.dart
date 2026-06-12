import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_going_concern_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_going_concern_review_service.dart';

void main() {
  group('FinancialReportGoingConcernReviewService', () {
    const service = FinancialReportGoingConcernReviewService();

    test('summarizes a supportable going-concern basis', () {
      final summary = service.summarize(
        pack: _pack(
          totalAssets: 1000,
          totalLiabilities: 300,
          totalEquity: 700,
          revenue: 1000,
          profitForPeriod: 120,
          operatingCashFlow: 200,
          cash: 500,
        ),
        disclosureReviewItems: [_approvedManagementAssertion],
        signOffItems: [_signedApprover],
      );

      expect(summary.standardReference, 'PSAK 201 / IAS 1');
      expect(summary.satisfactoryCount, 6);
      expect(summary.watchCount, 0);
      expect(summary.attentionCount, 0);
      expect(summary.materialUncertaintyCount, 0);
      expect(summary.incompleteCount, 0);
      expect(summary.readinessRatio, 1);
      expect(summary.needsAttention, isFalse);
      expect(summary.conclusion, 'Going-concern basis appears supportable.');
      expect(
        summary.nextAction,
        'Going-concern review is ready for report release.',
      );
    });

    test('flags material uncertainty signals and incomplete conclusion', () {
      final summary = service.summarize(
        pack: _pack(
          totalAssets: 1000,
          totalLiabilities: 1200,
          totalEquity: -200,
          revenue: 1000,
          profitForPeriod: -200,
          operatingCashFlow: -300,
          cash: -100,
        ),
        disclosureReviewItems: const [],
        signOffItems: const [],
      );

      expect(summary.satisfactoryCount, 0);
      expect(summary.watchCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.materialUncertaintyCount, 3);
      expect(summary.incompleteCount, 1);
      expect(summary.hasMaterialUncertainty, isTrue);
      expect(summary.needsAttention, isTrue);
      expect(
        summary.conclusion,
        'Material uncertainty indicators require management assessment.',
      );
      expect(summary.nextAction, contains('Cash runway and liquidity buffer'));
      expect(
        summary.items.map((item) => item.status),
        contains(FinancialReportGoingConcernReviewStatus.materialUncertainty),
      );
    });
  });
}

FinancialReportPack _pack({
  required double totalAssets,
  required double totalLiabilities,
  required double totalEquity,
  required double revenue,
  required double profitForPeriod,
  required double operatingCashFlow,
  required double cash,
}) {
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
    statements: [
      FinancialReportStatement(
        kind: FinancialReportStatementKind.financialPosition,
        title: 'Statement of Financial Position',
        subtitle: 'As of Jan 31, 2026',
        lines: [
          FinancialReportLine(label: 'Total assets', amount: totalAssets),
          FinancialReportLine(
            label: 'Total liabilities',
            amount: totalLiabilities,
          ),
          FinancialReportLine(label: 'Total equity', amount: totalEquity),
        ],
      ),
      FinancialReportStatement(
        kind: FinancialReportStatementKind.profitOrLossAndOci,
        title: 'Profit or Loss and OCI',
        subtitle: 'For Jan 2026',
        lines: [
          FinancialReportLine(label: 'Total revenue', amount: revenue),
          FinancialReportLine(
            label: 'Profit (loss) for the period',
            amount: profitForPeriod,
          ),
        ],
      ),
      FinancialReportStatement(
        kind: FinancialReportStatementKind.cashFlows,
        title: 'Statement of Cash Flows',
        subtitle: 'For Jan 2026',
        lines: [
          FinancialReportLine(
            label: 'Net cash from operating activities',
            amount: operatingCashFlow,
          ),
          FinancialReportLine(
            label: 'Cash and cash equivalents at end of period',
            amount: cash,
          ),
        ],
      ),
    ],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}

final _signedApprover = FinancialReportReleaseSignOffItem(
  requirement: const FinancialReportReleaseSignOffRequirement(
    id: 'approved-for-release',
    role: FinancialReportReleaseSignOffRole.approver,
    title: 'Approved for release',
    description: 'Approve report pack release.',
    owner: 'Finance director',
    reference: 'Release approval',
  ),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance director',
    signedAt: DateTime(2026, 2, 3),
    note: 'Going-concern conclusion approved.',
    evidenceReference: 'GC-APPROVAL-001',
  ),
);

final _approvedManagementAssertion = FinancialReportDisclosureReviewItem(
  requirement: const FinancialReportDisclosureRequirement(
    id: 'policy-management-assertions',
    noteNumber: '1',
    title: 'Management assertions',
    description: 'Confirm the basis and judgments for report release.',
    standardReferences: ['PSAK 201 / IAS 1'],
    owner: 'Controller',
    priority: FinancialReportDisclosureRequirementPriority.required,
  ),
  resolution: FinancialReportDisclosureResolution(
    requirementId: 'policy-management-assertions',
    status: FinancialReportDisclosureResolutionStatus.approved,
    reviewer: 'Controller',
    reviewedAt: DateTime(2026, 2, 2),
    note: 'Management assertion approved.',
    evidenceReference: 'GC-MGMT-001',
  ),
);
