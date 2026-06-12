import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_layout.dart';

void main() {
  testWidgets('project responsive form grid adapts column widths', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: ProjectResponsiveFormGrid(
              children: [
                SizedBox(key: ValueKey('first-cell'), height: 20),
                SizedBox(key: ValueKey('second-cell'), height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('first-cell'))).width, 374);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('second-cell'))).dx,
      greaterThan(0),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: ProjectResponsiveFormGrid(
              children: [
                SizedBox(key: ValueKey('first-cell'), height: 20),
                SizedBox(key: ValueKey('second-cell'), height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('first-cell'))).width, 360);
    expect(tester.getTopLeft(find.byKey(const ValueKey('second-cell'))).dx, 0);
  });

  testWidgets('project form text field emits edits', (tester) async {
    final controller = TextEditingController(text: 'Campus Renovation');
    addTearDown(controller.dispose);
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectFormTextField(
            label: 'Project name',
            controller: controller,
            icon: Icons.work_outline,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.text('Campus Renovation'), findsOneWidget);
    expect(find.byIcon(Icons.work_outline), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Campus Phase 2');

    expect(changes.last, 'Campus Phase 2');
  });
}
