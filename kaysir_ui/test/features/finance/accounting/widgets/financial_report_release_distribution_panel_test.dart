import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_action_card_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('FinancialReportReleaseDistributionPanel', () {
    testWidgets('renders metrics and distribution actions', (tester) async {
      FinancialReportReleaseDistributionStatus? selectedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 900,
                child: FinancialReportReleaseDistributionPanel(
                  items: [_item()],
                  completedCount: 0,
                  acknowledgedCount: 0,
                  exceptionCount: 0,
                  overdueCount: 1,
                  onUpdate: (item, status) => selectedStatus = status,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Distribution Register'), findsOneWidget);
      expect(find.text('0/1 complete'), findsOneWidget);
      expect(find.text('1 overdue'), findsOneWidget);
      expect(find.text('Board / owners'), findsOneWidget);
      expect(find.text('Ack required'), findsOneWidget);
      expect(find.text('Due Feb 3, 2026'), findsOneWidget);
      expect(find.byType(FinancialReportPanelBadge), findsNWidgets(4));
      expect(
        find.byType(
          FinancialReportResponsiveWrapGrid<
            FinancialReportReleaseDistributionItem
          >,
        ),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(1),
      );
      expect(find.byType(FinancialReportActionCardTitleRow), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Ack'));
      await tester.pump();

      expect(
        selectedStatus,
        FinancialReportReleaseDistributionStatus.acknowledged,
      );
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportReleaseDistributionPanel(
              items: [],
              completedCount: 0,
              acknowledgedCount: 0,
              exceptionCount: 0,
              overdueCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('Distribution Register'), findsOneWidget);
      expect(
        find.text('No distribution recipients are configured.'),
        findsOneWidget,
      );
    });

    testWidgets('shows release gate reason and disables update actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportReleaseDistributionPanel(
              items: [_item()],
              completedCount: 0,
              acknowledgedCount: 0,
              exceptionCount: 0,
              overdueCount: 0,
              actionLockedReason:
                  'Complete all required release sign-offs before distribution.',
              onUpdate: (_, _) {},
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Complete all required release sign-offs before distribution.',
        ),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportReleaseDistributionLockNotice),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(2),
      );
      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Sent'))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Ack'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('renders shared resolution line for completed recipients', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportReleaseDistributionPanel(
              items: [_resolvedItem()],
              completedCount: 1,
              acknowledgedCount: 1,
              exceptionCount: 0,
              overdueCount: 0,
              onClear: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(FinancialReportActionCardTitleRow), findsOneWidget);
      expect(
        find.byType(FinancialReportActionCardResolutionLine),
        findsOneWidget,
      );
      expect(
        find.text(
          'Acknowledged by Controller / Jan 31, 2026 11:15 / ACK-42 | Board confirmed receipt.',
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Clear distribution status'), findsOneWidget);
    });
  });
}

FinancialReportReleaseDistributionItem _item() {
  return FinancialReportReleaseDistributionItem(
    recipient: FinancialReportReleaseDistributionRecipient(
      id: 'board-owners',
      name: 'Board / owners',
      role: 'Governance recipients',
      organization: 'Kaysir Advisory',
      channel: FinancialReportReleaseDistributionChannel.email,
      requiresAcknowledgement: true,
      dueDate: DateTime(2026, 2, 3),
      purpose: 'Governance review and formal distribution record.',
    ),
  );
}

FinancialReportReleaseDistributionItem _resolvedItem() {
  return FinancialReportReleaseDistributionItem(
    recipient: _item().recipient,
    resolution: FinancialReportReleaseDistributionResolution(
      recipientId: _item().recipient.id,
      status: FinancialReportReleaseDistributionStatus.acknowledged,
      owner: 'Controller',
      updatedAt: DateTime(2026, 1, 31, 11, 15),
      note: 'Board confirmed receipt.',
      evidenceReference: 'ACK-42',
    ),
  );
}
