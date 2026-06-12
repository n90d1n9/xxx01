import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_status_badge.dart';
import 'package:kaysir/features/dashboard/states/dashboard_provider.dart';
import 'package:kaysir/features/dashboard/widgets/dashboard_header.dart';

void main() {
  testWidgets('renders dashboard header with reusable live status badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHeader(
            selectedFilter: DashboardFilters.thisWeek,
            onFilterChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Retail intelligence'), findsOneWidget);
    expect(find.text('Sales dashboard'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.byType(AdminStatusBadge), findsOneWidget);
    expect(find.text('Live retail signal'), findsOneWidget);
    expect(find.byIcon(Icons.sensors_outlined), findsOneWidget);
  });
}
