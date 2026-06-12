import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_action_card_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_disclosure_review_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report disclosure review components', () {
    testWidgets('renders header metrics and review actions', (tester) async {
      FinancialReportDisclosureResolutionStatus? selectedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 900,
                child: Column(
                  children: [
                    const FinancialReportDisclosureReviewHeader(
                      periodLabel: 'Jan 2026',
                      frameworkName: 'SAK Indonesia',
                      totalCount: 1,
                      unresolvedCount: 1,
                      approvedCount: 0,
                      reviewRatio: 0,
                      locked: false,
                    ),
                    FinancialReportDisclosureReviewList(
                      items: [_item()],
                      locked: false,
                      onResolve: (item, status) => selectedStatus = status,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Financial Notes Center'), findsOneWidget);
      expect(find.text('1 review'), findsOneWidget);
      expect(find.text('Basis of Preparation'), findsOneWidget);
      expect(find.text('Needs review'), findsWidgets);
      expect(
        find.byType(FinancialReportResponsiveWrapGrid<Widget>),
        findsOneWidget,
      );
      expect(
        find.byType(
          FinancialReportResponsiveWrapGrid<
            FinancialReportDisclosureReviewItem
          >,
        ),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportPanelSurface), findsNWidgets(2));
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(4),
      );
      expect(find.byType(FinancialReportActionCardTitleRow), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Approve'));
      await tester.pump();

      expect(
        selectedStatus,
        FinancialReportDisclosureResolutionStatus.approved,
      );
    });

    testWidgets('disables review actions when the period is locked', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportDisclosureReviewList(
              items: [_item()],
              locked: true,
              onResolve: (_, _) {},
            ),
          ),
        ),
      );

      final approveButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Approve'),
      );
      expect(approveButton.onPressed, isNull);
    });

    testWidgets('renders shared resolution line for completed reviews', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportDisclosureReviewList(
              items: [_resolvedItem()],
              locked: false,
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
        find.text('Approved by Controller | Disclosure note reviewed.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Clear review'), findsOneWidget);
    });

    testWidgets('renders empty state with shared report panel chrome', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportDisclosureReviewList(items: [], locked: false),
          ),
        ),
      );

      expect(find.text('Disclosure Review'), findsOneWidget);
      expect(
        find.text(
          'No disclosure requirements are attached to the current report pack.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportPanelEmptyState), findsOneWidget);
    });
  });
}

FinancialReportDisclosureReviewItem _item() {
  return const FinancialReportDisclosureReviewItem(
    requirement: FinancialReportDisclosureRequirement(
      id: 'note-1-basis-of-preparation',
      noteNumber: '1',
      title: 'Basis of Preparation',
      description:
          'Prepared using accrual basis and SAK presentation concepts.',
      standardReferences: ['PSAK 201'],
      owner: 'Controller',
      priority: FinancialReportDisclosureRequirementPriority.required,
    ),
  );
}

FinancialReportDisclosureReviewItem _resolvedItem() {
  return FinancialReportDisclosureReviewItem(
    requirement: _item().requirement,
    resolution: FinancialReportDisclosureResolution(
      requirementId: _item().requirement.id,
      status: FinancialReportDisclosureResolutionStatus.approved,
      reviewer: 'Controller',
      reviewedAt: DateTime(2026, 1, 31, 10),
      note: 'Disclosure note reviewed.',
    ),
  );
}
