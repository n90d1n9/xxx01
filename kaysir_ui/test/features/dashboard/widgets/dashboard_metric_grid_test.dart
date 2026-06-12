import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_metric_grid.dart';
import 'package:kaysir/features/dashboard/models/dashboard_data.dart';
import 'package:kaysir/features/dashboard/widgets/dashboard_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';

void main() {
  testWidgets('maps dashboard data into reusable admin metric grid items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: DashboardMetricGrid(data: _dashboardData()),
          ),
        ),
      ),
    );

    expect(find.byType(AdminMetricGrid), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(4));
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Items sold'), findsOneWidget);
    expect(find.text('Open orders'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('127K'), findsOneWidget);
    expect(find.text('5K'), findsOneWidget);
    expect(find.text('19.6%'), findsOneWidget);
  });
}

DashboardData _dashboardData() {
  return DashboardData(
    photos: 127012,
    photosChange: '+ 2% than last week',
    video: 5000,
    videoChange: '+ 3.2% than last week',
    event: 15138,
    eventChange: '+ 12% than last week',
    growth: 19.6,
    growthChange: '- 4.9% than last week',
    salesData: const [],
    acquisitionData: AcquisitionData(reviews: 31, education: 18, deals: 51),
    topProducts: const [],
    customerData: const [],
  );
}
