import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  group('financial report responsive grid components', () {
    testWidgets('sizes items from configured breakpoints', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              child: FinancialReportResponsiveWrapGrid<int>(
                items: const [1, 2, 3],
                spacing: 10,
                breakpoints: const [
                  FinancialReportResponsiveGridBreakpoint(
                    minWidth: 620,
                    columns: 2,
                  ),
                  FinancialReportResponsiveGridBreakpoint(
                    minWidth: 860,
                    columns: 3,
                  ),
                ],
                itemBuilder:
                    (context, item) => SizedBox(
                      key: ValueKey('grid-item-$item'),
                      height: 24,
                      child: Text('Item $item'),
                    ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('grid-item-1'))).width,
        moreOrLessEquals(293.33, epsilon: 0.01),
      );
    });

    testWidgets('uses one full-width column below the first breakpoint', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: FinancialReportResponsiveWrapGrid<int>(
                items: const [1],
                breakpoints: const [
                  FinancialReportResponsiveGridBreakpoint(
                    minWidth: 620,
                    columns: 2,
                  ),
                ],
                itemBuilder:
                    (context, item) => const SizedBox(
                      key: ValueKey('compact-grid-item'),
                      height: 24,
                      child: Text('Compact item'),
                    ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(const ValueKey('compact-grid-item'))).width,
        500,
      );
    });
  });
}
