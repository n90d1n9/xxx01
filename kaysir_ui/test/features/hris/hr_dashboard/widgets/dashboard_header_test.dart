import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_header.dart';

void main() {
  testWidgets(
    'dashboard header renders controlled freshness and refresh action',
    (tester) async {
      var refreshCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              child: DashboardHeader(
                selectedPeriod: 'This Month',
                lastUpdated: DateTime(2026, 5, 31, 9, 15),
                onPeriodChanged: (_) {},
                onRefresh: () => refreshCount++,
              ),
            ),
          ),
        ),
      );

      expect(find.text('HR Analytics Overview'), findsOneWidget);
      expect(find.text('Last updated May 31, 2026, 09:15'), findsOneWidget);
      expect(find.byTooltip('Refresh dashboard'), findsOneWidget);

      await tester.tap(find.byTooltip('Refresh dashboard'));
      await tester.pump();

      expect(refreshCount, 1);
    },
  );
}
