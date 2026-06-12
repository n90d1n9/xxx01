import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_evidence_manifest.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('renders release evidence manifest status and artifact tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseEvidenceManifestPanel(summary: _summary),
        ),
      ),
    );

    expect(find.text('Release Evidence Manifest'), findsOneWidget);
    expect(find.text('Archive open'), findsOneWidget);
    expect(
      find.text(
        'Distribution register: 1/2 recipient(s) complete; 1 exception(s).',
      ),
      findsOneWidget,
    );
    expect(find.text('1 ready'), findsOneWidget);
    expect(find.text('1 attention'), findsOneWidget);
    expect(find.text('1 missing'), findsOneWidget);
    expect(find.text('Package fingerprint'), findsOneWidget);
    expect(find.text('Distribution register'), findsOneWidget);
    expect(find.text('Distribution audit trail'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<
          FinancialReportReleaseEvidenceManifestItem
        >,
      ),
      findsOneWidget,
    );
    expect(find.byType(FinancialReportTintedSurface), findsAtLeastNWidgets(3));

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(1 / 3, 0.001));
  });

  testWidgets('opens management measures from UKTM audit blocker', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseEvidenceManifestPanel(
            summary: _uktmBlockedSummary,
            onOpenManagementMeasures: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('UKTM audit trail'), findsOneWidget);
    expect(find.text('Open UKTM'), findsOneWidget);

    await tester.tap(find.text('Open UKTM'));
    await tester.pump();

    expect(opened, isTrue);
  });
}

const _summary = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.packageFingerprint,
      title: 'Package fingerprint',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'The displayed report package matches the closed package.',
      reference: 'ABCDEF123456',
    ),
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.distributionRegister,
      title: 'Distribution register',
      status: FinancialReportReleaseEvidenceStatus.attention,
      detail: '1/2 recipient(s) complete; 1 exception(s).',
      reference: 'Release recipients',
    ),
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.distributionAuditTrail,
      title: 'Distribution audit trail',
      status: FinancialReportReleaseEvidenceStatus.missing,
      detail: 'Capture distribution audit events for the release file.',
      reference: 'Release distribution audit',
    ),
  ],
  readyCount: 1,
  attentionCount: 1,
  missingCount: 1,
  archiveReady: false,
  completionRatio: 1 / 3,
  nextAction:
      'Distribution register: 1/2 recipient(s) complete; 1 exception(s).',
);

const _uktmBlockedSummary = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.managementMeasureAuditTrail,
      title: 'UKTM audit trail',
      status: FinancialReportReleaseEvidenceStatus.missing,
      detail: 'Capture UKTM approval audit events before archive.',
      reference: 'UKTM management measures audit',
    ),
  ],
  readyCount: 0,
  attentionCount: 0,
  missingCount: 1,
  archiveReady: false,
  completionRatio: 0,
  nextAction:
      'UKTM audit trail: Capture UKTM approval audit events before archive.',
);
