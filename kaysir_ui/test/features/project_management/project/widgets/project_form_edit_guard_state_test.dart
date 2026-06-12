import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_edit_guard_state.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('project form edit guard state renders actions', (tester) async {
    var projectTapCount = 0;
    var tableTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectFormEditGuardState(
            projectId: 'retail-modernization',
            onOpenProjects: () => projectTapCount++,
            onOpenProjectTable: () => tableTapCount++,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Project cannot be edited'), findsOneWidget);
    expect(find.textContaining('retail-modernization'), findsOneWidget);
    expect(find.text('Open Project Table'), findsOneWidget);
    expect(find.text('Back to Projects'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.table_chart_outlined), findsOneWidget);

    await tester.tap(find.text('Open Project Table'));
    await tester.tap(find.text('Back to Projects'));

    expect(tableTapCount, 1);
    expect(projectTapCount, 1);
  });
}
