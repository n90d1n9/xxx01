import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_saved_view.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_saved_view_chip.dart';

void main() {
  test('workspace saved view count label pluralizes workspaces', () {
    expect(dashboardWorkspaceSavedViewCountLabel(0), '0 workspaces');
    expect(dashboardWorkspaceSavedViewCountLabel(1), '1 workspace');
    expect(dashboardWorkspaceSavedViewCountLabel(2), '2 workspaces');
  });

  testWidgets('workspace saved view chip renders selected state', (
    tester,
  ) async {
    final view = dashboardWorkspaceSavedViews.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardWorkspaceSavedViewChip(
            view: view,
            count: 1,
            isSelected: true,
            onSelected: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(view.icon), findsOneWidget);
    expect(find.text(view.label), findsOneWidget);
    expect(find.text('1 workspace'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('workspace saved view chip delegates taps', (tester) async {
    var tapCount = 0;
    final view = dashboardWorkspaceSavedViews.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardWorkspaceSavedViewChip(
            view: view,
            count: 2,
            isSelected: false,
            onSelected: () => tapCount++,
          ),
        ),
      ),
    );

    expect(find.text('2 workspaces'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await tester.tap(find.text(view.label));
    await tester.pump();

    expect(tapCount, 1);
  });
}
