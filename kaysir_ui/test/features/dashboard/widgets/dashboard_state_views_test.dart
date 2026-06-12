import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_state_views.dart';
import 'package:kaysir/features/dashboard/widgets/dashboard_state_views.dart';

void main() {
  testWidgets('dashboard loading delegates to admin loading state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingDashboard())),
    );

    expect(find.byType(AdminLoadingState), findsOneWidget);
    expect(find.text('Loading dashboard'), findsOneWidget);
  });

  testWidgets('dashboard error delegates to admin error state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ErrorDashboard(error: 'Service unavailable')),
      ),
    );

    expect(find.byType(AdminErrorState), findsOneWidget);
    expect(find.text('Unable to load dashboard'), findsOneWidget);
    expect(find.text('Service unavailable'), findsOneWidget);
  });

  testWidgets('dashboard updating delegates to admin update indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [SizedBox.expand(), DashboardUpdatingIndicator()],
          ),
        ),
      ),
    );

    expect(find.byType(AdminPageUpdatingIndicator), findsOneWidget);
  });
}
