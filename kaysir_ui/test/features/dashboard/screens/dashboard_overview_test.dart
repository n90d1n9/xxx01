import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/dashboard/screens/dashboard_large.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';

void main() {
  testWidgets('renders the modern dashboard overview sections', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: DashboardOverview())),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Retail intelligence'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Sales dashboard'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Live retail signal'), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(4));
    expect(find.text('Revenue trend'), findsOneWidget);
    expect(find.text('Customer mix'), findsOneWidget);
    expect(find.text('Top products'), findsOneWidget);
  });
}
