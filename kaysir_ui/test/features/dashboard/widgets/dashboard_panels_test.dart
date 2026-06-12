import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_content_panel.dart';
import 'package:kaysir/features/dashboard/models/dashboard_data.dart';
import 'package:kaysir/features/dashboard/states/dashboard_provider.dart';
import 'package:kaysir/features/dashboard/widgets/dashboard_panels.dart';

void main() {
  testWidgets('renders dashboard panels with reusable admin panels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: DashboardPanels(
              data: _dashboardData(),
              selectedFilter: DashboardFilters.thisWeek,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AdminContentPanel), findsNWidgets(2));
    expect(find.text('Revenue trend'), findsOneWidget);
    expect(find.text('Current and previous sales movement.'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Last week'), findsOneWidget);
    expect(find.text('Customer mix'), findsOneWidget);
    expect(
      find.text('Source contribution by engagement channel.'),
      findsOneWidget,
    );
  });
}

DashboardData _dashboardData() {
  final today = DateTime(2026, 5, 30);

  return DashboardData(
    photos: 127012,
    photosChange: '+ 2% than last week',
    video: 5661,
    videoChange: '+ 3.2% than last week',
    event: 15138,
    eventChange: '+ 12% than last week',
    growth: 19.6,
    growthChange: '- 4.9% than last week',
    salesData: [
      SalesDataPoint(
        date: today.subtract(const Duration(days: 1)),
        currentWeekSales: 15000,
        previousWeekSales: 12000,
      ),
      SalesDataPoint(
        date: today,
        currentWeekSales: 20000,
        previousWeekSales: 18000,
      ),
    ],
    acquisitionData: AcquisitionData(reviews: 31, education: 18, deals: 51),
    topProducts: const [],
    customerData: const [],
  );
}
