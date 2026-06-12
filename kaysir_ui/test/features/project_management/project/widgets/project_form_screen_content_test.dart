import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_readiness_pill.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_screen_content.dart';

void main() {
  testWidgets('project form screen content renders create shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const _FormScreenContentHarness(isEditing: false));

    expect(find.text('Project Management'), findsOneWidget);
    expect(find.text('Create Project'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.byType(ProjectFormPanel), findsOneWidget);
    expect(find.byType(ProjectFormReadinessPill), findsOneWidget);
    expect(_scrollPadding(tester), const EdgeInsets.all(24));
  });

  testWidgets('project form screen content compacts narrow edit layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const _FormScreenContentHarness(isEditing: true));

    expect(find.text('Edit Project'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(_scrollPadding(tester), const EdgeInsets.all(16));
  });
}

EdgeInsets _scrollPadding(WidgetTester tester) {
  final scrollView = tester.widget<SingleChildScrollView>(
    find.byType(SingleChildScrollView).first,
  );

  return scrollView.padding! as EdgeInsets;
}

class _FormScreenContentHarness extends StatelessWidget {
  const _FormScreenContentHarness({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ProjectFormScreenContent(
          initialDraft: ProjectFormDraft.initial(today: DateTime(2026, 6)),
          isEditing: isEditing,
          onSubmitted: (_) {},
        ),
      ),
    );
  }
}
