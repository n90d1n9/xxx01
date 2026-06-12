import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_readiness_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  group('financial report export readiness components', () {
    testWidgets('summarizes export readiness and coverage chips', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportExportReadinessPanel(pack: _reviewPack),
          ),
        ),
      );

      expect(find.text('Export Readiness'), findsOneWidget);
      expect(find.text('Review recommended'), findsOneWidget);
      expect(
        find.text(
          'Export is available, but open checks should be reviewed first.',
        ),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(AppStatusPill), findsOneWidget);
      expect(find.byType(FinancialReportPanelSurface), findsOneWidget);
      expect(find.text('1 statement(s)'), findsOneWidget);
      expect(find.text('1 schedule(s)'), findsOneWidget);
      expect(find.text('1 note(s)'), findsOneWidget);
      expect(find.text('2/3 checks'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));
    });

    testWidgets('summarizes release sign-off coverage when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportExportReadinessPanel(
              pack: _reviewPack,
              signOffItems: [_signedSignOff, _pendingSignOff],
              distributionItems: [
                _acknowledgedDistribution,
                _pendingDistribution,
              ],
            ),
          ),
        ),
      );

      expect(find.text('1/2 sign-off(s)'), findsOneWidget);
      expect(find.text('1/2 distribution(s)'), findsOneWidget);
    });

    testWidgets('exposes readiness labels and coverage item health', (
      tester,
    ) async {
      final items = financialReportExportCoverageItems(
        _draftPack,
        signOffItems: [_signedSignOff, _pendingSignOff],
        distributionItems: [_acknowledgedDistribution, _pendingDistribution],
      );

      expect(financialReportExportReadinessLabel(0.95), 'Ready to share');
      expect(financialReportExportReadinessLabel(0.72), 'Review recommended');
      expect(financialReportExportReadinessLabel(0.4), 'Needs review');
      expect(items.map((item) => item.label), contains('0 note(s)'));
      expect(items.map((item) => item.label), contains('1/2 sign-off(s)'));
      expect(items.map((item) => item.label), contains('1/2 distribution(s)'));
      expect(items.last.isHealthy, isFalse);
    });
  });
}

final _signedSignOff = FinancialReportReleaseSignOffItem(
  requirement: _signOffRequirement('prepared-by-accounting'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'prepared-by-accounting',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Controller',
    signedAt: DateTime(2026, 2, 1, 10),
    note: 'Signed.',
  ),
);

final _pendingSignOff = FinancialReportReleaseSignOffItem(
  requirement: _signOffRequirement('approved-for-release'),
);

final _acknowledgedDistribution = FinancialReportReleaseDistributionItem(
  recipient: _distributionRecipient('board-owners', requiresAck: true),
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 1, 10),
    note: 'Acknowledged.',
  ),
);

final _pendingDistribution = FinancialReportReleaseDistributionItem(
  recipient: _distributionRecipient('auditor', requiresAck: true),
);

FinancialReportReleaseDistributionRecipient _distributionRecipient(
  String id, {
  required bool requiresAck,
}) {
  return FinancialReportReleaseDistributionRecipient(
    id: id,
    name: id,
    role: 'Recipient',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    requiresAcknowledgement: requiresAck,
    dueDate: DateTime(2026, 2, 3),
    purpose: 'Release distribution.',
  );
}

FinancialReportReleaseSignOffRequirement _signOffRequirement(String id) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role:
        id == 'prepared-by-accounting'
            ? FinancialReportReleaseSignOffRole.preparer
            : FinancialReportReleaseSignOffRole.approver,
    title: id,
    description: 'Release sign-off.',
    owner: 'Controller',
    reference: 'Internal control',
  );
}

final _reviewPack = FinancialReportPack(
  entityName: 'Kaysir Advisory',
  frameworkName: 'SAK Indonesia',
  jurisdiction: 'Indonesia',
  presentationCurrency: 'IDR',
  periodLabel: 'FY 2026',
  asOfLabel: '31 Dec 2026',
  periodStart: DateTime(2026),
  periodEnd: DateTime(2026, 12, 31),
  generatedAt: DateTime(2026, 12, 31, 18),
  statements: const [
    FinancialReportStatement(
      kind: FinancialReportStatementKind.financialPosition,
      title: 'Statement of Financial Position',
      subtitle: 'As of 31 Dec 2026',
      lines: [],
    ),
  ],
  supportingSchedules: const [
    FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.cashRollForward,
      title: 'Cash roll-forward',
      subtitle: 'Cash support',
      totalLabel: 'Closing cash',
      lines: [],
    ),
  ],
  notes: const [
    FinancialReportDisclosureNote(
      number: '1',
      title: 'Basis',
      body: 'Prepared under SAK Indonesia.',
    ),
  ],
  complianceItems: const [
    FinancialReportComplianceItem(
      id: 'ready',
      title: 'Primary statements prepared',
      description: 'All primary statements are available.',
      standardReference: 'PSAK 1',
      isSatisfied: true,
    ),
    FinancialReportComplianceItem(
      id: 'cash-flow',
      title: 'Cash flow disclosure prepared',
      description: 'Cash flow disclosure is available.',
      standardReference: 'PSAK 207',
      isSatisfied: true,
    ),
    FinancialReportComplianceItem(
      id: 'review',
      title: 'Management review pending',
      description: 'Review sign-off is still pending.',
      standardReference: 'Internal control',
      isSatisfied: false,
    ),
  ],
  metrics: const [],
);

final _draftPack = FinancialReportPack(
  entityName: 'Kaysir Advisory',
  frameworkName: 'SAK Indonesia',
  jurisdiction: 'Indonesia',
  presentationCurrency: 'IDR',
  periodLabel: 'FY 2026',
  asOfLabel: '31 Dec 2026',
  periodStart: DateTime(2026),
  periodEnd: DateTime(2026, 12, 31),
  generatedAt: DateTime(2026, 12, 31, 18),
  statements: const [],
  notes: const [],
  complianceItems: const [],
  metrics: const [],
);
