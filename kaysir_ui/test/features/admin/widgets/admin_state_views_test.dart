import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_state_views.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('renders reusable loading state content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminLoadingState(
            title: 'Loading dashboard',
            message: 'Preparing signals.',
            icon: Icons.dashboard_customize_outlined,
          ),
        ),
      ),
    );

    expect(find.byType(AppSurface), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_customize_outlined), findsOneWidget);
    expect(find.text('Loading dashboard'), findsOneWidget);
    expect(find.text('Preparing signals.'), findsOneWidget);
  });

  testWidgets('renders reusable error state content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminErrorState(
            title: 'Unable to load dashboard',
            message: 'Network unavailable',
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Unable to load dashboard'), findsOneWidget);
    expect(find.text('Network unavailable'), findsOneWidget);
  });

  testWidgets('renders reusable page updating indicator in a stack', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [SizedBox.expand(), AdminPageUpdatingIndicator()],
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
