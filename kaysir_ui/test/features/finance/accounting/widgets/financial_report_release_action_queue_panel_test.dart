import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_action_queue.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  testWidgets('renders release action queue priorities and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseActionQueuePanel(summary: _summary),
        ),
      ),
    );

    expect(find.text('Release Action Queue'), findsOneWidget);
    expect(find.text('3 open action(s)'), findsOneWidget);
    expect(find.text('1 critical'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('1 high'), findsOneWidget);
    expect(
      find.text('Clear overdue distribution: Board / owners'),
      findsOneWidget,
    );
    expect(find.text('SPT Tahunan Badan support pack'), findsOneWidget);
    expect(find.textContaining('Governance recipients'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<FinancialReportReleaseActionItem>,
      ),
      findsOneWidget,
    );
  });

  testWidgets('opens a destination action from a release queue tile', (
    tester,
  ) async {
    FinancialReportReleaseActionItem? openedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseActionQueuePanel(
            summary: _actionableSummary,
            onOpenAction: (item) => openedAction = item,
          ),
        ),
      ),
    );

    expect(find.text('Open UKTM'), findsOneWidget);

    await tester.tap(find.text('Open UKTM'));
    await tester.pump();

    expect(openedAction?.id, 'management-measure-release-auditTrail');
    expect(
      openedAction?.destination,
      FinancialReportReleaseActionDestination.managementMeasureAuditTrail,
    );
  });

  testWidgets('labels local release section destinations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FinancialReportReleaseActionQueuePanel(
              summary: _localActionableSummary,
              onOpenAction: _noopOpenAction,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Open Sign-off'), findsOneWidget);
    expect(find.text('Open Evidence'), findsOneWidget);
    expect(find.text('Open Report pack'), findsOneWidget);
    expect(find.text('Open Distribution'), findsOneWidget);
    expect(find.text('Open Archive'), findsOneWidget);
    expect(find.text('Open Retention'), findsOneWidget);
    expect(find.text('Open Filing'), findsOneWidget);
  });

  testWidgets('renders a clear state when no actions remain', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseActionQueuePanel(summary: _clearSummary),
        ),
      ),
    );

    expect(find.text('Queue clear'), findsOneWidget);
    expect(find.text('No open release actions.'), findsOneWidget);
  });
}

void _noopOpenAction(FinancialReportReleaseActionItem item) {}

final _summary = FinancialReportReleaseActionQueueSummary(
  items: [
    FinancialReportReleaseActionItem(
      id: 'distribution-board-owners',
      area: FinancialReportReleaseActionArea.distribution,
      priority: FinancialReportReleaseActionPriority.critical,
      title: 'Clear overdue distribution: Board / owners',
      owner: 'Governance recipients',
      dueDate: DateTime(2026, 2, 3),
      detail: 'Board package acknowledgement is overdue.',
      reference: 'Secure link / acknowledgement required',
      blocked: true,
    ),
    FinancialReportReleaseActionItem(
      id: 'statutory-tax',
      area: FinancialReportReleaseActionArea.statutoryFiling,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'SPT Tahunan Badan support pack',
      owner: 'Tax / statutory archive',
      dueDate: DateTime(2026, 5, 31),
      detail: 'Prepare annual corporate return support.',
      reference: 'DJP annual tax support',
    ),
    const FinancialReportReleaseActionItem(
      id: 'archive-register',
      area: FinancialReportReleaseActionArea.archive,
      priority: FinancialReportReleaseActionPriority.normal,
      title: 'Create release archive register',
      owner: 'Finance archive owner',
      dueDate: null,
      detail: 'Archive the release evidence pack.',
      reference: '6/6 evidence item(s) ready',
    ),
  ],
  criticalCount: 1,
  highCount: 1,
  overdueCount: 1,
  blockedCount: 1,
  nextAction:
      'Clear overdue distribution: Board / owners: Board package acknowledgement is overdue.',
);

const _actionableSummary = FinancialReportReleaseActionQueueSummary(
  items: [
    FinancialReportReleaseActionItem(
      id: 'management-measure-release-auditTrail',
      area: FinancialReportReleaseActionArea.managementMeasures,
      priority: FinancialReportReleaseActionPriority.critical,
      title: 'Complete UKTM audit trail',
      owner: 'Finance controller',
      dueDate: null,
      detail: 'Create UKTM approval or review audit evidence before archive.',
      reference: 'UKTM release evidence / No event',
      blocked: true,
      destination:
          FinancialReportReleaseActionDestination.managementMeasureAuditTrail,
    ),
  ],
  criticalCount: 1,
  highCount: 0,
  overdueCount: 0,
  blockedCount: 1,
  nextAction:
      'Complete UKTM audit trail: Create UKTM approval or review audit evidence before archive.',
);

const _localActionableSummary = FinancialReportReleaseActionQueueSummary(
  items: [
    FinancialReportReleaseActionItem(
      id: 'package-integrity',
      area: FinancialReportReleaseActionArea.packageIntegrity,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'Certify report package',
      owner: 'Controller',
      dueDate: null,
      detail: 'Report package requires verification.',
      reference: 'Changed',
      blocked: true,
      destination: FinancialReportReleaseActionDestination.reportPack,
    ),
    FinancialReportReleaseActionItem(
      id: 'signoff-review',
      area: FinancialReportReleaseActionArea.signOff,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'Resolve returned sign-off: Controller review',
      owner: 'Controller',
      dueDate: null,
      detail: 'Variance explanation needs follow-up.',
      reference: 'Reviewer / Release approval',
      blocked: true,
      destination: FinancialReportReleaseActionDestination.signOff,
    ),
    FinancialReportReleaseActionItem(
      id: 'evidence-signoffAuditTrail',
      area: FinancialReportReleaseActionArea.evidenceManifest,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'Prepare Sign-off audit trail',
      owner: 'Finance controller',
      dueDate: null,
      detail: 'Capture sign-off audit evidence.',
      reference: 'Release audit',
      blocked: true,
      destination: FinancialReportReleaseActionDestination.evidenceManifest,
    ),
    FinancialReportReleaseActionItem(
      id: 'distribution-board',
      area: FinancialReportReleaseActionArea.distribution,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'Clear overdue distribution: Board / owners',
      owner: 'Governance recipients',
      dueDate: null,
      detail: 'Governance distribution evidence.',
      reference: 'Secure link',
      blocked: true,
      destination: FinancialReportReleaseActionDestination.distribution,
    ),
    FinancialReportReleaseActionItem(
      id: 'archive-register',
      area: FinancialReportReleaseActionArea.archive,
      priority: FinancialReportReleaseActionPriority.normal,
      title: 'Create release archive register',
      owner: 'Finance archive owner',
      dueDate: null,
      detail: 'Archive the release evidence pack.',
      reference: '2/2 evidence item(s) ready',
      destination: FinancialReportReleaseActionDestination.archive,
    ),
    FinancialReportReleaseActionItem(
      id: 'retention-review',
      area: FinancialReportReleaseActionArea.retention,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'Complete archive retention review',
      owner: 'Finance archive owner',
      dueDate: null,
      detail: 'Archive custody review is due.',
      reference: 'Jan 2026',
      destination: FinancialReportReleaseActionDestination.retention,
    ),
    FinancialReportReleaseActionItem(
      id: 'statutory-tax',
      area: FinancialReportReleaseActionArea.statutoryFiling,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'SPT Tahunan Badan support pack',
      owner: 'Tax / statutory archive',
      dueDate: null,
      detail: 'Prepare annual corporate return support.',
      reference: 'DJP annual tax support',
      destination: FinancialReportReleaseActionDestination.statutoryFiling,
    ),
  ],
  criticalCount: 0,
  highCount: 5,
  overdueCount: 0,
  blockedCount: 4,
  nextAction:
      'Resolve returned sign-off: Controller review: Variance explanation needs follow-up.',
);

const _clearSummary = FinancialReportReleaseActionQueueSummary(
  items: [],
  criticalCount: 0,
  highCount: 0,
  overdueCount: 0,
  blockedCount: 0,
  nextAction: 'Release action queue is clear.',
);
