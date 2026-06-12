import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_navigation_actions.dart';

void main() {
  testWidgets('project form navigation actions trigger shortcuts', (
    tester,
  ) async {
    var dashboardTapCount = 0;
    var detailTapCount = 0;
    var tableTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              ProjectFormNavigationActions(
                onOpenProjects: () => dashboardTapCount++,
                onOpenProjectTable: () => tableTapCount++,
                onOpenProjectDetail: () => detailTapCount++,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Open project detail'), findsOneWidget);
    expect(find.byTooltip('Open project table'), findsOneWidget);
    expect(find.byTooltip('Open project dashboard'), findsOneWidget);

    await tester.tap(find.byTooltip('Open project detail'));
    await tester.tap(find.byTooltip('Open project table'));
    await tester.tap(find.byTooltip('Open project dashboard'));

    expect(detailTapCount, 1);
    expect(tableTapCount, 1);
    expect(dashboardTapCount, 1);
  });

  testWidgets('project form navigation actions hide optional detail shortcut', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              ProjectFormNavigationActions(
                onOpenProjects: () {},
                onOpenProjectTable: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Open project detail'), findsNothing);
    expect(find.byTooltip('Open project table'), findsOneWidget);
    expect(find.byTooltip('Open project dashboard'), findsOneWidget);
  });
}
