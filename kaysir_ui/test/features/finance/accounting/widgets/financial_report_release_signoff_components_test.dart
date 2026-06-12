import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_action_card_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report release sign-off components', () {
    testWidgets('renders header metrics and sign-off actions', (tester) async {
      FinancialReportReleaseSignOffStatus? selectedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 900,
                child: Column(
                  children: [
                    const FinancialReportReleaseSignOffHeader(
                      periodLabel: 'Jan 2026',
                      frameworkName: 'SAK Indonesia',
                      totalCount: 1,
                      signedCount: 0,
                      pendingCount: 1,
                      returnedCount: 0,
                      completionRatio: 0,
                      integrityStatus:
                          FinancialReportPackageIntegrityStatus.notClosed,
                    ),
                    FinancialReportReleaseSignOffList(
                      items: [_item()],
                      onResolve: (item, status) => selectedStatus = status,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Report Release Center'), findsOneWidget);
      expect(find.text('1 pending'), findsOneWidget);
      expect(find.text('Prepared by accounting'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
      expect(
        find.byType(FinancialReportResponsiveWrapGrid<Widget>),
        findsOneWidget,
      );
      expect(
        find.byType(
          FinancialReportResponsiveWrapGrid<FinancialReportReleaseSignOffItem>,
        ),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportPanelSurface), findsNWidgets(2));
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(4),
      );
      expect(find.byType(FinancialReportActionCardTitleRow), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sign off'));
      await tester.pump();

      expect(selectedStatus, FinancialReportReleaseSignOffStatus.signed);
    });

    testWidgets('renders shared resolution line for completed sign-offs', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportReleaseSignOffList(
              items: [_resolvedItem()],
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
        find.text('Signed by Controller | Release pack approved.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Clear sign-off'), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FinancialReportReleaseSignOffList(items: [])),
        ),
      );

      expect(find.text('Release Sign-offs'), findsOneWidget);
      expect(
        find.text('No release sign-offs are configured for this report pack.'),
        findsOneWidget,
      );
    });
  });
}

FinancialReportReleaseSignOffItem _item() {
  return const FinancialReportReleaseSignOffItem(
    requirement: FinancialReportReleaseSignOffRequirement(
      id: 'prepared-by-accounting',
      role: FinancialReportReleaseSignOffRole.preparer,
      title: 'Prepared by accounting',
      description: 'Confirm statements and schedules are prepared.',
      owner: 'Reporting accountant',
      reference: 'PSAK 201',
    ),
  );
}

FinancialReportReleaseSignOffItem _resolvedItem() {
  return FinancialReportReleaseSignOffItem(
    requirement: _item().requirement,
    resolution: FinancialReportReleaseSignOffResolution(
      requirementId: _item().requirement.id,
      status: FinancialReportReleaseSignOffStatus.signed,
      signer: 'Controller',
      signedAt: DateTime(2026, 1, 31, 11),
      note: 'Release pack approved.',
    ),
  );
}
