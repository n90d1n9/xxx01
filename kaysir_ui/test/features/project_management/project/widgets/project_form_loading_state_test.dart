import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_loading_state.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('project form loading state renders loading context', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectFormLoadingState(projectId: 'campus-renovation'),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Loading project form'), findsOneWidget);
    expect(find.textContaining('campus-renovation'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
